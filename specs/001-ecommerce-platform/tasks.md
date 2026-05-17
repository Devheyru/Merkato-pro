# Tasks: Merkato-pro E-Commerce Platform

**Input**: Design documents from `specs/001-ecommerce-platform/`

**Prerequisites**: plan.md (required), spec.md (required), research.md, data-model.md, contracts/

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

## Phase 1: Setup

**Purpose**: Project initialization and monorepo structure

- [X] T001 Initialize Next.js 14 project with App Router in `web/` directory
- [X] T002 Initialize Flutter 3.x project in `mobile/` directory
- [X] T003 Initialize Supabase project with `supabase init` in `supabase/` directory
- [X] T004 [P] Configure ESLint + Prettier in `web/.eslintrc.json` and `web/.prettierrc`
- [X] T005 [P] Configure flutter_lints in `mobile/analysis_options.yaml`
- [X] T006 [P] Install web dependencies: @supabase/supabase-js, next-intl, tailwindcss, shadcn/ui in `web/package.json`
- [X] T007 [P] Install mobile dependencies: supabase_flutter, flutter_riverpod, go_router, flutter_localizations in `mobile/pubspec.yaml`
- [X] T008 [P] Configure Tailwind CSS in `web/tailwind.config.ts` with custom theme tokens
- [X] T009 [P] Create shared Edge Function utilities in `supabase/functions/_shared/cors.ts`, `response.ts`, `auth.ts`, `logger.ts`
- [X] T010 Create root layout with font loading and metadata in `web/app/layout.tsx`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Database schema, auth infrastructure, and shared services that ALL user stories depend on

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [X] T011 Create users table migration with RLS policies in `supabase/migrations/00001_create_users.sql`
- [X] T012 [P] Create vendors table migration with RLS policies in `supabase/migrations/00002_create_vendors.sql`
- [X] T013 [P] Create categories table migration with RLS policies in `supabase/migrations/00003_create_categories.sql`
- [X] T014 [P] Create products table migration with RLS, full-text search GIN index in `supabase/migrations/00004_create_products.sql`
- [X] T015 [P] Create carts and cart_items tables migration with RLS in `supabase/migrations/00005_create_carts.sql`
- [X] T016 [P] Create orders and order_items tables migration with RLS in `supabase/migrations/00006_create_orders.sql`
- [X] T017 [P] Create payments table migration with RLS in `supabase/migrations/00007_create_payments.sql`
- [X] T018 [P] Create reviews table migration with RLS in `supabase/migrations/00008_create_reviews.sql`
- [X] T019 [P] Create notifications table migration with RLS in `supabase/migrations/00009_create_notifications.sql`
- [X] T020 [P] Create platform_settings table migration in `supabase/migrations/00010_create_platform_settings.sql`
- [X] T021 [P] Create audit_logs table migration (append-only, no update/delete RLS) in `supabase/migrations/00011_create_audit_logs.sql`
- [X] T022 [P] Create homepage_banners and wishlists tables migration in `supabase/migrations/00012_create_banners_wishlists.sql`
- [X] T023 Create comprehensive indexes migration in `supabase/migrations/00014_create_indexes.sql`
- [X] T024 Create seed data (categories, admin user, sample settings) in `supabase/migrations/00015_seed_data.sql`
- [X] T025 Push migrations to Supabase with `supabase db push`
- [X] T026 [P] Create Supabase client (browser) in `web/lib/supabase/client.ts`
- [X] T027 [P] Create Supabase client (server) in `web/lib/supabase/server.ts`
- [X] T028 [P] Create TypeScript types for all entities in `web/lib/types/database.ts`
- [X] T029 [P] Create Dart data models for User, Product, Category, Cart, Order in `mobile/lib/shared/models/`
- [X] T030 [P] Create Supabase service singleton in `mobile/lib/shared/services/supabase_service.dart`
- [X] T031 Create RBAC middleware for admin/vendor route protection in `web/app/middleware.ts`
- [X] T032 [P] Create i18n configuration with next-intl and English messages in `web/messages/en.json`
- [X] T033 [P] Create Flutter localization setup with English ARB in `mobile/lib/core/l10n/`
- [X] T034 [P] Create app theme (Material 3 + Cupertino) in `mobile/lib/core/theme/app_theme.dart`
- [X] T035 Create GoRouter navigation setup in `mobile/lib/core/router/app_router.dart`

**Checkpoint**: Foundation ready — user story implementation can now begin

---

## Phase 3: User Story 2 — Customer Registration & Auth (Priority: P1) 🎯 MVP

**Goal**: Users can register, verify, log in (email/Google OAuth), reset password, and maintain sessions

**Independent Test**: Register account → verify email → log in → log out → reset password

### Implementation for User Story 2

- [X] T036 [US2] Create auth layout with centered card design in `web/app/(auth)/layout.tsx`
- [X] T037 [P] [US2] Create registration page with email/password form in `web/app/(auth)/register/page.tsx`
- [X] T038 [P] [US2] Create login page with email/password + Google OAuth in `web/app/(auth)/login/page.tsx`
- [X] T039 [P] [US2] Create forgot password page in `web/app/(auth)/forgot-password/page.tsx`
- [X] T040 [US2] Create auth callback handler for OAuth/email verification in `web/app/(auth)/callback/route.ts`
- [X] T041 [US2] Create register-vendor Edge Function in `supabase/functions/register-vendor/index.ts`
- [X] T042 [P] [US2] Create Flutter auth feature: login screen in `mobile/lib/features/auth/screens/login_screen.dart`
- [X] T043 [P] [US2] Create Flutter auth feature: register screen in `mobile/lib/features/auth/screens/register_screen.dart`
- [X] T044 [US2] Create Flutter auth providers (Riverpod) in `mobile/lib/features/auth/providers/auth_provider.dart`
- [X] T045 [US2] Implement auth state listener and route guards in `mobile/lib/core/router/app_router.dart`

**Checkpoint**: Users can register, log in, and authenticate across web and mobile

---

## Phase 4: User Story 5 — Vendor Product Management (Priority: P1)

**Goal**: Vendors create/edit/deactivate products with images, variants, and stock

**Independent Test**: Vendor creates product → uploads images → sets variants → edits → deactivates

### Implementation for User Story 5

- [ ] T046 [US5] Create products Edge Function (create/update) in `supabase/functions/products/index.ts`
- [ ] T047 [P] [US5] Create upload-image Edge Function (validate, WebP convert, compress) in `supabase/functions/upload-image/index.ts`
- [ ] T048 [US5] Create vendor product list page in `web/app/(admin)/vendor/products/page.tsx`
- [ ] T049 [US5] Create vendor product create/edit form in `web/app/(admin)/vendor/products/new/page.tsx`
- [ ] T050 [US5] Create image upload component with drag-and-drop in `web/components/shared/image-upload.tsx`
- [ ] T051 [US5] Create product variant editor component in `web/components/shared/variant-editor.tsx`
- [ ] T052 [P] [US5] Create Flutter vendor product list screen in `mobile/lib/features/vendor/screens/vendor_products_screen.dart`
- [ ] T053 [P] [US5] Create Flutter product create/edit screen in `mobile/lib/features/vendor/screens/product_form_screen.dart`
- [ ] T054 [US5] Create vendor product providers (Riverpod) in `mobile/lib/features/vendor/providers/vendor_product_provider.dart`

**Checkpoint**: Vendors can manage their product catalog end-to-end

---

## Phase 5: User Story 1 — Customer Browse & Search (Priority: P1)

**Goal**: Customers discover products via homepage, categories, search with filters and sorting

**Independent Test**: View homepage → browse categories → search with filters → sort results → view product detail

### Implementation for User Story 1

- [ ] T055 [US1] Create shop layout with navbar, search bar, cart icon in `web/app/(shop)/layout.tsx`
- [ ] T056 [US1] Create homepage with banners, trending products, featured categories in `web/app/(shop)/page.tsx`
- [ ] T057 [P] [US1] Create product listing page with search, filters, sorting, pagination in `web/app/(shop)/products/page.tsx`
- [ ] T058 [P] [US1] Create product detail page with image gallery, variants, add-to-cart in `web/app/(shop)/products/[id]/page.tsx`
- [ ] T059 [P] [US1] Create category browse page in `web/app/(shop)/categories/[slug]/page.tsx`
- [ ] T060 [P] [US1] Create search autocomplete component in `web/components/shop/search-autocomplete.tsx`
- [ ] T061 [P] [US1] Create product card component in `web/components/shop/product-card.tsx`
- [ ] T062 [P] [US1] Create filter sidebar component in `web/components/shop/filter-sidebar.tsx`
- [ ] T063 [US1] Create Flutter home screen with banners and trending in `mobile/lib/features/home/screens/home_screen.dart`
- [ ] T064 [P] [US1] Create Flutter search screen with autocomplete in `mobile/lib/features/search/screens/search_screen.dart`
- [ ] T065 [P] [US1] Create Flutter product detail screen in `mobile/lib/features/product/screens/product_detail_screen.dart`
- [ ] T066 [US1] Create Flutter product/search providers in `mobile/lib/features/search/providers/search_provider.dart`

**Checkpoint**: Customers can discover and view products across web and mobile

---

## Phase 6: User Story 3 — Shopping Cart & Wishlist (Priority: P1)

**Goal**: Customers add/remove/update cart items, see vendor grouping, manage wishlists

**Independent Test**: Add products to cart → view vendor-grouped cart → adjust quantities → save to wishlist

### Implementation for User Story 3

- [ ] T067 [US3] Create cart-validate Edge Function in `supabase/functions/cart-validate/index.ts`
- [ ] T068 [US3] Create cart page with vendor grouping and subtotals in `web/app/(shop)/cart/page.tsx`
- [ ] T069 [P] [US3] Create wishlist page in `web/app/(shop)/account/wishlist/page.tsx`
- [ ] T070 [P] [US3] Create cart item component with quantity controls in `web/components/shop/cart-item.tsx`
- [ ] T071 [US3] Create cart context/hooks for real-time cart state in `web/lib/hooks/use-cart.ts`
- [ ] T072 [US3] Create Flutter cart screen in `mobile/lib/features/cart/screens/cart_screen.dart`
- [ ] T073 [P] [US3] Create Flutter wishlist screen in `mobile/lib/features/cart/screens/wishlist_screen.dart`
- [ ] T074 [US3] Create Flutter cart provider (Riverpod) in `mobile/lib/features/cart/providers/cart_provider.dart`

**Checkpoint**: Cart and wishlist fully functional on both platforms

---

## Phase 7: User Story 4 — Order Checkout & Payment (Priority: P1)

**Goal**: Complete checkout with delivery address, Telebirr/M-Pesa payment, multi-vendor order splitting

**Independent Test**: Proceed to checkout → enter address → pay via Telebirr → verify order created with sub-orders

### Implementation for User Story 4

- [ ] T075 [US4] Create checkout Edge Function (order creation, stock decrement, payment initiation) in `supabase/functions/checkout/index.ts`
- [ ] T076 [P] [US4] Create Telebirr webhook Edge Function in `supabase/functions/webhooks-telebirr/index.ts`
- [ ] T077 [P] [US4] Create M-Pesa webhook Edge Function in `supabase/functions/webhooks-mpesa/index.ts`
- [ ] T078 [US4] Create checkout page with address form and payment selection in `web/app/(shop)/checkout/page.tsx`
- [ ] T079 [P] [US4] Create order confirmation page in `web/app/(shop)/orders/confirmation/page.tsx`
- [ ] T080 [P] [US4] Create order history page in `web/app/(shop)/orders/page.tsx`
- [ ] T081 [US4] Create Flutter checkout screen in `mobile/lib/features/checkout/screens/checkout_screen.dart`
- [ ] T082 [P] [US4] Create Flutter order history screen in `mobile/lib/features/orders/screens/order_history_screen.dart`
- [ ] T083 [US4] Create Flutter checkout/payment providers in `mobile/lib/features/checkout/providers/checkout_provider.dart`
- [ ] T084 [US4] Create send-notification Edge Function for order emails/push in `supabase/functions/send-notification/index.ts`

**Checkpoint**: End-to-end purchase flow working with payment integration

---

## Phase 8: User Story 6 — Order Fulfillment & Delivery Tracking (Priority: P1)

**Goal**: Vendors accept/reject orders, delivery agents assigned, customers track in real-time

**Independent Test**: Vendor accepts order → marks shipped → agent assigned → customer sees timeline updates

### Implementation for User Story 6

- [ ] T085 [US6] Create orders-status Edge Function in `supabase/functions/orders-status/index.ts`
- [ ] T086 [P] [US6] Create orders-assign-agent Edge Function in `supabase/functions/orders-assign-agent/index.ts`
- [ ] T087 [US6] Create order detail page with tracking timeline in `web/app/(shop)/orders/[id]/page.tsx`
- [ ] T088 [P] [US6] Create vendor order management page in `web/app/(admin)/vendor/orders/page.tsx`
- [ ] T089 [US6] Configure Supabase Realtime subscription for order status changes in `web/lib/hooks/use-order-tracking.ts`
- [ ] T090 [US6] Create Flutter order tracking screen with timeline in `mobile/lib/features/orders/screens/order_tracking_screen.dart`
- [ ] T091 [P] [US6] Create Flutter delivery agent screen (status updates) in `mobile/lib/features/orders/screens/delivery_agent_screen.dart`
- [ ] T092 [US6] Create Flutter order tracking provider with Realtime in `mobile/lib/features/orders/providers/order_tracking_provider.dart`

**Checkpoint**: Full order lifecycle with real-time tracking operational

---

## Phase 9: User Story 9 — Reviews & Ratings (Priority: P1)

**Goal**: Customers submit reviews, see aggregates, vendors reply, admins moderate

**Independent Test**: Submit review on delivered product → see aggregate update → vendor replies → admin hides

### Implementation for User Story 9

- [ ] T093 [US9] Create review submission component in `web/components/shop/review-form.tsx`
- [ ] T094 [P] [US9] Create review list component with vendor replies in `web/components/shop/review-list.tsx`
- [ ] T095 [US9] Add reviews section to product detail page in `web/app/(shop)/products/[id]/page.tsx`
- [ ] T096 [US9] Create database trigger to update product avg_rating/review_count on review insert/update in `supabase/migrations/00013_create_review_trigger.sql`
- [ ] T097 [US9] Create Flutter review submission widget in `mobile/lib/features/product/widgets/review_form_widget.dart`
- [ ] T098 [P] [US9] Create Flutter review list widget in `mobile/lib/features/product/widgets/review_list_widget.dart`
- [ ] T099 [US9] Create review provider (Riverpod) in `mobile/lib/features/product/providers/review_provider.dart`

**Checkpoint**: Review system fully operational with aggregation

---

## Phase 10: User Story 8 — Admin Platform Management (Priority: P1)

**Goal**: Admin panel with user management, vendor approval, product moderation, settings, audit log

**Independent Test**: Admin logs in → reviews vendor application → approves → moderates product → changes commission

### Implementation for User Story 8

- [ ] T100 [US8] Create admin layout with sidebar navigation in `web/app/(admin)/layout.tsx`
- [ ] T101 [US8] Create admin dashboard with platform-wide metrics in `web/app/(admin)/dashboard/page.tsx`
- [ ] T102 [US8] Create admin-dashboard Edge Function in `supabase/functions/admin-dashboard/index.ts`
- [ ] T103 [P] [US8] Create user management page in `web/app/(admin)/users/page.tsx`
- [ ] T104 [P] [US8] Create vendor management page with approve/reject in `web/app/(admin)/vendors/page.tsx`
- [ ] T105 [US8] Create vendors-moderate Edge Function in `supabase/functions/vendors-moderate/index.ts`
- [ ] T106 [P] [US8] Create product moderation page in `web/app/(admin)/products/page.tsx`
- [ ] T107 [US8] Create products moderate Edge Function in `supabase/functions/products/index.ts` (add moderate handler)
- [ ] T108 [P] [US8] Create platform settings page in `web/app/(admin)/settings/page.tsx`
- [ ] T109 [US8] Create admin-settings Edge Function in `supabase/functions/admin-settings/index.ts`
- [ ] T110 [P] [US8] Create audit log viewer page in `web/app/(admin)/audit-log/page.tsx`
- [ ] T111 [US8] Create order oversight page in `web/app/(admin)/orders/page.tsx`
- [ ] T112 [US8] Create orders-refund Edge Function in `supabase/functions/orders-refund/index.ts`

**Checkpoint**: Admin panel fully functional with all management capabilities

---

## Phase 11: User Story 7 — Vendor Dashboard & Analytics (Priority: P2)

**Goal**: Vendor dashboard with sales metrics, revenue charts, payout history, store profile

**Independent Test**: Vendor views dashboard metrics → filters charts → views payouts → edits store profile

### Implementation for User Story 7

- [ ] T113 [US7] Create vendors-analytics Edge Function in `supabase/functions/vendors-analytics/index.ts`
- [ ] T114 [US7] Create vendor dashboard page with metrics cards in `web/app/(admin)/vendor/dashboard/page.tsx`
- [ ] T115 [P] [US7] Create vendor analytics page with date-range charts in `web/app/(admin)/vendor/analytics/page.tsx`
- [ ] T116 [P] [US7] Create vendor store profile editor page in `web/app/(admin)/vendor/profile/page.tsx`
- [ ] T117 [P] [US7] Create vendor payout history page in `web/app/(admin)/vendor/payouts/page.tsx`
- [ ] T118 [US7] Create Flutter vendor dashboard screen in `mobile/lib/features/vendor/screens/vendor_dashboard_screen.dart`
- [ ] T119 [US7] Create vendor dashboard provider in `mobile/lib/features/vendor/providers/vendor_analytics_provider.dart`

**Checkpoint**: Vendor analytics and management fully operational

---

## Phase 12: User Story 10 — Multi-Language Support (Priority: P2)

**Goal**: Full English and Amharic support with language switcher, persistent preference

**Independent Test**: Switch to Amharic → verify all labels → refresh → confirm persistence

### Implementation for User Story 10

- [ ] T120 [US10] Create Amharic translation file in `web/messages/am.json`
- [ ] T121 [P] [US10] Create language switcher component in `web/components/shared/language-switcher.tsx`
- [ ] T122 [US10] Replace all hardcoded strings with i18n keys across web app
- [ ] T123 [P] [US10] Create Amharic ARB translation file in `mobile/lib/core/l10n/app_am.arb`
- [ ] T124 [US10] Create Flutter language switcher in settings in `mobile/lib/features/settings/screens/settings_screen.dart`
- [ ] T125 [US10] Replace all hardcoded strings with i18n keys across mobile app

**Checkpoint**: Platform fully bilingual (English + Amharic)

---

## Phase 13: Polish & Cross-Cutting Concerns

**Purpose**: Performance optimization, security hardening, and documentation

- [ ] T126 [P] Configure Lighthouse CI gating in `web/.github/workflows/lighthouse.yml`
- [ ] T127 [P] Add loading skeletons and error boundaries across all web pages
- [ ] T128 [P] Add pull-to-refresh and infinite scroll across mobile list screens
- [ ] T129 Implement rate limiting on auth Edge Functions (5 attempts per 15min)
- [ ] T130 [P] Add SEO metadata (title, description, Open Graph) to all public web pages
- [ ] T131 [P] Create 404 and error pages in `web/app/not-found.tsx` and `web/app/error.tsx`
- [ ] T132 Performance audit: verify LCP < 2.5s, API p95 < 300ms, DB < 100ms
- [ ] T133 Security audit: verify RLS on all tables, no secrets in client code
- [ ] T134 Run quickstart.md validation end-to-end
- [ ] T135 [P] Update README.md with project overview and setup instructions

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **US2 Auth (Phase 3)**: Depends on Foundational — recommended first (all stories need auth)
- **US5 Vendor Products (Phase 4)**: Depends on Foundational — products must exist before browse
- **US1 Browse & Search (Phase 5)**: Depends on Foundational — benefits from US5 (products to display)
- **US3 Cart & Wishlist (Phase 6)**: Depends on Foundational + US2 (auth for persistence)
- **US4 Checkout & Payment (Phase 7)**: Depends on US3 (cart) + US2 (auth)
- **US6 Order Tracking (Phase 8)**: Depends on US4 (orders must exist)
- **US9 Reviews (Phase 9)**: Depends on US4 (delivered orders)
- **US8 Admin Panel (Phase 10)**: Depends on Foundational — can parallel with US3+
- **US7 Vendor Dashboard (Phase 11)**: Depends on US5 + US4 (needs sales data)
- **US10 i18n (Phase 12)**: Depends on all UI being built (Phases 3–11)
- **Polish (Phase 13)**: Depends on all user stories complete

### Parallel Opportunities

- **Phase 2**: All migration files (T011–T022) can run in parallel
- **Phase 3**: Web auth pages (T037–T039) in parallel; Mobile auth screens (T042–T043) in parallel
- **Phase 5**: Web components (T057–T062) in parallel; Mobile screens (T064–T065) in parallel
- **Phase 10**: Admin pages (T103–T110) many can run in parallel
- **Cross-phase**: US8 (Admin) can start after Foundational, parallel with US3–US6

---

## Implementation Strategy

### MVP First (User Story 2 + 5 + 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL)
3. Complete Phase 3: US2 — Auth
4. Complete Phase 4: US5 — Vendor Product Management
5. Complete Phase 5: US1 — Browse & Search
6. **STOP and VALIDATE**: Customers can register, browse, and search products

### Incremental Delivery

1. Setup + Foundational → Foundation ready
2. US2 (Auth) → Users can register/login (MVP base)
3. US5 (Vendor Products) → Vendors can list products
4. US1 (Browse & Search) → Customers can discover products
5. US3 (Cart) → Customers can build carts
6. US4 (Checkout & Payment) → Full purchase flow (Revenue MVP! 🎯)
7. US6 (Order Tracking) → Real-time tracking
8. US9 (Reviews) → Trust & social proof
9. US8 (Admin) → Platform governance
10. US7 (Vendor Dashboard) → Vendor analytics (P2)
11. US10 (i18n) → Amharic support (P2)
12. Polish → Performance, security, SEO

---

## Notes

- [P] tasks = different files, no dependencies
- [Story] label maps task to specific user story for traceability
- Each user story is independently completable and testable
- Commit after each task or logical group
- Stop at any checkpoint to validate story independently
- Tests not included as they were not explicitly requested — add via `/speckit-tasks` with TDD flag if needed

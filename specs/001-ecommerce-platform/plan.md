# Implementation Plan: Merkato-pro E-Commerce Platform

**Branch**: `001-ecommerce-platform` | **Date**: 2026-05-17 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-ecommerce-platform/spec.md`

## Summary

Merkato-pro is a multi-vendor e-commerce marketplace targeting the East African market (Ethiopia and Kenya). The platform consists of three interconnected systems: a customer-facing web application (Next.js 14+), a cross-platform mobile application (Flutter 3.x), and an admin/vendor management panel (shared Next.js codebase). The backend is powered by Supabase (PostgreSQL, Auth, Storage, Realtime, Edge Functions). Payments are processed via Telebirr (ETB) and M-Pesa (KES) mobile money gateways exclusively through server-side Edge Functions. The platform supports English and Amharic languages.

## Technical Context

**Language/Version**: TypeScript 5.x (Next.js/Edge Functions), Dart 3.x (Flutter)

**Primary Dependencies**:
- Web: Next.js 14+ (App Router), Tailwind CSS, shadcn/ui, next-intl, @supabase/supabase-js
- Mobile: Flutter 3.x, supabase_flutter, flutter_riverpod, go_router, flutter_localizations
- Backend: Supabase Edge Functions (Deno runtime), supabase-js (server)

**Storage**: PostgreSQL via Supabase (14 tables), Supabase Storage (images/media)

**Testing**:
- Web: Vitest (unit), Playwright (E2E), ESLint + Prettier (lint)
- Mobile: flutter_test (unit/widget), integration_test, flutter_lints
- Backend: Deno.test (Edge Functions), contract tests

**Target Platform**:
- Web: Chrome 100+, Firefox 100+, Safari 15+, Edge 100+ | 320px–2560px responsive
- Mobile: Android API 21+ (5.0), iOS 13.0+
- Admin: Desktop/tablet browsers, 1280×720+

**Project Type**: Multi-platform marketplace (web-app + mobile-app + serverless-api)

**Performance Goals**:
- LCP < 2.5s on 3G (web)
- API p95 < 300ms (Edge Functions)
- 1,000 concurrent users without degradation
- DB queries < 100ms (product listings)
- Cold start < 3s (mobile)
- Images < 200KB WebP via CDN

**Constraints**:
- Supabase is the exclusive backend (no self-hosted alternatives in Phase 1)
- Payments limited to Telebirr + M-Pesa (no card payments in Phase 1)
- Edge Functions must use TypeScript on Deno (no external runtimes)
- Admin panel shares Next.js codebase via route groups + middleware RBAC

**Scale/Scope**:
- 1,000 concurrent users (initial)
- ~50 screens across web + mobile + admin
- 14 database tables
- 15 Edge Functions
- 2 payment gateways
- 2 languages (en, am)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Evidence |
|-----------|--------|----------|
| I. Code Quality & Architectural Integrity | ✅ PASS | ESLint+Prettier for web, flutter_lints for mobile, strict TS for Edge Functions. Three-tier architecture respected (Next.js/Flutter → Edge Functions → PostgreSQL). Migrations via Supabase CLI. |
| II. Testing Standards | ✅ PASS | 70% unit coverage target for Edge Functions. Contract tests for all API endpoints (15 functions). Integration tests for critical journeys. Payment test suites planned. |
| III. User Experience Consistency | ✅ PASS | Responsive 320px–2560px (web). Material Design 3 / Cupertino (mobile). ≤5 interactions for core journey. English + Amharic i18n. WCAG 2.1 AA target. Tailwind+shadcn/ui (web), Material/Cupertino (mobile). |
| IV. Performance Requirements | ✅ PASS | LCP <2.5s, API p95 <300ms, 1000 concurrent users, DB <100ms, mobile cold start <3s, images <200KB WebP. Lighthouse CI gating planned. |
| V. Security & Data Integrity | ✅ PASS | TLS 1.2+ enforced. RLS on all 14 tables. Secrets in Edge Function env vars only. No raw payment credentials stored. Rate limiting on auth. File upload validation. OWASP Top 10 protection. Append-only audit_logs. |

**Gate result**: ✅ ALL PASS — proceeding to implementation.

## Project Structure

### Documentation (this feature)

```text
specs/001-ecommerce-platform/
├── plan.md              # This file
├── research.md          # Phase 0 output — 8 research decisions
├── data-model.md        # Phase 1 output — 14 entities with full schemas
├── quickstart.md        # Phase 1 output — setup & deployment guide
├── contracts/
│   └── api-contracts.md # Phase 1 output — 15 Edge Function contracts
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (/speckit-tasks command)
```

### Source Code (repository root)

```text
web/                                # Next.js 14+ (Customer + Admin)
├── app/
│   ├── (shop)/                     # Customer-facing routes
│   │   ├── page.tsx                # Homepage (banners, trending, categories)
│   │   ├── products/
│   │   │   ├── page.tsx            # Product listing with search/filter
│   │   │   └── [id]/page.tsx       # Product detail + reviews
│   │   ├── cart/page.tsx           # Cart (vendor-grouped)
│   │   ├── checkout/page.tsx       # Checkout flow
│   │   ├── orders/
│   │   │   ├── page.tsx            # Order history
│   │   │   └── [id]/page.tsx       # Order detail + tracking timeline
│   │   ├── account/
│   │   │   ├── page.tsx            # Profile
│   │   │   └── wishlist/page.tsx   # Wishlist
│   │   └── layout.tsx              # Shop layout (navbar, footer)
│   ├── (admin)/                    # Admin panel routes
│   │   ├── dashboard/page.tsx      # Platform overview
│   │   ├── users/page.tsx          # User management
│   │   ├── vendors/page.tsx        # Vendor approval
│   │   ├── products/page.tsx       # Product moderation
│   │   ├── orders/page.tsx         # Order oversight
│   │   ├── settings/page.tsx       # Platform config
│   │   ├── audit-log/page.tsx      # Audit log viewer
│   │   └── layout.tsx              # Admin layout (sidebar)
│   ├── (auth)/
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── forgot-password/page.tsx
│   ├── api/webhooks/               # Webhook API routes
│   │   ├── telebirr/route.ts
│   │   └── mpesa/route.ts
│   ├── layout.tsx                  # Root layout
│   └── middleware.ts               # RBAC middleware
├── components/
│   ├── ui/                         # shadcn/ui components
│   ├── shop/                       # Customer components
│   ├── admin/                      # Admin components
│   └── shared/                     # Shared components
├── lib/
│   ├── supabase/                   # Client/server Supabase instances
│   ├── utils/                      # Helpers
│   └── types/                      # TypeScript types
├── messages/
│   ├── en.json                     # English strings
│   └── am.json                     # Amharic strings
├── public/                         # Static assets
├── tests/
│   ├── unit/
│   ├── e2e/
│   └── contract/
├── next.config.ts
├── tailwind.config.ts
├── tsconfig.json
├── package.json
└── .eslintrc.json

mobile/                             # Flutter 3.x (Android + iOS)
├── lib/
│   ├── core/
│   │   ├── config/env.dart         # Environment config
│   │   ├── router/app_router.dart  # GoRouter routes
│   │   ├── theme/app_theme.dart    # Material/Cupertino themes
│   │   └── l10n/                   # Localization (en, am)
│   ├── features/
│   │   ├── auth/                   # Login, register, profile
│   │   ├── home/                   # Homepage, banners, trending
│   │   ├── search/                 # Search, filters, autocomplete
│   │   ├── product/               # Product detail, reviews
│   │   ├── cart/                   # Cart management
│   │   ├── checkout/              # Checkout flow
│   │   ├── orders/                # Order history, tracking
│   │   ├── vendor/                # Vendor dashboard (role-gated)
│   │   └── settings/              # Language, notifications
│   ├── shared/
│   │   ├── models/                # Data classes
│   │   ├── providers/             # Riverpod providers
│   │   ├── services/              # Supabase service layer
│   │   └── widgets/               # Reusable widgets
│   └── main.dart
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration_test/
├── android/
├── ios/
├── pubspec.yaml
└── analysis_options.yaml

supabase/                           # Supabase project config
├── functions/
│   ├── register-vendor/index.ts
│   ├── products/index.ts
│   ├── cart-validate/index.ts
│   ├── checkout/index.ts
│   ├── webhooks-telebirr/index.ts
│   ├── webhooks-mpesa/index.ts
│   ├── orders-status/index.ts
│   ├── orders-assign-agent/index.ts
│   ├── orders-refund/index.ts
│   ├── vendors-moderate/index.ts
│   ├── vendors-analytics/index.ts
│   ├── admin-dashboard/index.ts
│   ├── admin-settings/index.ts
│   ├── upload-image/index.ts
│   ├── send-notification/index.ts
│   └── _shared/                    # Shared utilities
│       ├── cors.ts
│       ├── response.ts
│       ├── auth.ts
│       └── logger.ts
├── migrations/
│   ├── 00001_create_users.sql
│   ├── 00002_create_vendors.sql
│   ├── 00003_create_categories.sql
│   ├── 00004_create_products.sql
│   ├── 00005_create_carts.sql
│   ├── 00006_create_orders.sql
│   ├── 00007_create_payments.sql
│   ├── 00008_create_reviews.sql
│   ├── 00009_create_notifications.sql
│   ├── 00010_create_platform_settings.sql
│   ├── 00011_create_audit_logs.sql
│   ├── 00012_create_banners_wishlists.sql
│   ├── 00013_create_rls_policies.sql
│   ├── 00014_create_indexes.sql
│   └── 00015_seed_data.sql
├── seed.sql
└── config.toml
```

**Structure Decision**: The project uses a **Web + Mobile + Serverless API** structure with three top-level directories (`web/`, `mobile/`, `supabase/`). This reflects the SRS's three interconnected systems and the constitution's technology constraints. The admin panel is embedded within the web app via Next.js route groups `(admin)` rather than a separate app, per constitution mandate.

## Complexity Tracking

> No constitution violations detected — table left empty.

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|--------------------------------------|
| — | — | — |

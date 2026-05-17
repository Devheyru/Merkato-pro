# Research: Merkato-pro E-Commerce Platform

**Date**: 2026-05-17 | **Branch**: `001-ecommerce-platform`

## R1: Supabase Architecture for Multi-Vendor Marketplace

**Decision**: Use Supabase as the exclusive backend platform with Edge Functions as the API layer, PostgreSQL as the database with RLS, Supabase Auth for authentication, Supabase Storage for media, and Supabase Realtime for live updates.

**Rationale**: The SRS mandates Supabase as the exclusive backend (§9.1). Supabase provides a tightly integrated stack that eliminates the need for separate auth, storage, and realtime services. Edge Functions (Deno/TypeScript) provide serverless compute with global distribution, and RLS provides data-layer security enforcement that prevents bypassing application-layer authorization checks.

**Alternatives considered**:
- Custom backend (Express/NestJS): Rejected — SRS §9.1 explicitly prohibits non-Supabase backends in Phase 1. Also higher operational overhead.
- Firebase: Rejected — NoSQL (Firestore) is a poor fit for relational e-commerce data with complex joins (orders, items, vendors). PostgreSQL's ACID guarantees are critical for payment processing.
- Prisma + PlanetScale: Rejected — adds a separate ORM layer and MySQL instead of PostgreSQL. Does not provide integrated auth, storage, or realtime.

## R2: Payment Integration Patterns (Telebirr + M-Pesa)

**Decision**: Implement payment initiation and verification exclusively through Supabase Edge Functions. Client apps send payment requests to Edge Functions, which call Telebirr/M-Pesa APIs server-side. Webhooks are received by dedicated Edge Function endpoints with signature verification.

**Rationale**: FR-019 mandates server-side payment handling only. Both Telebirr and M-Pesa use callback/webhook patterns for payment confirmation. Edge Functions provide the necessary server environment for secret management (API keys as environment variables per NFR-SEC-03) and webhook signature validation.

**Key patterns**:
- **Telebirr flow**: Client → Edge Function (initiate) → Telebirr API → Telebirr callback → Edge Function (verify webhook) → Update order status
- **M-Pesa flow**: Client → Edge Function (STK Push) → M-Pesa Daraja API → M-Pesa callback → Edge Function (verify webhook) → Update order status
- **Idempotency**: Each payment request generates a unique idempotency key stored in the payments table to prevent duplicate charges
- **Timeout handling**: If no webhook received within 5 minutes, Edge Function polls gateway status once, then marks payment as "pending_verification"

**Alternatives considered**:
- Client-side SDK integration: Rejected — violates FR-019 and NFR-SEC-03 (secrets would be exposed in client bundles)
- Third-party payment aggregator (Stripe, Paystack): Rejected — SRS §9.1 limits Phase 1 to Telebirr and M-Pesa only

## R3: Next.js App Router Architecture (Web + Admin)

**Decision**: Use a single Next.js 14+ monorepo with App Router, route groups for customer `(shop)` and admin `(admin)` experiences, and middleware-based RBAC for access control.

**Rationale**: The constitution mandates that the admin panel shares the Next.js codebase with the customer web application using route groups and middleware-based RBAC. App Router provides server components for performance (SSR/SSG), nested layouts for consistent UI shells, and route groups for logical separation without URL impact.

**Structure**:
```
app/
├── (shop)/                 # Customer-facing routes
│   ├── page.tsx            # Homepage
│   ├── products/           # Product listing, detail
│   ├── cart/               # Cart page
│   ├── checkout/           # Checkout flow
│   ├── orders/             # Order history, tracking
│   ├── account/            # Profile, wishlist
│   └── layout.tsx          # Shop layout with nav
├── (admin)/                # Admin panel routes
│   ├── dashboard/          # Admin overview
│   ├── users/              # User management
│   ├── vendors/            # Vendor approval
│   ├── products/           # Product moderation
│   ├── orders/             # Order oversight
│   ├── settings/           # Platform config
│   └── layout.tsx          # Admin layout with sidebar
├── (auth)/                 # Auth routes (login, register)
├── api/                    # API routes (webhooks, etc.)
└── layout.tsx              # Root layout
```

**Alternatives considered**:
- Separate Next.js apps for customer and admin: Rejected — constitution mandates shared codebase
- Pages Router: Rejected — App Router provides better server component support, nested layouts, and is the current Next.js standard

## R4: Flutter Mobile Architecture

**Decision**: Use Flutter 3.x with Riverpod for state management, the supabase-flutter SDK for backend communication, and a feature-based folder structure.

**Rationale**: Constitution mandates Flutter 3.x with Riverpod/BLoC state management. Riverpod provides compile-time safety, testability, and a clear dependency injection pattern. The supabase-flutter SDK gives direct access to Auth, Database, Storage, and Realtime channels.

**Structure**:
```
lib/
├── core/                   # App-wide utilities
│   ├── config/             # Environment, constants
│   ├── router/             # GoRouter navigation
│   ├── theme/              # Material/Cupertino themes
│   └── l10n/               # Internationalization
├── features/               # Feature modules
│   ├── auth/               # Login, register, profile
│   ├── home/               # Homepage, banners
│   ├── search/             # Search, filters
│   ├── product/            # Product detail, reviews
│   ├── cart/               # Cart management
│   ├── checkout/           # Checkout flow
│   ├── orders/             # Order history, tracking
│   ├── vendor/             # Vendor dashboard (role-gated)
│   └── settings/           # App settings, language
├── shared/                 # Shared widgets, models
│   ├── models/             # Data models
│   ├── providers/          # Shared Riverpod providers
│   ├── services/           # Supabase client, API
│   └── widgets/            # Reusable UI components
└── main.dart               # App entry point
```

**Alternatives considered**:
- BLoC only: Viable but Riverpod offers lighter boilerplate for this project size
- GetX: Rejected — less mature testing story and not recommended for large-scale apps

## R5: Database Design Patterns for Multi-Vendor E-Commerce

**Decision**: Use PostgreSQL with UUIDs as primary keys, RLS on all tables, JSONB for product variants, soft deletes for auditable entities, and optimistic locking for stock management.

**Rationale**: Constitution mandates UUIDs, RLS, and soft deletes. JSONB for variants provides schema flexibility without migration overhead (SRS §7.2). Optimistic locking (using a `version` column) prevents overselling during concurrent checkout.

**Key patterns**:
- **Multi-tenancy via RLS**: Vendors see only their products/orders. Customers see only their carts/orders. Admins see everything. All enforced at the database level.
- **Order splitting**: When a cart contains items from multiple vendors, the checkout Edge Function creates one parent order and multiple vendor sub-orders (order_items grouped by vendor_id), each with independent status tracking.
- **Stock management**: `stock_level` is decremented atomically during checkout using PostgreSQL's `UPDATE ... SET stock_level = stock_level - $qty WHERE stock_level >= $qty RETURNING *` pattern. If the RETURNING clause returns no rows, the item is sold out.

**Alternatives considered**:
- Separate databases per vendor: Rejected — excessive complexity for Phase 1
- Integer auto-increment IDs: Rejected — constitution mandates UUIDs for security and horizontal scalability

## R6: Realtime Architecture for Order Tracking & Notifications

**Decision**: Use Supabase Realtime WebSocket channels with row-level subscriptions for order status updates, vendor notifications, and delivery tracking.

**Rationale**: Constitution mandates Supabase Realtime. Realtime channels provide push-based updates to connected clients without polling, reducing server load and improving user experience for order tracking (US6) and vendor notifications (US7).

**Implementation pattern**:
- **Order tracking**: Customer subscribes to `orders:id=eq.<order_id>` channel. On status change, the update triggers a Realtime broadcast.
- **Vendor notifications**: Vendor subscribes to `order_items:vendor_id=eq.<vendor_id>` channel for new order alerts.
- **Push notifications**: For offline users, order status changes trigger an Edge Function that sends FCM push notifications (Firebase Cloud Messaging).

**Alternatives considered**:
- Long polling: Rejected — higher server overhead and worse UX than WebSockets
- Server-Sent Events: Rejected — Supabase Realtime already provides WebSocket infrastructure

## R7: Internationalization (i18n) Strategy

**Decision**: Use next-intl for the Next.js web app and flutter_localizations + intl package for the Flutter mobile app. All user-facing strings are stored as key-value pairs in JSON locale files.

**Rationale**: NFR-USE-04 mandates English and Amharic from launch. Constitution prohibits hardcoded strings. next-intl integrates with App Router for server-side locale detection and provides type-safe message access. Flutter's built-in localization supports Amharic (am) locale.

**Structure**:
- Web: `messages/en.json`, `messages/am.json` with nested keys
- Mobile: `lib/core/l10n/app_en.arb`, `lib/core/l10n/app_am.arb`

**Alternatives considered**:
- i18next: Viable for web but next-intl has better App Router integration
- Manual string maps: Rejected — no compile-time safety or pluralization support

## R8: Image Processing Pipeline

**Decision**: Implement server-side image processing via a Supabase Edge Function that intercepts uploads, validates file type/size, converts to WebP, and compresses to under 200KB before storing in Supabase Storage.

**Rationale**: FR-011 mandates auto-compression to WebP under 200KB. NFR-SEC-08 mandates file type/size validation. Processing server-side ensures consistent output regardless of client platform and prevents malicious file uploads.

**Flow**: Client upload → Edge Function (validate type, check size ≤ 10MB) → Convert to WebP → Compress to ≤ 200KB → Store in Supabase Storage → Return public URL

**Alternatives considered**:
- Client-side compression: Rejected — inconsistent across devices, can be bypassed
- Supabase Storage transforms: Currently limited in Supabase; Edge Function gives full control

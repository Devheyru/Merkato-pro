<!--
  Sync Impact Report
  ===================
  Version change: 0.0.0 (template) → 1.0.0 (initial ratification)

  Added principles:
    - I. Code Quality & Architectural Integrity
    - II. Testing Standards
    - III. User Experience Consistency
    - IV. Performance Requirements
    - V. Security & Data Integrity

  Added sections:
    - Technology Constraints (Section 2)
    - Development Workflow (Section 3)
    - Governance (Section 4)

  Removed sections: None (first constitution)

  Templates validated:
    ✅ .specify/templates/plan-template.md — Constitution Check section
        aligns with all 5 principles; no updates needed.
    ✅ .specify/templates/spec-template.md — User stories and requirements
        sections support performance/UX/security principles; no updates needed.
    ✅ .specify/templates/tasks-template.md — Task phases support testing-first
        workflow and polish phase covers security/perf; no updates needed.

  Follow-up TODOs: None.
-->

# SuQmarket (Merkato-pro) Constitution

## Core Principles

### I. Code Quality & Architectural Integrity

Every component of SuQmarket MUST adhere to strict code quality
standards enforced via automated tooling and review processes.

- All web (Next.js) code MUST pass ESLint + Prettier checks with zero
  errors before merge. No lint suppressions without documented
  justification.
- All mobile (Flutter/Dart) code MUST pass `flutter_lints` analysis
  with zero warnings. Custom lint rules MUST be documented in
  `analysis_options.yaml`.
- All Edge Functions MUST be written in TypeScript (Deno runtime) with
  strict mode enabled (`"strict": true` in tsconfig). No `any` types
  without explicit justification.
- The three-tier architecture (presentation → API/Edge Functions →
  data layer) MUST be respected. Presentation layers MUST NOT access
  the database directly; all data access goes through Supabase client
  SDK or Edge Functions.
- Supabase database migrations MUST be managed via Supabase CLI
  migration files under version control. Manual schema changes in
  production are prohibited.
- Structured logging MUST be implemented for all Edge Function
  invocations and errors (NFR-MAIN-03). Logs MUST include request ID,
  timestamp, severity, and context.

### II. Testing Standards

Testing is a mandatory gate for all feature work. Code without
adequate test coverage MUST NOT be merged.

- All Edge Functions MUST maintain unit test coverage of at least 70%
  (NFR-MAIN-01). Coverage reports MUST be generated on every CI run.
- Contract tests MUST exist for every public API endpoint (Edge
  Function). Tests MUST validate request/response schemas, HTTP status
  codes, and error shapes.
- Integration tests MUST cover all critical user journeys: search →
  product → cart → checkout → payment → order tracking.
- Payment integration (Telebirr, M-Pesa) MUST have dedicated test
  suites covering: successful payment, failed payment, webhook
  verification, and timeout scenarios (FR-PAY-01 through FR-PAY-06).
- Tests MUST be written before or alongside implementation. A PR with
  new functionality and zero test additions requires explicit
  justification and a follow-up test ticket.
- Mobile (Flutter) tests MUST include widget tests for all custom UI
  components and integration tests for navigation flows.

### III. User Experience Consistency

SuQmarket MUST deliver a cohesive, accessible, and responsive user
experience across all three platforms (web, mobile, admin).

- The web application MUST be fully responsive from 320px (mobile) to
  2560px (4K desktop) per NFR-USE-01. Breakpoint behavior MUST be
  verified in automated tests or documented manual QA checklists.
- The mobile app MUST conform to Material Design 3 (Android) and
  Cupertino (iOS) guidelines where applicable (NFR-USE-02). Custom
  components MUST document deviations from platform guidelines.
- Core customer journeys (search → product → cart → payment) MUST be
  completable in 5 or fewer user interactions (NFR-USE-03).
- The system MUST support English and Amharic as display languages
  from launch (NFR-USE-04). All user-facing strings MUST use i18n
  keys; hardcoded strings are prohibited.
- The web app MUST achieve a minimum WCAG 2.1 Level AA accessibility
  score (NFR-USE-05). Color contrast, keyboard navigation, and screen
  reader compatibility MUST be validated.
- UI component libraries are standardized: Tailwind CSS + shadcn/ui
  for web, Flutter's Material/Cupertino widgets for mobile. Ad-hoc
  styling outside these systems requires design review approval.

### IV. Performance Requirements

SuQmarket MUST meet quantified performance targets as defined in the
SRS. Performance regressions are treated as bugs with P1 priority.

- Web pages MUST achieve Largest Contentful Paint (LCP) under 2.5
  seconds on a 3G connection (NFR-PERF-01). Lighthouse CI MUST gate
  deployments against this threshold.
- Edge Function API responses MUST have p95 latency under 300ms
  (NFR-PERF-02). Endpoints exceeding this MUST be profiled and
  optimized before release.
- The system MUST support 1,000 concurrent active users without
  degradation (NFR-PERF-03). Load testing MUST validate this before
  each major release.
- Database queries for product listings MUST execute in under 100ms
  (NFR-PERF-04). All foreign key columns and frequently filtered
  columns (status, created_at, vendor_id) MUST have indexes.
- Mobile app cold start time MUST be under 3 seconds on mid-range
  devices (NFR-PERF-05). Startup profiling MUST be part of release
  QA.
- Image assets MUST be served via CDN in WebP format, each under
  200KB (NFR-PERF-06). Upload pipelines MUST auto-compress and
  convert images.

### V. Security & Data Integrity

SuQmarket handles financial transactions and personal data. Security
is non-negotiable and MUST be designed into every layer.

- All data transmission MUST use TLS 1.2+ (HTTPS enforced). HTTP
  requests MUST be rejected or redirected (NFR-SEC-01).
- Supabase Row-Level Security (RLS) MUST be enabled on all tables
  containing user or vendor data (NFR-SEC-02). New tables MUST ship
  with RLS policies before deployment.
- Payment gateway API keys and secrets MUST be stored exclusively as
  Supabase Edge Function environment variables. No secrets in source
  code, client bundles, or logs (NFR-SEC-03).
- The system MUST NOT store raw payment credentials. Only
  gateway-issued transaction reference IDs are persisted (SRS §9.1).
- Rate limiting MUST be enforced on authentication endpoints: maximum
  5 failed login attempts per 15-minute window per IP (NFR-SEC-05).
- File uploads MUST be validated for type and size (max 10MB per
  file) and scanned for malicious content (NFR-SEC-08).
- The platform MUST protect against OWASP Top 10 vulnerabilities
  including SQL injection, XSS, and CSRF (NFR-SEC-07).
- All admin actions MUST be logged to an append-only audit_logs table
  (FR-ADM-10). No RLS update/delete policies are permitted on this
  table.

## Technology Constraints

The following technology decisions are binding for all SuQmarket
development and MUST NOT be deviated from without a constitution
amendment.

| Layer | Technology | Constraint Level |
|---|---|---|
| Web Frontend | Next.js 14+ (App Router) | MANDATORY |
| Admin Panel | Next.js 14 + Role-based routing | MANDATORY |
| Mobile App | Flutter 3.x (Dart) | MANDATORY |
| Backend / API | Supabase Edge Functions (Deno/TS) | MANDATORY |
| Database | PostgreSQL via Supabase | MANDATORY |
| Authentication | Supabase Auth (JWT + OAuth) | MANDATORY |
| File Storage | Supabase Storage | MANDATORY |
| Realtime | Supabase Realtime (WebSockets) | MANDATORY |
| Payment — ETB | Telebirr API | MANDATORY (Phase 1) |
| Payment — KES | M-Pesa Daraja API | MANDATORY (Phase 1) |
| Push Notifications | Firebase Cloud Messaging | MANDATORY |
| Styling (Web) | Tailwind CSS + shadcn/ui | MANDATORY |
| State (Mobile) | Riverpod / BLoC | MANDATORY |
| Deployment | Vercel (Next.js) + Supabase Cloud | MANDATORY |

- All Edge Functions MUST use TypeScript on the Deno runtime. No
  external runtime dependencies beyond what Supabase supports.
- The admin panel MUST share the Next.js codebase with the customer
  web application using route groups and middleware-based RBAC.
- UUIDs (`gen_random_uuid()`) MUST be used as primary keys on all
  tables for security and horizontal scalability.
- Soft deletes (`deleted_at` timestamp) MUST be used for products,
  orders, and vendors to preserve referential integrity and audit
  history.

## Development Workflow

All contributors MUST follow this workflow to ensure consistency
and traceability across the SuQmarket codebase.

- **Feature branches**: All work MUST be done on feature branches
  created from `main`. Direct pushes to `main` are prohibited.
- **Spec-Kit workflow**: Features MUST follow the Spec Kit lifecycle:
  specify → clarify → plan → tasks → implement. Skipping steps
  requires documented justification.
- **Code review**: All PRs MUST be reviewed by at least one other
  contributor before merge. Self-merges are prohibited except for
  emergency hotfixes (which MUST be retroactively reviewed within
  24 hours).
- **CI gates**: Every PR MUST pass: lint checks (ESLint/Prettier for
  web, flutter_lints for mobile), unit tests, contract tests, and
  build verification before merge is permitted.
- **Commit messages**: MUST follow Conventional Commits format
  (`feat:`, `fix:`, `docs:`, `chore:`, `refactor:`, `test:`).
- **Critical errors**: MUST trigger automated alerts to the admin
  team within 5 minutes (NFR-MAIN-05). Alert configuration MUST be
  tested as part of infrastructure changes.

## Governance

This constitution is the authoritative source of project standards
for SuQmarket (Merkato-pro). It supersedes all other practices,
informal agreements, and ad-hoc decisions.

- **Amendments**: Any change to this constitution MUST be documented
  with a version bump, a description of what changed and why, and a
  migration plan for existing code if the change is backward
  incompatible.
- **Versioning**: This constitution follows semantic versioning:
  - MAJOR: Principle removal, redefinition, or backward-incompatible
    governance change.
  - MINOR: New principle or section added, or materially expanded
    guidance.
  - PATCH: Clarifications, wording fixes, non-semantic refinements.
- **Compliance review**: All PRs and code reviews MUST verify
  compliance with these principles. Reviewers MUST flag violations
  as blocking issues.
- **Complexity justification**: Any architectural decision that
  increases complexity beyond the patterns established here MUST be
  justified in writing and tracked in the plan's Complexity Tracking
  table.
- **Guidance**: For runtime development guidance, refer to the
  current feature's plan.md and the Spec Kit workflow documents.

**Version**: 1.0.0 | **Ratified**: 2026-05-17 | **Last Amended**: 2026-05-17

# Quickstart: Merkato-pro E-Commerce Platform

**Date**: 2026-05-17 | **Branch**: `001-ecommerce-platform`

## Prerequisites

- **Node.js** 18+ and npm 9+
- **Flutter** 3.x with Dart SDK
- **Supabase CLI** (`npm install -g supabase`)
- **Git**
- A **Supabase** project (free or pro tier)
- **Telebirr** developer credentials (for ETB payments)
- **M-Pesa Daraja** API credentials (for KES payments)
- **Firebase** project with Cloud Messaging enabled

## 1. Clone and Setup

```bash
git clone https://github.com/Devheyru/Merkato-pro.git
cd Merkato-pro
```

## 2. Supabase Backend Setup

### Link to your Supabase project

```bash
supabase login
supabase link --project-ref <your-project-ref>
```

### Run database migrations

```bash
supabase db push
```

### Set Edge Function secrets

```bash
supabase secrets set TELEBIRR_APP_ID=<value>
supabase secrets set TELEBIRR_APP_KEY=<value>
supabase secrets set TELEBIRR_SHORT_CODE=<value>
supabase secrets set MPESA_CONSUMER_KEY=<value>
supabase secrets set MPESA_CONSUMER_SECRET=<value>
supabase secrets set MPESA_SHORTCODE=<value>
supabase secrets set MPESA_PASSKEY=<value>
supabase secrets set FCM_SERVER_KEY=<value>
```

### Deploy Edge Functions

```bash
supabase functions deploy --no-verify-jwt register-vendor
supabase functions deploy products
supabase functions deploy cart-validate
supabase functions deploy checkout
supabase functions deploy webhooks-telebirr --no-verify-jwt
supabase functions deploy webhooks-mpesa --no-verify-jwt
supabase functions deploy orders-status
supabase functions deploy orders-assign-agent
supabase functions deploy orders-refund
supabase functions deploy vendors-moderate
supabase functions deploy vendors-analytics
supabase functions deploy admin-dashboard
supabase functions deploy admin-settings
supabase functions deploy upload-image
supabase functions deploy send-notification
```

## 3. Web Application Setup (Next.js)

```bash
cd web
npm install
```

### Create environment file

```bash
cp .env.example .env.local
```

Edit `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://<project>.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=<your-anon-key>
NEXT_PUBLIC_DEFAULT_LOCALE=en
```

### Run development server

```bash
npm run dev
```

Open [http://localhost:3000](http://localhost:3000) for the customer storefront.
Open [http://localhost:3000/admin](http://localhost:3000/admin) for the admin panel (requires admin role).

## 4. Mobile Application Setup (Flutter)

```bash
cd mobile
flutter pub get
```

### Configure environment

Edit `lib/core/config/env.dart`:
```dart
class Env {
  static const supabaseUrl = 'https://<project>.supabase.co';
  static const supabaseAnonKey = '<your-anon-key>';
}
```

### Run on device/emulator

```bash
flutter run
```

## 5. Verification

### Verify backend

```bash
# Check database tables
supabase db status

# Test an Edge Function
curl -X POST https://<project>.supabase.co/functions/v1/admin-dashboard \
  -H "Authorization: Bearer <admin-jwt>" \
  -H "Content-Type: application/json"
```

### Verify web app

1. Navigate to `http://localhost:3000`
2. Register a customer account
3. Browse the homepage (should show banners and categories)

### Verify mobile app

1. Launch app on device/emulator
2. Register or log in
3. Browse products and add to cart

## 6. Running Tests

### Edge Functions

```bash
supabase functions test <function-name>
```

### Web (Next.js)

```bash
cd web
npm run test          # Unit tests
npm run test:e2e      # E2E tests (Playwright)
npm run lint          # ESLint + Prettier
```

### Mobile (Flutter)

```bash
cd mobile
flutter test                    # Unit + widget tests
flutter test integration_test/  # Integration tests
flutter analyze                 # Lint analysis
```

## 7. Deployment

### Web → Vercel

```bash
cd web
vercel --prod
```

### Mobile → App Stores

```bash
cd mobile
flutter build apk --release    # Android
flutter build ios --release     # iOS
```

### Edge Functions → Supabase Cloud

```bash
supabase functions deploy --all
```

## Project Structure Overview

```
Merkato-pro/
├── web/                        # Next.js 14 (Customer + Admin)
│   ├── app/
│   │   ├── (shop)/             # Customer routes
│   │   ├── (admin)/            # Admin panel routes
│   │   ├── (auth)/             # Auth routes
│   │   └── api/                # Webhook receivers
│   ├── components/             # Shared UI components
│   ├── lib/                    # Utilities, Supabase client
│   ├── messages/               # i18n (en.json, am.json)
│   └── tests/
├── mobile/                     # Flutter 3.x (Android + iOS)
│   ├── lib/
│   │   ├── core/               # Config, router, theme, l10n
│   │   ├── features/           # Feature modules
│   │   └── shared/             # Models, providers, widgets
│   └── test/
├── supabase/                   # Supabase config
│   ├── functions/              # Edge Functions (TypeScript/Deno)
│   ├── migrations/             # SQL migration files
│   └── config.toml
├── specs/                      # Feature specifications
└── .specify/                   # Spec Kit configuration
```

# API Contracts: Merkato-pro Edge Functions

**Date**: 2026-05-17 | **Branch**: `001-ecommerce-platform`

All endpoints are Supabase Edge Functions invoked via `POST https://<project>.supabase.co/functions/v1/<function-name>`. Authentication is via `Authorization: Bearer <JWT>` header from Supabase Auth.

## Standard Response Envelope

All Edge Functions return responses in this format:

```json
{
  "success": true,
  "data": { ... },
  "error": null
}
```

Error responses:

```json
{
  "success": false,
  "data": null,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Human-readable error message",
    "details": { ... }
  }
}
```

**Standard HTTP Status Codes**: 200 (success), 201 (created), 400 (validation), 401 (unauthenticated), 403 (forbidden), 404 (not found), 409 (conflict), 422 (unprocessable), 429 (rate limited), 500 (server error)

---

## Auth Endpoints

> Note: Most auth is handled by Supabase Auth SDK directly. These Edge Functions handle custom auth logic.

### POST /functions/v1/register-vendor

Register a new vendor application (creates user + vendor record in pending state).

**Auth**: None (public)

**Request**:
```json
{
  "email": "vendor@example.com",
  "password": "securePassword123",
  "full_name": "Store Owner",
  "phone": "+251911234567",
  "store_name": "My Shop",
  "store_description": "Quality products from Ethiopia"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "user_id": "uuid",
    "vendor_id": "uuid",
    "approval_status": "pending",
    "message": "Vendor application submitted. Awaiting admin approval."
  }
}
```

---

## Product Endpoints

### POST /functions/v1/products

Create a new product listing.

**Auth**: Vendor (approved)

**Request**:
```json
{
  "title": "Ethiopian Coffee Beans",
  "title_am": "የኢትዮጵያ ቡና",
  "description": "Premium arabica coffee beans from Yirgacheffe",
  "description_am": "ከይርጋጨፌ የመጣ ከፍተኛ ጥራት ያለው ቡና",
  "base_price": 850.00,
  "currency": "ETB",
  "category_id": "uuid",
  "variants": [
    { "name": "size", "value": "250g", "price_modifier": 0, "stock": 100 },
    { "name": "size", "value": "500g", "price_modifier": 350, "stock": 50 }
  ],
  "stock_level": 150,
  "images": ["base64_or_upload_ref"]
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "pending_approval",
    "images": ["https://storage.supabase.co/..."],
    "created_at": "2026-05-17T12:00:00Z"
  }
}
```

### PUT /functions/v1/products/{id}

Update an existing product.

**Auth**: Vendor (owner)

**Request**: Same fields as create (partial updates supported)

**Response** (200): Updated product data

### POST /functions/v1/products/{id}/moderate

Admin moderation action on a product.

**Auth**: Admin

**Request**:
```json
{
  "action": "approve",
  "reason": "Meets listing guidelines"
}
```
Actions: `approve`, `reject`, `deactivate`

**Response** (200): Updated product with new status

---

## Cart Endpoints

> Note: Cart reads/writes use Supabase client SDK directly (carts + cart_items tables with RLS). These Edge Functions handle validation-heavy operations.

### POST /functions/v1/cart/validate

Validate cart contents before checkout (check stock, prices, product availability).

**Auth**: Customer

**Request**:
```json
{
  "cart_id": "uuid"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "valid": true,
    "items": [
      {
        "product_id": "uuid",
        "available": true,
        "current_price": 850.00,
        "price_changed": false,
        "in_stock": true,
        "available_stock": 100
      }
    ],
    "warnings": [],
    "total": 1700.00,
    "currency": "ETB"
  }
}
```

---

## Checkout & Payment Endpoints

### POST /functions/v1/checkout

Create an order from the cart and initiate payment.

**Auth**: Customer

**Request**:
```json
{
  "cart_id": "uuid",
  "delivery_address": {
    "street": "Bole Road, Building 42",
    "city": "Addis Ababa",
    "region": "Addis Ababa",
    "postal_code": "1000",
    "lat": 9.0054,
    "lng": 38.7636
  },
  "payment_method": "telebirr",
  "notes": "Please call before delivery"
}
```

**Response** (201):
```json
{
  "success": true,
  "data": {
    "order_id": "uuid",
    "status": "pending",
    "total_amount": 1700.00,
    "currency": "ETB",
    "payment": {
      "gateway": "telebirr",
      "payment_url": "https://telebirr.com/pay/...",
      "idempotency_key": "uuid",
      "expires_at": "2026-05-17T12:30:00Z"
    },
    "vendor_sub_orders": [
      { "vendor_id": "uuid", "vendor_name": "My Shop", "item_count": 2, "subtotal": 1700.00 }
    ]
  }
}
```

### POST /functions/v1/webhooks/telebirr

Telebirr payment webhook receiver.

**Auth**: Signature verification (Telebirr)

**Request**: Telebirr callback payload (gateway-specific format)

**Response** (200): `{ "success": true }`

### POST /functions/v1/webhooks/mpesa

M-Pesa payment webhook receiver.

**Auth**: Signature verification (M-Pesa Daraja)

**Request**: M-Pesa callback payload (gateway-specific format)

**Response** (200): `{ "success": true }`

---

## Order Management Endpoints

### PUT /functions/v1/orders/{id}/status

Update order or sub-order status.

**Auth**: Vendor (for their items), Delivery Agent (for assigned items), Admin (all)

**Request**:
```json
{
  "status": "accepted",
  "scope": "vendor",
  "notes": "Order ready for pickup"
}
```

**Response** (200):
```json
{
  "success": true,
  "data": {
    "order_id": "uuid",
    "new_status": "accepted",
    "updated_items": 3,
    "notification_sent": true
  }
}
```

### POST /functions/v1/orders/{id}/assign-agent

Assign a delivery agent to an order.

**Auth**: Admin

**Request**:
```json
{
  "delivery_agent_id": "uuid"
}
```

**Response** (200): Updated order items with agent assignment

### POST /functions/v1/orders/{id}/refund

Initiate a refund request.

**Auth**: Customer (own order), Admin (any order)

**Request**:
```json
{
  "reason": "Product damaged during delivery",
  "items": ["order_item_uuid_1", "order_item_uuid_2"]
}
```

**Response** (200): Refund request created, status updated to `refund_requested`

---

## Vendor Endpoints

### POST /functions/v1/vendors/{id}/moderate

Admin moderation of vendor application.

**Auth**: Admin

**Request**:
```json
{
  "action": "approve",
  "reason": "Verified business documents"
}
```
Actions: `approve`, `reject`, `suspend`

**Response** (200): Updated vendor with new approval_status

### GET /functions/v1/vendors/{id}/analytics

Vendor sales analytics.

**Auth**: Vendor (own), Admin

**Query params**: `?from=2026-01-01&to=2026-05-17&group_by=day`

**Response** (200):
```json
{
  "success": true,
  "data": {
    "total_revenue": 125000.00,
    "total_orders": 342,
    "total_products": 48,
    "avg_rating": 4.3,
    "commission_paid": 6250.00,
    "chart_data": [
      { "date": "2026-05-01", "revenue": 4500.00, "orders": 12 }
    ]
  }
}
```

---

## Admin Endpoints

### GET /functions/v1/admin/dashboard

Platform-wide analytics overview.

**Auth**: Admin

**Response** (200):
```json
{
  "success": true,
  "data": {
    "total_users": 15420,
    "total_vendors": 234,
    "total_products": 8920,
    "total_orders": 45200,
    "total_revenue": 12500000.00,
    "pending_vendor_applications": 12,
    "pending_product_reviews": 45,
    "active_deliveries": 89
  }
}
```

### PUT /functions/v1/admin/settings

Update platform settings.

**Auth**: Admin (super)

**Request**:
```json
{
  "key": "default_commission_rate",
  "value": 7.5
}
```

**Response** (200): Updated setting

---

## Image Upload Endpoint

### POST /functions/v1/upload-image

Upload and process an image (validate, convert to WebP, compress).

**Auth**: Vendor, Admin

**Request**: `multipart/form-data` with `file` field

**Headers**: `Content-Type: multipart/form-data`

**Response** (201):
```json
{
  "success": true,
  "data": {
    "url": "https://<project>.supabase.co/storage/v1/object/public/images/products/uuid.webp",
    "size_bytes": 145000,
    "format": "webp",
    "width": 800,
    "height": 600
  }
}
```

**Validation rules**: Max 10MB input, allowed types: image/jpeg, image/png, image/webp, image/gif

---

## Notification Endpoint

### POST /functions/v1/send-notification

Send push notification via FCM (internal, called by other Edge Functions).

**Auth**: Service role key (internal only)

**Request**:
```json
{
  "user_id": "uuid",
  "title": "Order Update",
  "body": "Your order #1234 has been shipped!",
  "data": { "type": "order_update", "order_id": "uuid" }
}
```

**Response** (200): `{ "success": true, "fcm_message_id": "..." }`

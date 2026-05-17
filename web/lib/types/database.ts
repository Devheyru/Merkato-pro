/**
 * Merkato-pro Database TypeScript Types
 * Auto-generated from data-model.md — 14 entities
 * 
 * These types mirror the Supabase PostgreSQL schema for type-safe
 * database queries across the web application.
 */

// ============================================================
// Enums
// ============================================================

export type UserRole = "customer" | "vendor" | "delivery_agent" | "admin";
export type VendorApprovalStatus = "pending" | "approved" | "rejected" | "suspended";
export type ProductStatus = "draft" | "pending_approval" | "approved" | "rejected" | "deactivated";
export type Currency = "ETB" | "KES";
export type OrderStatus =
  | "pending"
  | "confirmed"
  | "processing"
  | "shipped"
  | "in_transit"
  | "delivered"
  | "cancelled"
  | "refund_requested"
  | "refunded";
export type VendorItemStatus = "pending" | "accepted" | "rejected" | "processing" | "shipped";
export type PaymentGateway = "telebirr" | "mpesa";
export type PaymentStatus = "initiated" | "pending" | "completed" | "failed" | "refunded";

// ============================================================
// Database Row Types
// ============================================================

export interface User {
  id: string;
  email: string;
  phone: string | null;
  full_name: string;
  avatar_url: string | null;
  role: UserRole;
  is_verified: boolean;
  locale: string;
  created_at: string;
  updated_at: string;
}

export interface Vendor {
  id: string;
  user_id: string;
  store_name: string;
  store_slug: string;
  description: string | null;
  logo_url: string | null;
  banner_url: string | null;
  approval_status: VendorApprovalStatus;
  commission_rate: number;
  deleted_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Category {
  id: string;
  name: string;
  name_am: string | null;
  slug: string;
  parent_id: string | null;
  icon_url: string | null;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ProductVariant {
  name: string;
  value: string;
  price_modifier: number;
  stock: number;
}

export interface Product {
  id: string;
  vendor_id: string;
  category_id: string;
  title: string;
  title_am: string | null;
  description: string;
  description_am: string | null;
  base_price: number;
  currency: Currency;
  variants: ProductVariant[];
  images: string[];
  stock_level: number;
  status: ProductStatus;
  is_featured: boolean;
  sale_price: number | null;
  sale_start: string | null;
  sale_end: string | null;
  avg_rating: number;
  review_count: number;
  version: number;
  deleted_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Cart {
  id: string;
  user_id: string;
  created_at: string;
  updated_at: string;
}

export interface CartItem {
  id: string;
  cart_id: string;
  product_id: string;
  variant: { name: string; value: string } | null;
  quantity: number;
  created_at: string;
  updated_at: string;
}

export interface Wishlist {
  id: string;
  user_id: string;
  product_id: string;
  created_at: string;
}

export interface DeliveryAddress {
  street: string;
  city: string;
  region: string;
  postal_code: string;
  lat: number;
  lng: number;
}

export interface Order {
  id: string;
  customer_id: string;
  status: OrderStatus;
  total_amount: number;
  currency: Currency;
  delivery_address: DeliveryAddress;
  payment_method: PaymentGateway;
  payment_reference: string | null;
  notes: string | null;
  estimated_delivery: string | null;
  delivered_at: string | null;
  deleted_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface OrderItem {
  id: string;
  order_id: string;
  product_id: string;
  vendor_id: string;
  variant: { name: string; value: string } | null;
  quantity: number;
  unit_price: number;
  subtotal: number;
  vendor_status: VendorItemStatus;
  delivery_agent_id: string | null;
  created_at: string;
  updated_at: string;
}

export interface Payment {
  id: string;
  order_id: string;
  gateway: PaymentGateway;
  transaction_ref: string | null;
  idempotency_key: string;
  amount: number;
  currency: Currency;
  status: PaymentStatus;
  gateway_response: Record<string, unknown> | null;
  webhook_received_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Review {
  id: string;
  customer_id: string;
  product_id: string;
  order_id: string;
  rating: number;
  text: string;
  photos: string[];
  vendor_reply: string | null;
  vendor_replied_at: string | null;
  is_visible: boolean;
  helpful_count: number;
  created_at: string;
  updated_at: string;
}

export interface HomepageBanner {
  id: string;
  title: string;
  title_am: string | null;
  image_url: string;
  link_url: string | null;
  display_order: number;
  is_active: boolean;
  starts_at: string | null;
  ends_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Notification {
  id: string;
  user_id: string;
  type: string;
  title: string;
  body: string;
  data: Record<string, unknown> | null;
  is_read: boolean;
  created_at: string;
}

export interface PlatformSetting {
  key: string;
  value: Record<string, unknown>;
  updated_by: string | null;
  updated_at: string;
}

export interface AuditLog {
  id: string;
  actor_id: string;
  action: string;
  entity_type: string;
  entity_id: string;
  details: Record<string, unknown> | null;
  ip_address: string | null;
  created_at: string;
}

// ============================================================
// Insert Types (omit auto-generated fields)
// ============================================================

export type UserInsert = Omit<User, "created_at" | "updated_at">;
export type VendorInsert = Omit<Vendor, "id" | "created_at" | "updated_at" | "deleted_at">;
export type ProductInsert = Omit<Product, "id" | "avg_rating" | "review_count" | "version" | "created_at" | "updated_at" | "deleted_at">;
export type OrderInsert = Omit<Order, "id" | "payment_reference" | "estimated_delivery" | "delivered_at" | "created_at" | "updated_at" | "deleted_at">;
export type ReviewInsert = Omit<Review, "id" | "vendor_reply" | "vendor_replied_at" | "is_visible" | "helpful_count" | "created_at" | "updated_at">;

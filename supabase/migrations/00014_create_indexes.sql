-- Migration: Create comprehensive indexes
-- Covers composite indexes and additional performance indexes
-- not already created in individual table migrations.

-- Composite indexes for common query patterns

-- Product listing: filter by status + category + price range
CREATE INDEX IF NOT EXISTS idx_products_listing
  ON public.products(status, category_id, base_price)
  WHERE deleted_at IS NULL;

-- Product search: status filter for approved products
CREATE INDEX IF NOT EXISTS idx_products_approved
  ON public.products(created_at DESC)
  WHERE status = 'approved' AND deleted_at IS NULL;

-- Orders: customer order history sorted by date
CREATE INDEX IF NOT EXISTS idx_orders_customer_history
  ON public.orders(customer_id, created_at DESC)
  WHERE deleted_at IS NULL;

-- Order items: vendor order management
CREATE INDEX IF NOT EXISTS idx_order_items_vendor_status
  ON public.order_items(vendor_id, vendor_status);

-- Reviews: product reviews sorted by date
CREATE INDEX IF NOT EXISTS idx_reviews_product_recent
  ON public.reviews(product_id, created_at DESC)
  WHERE is_visible = TRUE;

-- Notifications: unread notifications per user
CREATE INDEX IF NOT EXISTS idx_notifications_unread
  ON public.notifications(user_id, created_at DESC)
  WHERE is_read = FALSE;

-- Banners: active banners sorted by display order
CREATE INDEX IF NOT EXISTS idx_banners_active
  ON public.homepage_banners(display_order)
  WHERE is_active = TRUE;

-- Vendors: approved vendors for public browsing
CREATE INDEX IF NOT EXISTS idx_vendors_approved
  ON public.vendors(created_at DESC)
  WHERE approval_status = 'approved' AND deleted_at IS NULL;

-- Migration: Create reviews table
-- Data model: reviews entity from data-model.md

CREATE TABLE IF NOT EXISTS public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  text TEXT NOT NULL,
  photos TEXT[] DEFAULT '{}',
  vendor_reply TEXT,
  vendor_replied_at TIMESTAMPTZ,
  is_visible BOOLEAN DEFAULT TRUE,
  helpful_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (customer_id, product_id)
);

-- Indexes
CREATE INDEX idx_reviews_product_id ON public.reviews(product_id);
CREATE INDEX idx_reviews_customer_id ON public.reviews(customer_id);
CREATE INDEX idx_reviews_rating ON public.reviews(rating);
CREATE INDEX idx_reviews_created_at ON public.reviews(created_at DESC);
CREATE INDEX idx_reviews_is_visible ON public.reviews(is_visible);

-- Enable RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Public can read visible reviews
CREATE POLICY "reviews_select_public" ON public.reviews FOR SELECT
  USING (is_visible = TRUE);

-- Customers can create reviews for their delivered orders
CREATE POLICY "reviews_insert_customer" ON public.reviews FOR INSERT
  WITH CHECK (
    auth.uid() = customer_id
    AND order_id IN (
      SELECT id FROM public.orders
      WHERE customer_id = auth.uid() AND status = 'delivered'
    )
  );

-- Customers can update their own reviews
CREATE POLICY "reviews_update_customer" ON public.reviews FOR UPDATE
  USING (auth.uid() = customer_id);

-- Vendors can update vendor_reply on their product reviews
CREATE POLICY "reviews_update_vendor_reply" ON public.reviews FOR UPDATE
  USING (
    product_id IN (
      SELECT p.id FROM public.products p
      JOIN public.vendors v ON v.id = p.vendor_id
      WHERE v.user_id = auth.uid()
    )
  );

-- Admins can update is_visible (moderation)
CREATE POLICY "reviews_update_admin" ON public.reviews FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "reviews_select_admin" ON public.reviews FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Trigger
CREATE TRIGGER reviews_updated_at BEFORE UPDATE ON public.reviews
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

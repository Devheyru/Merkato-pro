-- Migration: Create products table with full-text search
-- Data model: products entity from data-model.md

CREATE TABLE IF NOT EXISTS public.products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE CASCADE,
  category_id UUID NOT NULL REFERENCES public.categories(id) ON DELETE RESTRICT,
  title TEXT NOT NULL,
  title_am TEXT,
  description TEXT NOT NULL,
  description_am TEXT,
  base_price DECIMAL(12,2) NOT NULL CHECK (base_price > 0),
  currency TEXT NOT NULL CHECK (currency IN ('ETB', 'KES')),
  variants JSONB DEFAULT '[]'::jsonb,
  images TEXT[] NOT NULL DEFAULT '{}',
  stock_level INTEGER NOT NULL DEFAULT 0 CHECK (stock_level >= 0),
  status TEXT NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'pending_approval', 'approved', 'rejected', 'deactivated')),
  is_featured BOOLEAN DEFAULT FALSE,
  sale_price DECIMAL(12,2),
  sale_start TIMESTAMPTZ,
  sale_end TIMESTAMPTZ,
  avg_rating DECIMAL(3,2) DEFAULT 0.00,
  review_count INTEGER DEFAULT 0,
  version INTEGER DEFAULT 1,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Standard indexes
CREATE INDEX idx_products_vendor_id ON public.products(vendor_id);
CREATE INDEX idx_products_category_id ON public.products(category_id);
CREATE INDEX idx_products_status ON public.products(status);
CREATE INDEX idx_products_created_at ON public.products(created_at DESC);
CREATE INDEX idx_products_deleted_at ON public.products(deleted_at);
CREATE INDEX idx_products_is_featured ON public.products(is_featured) WHERE is_featured = TRUE;
CREATE INDEX idx_products_base_price ON public.products(base_price);
CREATE INDEX idx_products_avg_rating ON public.products(avg_rating DESC);

-- Full-text search GIN index
CREATE INDEX idx_products_fts ON public.products
  USING GIN (to_tsvector('english', coalesce(title, '') || ' ' || coalesce(description, '')));

-- Enable RLS
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

-- Public can read approved, non-deleted products
CREATE POLICY "products_select_public"
  ON public.products FOR SELECT
  USING (status = 'approved' AND deleted_at IS NULL);

-- Vendors can CRUD their own products
CREATE POLICY "products_select_vendor"
  ON public.products FOR SELECT
  USING (
    vendor_id IN (
      SELECT id FROM public.vendors WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "products_insert_vendor"
  ON public.products FOR INSERT
  WITH CHECK (
    vendor_id IN (
      SELECT id FROM public.vendors
      WHERE user_id = auth.uid() AND approval_status = 'approved'
    )
  );

CREATE POLICY "products_update_vendor"
  ON public.products FOR UPDATE
  USING (
    vendor_id IN (
      SELECT id FROM public.vendors WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "products_delete_vendor"
  ON public.products FOR DELETE
  USING (
    vendor_id IN (
      SELECT id FROM public.vendors WHERE user_id = auth.uid()
    )
  );

-- Admins can read/update all products (moderation)
CREATE POLICY "products_select_admin"
  ON public.products FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "products_update_admin"
  ON public.products FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Trigger
CREATE TRIGGER products_updated_at
  BEFORE UPDATE ON public.products
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

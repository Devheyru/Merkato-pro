-- Migration: Create homepage_banners and wishlists tables
-- Data model: homepage_banners + wishlists entities from data-model.md

CREATE TABLE IF NOT EXISTS public.homepage_banners (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  title_am TEXT,
  image_url TEXT NOT NULL,
  link_url TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  starts_at TIMESTAMPTZ,
  ends_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.wishlists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (user_id, product_id)
);

-- Enable RLS
ALTER TABLE public.homepage_banners ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlists ENABLE ROW LEVEL SECURITY;

-- Banner RLS: Public read active banners, admin CRUD
CREATE POLICY "banners_select_public" ON public.homepage_banners FOR SELECT
  USING (is_active = TRUE AND (starts_at IS NULL OR starts_at <= now()) AND (ends_at IS NULL OR ends_at >= now()));

CREATE POLICY "banners_all_admin" ON public.homepage_banners FOR ALL
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Wishlist RLS: Users can only access their own wishlist
CREATE POLICY "wishlists_select_own" ON public.wishlists FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "wishlists_insert_own" ON public.wishlists FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "wishlists_delete_own" ON public.wishlists FOR DELETE
  USING (auth.uid() = user_id);

-- Triggers
CREATE TRIGGER banners_updated_at BEFORE UPDATE ON public.homepage_banners
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

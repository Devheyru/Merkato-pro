-- Migration: Create categories table (hierarchical)
-- Data model: categories entity from data-model.md

CREATE TABLE IF NOT EXISTS public.categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  name_am TEXT,
  slug TEXT UNIQUE NOT NULL,
  parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
  icon_url TEXT,
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_categories_parent_id ON public.categories(parent_id);
CREATE INDEX idx_categories_slug ON public.categories(slug);
CREATE INDEX idx_categories_is_active ON public.categories(is_active);
CREATE INDEX idx_categories_display_order ON public.categories(display_order);

-- Enable RLS
ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;

-- Public can read active categories
CREATE POLICY "categories_select_public"
  ON public.categories FOR SELECT
  USING (is_active = TRUE);

-- Admins can CRUD all categories
CREATE POLICY "categories_all_admin"
  ON public.categories FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Trigger
CREATE TRIGGER categories_updated_at
  BEFORE UPDATE ON public.categories
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

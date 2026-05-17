-- Migration: Create carts and cart_items tables
-- Data model: carts + cart_items entities from data-model.md

CREATE TABLE IF NOT EXISTS public.carts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.cart_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  variant JSONB,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE (cart_id, product_id, variant)
);

-- Indexes
CREATE INDEX idx_cart_items_cart_id ON public.cart_items(cart_id);
CREATE INDEX idx_cart_items_product_id ON public.cart_items(product_id);

-- Enable RLS
ALTER TABLE public.carts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

-- Cart RLS: Users can only access their own cart
CREATE POLICY "carts_select_own" ON public.carts FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "carts_insert_own" ON public.carts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "carts_update_own" ON public.carts FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "carts_delete_own" ON public.carts FOR DELETE USING (auth.uid() = user_id);

-- Cart items RLS: Users can only access items in their own cart
CREATE POLICY "cart_items_select_own" ON public.cart_items FOR SELECT
  USING (cart_id IN (SELECT id FROM public.carts WHERE user_id = auth.uid()));
CREATE POLICY "cart_items_insert_own" ON public.cart_items FOR INSERT
  WITH CHECK (cart_id IN (SELECT id FROM public.carts WHERE user_id = auth.uid()));
CREATE POLICY "cart_items_update_own" ON public.cart_items FOR UPDATE
  USING (cart_id IN (SELECT id FROM public.carts WHERE user_id = auth.uid()));
CREATE POLICY "cart_items_delete_own" ON public.cart_items FOR DELETE
  USING (cart_id IN (SELECT id FROM public.carts WHERE user_id = auth.uid()));

-- Triggers
CREATE TRIGGER carts_updated_at BEFORE UPDATE ON public.carts
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER cart_items_updated_at BEFORE UPDATE ON public.cart_items
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

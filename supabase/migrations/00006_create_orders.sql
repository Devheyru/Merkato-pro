-- Migration: Create orders and order_items tables
-- Data model: orders + order_items entities from data-model.md

CREATE TABLE IF NOT EXISTS public.orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID NOT NULL REFERENCES public.users(id) ON DELETE RESTRICT,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'in_transit', 'delivered', 'cancelled', 'refund_requested', 'refunded')),
  total_amount DECIMAL(12,2) NOT NULL,
  currency TEXT NOT NULL CHECK (currency IN ('ETB', 'KES')),
  delivery_address JSONB NOT NULL,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('telebirr', 'mpesa')),
  payment_reference TEXT,
  notes TEXT,
  estimated_delivery TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE RESTRICT,
  vendor_id UUID NOT NULL REFERENCES public.vendors(id) ON DELETE RESTRICT,
  variant JSONB,
  quantity INTEGER NOT NULL CHECK (quantity > 0),
  unit_price DECIMAL(12,2) NOT NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  vendor_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (vendor_status IN ('pending', 'accepted', 'rejected', 'processing', 'shipped')),
  delivery_agent_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_orders_customer_id ON public.orders(customer_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX idx_orders_deleted_at ON public.orders(deleted_at);
CREATE INDEX idx_orders_payment_method ON public.orders(payment_method);

CREATE INDEX idx_order_items_order_id ON public.order_items(order_id);
CREATE INDEX idx_order_items_vendor_id ON public.order_items(vendor_id);
CREATE INDEX idx_order_items_product_id ON public.order_items(product_id);
CREATE INDEX idx_order_items_delivery_agent_id ON public.order_items(delivery_agent_id);
CREATE INDEX idx_order_items_vendor_status ON public.order_items(vendor_status);

-- Enable RLS
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.order_items ENABLE ROW LEVEL SECURITY;

-- Orders RLS
CREATE POLICY "orders_select_customer" ON public.orders FOR SELECT
  USING (auth.uid() = customer_id);

CREATE POLICY "orders_select_vendor" ON public.orders FOR SELECT
  USING (
    id IN (
      SELECT oi.order_id FROM public.order_items oi
      JOIN public.vendors v ON v.id = oi.vendor_id
      WHERE v.user_id = auth.uid()
    )
  );

CREATE POLICY "orders_select_delivery_agent" ON public.orders FOR SELECT
  USING (
    id IN (
      SELECT oi.order_id FROM public.order_items oi
      WHERE oi.delivery_agent_id = auth.uid()
    )
  );

CREATE POLICY "orders_select_admin" ON public.orders FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "orders_update_admin" ON public.orders FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "orders_insert_customer" ON public.orders FOR INSERT
  WITH CHECK (auth.uid() = customer_id);

-- Order items RLS
CREATE POLICY "order_items_select_customer" ON public.order_items FOR SELECT
  USING (order_id IN (SELECT id FROM public.orders WHERE customer_id = auth.uid()));

CREATE POLICY "order_items_select_vendor" ON public.order_items FOR SELECT
  USING (vendor_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid()));

CREATE POLICY "order_items_update_vendor" ON public.order_items FOR UPDATE
  USING (vendor_id IN (SELECT id FROM public.vendors WHERE user_id = auth.uid()));

CREATE POLICY "order_items_select_delivery_agent" ON public.order_items FOR SELECT
  USING (delivery_agent_id = auth.uid());

CREATE POLICY "order_items_update_delivery_agent" ON public.order_items FOR UPDATE
  USING (delivery_agent_id = auth.uid());

CREATE POLICY "order_items_select_admin" ON public.order_items FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "order_items_update_admin" ON public.order_items FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "order_items_insert_system" ON public.order_items FOR INSERT
  WITH CHECK (
    order_id IN (SELECT id FROM public.orders WHERE customer_id = auth.uid())
  );

-- Triggers
CREATE TRIGGER orders_updated_at BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
CREATE TRIGGER order_items_updated_at BEFORE UPDATE ON public.order_items
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

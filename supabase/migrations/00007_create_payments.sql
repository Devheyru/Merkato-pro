-- Migration: Create payments table
-- Data model: payments entity from data-model.md

CREATE TABLE IF NOT EXISTS public.payments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE RESTRICT,
  gateway TEXT NOT NULL CHECK (gateway IN ('telebirr', 'mpesa')),
  transaction_ref TEXT UNIQUE,
  idempotency_key TEXT UNIQUE NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  currency TEXT NOT NULL CHECK (currency IN ('ETB', 'KES')),
  status TEXT NOT NULL DEFAULT 'initiated'
    CHECK (status IN ('initiated', 'pending', 'completed', 'failed', 'refunded')),
  gateway_response JSONB,
  webhook_received_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_payments_order_id ON public.payments(order_id);
CREATE INDEX idx_payments_transaction_ref ON public.payments(transaction_ref);
CREATE INDEX idx_payments_idempotency_key ON public.payments(idempotency_key);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_payments_gateway ON public.payments(gateway);

-- Enable RLS
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

-- Customers can read payments for their orders
CREATE POLICY "payments_select_customer" ON public.payments FOR SELECT
  USING (
    order_id IN (SELECT id FROM public.orders WHERE customer_id = auth.uid())
  );

-- Admins can read all payments
CREATE POLICY "payments_select_admin" ON public.payments FOR SELECT
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- No direct user updates (Edge Functions only via service role)

-- Trigger
CREATE TRIGGER payments_updated_at BEFORE UPDATE ON public.payments
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

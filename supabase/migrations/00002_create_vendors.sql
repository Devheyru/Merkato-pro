-- Migration: Create vendors table
-- Data model: vendors entity from data-model.md

CREATE TABLE IF NOT EXISTS public.vendors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  store_name TEXT NOT NULL,
  store_slug TEXT UNIQUE NOT NULL,
  description TEXT,
  logo_url TEXT,
  banner_url TEXT,
  approval_status TEXT NOT NULL DEFAULT 'pending'
    CHECK (approval_status IN ('pending', 'approved', 'rejected', 'suspended')),
  commission_rate DECIMAL(5,2) DEFAULT 5.00,
  deleted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes
CREATE INDEX idx_vendors_user_id ON public.vendors(user_id);
CREATE INDEX idx_vendors_approval_status ON public.vendors(approval_status);
CREATE INDEX idx_vendors_store_slug ON public.vendors(store_slug);
CREATE INDEX idx_vendors_deleted_at ON public.vendors(deleted_at);

-- Enable RLS
ALTER TABLE public.vendors ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "vendors_select_own"
  ON public.vendors FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "vendors_update_own"
  ON public.vendors FOR UPDATE
  USING (auth.uid() = user_id AND deleted_at IS NULL);

CREATE POLICY "vendors_select_approved"
  ON public.vendors FOR SELECT
  USING (approval_status = 'approved' AND deleted_at IS NULL);

CREATE POLICY "vendors_select_admin"
  ON public.vendors FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "vendors_update_admin"
  ON public.vendors FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM public.users
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "vendors_insert_own"
  ON public.vendors FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Trigger
CREATE TRIGGER vendors_updated_at
  BEFORE UPDATE ON public.vendors
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at();

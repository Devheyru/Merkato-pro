-- Migration: Create platform_settings table
-- Data model: platform_settings entity from data-model.md

CREATE TABLE IF NOT EXISTS public.platform_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  updated_by UUID REFERENCES public.users(id) ON DELETE SET NULL,
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.platform_settings ENABLE ROW LEVEL SECURITY;

-- Public read
CREATE POLICY "platform_settings_select_public" ON public.platform_settings FOR SELECT
  USING (TRUE);

-- Admin update
CREATE POLICY "platform_settings_update_admin" ON public.platform_settings FOR UPDATE
  USING (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

CREATE POLICY "platform_settings_insert_admin" ON public.platform_settings FOR INSERT
  WITH CHECK (EXISTS (SELECT 1 FROM public.users WHERE id = auth.uid() AND role = 'admin'));

-- Trigger
CREATE TRIGGER platform_settings_updated_at BEFORE UPDATE ON public.platform_settings
  FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

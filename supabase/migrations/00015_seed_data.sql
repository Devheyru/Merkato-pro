-- Migration: Create seed data
-- Populates initial categories, admin user settings, and sample platform config

-- Insert default platform settings
INSERT INTO public.platform_settings (key, value) VALUES
  ('default_commission_rate', '5.00'::jsonb),
  ('supported_currencies', '["ETB", "KES"]'::jsonb),
  ('maintenance_mode', 'false'::jsonb),
  ('max_upload_size_mb', '10'::jsonb),
  ('supported_languages', '["en", "am"]'::jsonb)
ON CONFLICT (key) DO NOTHING;

-- Insert seed categories
INSERT INTO public.categories (name, name_am, slug, display_order, is_active) VALUES
  ('Electronics', 'ኤሌክትሮኒክስ', 'electronics', 1, TRUE),
  ('Fashion', 'ፋሽን', 'fashion', 2, TRUE),
  ('Food & Beverages', 'ምግብ እና መጠጥ', 'food-beverages', 3, TRUE),
  ('Home & Garden', 'ቤት እና አትክልት', 'home-garden', 4, TRUE),
  ('Health & Beauty', 'ጤና እና ውበት', 'health-beauty', 5, TRUE),
  ('Sports & Outdoors', 'ስፖርት', 'sports-outdoors', 6, TRUE),
  ('Books & Stationery', 'መጽሐፍት', 'books-stationery', 7, TRUE),
  ('Automotive', 'አውቶሞቲቭ', 'automotive', 8, TRUE),
  ('Baby & Kids', 'ሕፃናት', 'baby-kids', 9, TRUE),
  ('Handmade & Crafts', 'የእጅ ስራ', 'handmade-crafts', 10, TRUE)
ON CONFLICT (slug) DO NOTHING;

-- Insert subcategories for Electronics
INSERT INTO public.categories (name, name_am, slug, parent_id, display_order, is_active)
SELECT name, name_am, slug, parent.id, display_order, TRUE
FROM (VALUES
  ('Phones & Tablets', 'ስልክ እና ታብሌት', 'phones-tablets', 1),
  ('Computers & Laptops', 'ኮምፒውተር', 'computers-laptops', 2),
  ('Audio & Headphones', 'ኦዲዮ', 'audio-headphones', 3),
  ('Accessories', 'ተጨማሪ እቃዎች', 'electronics-accessories', 4)
) AS sub(name, name_am, slug, display_order)
CROSS JOIN (SELECT id FROM public.categories WHERE slug = 'electronics') AS parent
ON CONFLICT (slug) DO NOTHING;

-- Insert subcategories for Fashion
INSERT INTO public.categories (name, name_am, slug, parent_id, display_order, is_active)
SELECT name, name_am, slug, parent.id, display_order, TRUE
FROM (VALUES
  ('Men''s Clothing', 'የወንዶች ልብስ', 'mens-clothing', 1),
  ('Women''s Clothing', 'የሴቶች ልብስ', 'womens-clothing', 2),
  ('Shoes', 'ጫማ', 'shoes', 3),
  ('Jewelry', 'ጌጣጌጥ', 'jewelry', 4),
  ('Traditional Wear', 'ባህላዊ ልብስ', 'traditional-wear', 5)
) AS sub(name, name_am, slug, display_order)
CROSS JOIN (SELECT id FROM public.categories WHERE slug = 'fashion') AS parent
ON CONFLICT (slug) DO NOTHING;

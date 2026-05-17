import { createBrowserClient } from "@supabase/ssr";

/**
 * Create a Supabase client for use in browser (Client Components).
 * This client respects RLS policies based on the user's auth session.
 */
export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );
}

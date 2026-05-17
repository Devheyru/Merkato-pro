import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

/**
 * Authenticated user context extracted from the JWT.
 */
export interface AuthUser {
  id: string;
  email: string;
  role: string;
}

/**
 * Create a Supabase client scoped to the requesting user's JWT.
 * This ensures RLS policies are enforced for the user.
 */
export function createUserClient(req: Request) {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY")!;
  const authHeader = req.headers.get("Authorization");

  return createClient(supabaseUrl, supabaseAnonKey, {
    global: {
      headers: authHeader ? { Authorization: authHeader } : {},
    },
  });
}

/**
 * Create a Supabase admin client with service role key.
 * Bypasses RLS — use only for internal operations.
 */
export function createAdminClient() {
  const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}

/**
 * Extract and verify the authenticated user from the request.
 * Returns null if no valid auth token is present.
 */
export async function getAuthUser(req: Request): Promise<AuthUser | null> {
  const client = createUserClient(req);
  const {
    data: { user },
    error,
  } = await client.auth.getUser();

  if (error || !user) {
    return null;
  }

  // Fetch user role from public.users table
  const { data: profile } = await client
    .from("users")
    .select("role")
    .eq("id", user.id)
    .single();

  return {
    id: user.id,
    email: user.email ?? "",
    role: profile?.role ?? "customer",
  };
}

/**
 * Require authentication — returns the user or throws.
 */
export async function requireAuth(req: Request): Promise<AuthUser> {
  const user = await getAuthUser(req);
  if (!user) {
    throw new Error("UNAUTHORIZED");
  }
  return user;
}

/**
 * Require a specific role — returns the user or throws.
 */
export async function requireRole(
  req: Request,
  ...roles: string[]
): Promise<AuthUser> {
  const user = await requireAuth(req);
  if (!roles.includes(user.role)) {
    throw new Error("FORBIDDEN");
  }
  return user;
}

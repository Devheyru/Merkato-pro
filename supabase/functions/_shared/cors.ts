/**
 * CORS headers for Supabase Edge Functions.
 * Applied to all Edge Function responses to allow cross-origin requests
 * from the web and mobile clients.
 */
export const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
};

/**
 * Handle CORS preflight (OPTIONS) requests.
 * Call this at the top of every Edge Function to handle browser preflight.
 */
export function handleCors(req: Request): Response | null {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  return null;
}

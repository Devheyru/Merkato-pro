import { corsHeaders } from "./cors.ts";

/**
 * Standard API response envelope as defined in api-contracts.md.
 * All Edge Functions MUST use these helpers for consistency.
 */

interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
}

interface ApiResponse<T = unknown> {
  success: boolean;
  data: T | null;
  error: ApiError | null;
}

/**
 * Send a successful JSON response.
 */
export function success<T>(data: T, status = 200): Response {
  const body: ApiResponse<T> = {
    success: true,
    data,
    error: null,
  };
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/**
 * Send an error JSON response.
 */
export function error(
  code: string,
  message: string,
  status = 400,
  details?: Record<string, unknown>
): Response {
  const body: ApiResponse = {
    success: false,
    data: null,
    error: { code, message, details },
  };
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

/** Common error shortcuts */
export const errors = {
  unauthorized: (msg = "Authentication required") =>
    error("UNAUTHORIZED", msg, 401),
  forbidden: (msg = "Insufficient permissions") =>
    error("FORBIDDEN", msg, 403),
  notFound: (msg = "Resource not found") =>
    error("NOT_FOUND", msg, 404),
  validation: (msg: string, details?: Record<string, unknown>) =>
    error("VALIDATION_ERROR", msg, 400, details),
  conflict: (msg: string) =>
    error("CONFLICT", msg, 409),
  rateLimited: (msg = "Too many requests") =>
    error("RATE_LIMITED", msg, 429),
  internal: (msg = "Internal server error") =>
    error("INTERNAL_ERROR", msg, 500),
};

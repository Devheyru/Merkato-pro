/**
 * Structured logger for Edge Functions.
 * Constitution mandates structured logging with request ID, timestamp,
 * severity, and context for all Edge Function invocations.
 */

type LogLevel = "DEBUG" | "INFO" | "WARN" | "ERROR";

interface LogEntry {
  timestamp: string;
  level: LogLevel;
  requestId: string;
  function: string;
  message: string;
  context?: Record<string, unknown>;
  error?: string;
  stack?: string;
}

/**
 * Create a logger scoped to a specific Edge Function and request.
 */
export function createLogger(functionName: string, requestId?: string) {
  const reqId = requestId ?? crypto.randomUUID();

  function log(
    level: LogLevel,
    message: string,
    context?: Record<string, unknown>
  ): void {
    const entry: LogEntry = {
      timestamp: new Date().toISOString(),
      level,
      requestId: reqId,
      function: functionName,
      message,
      context,
    };
    // Use console methods so Supabase can capture them
    switch (level) {
      case "DEBUG":
        console.debug(JSON.stringify(entry));
        break;
      case "INFO":
        console.info(JSON.stringify(entry));
        break;
      case "WARN":
        console.warn(JSON.stringify(entry));
        break;
      case "ERROR":
        console.error(JSON.stringify(entry));
        break;
    }
  }

  return {
    requestId: reqId,
    debug: (msg: string, ctx?: Record<string, unknown>) =>
      log("DEBUG", msg, ctx),
    info: (msg: string, ctx?: Record<string, unknown>) =>
      log("INFO", msg, ctx),
    warn: (msg: string, ctx?: Record<string, unknown>) =>
      log("WARN", msg, ctx),
    error: (msg: string, err?: Error, ctx?: Record<string, unknown>) => {
      const entry: LogEntry = {
        timestamp: new Date().toISOString(),
        level: "ERROR",
        requestId: reqId,
        function: functionName,
        message: msg,
        context: ctx,
        error: err?.message,
        stack: err?.stack,
      };
      console.error(JSON.stringify(entry));
    },
  };
}

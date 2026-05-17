import { handleCors } from "../_shared/cors.ts";
import { success, errors } from "../_shared/response.ts";
import { createAdminClient } from "../_shared/auth.ts";
import { createLogger } from "../_shared/logger.ts";

Deno.serve(async (req) => {
  const corsResponse = handleCors(req);
  if (corsResponse) return corsResponse;

  const logger = createLogger("register-vendor");
  logger.info("Vendor registration request received");

  if (req.method !== "POST") {
    return errors.validation("Method not allowed");
  }

  try {
    const body = await req.json();
    const { email, password, full_name, phone, store_name, store_description } = body;

    // Validate required fields
    if (!email || !password || !full_name || !store_name) {
      return errors.validation("Missing required fields", {
        required: ["email", "password", "full_name", "store_name"],
      });
    }

    if (password.length < 8) {
      return errors.validation("Password must be at least 8 characters");
    }

    const adminClient = createAdminClient();

    // Create user via Supabase Auth
    const { data: authData, error: authError } = await adminClient.auth.admin.createUser({
      email,
      password,
      email_confirm: false,
      user_metadata: { full_name, phone, role: "vendor" },
    });

    if (authError) {
      logger.error("Auth user creation failed", authError);
      if (authError.message.includes("already")) {
        return errors.conflict("A user with this email already exists");
      }
      return errors.internal(authError.message);
    }

    const userId = authData.user.id;

    // Generate store slug
    const slug = store_name
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-|-$/g, "");

    // Create vendor record
    const { data: vendor, error: vendorError } = await adminClient
      .from("vendors")
      .insert({
        user_id: userId,
        store_name,
        store_slug: `${slug}-${userId.slice(0, 8)}`,
        description: store_description || null,
        approval_status: "pending",
      })
      .select()
      .single();

    if (vendorError) {
      logger.error("Vendor record creation failed", vendorError);
      // Cleanup: delete the auth user if vendor creation fails
      await adminClient.auth.admin.deleteUser(userId);
      return errors.internal("Failed to create vendor profile");
    }

    logger.info("Vendor registered successfully", { userId, vendorId: vendor.id });

    return success({
      user_id: userId,
      vendor_id: vendor.id,
      approval_status: "pending",
      message: "Vendor application submitted. Awaiting admin approval.",
    }, 201);
  } catch (err) {
    logger.error("Unexpected error", err as Error);
    return errors.internal();
  }
});

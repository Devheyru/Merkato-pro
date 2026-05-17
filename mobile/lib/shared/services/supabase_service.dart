import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:merkato_mobile/core/config/env.dart';

/// Supabase service singleton.
/// Provides centralized access to all Supabase services:
/// Auth, Database, Storage, Realtime, and Edge Functions.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  /// Initialize the Supabase client. Call once in main().
  static Future<void> initialize() async {
    if (_initialized) return;

    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );

    _initialized = true;
  }

  /// The Supabase client instance.
  static SupabaseClient get client => Supabase.instance.client;

  /// Shortcut to the Auth client.
  static GoTrueClient get auth => client.auth;

  /// The current authenticated user, if any.
  static User? get currentUser => auth.currentUser;

  /// The current session, if any.
  static Session? get currentSession => auth.currentSession;

  /// Stream of auth state changes.
  static Stream<AuthState> get authStateChanges => auth.onAuthStateChange;

  /// Check if the user is currently authenticated.
  static bool get isAuthenticated => currentUser != null;

  /// Invoke a Supabase Edge Function.
  static Future<FunctionResponse> invokeFunction(
    String functionName, {
    Map<String, String>? headers,
    Map<String, dynamic>? body,
    HttpMethod method = HttpMethod.post,
  }) async {
    return client.functions.invoke(
      functionName,
      headers: headers,
      body: body,
      method: method,
    );
  }
}

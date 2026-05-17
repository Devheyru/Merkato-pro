/// Merkato-pro environment configuration.
/// Values are set per-environment and referenced throughout the app.
class Env {
  /// Supabase project URL
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project.supabase.co',
  );

  /// Supabase anonymous (public) key
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );

  /// Default locale
  static const String defaultLocale = 'en';

  /// Supported locales
  static const List<String> supportedLocales = ['en', 'am'];
}

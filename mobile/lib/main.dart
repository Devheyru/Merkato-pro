import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'shared/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await SupabaseService.initialize();

  runApp(
    const ProviderScope(
      child: MerkatoApp(),
    ),
  );
}

/// Root widget for the Merkato mobile application.
class MerkatoApp extends ConsumerWidget {
  const MerkatoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Merkato',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,

      // Routing
      routerConfig: router,

      // Localization
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      locale: const Locale(Env.defaultLocale),
    );
  }
}

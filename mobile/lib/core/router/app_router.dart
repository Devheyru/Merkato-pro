import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:merkato_mobile/features/auth/providers/auth_provider.dart';
import 'package:merkato_mobile/features/auth/screens/login_screen.dart';
import 'package:merkato_mobile/features/auth/screens/register_screen.dart';

/// GoRouter configuration with auth-aware route guards.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';
      final isProtectedRoute = state.matchedLocation.startsWith('/checkout') ||
          state.matchedLocation.startsWith('/orders') ||
          state.matchedLocation.startsWith('/account') ||
          state.matchedLocation.startsWith('/vendor');

      // Still loading auth state — don't redirect
      if (isLoading) return null;

      // Redirect logged-in users away from auth pages
      if (isLoggedIn && isAuthRoute) return '/';

      // Redirect unauthenticated users to login for protected routes
      if (!isLoggedIn && isProtectedRoute) return '/login';

      // Vendor route guard
      if (isLoggedIn &&
          state.matchedLocation.startsWith('/vendor') &&
          authState.profile?.role.value != 'vendor' &&
          authState.profile?.role.value != 'admin') {
        return '/';
      }

      return null;
    },
    routes: [
      // ── Main Shell (Bottom Navigation) ─────────────────────
      ShellRoute(
        builder: (context, state, child) => _MainShell(child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: (_, __) => const _PlaceholderScreen(title: 'Home')),
          GoRoute(path: '/categories', name: 'categories', builder: (_, __) => const _PlaceholderScreen(title: 'Categories')),
          GoRoute(path: '/cart', name: 'cart', builder: (_, __) => const _PlaceholderScreen(title: 'Cart')),
          GoRoute(
            path: '/account', name: 'account',
            builder: (_, __) => const _PlaceholderScreen(title: 'Account'),
            routes: [
              GoRoute(path: 'wishlist', name: 'wishlist', builder: (_, __) => const _PlaceholderScreen(title: 'Wishlist')),
            ],
          ),
        ],
      ),

      // ── Auth Routes ────────────────────────────────────────
      GoRoute(path: '/login', name: 'login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', name: 'register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password', name: 'forgot-password', builder: (_, __) => const _PlaceholderScreen(title: 'Forgot Password')),

      // ── Product Routes ─────────────────────────────────────
      GoRoute(path: '/products', name: 'products', builder: (_, __) => const _PlaceholderScreen(title: 'Products')),
      GoRoute(path: '/products/:id', name: 'product-detail', builder: (_, state) => _PlaceholderScreen(title: 'Product ${state.pathParameters['id']}')),

      // ── Checkout & Orders ──────────────────────────────────
      GoRoute(path: '/checkout', name: 'checkout', builder: (_, __) => const _PlaceholderScreen(title: 'Checkout')),
      GoRoute(path: '/orders', name: 'orders', builder: (_, __) => const _PlaceholderScreen(title: 'Orders')),
      GoRoute(path: '/orders/:id', name: 'order-detail', builder: (_, state) => _PlaceholderScreen(title: 'Order ${state.pathParameters['id']}')),

      // ── Vendor Routes (role-gated) ─────────────────────────
      GoRoute(path: '/vendor', name: 'vendor-dashboard', builder: (_, __) => const _PlaceholderScreen(title: 'Vendor Dashboard')),

      // ── Settings ──────────────────────────────────────────
      GoRoute(path: '/settings', name: 'settings', builder: (_, __) => const _PlaceholderScreen(title: 'Settings')),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page not found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            TextButton(onPressed: () => context.go('/'), child: const Text('Go Home')),
          ],
        ),
      ),
    ),
  );
});

/// Main shell with bottom navigation bar.
class _MainShell extends StatelessWidget {
  const _MainShell({required this.child});
  final Widget child;

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/categories')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/account')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'Cart'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Account'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0: context.go('/');
            case 1: context.go('/categories');
            case 2: context.go('/cart');
            case 3: context.go('/account');
          }
        },
      ),
    );
  }
}

/// Placeholder screen — replaced by actual feature screens incrementally.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title, style: Theme.of(context).textTheme.headlineMedium)),
    );
  }
}

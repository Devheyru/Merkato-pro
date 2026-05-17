import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:merkato_mobile/shared/services/supabase_service.dart';
import 'package:merkato_mobile/shared/models/models.dart';
import 'package:merkato_mobile/shared/models/enums.dart';

/// Auth state — tracks current session and user profile.
class AuthState {
  final Session? session;
  final UserModel? profile;
  final bool isLoading;

  const AuthState({this.session, this.profile, this.isLoading = false});

  bool get isAuthenticated => session != null;
  bool get isAdmin => profile?.role == UserRole.admin;
  bool get isVendor => profile?.role == UserRole.vendor;

  AuthState copyWith({Session? session, UserModel? profile, bool? isLoading}) {
    return AuthState(
      session: session ?? this.session,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Auth notifier managing session lifecycle.
class AuthNotifier extends StateNotifier<AuthState> {
  StreamSubscription<AuthState>? _authSub;

  AuthNotifier() : super(const AuthState(isLoading: true)) {
    _init();
  }

  void _init() {
    // Check current session
    final session = SupabaseService.currentSession;
    if (session != null) {
      _loadProfile(session);
    } else {
      state = const AuthState(isLoading: false);
    }

    // Listen for auth changes
    SupabaseService.authStateChanges.listen((authState) {
      final session = authState.session;
      if (session != null) {
        _loadProfile(session);
      } else {
        state = const AuthState(isLoading: false);
      }
    });
  }

  Future<void> _loadProfile(Session session) async {
    try {
      final response = await SupabaseService.client
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();

      state = AuthState(
        session: session,
        profile: UserModel.fromJson(response),
        isLoading: false,
      );
    } catch (_) {
      state = AuthState(session: session, isLoading: false);
    }
  }

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
    state = const AuthState(isLoading: false);
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }
}

/// Global auth state provider.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Convenience provider for checking if user is authenticated.
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

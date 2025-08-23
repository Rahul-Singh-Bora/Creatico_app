import 'dart:async';
import 'package:creatico/features/auth/models/user_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription<AuthState>? _authSub;

  /// Check current user
  UserModel? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      return UserModel(
        id: user.id,
        email: user.email ?? '',
      );
    }
    return null;
  }

  /// Google Sign In
  Future<UserModel?> signInWithGoogle() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.flutter://login-callback/',
      );

      final user = _supabase.auth.currentUser;
      if (user != null) {
        return UserModel(
          id: user.id,
          email: user.email ?? '',
        );
      }
      return null;
    } catch (e) {
      throw Exception("Google Sign-In failed: $e");
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// 🔥 Listen to auth changes
  void listenToAuthChanges(void Function(UserModel? user) onChange) {
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      final user = session?.user;
      if (user != null) {
        onChange(UserModel(id: user.id, email: user.email ?? ''));
      } else {
        onChange(null);
      }
    });
  }

  /// Cleanup
  void dispose() {
    _authSub?.cancel();
  }
}

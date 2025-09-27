// lib/services/user_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  static final _supabase = Supabase.instance.client;

  // ===== Current user =====
  static User? get currentUser => _supabase.auth.currentUser;

  static bool isLoggedIn() => _supabase.auth.currentUser != null;

  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // ===== Authenticate (Login) =====
  static Future<User?> authenticate(String email, String password) async {
    try {
      final res = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      return res.user; // returns Supabase user on success
    } catch (e) {
      return null; // return null if auth fails
    }
  }

  // ===== Register new user =====
  static Future<User?> register(String email, String password) async {
    try {
      final res = await _supabase.auth.signUp(
        email: email,
        password: password,
      );
      return res.user;
    } catch (e) {
      return null;
    }
  }

  // ===== Helpers =====
  static String get currentUserId => _supabase.auth.currentUser?.id ?? '';

  static String get currentUserEmail =>
      _supabase.auth.currentUser?.email ?? '';

  static Map<String, dynamic> get currentUserMetadata =>
      _supabase.auth.currentUser?.userMetadata ?? {};
}

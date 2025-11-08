import 'package:flutter/material.dart';
import '../../../authentication/data/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // 🧠 EMAIL SIGNUP
  // ---------------------------------------------------------------------------
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      final user = await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      _clearError();
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 🔑 EMAIL LOGIN
  // ---------------------------------------------------------------------------
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      _clearError();
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 🟢 GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------
  Future<User?> signInWithGoogle() async {
    try {
      _setLoading(true);
      final user = await _authService.signInWithGoogle();
      _clearError();
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 👤 ANONYMOUS SIGN-IN
  // ---------------------------------------------------------------------------
  Future<User?> signInAnonymously() async {
    try {
      _setLoading(true);
      final user = await _authService.signInAnonymously();
      _clearError();
      return user;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 🚪 SIGN OUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('Sign out failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔍 GET ROLE
  // ---------------------------------------------------------------------------
  Future<String?> getCurrentUserRole() async {
    return await _authService.getCurrentUserRole();
  }

  // ---------------------------------------------------------------------------
  // ⚙️ INTERNAL STATE HELPERS
  // ---------------------------------------------------------------------------
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

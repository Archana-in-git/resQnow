import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../authentication/data/services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ---------------------------------------------------------------------------
  // 🧾 AUTH STATE (CRITICAL FOR ROUTER)
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // ---------------------------------------------------------------------------
  // 🧠 EMAIL SIGNUP
  // ---------------------------------------------------------------------------
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      return await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
    }, defaultError: 'Signup failed');
  }

  // ---------------------------------------------------------------------------
  // 🔑 EMAIL LOGIN
  // ---------------------------------------------------------------------------
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    return _runAuthAction(() async {
      return await _authService.loginWithEmail(
        email: email,
        password: password,
      );
    }, defaultError: 'Login failed');
  }

  // ---------------------------------------------------------------------------
  // 🔐 PASSWORD RESET
  // ---------------------------------------------------------------------------
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _authService.sendPasswordResetEmail(email);
      _clearError();
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? 'Failed to send reset email');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // 🟢 GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------
  Future<User?> signInWithGoogle() async {
    return _runAuthAction(() async {
      return await _authService.signInWithGoogle();
    }, defaultError: 'Google sign-in failed');
  }

  // ---------------------------------------------------------------------------
  // 👤 ANONYMOUS SIGN-IN
  // ---------------------------------------------------------------------------
  Future<User?> signInAnonymously() async {
    return _runAuthAction(() async {
      return await _authService.signInAnonymously();
    }, defaultError: 'Guest login failed');
  }

  // ---------------------------------------------------------------------------
  // 🚪 SIGN OUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners(); // ✅ force router & UI refresh
  }

  // ---------------------------------------------------------------------------
  // 🔍 ROLE
  // ---------------------------------------------------------------------------
  Future<String?> getCurrentUserRole() async {
    return _authService.getCurrentUserRole();
  }

  // ---------------------------------------------------------------------------
  // ⚙️ SHARED AUTH HANDLER
  // ---------------------------------------------------------------------------
  Future<User?> _runAuthAction(
    Future<User?> Function() action, {
    required String defaultError,
  }) async {
    _setLoading(true);
    try {
      final user = await action();
      _clearError();
      return user;
    } on FirebaseAuthException catch (e) {
      _setError(e.message ?? defaultError);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ---------------------------------------------------------------------------
  // ⚙️ STATE HELPERS
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

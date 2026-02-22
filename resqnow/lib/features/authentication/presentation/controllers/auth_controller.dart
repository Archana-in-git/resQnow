import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../authentication/data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<DocumentSnapshot>? _suspensionListener;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Initialize real-time suspension monitoring
  void initializeSuspensionMonitoring() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Listen to user document changes for suspension status
    _suspensionListener = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        // User Firestore document was deleted
        // Check if email is in blocked_emails to confirm it's a proper deletion
        if (user.email != null) {
          _firestore
              .collection('blocked_emails')
              .doc(user.email!)
              .get()
              .then((blockedDoc) {
            if (blockedDoc.exists) {
              // User was properly deleted - sign out
              print('DEBUG: User doc deleted and email in blocked_emails, signing out');
              _authService.signOut();
              notifyListeners();
            } else {
              // Document missing but email not blocked - could be data sync issue
              print('DEBUG: User doc missing but email not blocked, staying logged in');
            }
          }).catchError((e) {
            print('DEBUG: Error checking blocked_emails: $e');
          });
        }
        return;
      }

      // Use safe field access - don't use snapshot.get() as it throws if field doesn't exist
      final data = snapshot.data() ?? {};
      final accountStatus = data['accountStatus'] as String? ?? 'active';
      final isBlocked = data['isBlocked'] as bool? ?? false;

      print('DEBUG: Suspension check - accountStatus=$accountStatus, isBlocked=$isBlocked');

      // Only respect isBlocked if accountStatus is explicitly NOT 'active'
      // This prevents stale isBlocked flags from old test data
      final isSuspended =
          accountStatus == 'suspended' || (isBlocked && accountStatus != 'active');

      // If user becomes suspended, sign them out
      if (isSuspended) {
        print('DEBUG: User is suspended/blocked, signing out');
        _authService.signOut();
        notifyListeners();
      }
    }, onError: (error) {
      // Silently ignore errors - if we can't read the field, assume user is active
      print('Suspension monitoring error (non-critical): $error');
    });
  }

  /// Stop monitoring suspension status
  void disposeSuspensionMonitoring() {
    _suspensionListener?.cancel();
    _suspensionListener = null;
  }

  @override
  void dispose() {
    disposeSuspensionMonitoring();
    super.dispose();
  }

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
      final user = await _authService.signUpWithEmail(
        name: name,
        email: email,
        password: password,
      );
      if (user != null) {
        // ✅ Start monitoring for suspension changes after successful signup
        initializeSuspensionMonitoring();
      }
      return user;
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
      final user = await _authService.loginWithEmail(
        email: email,
        password: password,
      );
      if (user != null) {
        // ✅ Start monitoring for suspension changes after successful login
        initializeSuspensionMonitoring();
      }
      return user;
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
  // 🚪 SIGN OUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    disposeSuspensionMonitoring();
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
  // 🔍 SUSPENSION STATUS CHECK
  // ---------------------------------------------------------------------------
  Future<bool> isCurrentUserSuspended() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return false;
      return await _authService.checkIfUserSuspended(user.uid);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getCurrentUserStatusInfo() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return {'exists': false, 'isSuspended': false};
      }
      return await _authService.getCurrentUserStatus(user.uid);
    } catch (e) {
      return {'exists': false, 'isSuspended': false};
    }
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

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'dart:async';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  StreamSubscription<User?>? _authStateSubscription;

  static const String usersCollection = 'users';

  AuthService() {
    _authStateSubscription = _auth.authStateChanges().listen(
      _onAuthStateChanged,
    );
  }

  void _onAuthStateChanged(User? user) {
    if (user == null) return;

    _validateUserCanAccess(user).catchError((error) async {
      if (error is FirebaseAuthException &&
          (error.code == 'user-disabled' || error.code == 'user-not-found')) {
        await _auth.signOut();
      }
    });
  }

  Future<void> _validateUserCanAccess(User user) async {
    HttpsCallableResult<dynamic> result;
    try {
      result = await _functions.httpsCallable('checkUserAccessStatus').call();
    } on FirebaseFunctionsException {
      throw FirebaseAuthException(
        code: 'service-unavailable',
        message:
            'Unable to verify account status right now. Please try again in a moment.',
      );
    }

    final data = result.data as Map<dynamic, dynamic>? ?? {};
    final allowed = data['allowed'] == true;
    final reasonCode = (data['reasonCode'] ?? '').toString();
    final message = (data['message'] ?? '').toString();

    if (!allowed) {
      await _auth.signOut();

      if (reasonCode == 'account-deleted') {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: message.isNotEmpty
              ? message
              : 'No account exists with this email. Please create a new account.',
        );
      }

      throw FirebaseAuthException(
        code: 'user-disabled',
        message: message.isNotEmpty
            ? message
            : 'Login denied: your account is currently suspended for suspicious activities. Please contact support.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 🧠 EMAIL + PASSWORD SIGNUP
  // ---------------------------------------------------------------------------
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // ✅ Check if email is in blocked_emails collection (suspended or deleted)
      final blockedEmailDoc = await _firestore
          .collection('blocked_emails')
          .doc(email.toLowerCase())
          .get();

      if (blockedEmailDoc.exists) {
        final status = blockedEmailDoc.get('status') as String?;
        final reason = blockedEmailDoc.get('reason') as String?;

        if (status == 'deleted') {
          throw FirebaseAuthException(
            code: 'email-deleted',
            message:
                'This email address was previously deleted and cannot be used to create a new account. Please contact support.',
          );
        } else if (status == 'suspended') {
          throw FirebaseAuthException(
            code: 'email-suspended',
            message:
                'This email address is associated with a suspended account. Reason: ${reason ?? "Account suspended"}. Please contact support if you believe this is a mistake.',
          );
        }
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // ✅ Ensure display name exists in FirebaseAuth
        await user.updateDisplayName(name);

        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'user',
          'accountStatus': 'active',
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 🔑 EMAIL + PASSWORD LOGIN
  // ---------------------------------------------------------------------------
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _validateUserCanAccess(user);

        // ✅ Log login session
        await _firestore.collection('user_sessions').doc(user.uid).set({
          'userId': user.uid,
          'email': user.email,
          'loginTime': FieldValue.serverTimestamp(),
          'logoutTime': null,
          'isActive': true,
        }, SetOptions(merge: true));
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Login failed. Please try again.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 🚪 SIGN OUT
  // ---------------------------------------------------------------------------
  Future<void> signOut() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // ✅ Log logout session
        await _firestore.collection('user_sessions').doc(currentUser.uid).set({
          'userId': currentUser.uid,
          'logoutTime': FieldValue.serverTimestamp(),
          'isActive': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      print('Error logging logout: $e');
    }
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // � PASSWORD RESET
  // ---------------------------------------------------------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // �🔍 GET CURRENT USER ROLE
  // ---------------------------------------------------------------------------
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(user.uid)
        .get();
    return snapshot.data()?['role'];
  }

  // ---------------------------------------------------------------------------
  // 🧾 AUTH STATE STREAM
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  void dispose() {
    _authStateSubscription?.cancel();
  }
}

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
      try {
        final blockedEmailDoc = await _firestore
            .collection('blocked_emails')
            .doc(email.toLowerCase())
            .get();

        if (blockedEmailDoc.exists) {
          final data = blockedEmailDoc.data() ?? {};
          final status = data['status'] as String?;
          final reason = data['reason'] as String?;

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
      } catch (e) {
        // If it's a FirebaseAuthException, rethrow it
        if (e is FirebaseAuthException) rethrow;
        // For other Firestore errors, log but continue
        print('Warning: Could not check blocked_emails: $e');
      }

      // Create user in Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        try {
          // ✅ Update display name in Firebase Auth
          await user.updateDisplayName(name);

          // ✅ Create complete user document in Firestore
          await _firestore.collection(usersCollection).doc(user.uid).set({
            'uid': user.uid,
            'name': name,
            'email': email.toLowerCase(),
            'role': 'user',
            'accountStatus': 'active',
            'isBlocked': false,
            'emailVerified': user.emailVerified,
            'profileImage': null,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLogin': null,
            'suspendedAt': null,
            'suspensionReason': null,
          }, SetOptions(merge: true));

          print('DEBUG: User document created successfully: ${user.uid}');
        } catch (e) {
          // If Firestore write fails, delete the auth user
          print('ERROR: Failed to create user document: $e');
          print('ERROR TYPE: ${e.runtimeType}');
          if (e is FirebaseException) {
            print('FIREBASE ERROR CODE: ${e.code}');
            print('FIREBASE ERROR MESSAGE: ${e.message}');
          }
          try {
            await user.delete();
          } catch (_) {}
          throw FirebaseAuthException(
            code: 'firestore-error',
            message:
                'Failed to create user profile. Please try again. Error: ${e.toString()}',
          );
        }
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // Special handling for "email-already-in-use"
      if (e.code == 'email-already-in-use') {
        print(
          'INFO: Email already exists in authentication. Checking if user was reactivated...',
        );

        try {
          // Check if user has an account that might be reactivated
          final userquery = await _firestore
              .collection(usersCollection)
              .where('email', isEqualTo: email.toLowerCase())
              .limit(1)
              .get();

          if (userquery.docs.isNotEmpty) {
            final userData = userquery.docs.first.data();
            final accountStatus = userData['accountStatus'] ?? 'unknown';

            if (accountStatus == 'active') {
              throw FirebaseAuthException(
                code: 'email-already-in-use',
                message:
                    'This email is already registered and active. Please use the Login option instead. If you forgot your password, use "Forgot Password".',
              );
            } else {
              throw FirebaseAuthException(
                code: 'email-already-in-use',
                message:
                    'This email is already registered. Please use the Login option. If you forgot your password, use "Forgot Password".',
              );
            }
          }
        } catch (checkError) {
          if (checkError is FirebaseAuthException) rethrow;
          print('Warning: Could not check existing user: $checkError');
        }
      }
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: 'Signup failed: ${e.toString()}',
      );
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
        // ✅ Ensure user document exists in Firestore
        try {
          final userDoc = await _firestore
              .collection(usersCollection)
              .doc(user.uid)
              .get();

          if (!userDoc.exists) {
            print(
              'DEBUG: User document missing for ${user.uid}, creating it...',
            );
            // Create complete user document if missing
            await _firestore.collection(usersCollection).doc(user.uid).set({
              'uid': user.uid,
              'name': user.displayName ?? 'User',
              'email': user.email?.toLowerCase() ?? email.toLowerCase(),
              'role': 'user',
              'accountStatus': 'active',
              'isBlocked': false,
              'emailVerified': user.emailVerified,
              'profileImage': null,
              'createdAt': FieldValue.serverTimestamp(),
              'lastLogin': null,
              'suspendedAt': null,
              'suspensionReason': null,
            }, SetOptions(merge: true));
          }
        } catch (e) {
          print('WARNING: Could not verify user document: $e');
        }

        // ✅ Validate access status
        try {
          await _validateUserCanAccess(user);
        } catch (e) {
          print('ERROR: Access validation failed: $e');
          rethrow;
        }
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

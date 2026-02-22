import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String usersCollection = 'users';

  // ---------------------------------------------------------------------------
  // 🧠 EMAIL + PASSWORD SIGNUP
  // ---------------------------------------------------------------------------
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.toLowerCase();

      // Check if email is blocked (permanently deleted account)
      // Wrapped in try-catch because user might not have read permission
      try {
        final blockedEmailDoc = await _firestore
            .collection('blocked_emails')
            .doc(normalizedEmail)
            .get();

        if (blockedEmailDoc.exists) {
          throw FirebaseAuthException(
            code: 'email-blocked',
            message:
                'This email was associated with a deleted account and cannot be reused. Please use a different email.',
          );
        }
      } catch (e) {
        // If permission denied or other error, just continue
        // The check is optional and shouldn't block signup
        if (e is! FirebaseAuthException) {
          print('Warning: Could not check blocked emails: $e');
        } else {
          rethrow;
        }
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        // ✅ Ensure display name exists in FirebaseAuth
        await user.updateDisplayName(name);

        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': normalizedEmail,
          'role': 'user',
          'accountStatus': 'active',
          'isBlocked': false,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return user;
    } on FirebaseAuthException catch (e) {
      // If Firebase Auth says email exists, it might be because it's in blocked_emails
      // (though we checked first), so provide helpful message
      if (e.code == 'email-already-in-use') {
        // Double-check blocked_emails in case there was a permission issue before
        try {
          final blockedEmailDoc = await _firestore
              .collection('blocked_emails')
              .doc(email.toLowerCase())
              .get();
          if (blockedEmailDoc.exists) {
            throw FirebaseAuthException(
              code: 'email-blocked',
              message:
                  'This email was associated with a deleted account and cannot be reused. Please use a different email.',
            );
          }
        } catch (e) {
          if (e is FirebaseAuthException && e.code == 'email-blocked') {
            rethrow;
          }
          // Safe to rethrow the original email-already-in-use error
        }
      }
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
        // Check if user is suspended/blocked
        // Wrapped in try-catch because suspension check shouldn't block login
        try {
          print('DEBUG: Checking suspension status for ${user.uid}');
          final isSuspended = await _isUserSuspended(user.uid);
          print('DEBUG: isSuspended=$isSuspended');
          if (isSuspended) {
            print('DEBUG: User is suspended, signing out and throwing error');
            await _auth.signOut();
            throw FirebaseAuthException(
              code: 'user-suspended',
              message: 'Your account has been suspended. Contact support for details.',
            );
          }
          print('DEBUG: User is not suspended, continuing login');
        } catch (e) {
          // If it's already a FirebaseAuthException (suspension error), rethrow it
          if (e is FirebaseAuthException) {
            print('DEBUG: FirebaseAuthException during suspension check, rethrowing');
            rethrow;
          }
          // For any other error, just log it and allow login to proceed
          print('Warning: Could not check suspension status: $e');
        }

        // ✅ Ensure Firestore user doc exists
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'role': 'user',
        }, SetOptions(merge: true));

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
  // 🚫 CHECK IF USER IS SUSPENDED/BLOCKED (PRIVATE)
  // ---------------------------------------------------------------------------
  Future<bool> _isUserSuspended(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        // User Firestore document doesn't exist
        // This could mean: user was deleted (email in blocked_emails) or document is missing
        // Check if email is in blocked_emails to confirm deletion
        final currentUser = _auth.currentUser;
        if (currentUser?.email != null) {
          try {
            final blockedDoc = await _firestore
                .collection('blocked_emails')
                .doc(currentUser!.email!)
                .get();
            if (blockedDoc.exists) {
              print('DEBUG: User deleted (found in blocked_emails), blocking login');
              return true; // User was deleted - block login
            }
          } catch (e) {
            print('DEBUG: Could not check blocked_emails: $e');
          }
        }
        print('DEBUG: User doc missing but not in blocked_emails, allowing login');
        return false; // User doc missing but not deleted - allow login
      }

      // Use safer field access - provide defaults if fields don't exist
      final data = doc.data() ?? {};
      final accountStatus = data['accountStatus'] as String? ?? 'active';
      final isBlocked = data['isBlocked'] as bool? ?? false;

      print('DEBUG: _isUserSuspended - data=$data, accountStatus=$accountStatus, isBlocked=$isBlocked');

      // Only respect isBlocked if accountStatus is explicitly NOT 'active'
      // This prevents stale isBlocked flags from old test data
      return accountStatus == 'suspended' || (isBlocked && accountStatus != 'active');
    } catch (e) {
      // If we can't check, assume user is not suspended
      // This is safer than blocking access
      print('DEBUG: _isUserSuspended - exception: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 🚫 CHECK IF USER IS SUSPENDED/BLOCKED (PUBLIC - for router/UI checks)
  // ---------------------------------------------------------------------------
  Future<bool> checkIfUserSuspended(String uid) async {
    return _isUserSuspended(uid);
  }

  // ---------------------------------------------------------------------------
  // 📊 GET CURRENT USER ACCOUNT STATUS
  // ---------------------------------------------------------------------------
  Future<Map<String, dynamic>> getCurrentUserStatus(String uid) async {
    try {
      final doc = await _firestore
          .collection(usersCollection)
          .doc(uid)
          .get();

      if (!doc.exists) {
        return {
          'exists': false,
          'isSuspended': true,
          'isBlocked': true,
          'accountStatus': 'deleted',
        };
      }

      // Use safer field access - provide defaults if fields don't exist
      final data = doc.data() ?? {};
      final accountStatus = data['accountStatus'] as String? ?? 'active';
      final isBlocked = data['isBlocked'] as bool? ?? false;
      final suspensionReason = data['suspensionReason'] as String? ?? '';

      return {
        'exists': true,
        'isSuspended': accountStatus == 'suspended' || isBlocked,
        'isBlocked': isBlocked,
        'accountStatus': accountStatus,
        'suspensionReason': suspensionReason,
      };
    } catch (e) {
      return {
        'exists': false,
        'isSuspended': false,
        'isBlocked': false,
        'accountStatus': 'error',
      };
    }
  }

  // ---------------------------------------------------------------------------
  // 🧾 AUTH STATE STREAM
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

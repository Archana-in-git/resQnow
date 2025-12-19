import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
        // ✅ Ensure Firestore user doc exists
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'role': 'user',
        }, SetOptions(merge: true));
      }

      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // 🟢 GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------
  Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // avoid cached account

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        final docRef = _firestore.collection(usersCollection).doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          await docRef.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: e.toString(),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 👤 ANONYMOUS SIGN-IN (Guest)
  // ---------------------------------------------------------------------------
  Future<User?> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;

      if (user != null) {
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'role': 'guest',
          'createdAt': FieldValue.serverTimestamp(),
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
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // ---------------------------------------------------------------------------
  // 🔍 GET CURRENT USER ROLE
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
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String usersCollection = 'users';

  // ---------------------------------------------------------------------------
  // 🧠 EMAIL + PASSWORD SIGNUP (Default role: user)
  // ---------------------------------------------------------------------------
  Future<User?> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // 1️⃣ Create the Firebase Auth user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user != null) {
        // 2️⃣ Create Firestore document (role always "user" by default)
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': 'user', // ✅ manual change needed in Firestore for admins
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
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
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message);
    }
  }

  // ---------------------------------------------------------------------------
  // 🟢 GOOGLE SIGN-IN (Default role: user)
  // ---------------------------------------------------------------------------
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Check if user exists in Firestore
      if (user != null) {
        final docRef = _firestore.collection(usersCollection).doc(user.uid);
        final snapshot = await docRef.get();

        if (!snapshot.exists) {
          await docRef.set({
            'uid': user.uid,
            'name': user.displayName ?? '',
            'email': user.email,
            'role': 'user', // ✅ all Google sign-ins start as user
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
      return user;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 👤 ANONYMOUS SIGN-IN (Role: guest)
  // ---------------------------------------------------------------------------
  Future<User?> signInAnonymously() async {
    try {
      UserCredential userCredential = await _auth.signInAnonymously();
      User? user = userCredential.user;

      if (user != null) {
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'role': 'guest',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      throw Exception('Anonymous sign-in failed: $e');
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
  // 🔍 FETCH USER ROLE FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(user.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data()?['role'] ?? 'user';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 🧾 STREAM FOR AUTH STATE CHANGES
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

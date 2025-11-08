import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // 🔹 Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔹 Collection name
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
      // 1️⃣ Create Firebase user
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;

      if (user != null) {
        // 2️⃣ Determine role (admin if specific email, else user)
        String role = (email == "archana@email.com") ? "admin" : "user";

        // 3️⃣ Store in Firestore
        await _firestore.collection(usersCollection).doc(user.uid).set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'role': role,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return user;
      }
      return null;
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
  // 🟢 GOOGLE SIGN-IN
  // ---------------------------------------------------------------------------
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null; // user cancelled

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      // Store user if new
      if (user != null) {
        final docRef = _firestore.collection(usersCollection).doc(user.uid);
        final snapshot = await docRef.get();

        if (!snapshot.exists) {
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
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 👤 ANONYMOUS SIGN-IN
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
  // 🔍 GET CURRENT USER ROLE
  // ---------------------------------------------------------------------------
  Future<String?> getCurrentUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final snapshot = await _firestore
        .collection(usersCollection)
        .doc(user.uid)
        .get();
    if (snapshot.exists) {
      return snapshot.data()?['role'];
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // 🧾 STREAM FOR AUTH STATE CHANGES
  // ---------------------------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}

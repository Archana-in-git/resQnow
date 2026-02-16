import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_model.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get current logged-in user
  User? get currentUser => _auth.currentUser;

  /// ================= FETCH PROFILE =================
  Future<UserModel?> fetchUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final doc =
        await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!);
    }

    return null;
  }

  /// ================= UPDATE PROFILE =================
  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) return;

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true)); 
        // merge: true prevents overwriting entire document
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// ================= DELETE ACCOUNT =================
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) return;

    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}

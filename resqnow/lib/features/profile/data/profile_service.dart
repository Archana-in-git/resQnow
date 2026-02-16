import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'profile_model.dart';

class ProfileService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> fetchUserProfile() async {
    final doc = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .get();

    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    await _firestore.collection('users').doc(currentUser!.uid).delete();
    await currentUser!.delete();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/hospital_model.dart';

class HospitalRemoteDatasource {
  final FirebaseFirestore _firestore;

  HospitalRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<HospitalModel>> getApprovedHospitals() {
    return _firestore
        .collection('hospitals')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return HospitalModel.fromJson(data, doc.id);
          }).toList();
        });
  }
}

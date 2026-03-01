import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorRemoteDatasource {
  final FirebaseFirestore _firestore;

  DoctorRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<DoctorModel>> getDoctorsByHospital(String hospitalId) {
    print('[DoctorRemoteDatasource] hospitalId: $hospitalId');
    return _firestore
        .collection('doctors')
        .where('hospitalId', isEqualTo: hospitalId)
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          for (final doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print(
              '[DoctorRemoteDatasource] Firestore doctor docId: ${doc.id}, hospitalId: ${data['hospitalId']}',
            );
          }
          return snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return DoctorModel.fromJson(data, doc.id);
          }).toList();
        });
  }
}

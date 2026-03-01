import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/department_model.dart';

class DepartmentRemoteDatasource {
  final FirebaseFirestore _firestore;

  DepartmentRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DepartmentModel> getDepartmentById(String departmentId) async {
    final doc = await _firestore
        .collection('departments')
        .doc(departmentId)
        .get();
    if (!doc.exists) {
      throw Exception('Department not found: $departmentId');
    }
    final data = doc.data()!;
    return DepartmentModel.fromJson(data, doc.id);
  }
}

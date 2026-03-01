import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentRemoteDatasource {
  final FirebaseFirestore _firestore;

  AppointmentRemoteDatasource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<String> bookAppointment(AppointmentModel appointment) async {
    try {
      final docRef = await _firestore
          .collection('appointments')
          .add(appointment.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to book appointment: $e');
    }
  }

  Future<AppointmentModel> getAppointment(String appointmentId) async {
    try {
      final doc = await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .get();

      if (!doc.exists) {
        throw Exception('Appointment not found');
      }

      return AppointmentModel.fromJson(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Failed to fetch appointment: $e');
    }
  }

  Future<List<AppointmentModel>> getUserAppointments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user appointments: $e');
    }
  }

  Future<List<AppointmentModel>> getHospitalAppointments(
    String hospitalId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('appointments')
          .where('hospitalId', isEqualTo: hospitalId)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => AppointmentModel.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch hospital appointments: $e');
    }
  }

  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update appointment status: $e');
    }
  }
}

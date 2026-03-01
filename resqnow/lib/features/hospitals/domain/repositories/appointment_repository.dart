import '../entities/appointment_entity.dart';

abstract class AppointmentRepository {
  Future<String> bookAppointment(AppointmentEntity appointment);
  Future<AppointmentEntity> getAppointment(String appointmentId);
  Future<List<AppointmentEntity>> getUserAppointments(String userId);
  Future<List<AppointmentEntity>> getHospitalAppointments(String hospitalId);
  Future<void> updateAppointmentStatus(String appointmentId, String status);
}

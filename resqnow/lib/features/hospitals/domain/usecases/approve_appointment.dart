import '../repositories/appointment_repository.dart';

class ApproveAppointment {
  final AppointmentRepository repository;

  ApproveAppointment(this.repository);

  Future<void> call(String appointmentId) {
    return repository.updateAppointmentStatus(appointmentId, 'approved');
  }
}

import '../datasources/appointment_remote_datasource.dart';
import '../../domain/entities/appointment_entity.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../models/appointment_model.dart';

class AppointmentRepositoryImpl implements AppointmentRepository {
  final AppointmentRemoteDatasource remoteDatasource;

  AppointmentRepositoryImpl({required this.remoteDatasource});

  @override
  Future<String> bookAppointment(AppointmentEntity appointment) async {
    return await remoteDatasource.bookAppointment(
      AppointmentModel(
        id: appointment.id,
        userId: appointment.userId,
        hospitalId: appointment.hospitalId,
        doctorId: appointment.doctorId,
        patientName: appointment.patientName,
        phone: appointment.phone,
        description: appointment.description,
        preferredDate: appointment.preferredDate,
        status: appointment.status,
        createdAt: appointment.createdAt,
        updatedAt: appointment.updatedAt,
      ),
    );
  }

  @override
  Future<AppointmentEntity> getAppointment(String appointmentId) async {
    return await remoteDatasource.getAppointment(appointmentId);
  }

  @override
  Future<List<AppointmentEntity>> getUserAppointments(String userId) async {
    return await remoteDatasource.getUserAppointments(userId);
  }

  @override
  Future<List<AppointmentEntity>> getHospitalAppointments(
    String hospitalId,
  ) async {
    return await remoteDatasource.getHospitalAppointments(hospitalId);
  }

  @override
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    return await remoteDatasource.updateAppointmentStatus(
      appointmentId,
      status,
    );
  }
}

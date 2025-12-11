import 'package:resqnow/domain/entities/blood_bank.dart';
import 'package:resqnow/domain/repositories/blood_bank_repository.dart';
import 'package:resqnow/features/blood_donor/data/services/blood_bank_service.dart';

class BloodBankRepositoryImpl implements BloodBankRepository {
  final BloodBankService service;

  BloodBankRepositoryImpl({required this.service});

  @override
  Future<List<BloodBank>> getNearbyBloodBanks({
    required double latitude,
    required double longitude,
    double radiusInMeters = 5000,
  }) {
    return service.getNearbyBloodBanks(
      latitude: latitude,
      longitude: longitude,
      radiusInMeters: radiusInMeters,
    );
  }
}

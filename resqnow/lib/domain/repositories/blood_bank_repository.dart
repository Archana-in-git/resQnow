import 'package:resqnow/domain/entities/blood_bank.dart';

abstract class BloodBankRepository {
  Future<List<BloodBank>> getNearbyBloodBanks({
    required double latitude,
    required double longitude,
    double radiusInMeters,
  });
}

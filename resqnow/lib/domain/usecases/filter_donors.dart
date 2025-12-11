// lib/domain/usecases/filter_donors.dart
import 'package:resqnow/domain/entities/blood_donor.dart';
import 'package:resqnow/domain/repositories/blood_donor_repository.dart';

class FilterDonors {
  final BloodDonorRepository repository;

  FilterDonors(this.repository);

  Future<List<BloodDonor>> call({
    String? bloodGroup,
    String? gender,
    int? minAge,
    int? maxAge,
    bool? isAvailable,
  }) {
    return repository.filterDonors(
      bloodGroup: bloodGroup,
      gender: gender,
      minAge: minAge,
      maxAge: maxAge,
      isAvailable: isAvailable,
    );
  }
}

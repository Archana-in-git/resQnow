class BloodBank {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? phoneNumber;
  final double? rating;
  final bool? openNow;
  final double? distanceInKm;
  final String? photoUrl;
  final int? userRatingsTotal;
  final bool? isOpenNow;

  const BloodBank({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.phoneNumber,
    this.rating,
    this.openNow,
    this.distanceInKm,
    this.photoUrl,
    this.userRatingsTotal,
    this.isOpenNow,
  });
}

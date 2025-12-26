import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:resqnow/domain/entities/blood_bank.dart';

class BloodBankService {
  final String apiKey;

  BloodBankService({required this.apiKey});

  /// Fetch nearby blood banks using Google Places TEXT SEARCH API
  Future<List<BloodBank>> getNearbyBloodBanks({
    required double latitude,
    required double longitude,
    double radiusInMeters = 20000, // 20 km
  }) async {
    final url =
        "https://maps.googleapis.com/maps/api/place/textsearch/json"
        "?query=blood+bank"
        "&location=$latitude,$longitude"
        "&radius=$radiusInMeters"
        "&key=$apiKey";

    final response = await http.get(Uri.parse(url));

    // debugPrint("📡 BloodBankService Request URL → $url");
    // debugPrint("📨 Google Response → ${response.body}");

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch blood banks");
    }

    final data = jsonDecode(response.body);

    if (data["results"] == null) return [];

    final List results = data["results"];

    return results.map((place) {
      // Extract photo_reference from the photos array
      String? photoReference;
      int? userRatingsTotal;

      if (place["photos"] != null && place["photos"].isNotEmpty) {
        photoReference = place["photos"][0]["photo_reference"];
      }

      if (place["user_ratings_total"] != null) {
        userRatingsTotal = place["user_ratings_total"];
      }

      return BloodBank(
        id: place["place_id"] ?? "",
        name: place["name"] ?? "Unknown",
        address:
            place["formatted_address"] ??
            place["vicinity"] ??
            "No address available",
        latitude: place["geometry"]?["location"]?["lat"] ?? 0.0,
        longitude: place["geometry"]?["location"]?["lng"] ?? 0.0,
        phoneNumber: null,
        rating: place["rating"] != null
            ? double.tryParse(place["rating"].toString())
            : null,
        openNow: place["opening_hours"]?["open_now"],
        isOpenNow: place["opening_hours"]?["open_now"],
        photoUrl: photoReference,
        userRatingsTotal: userRatingsTotal,
      );
    }).toList();
  }
}

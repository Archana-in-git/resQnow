import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_strings.dart';
import '../../../data/models/hospital_model.dart';

class HospitalService {
  final String _baseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';

  Future<List<HospitalModel>> getNearbyHospitals(double lat, double lng) async {
    final url = Uri.parse(
      '$_baseUrl?location=$lat,$lng'
      '&radius=5000'
      '&type=hospital'
      '&keyword=clinic'
      '&key=${AppStrings.googleMapsApiKey}',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final results = jsonData['results'] as List;

      return results.map((item) => HospitalModel.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch hospitals');
    }
  }
}

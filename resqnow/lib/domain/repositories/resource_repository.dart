import 'package:resqnow/domain/entities/resource.dart';

abstract class ResourceRepository {
  /// Fetch all available resources
  Future<List<Resource>> getResources();

  /// Fetch a single resource by ID
  Future<Resource?> getResourceById(String id);

  /// Optionally: fetch featured resources
  Future<List<Resource>> getFeaturedResources();
}

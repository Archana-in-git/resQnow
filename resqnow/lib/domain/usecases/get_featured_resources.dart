import 'package:resqnow/domain/entities/resource.dart';
import 'package:resqnow/domain/repositories/resource_repository.dart';

class GetFeaturedResources {
  final ResourceRepository repository;

  GetFeaturedResources(this.repository);

  /// Fetches only featured first-aid resources (isFeatured: true)
  Future<List<Resource>> call() async {
    return await repository.getFeaturedResources();
  }
}

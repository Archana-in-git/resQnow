import 'package:resqnow/domain/entities/resource.dart';
import 'package:resqnow/domain/repositories/resource_repository.dart';

class GetResources {
  final ResourceRepository repository;

  GetResources(this.repository);

  /// Fetches all first-aid resources
  Future<List<Resource>> call() async {
    return await repository.getResources();
  }
}

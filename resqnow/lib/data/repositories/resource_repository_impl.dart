import 'package:resqnow/data/datasources/remote/resource_remote_datasource.dart';
import 'package:resqnow/domain/entities/resource.dart';
import 'package:resqnow/domain/repositories/resource_repository.dart';

class ResourceRepositoryImpl implements ResourceRepository {
  final ResourceRemoteDataSource remoteDataSource;

  ResourceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Resource>> getResources() async {
    return await remoteDataSource.getResources();
  }

  @override
  Future<Resource?> getResourceById(String id) async {
    return await remoteDataSource.getResourceById(id);
  }

  @override
  Future<List<Resource>> getFeaturedResources() async {
    return await remoteDataSource.getFeaturedResources();
  }
}

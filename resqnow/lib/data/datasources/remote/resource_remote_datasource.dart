import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/data/models/resource_model.dart';

abstract class ResourceRemoteDataSource {
  Future<List<ResourceModel>> getResources();
  Future<ResourceModel?> getResourceById(String id);
  Future<List<ResourceModel>> getFeaturedResources();
}

class ResourceRemoteDataSourceImpl implements ResourceRemoteDataSource {
  final FirebaseFirestore firestore;

  ResourceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<ResourceModel>> getResources() async {
    try {
      final snapshot = await firestore.collection('resources').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ResourceModel.fromJson({
          ...data,
          'id': doc.id, // Inject Firestore document ID
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch resources: $e');
    }
  }

  @override
  Future<ResourceModel?> getResourceById(String id) async {
    try {
      final doc = await firestore.collection('resources').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        return ResourceModel.fromJson({
          ...data,
          'id': doc.id, // Inject Firestore document ID
        });
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch resource: $e');
    }
  }

  @override
  Future<List<ResourceModel>> getFeaturedResources() async {
    try {
      final snapshot = await firestore
          .collection('resources')
          .where('isFeatured', isEqualTo: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ResourceModel.fromJson({
          ...data,
          'id': doc.id, // Inject Firestore document ID
        });
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured resources: $e');
    }
  }
}

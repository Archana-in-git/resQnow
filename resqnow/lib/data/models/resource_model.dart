// import 'package:resqnow/domain/entities/resource.dart';

// class ResourceModel extends Resource {
//   const ResourceModel({
//     required super.id,
//     required super.name,
//     required super.imageUrls,
//     required super.description,
//     required super.category,
//     required super.tags,
//     required super.createdAt,
//     required super.updatedAt,
//     required super.isFeatured,
//   });

//   /// Factory from JSON (Firebase/REST API)
//   factory ResourceModel.fromJson(Map<String, dynamic> json) {
//     return ResourceModel(
//       id: json['id'] as String,
//       name: json['name'] as String,
//       imageUrls: List<String>.from(json['imageUrls'] ?? []),
//       description: json['description'] as String? ?? '',
//       category: List<String>.from(json['category'] ?? []),
//       tags: List<String>.from(json['tags'] ?? []),
//       createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
//       updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
//       isFeatured: json['isFeatured'] ?? false,
//     );
//   }

//   /// Convert model to JSON (for saving/updating)
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'name': name,
//       'imageUrls': imageUrls,
//       'description': description,
//       'category': category,
//       'tags': tags,
//       'createdAt': createdAt.toIso8601String(),
//       'updatedAt': updatedAt.toIso8601String(),
//       'isFeatured': isFeatured,
//     };
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:resqnow/domain/entities/resource.dart';

class ResourceModel extends Resource {
  const ResourceModel({
    required super.id,
    required super.name,
    required super.imageUrls,
    required super.description,
    required super.category,
    required super.tags,
    required super.createdAt,
    required super.updatedAt,
    required super.isFeatured,
  });

  /// Factory from JSON (Firebase/REST API)
  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    return ResourceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      description: json['description'] as String? ?? '',
      category: List<String>.from(json['category'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  /// Convert model to JSON (for saving/updating)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrls': imageUrls,
      'description': description,
      'category': category,
      'tags': tags,
      // ✅ When saving back, use Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isFeatured': isFeatured,
    };
  }
}

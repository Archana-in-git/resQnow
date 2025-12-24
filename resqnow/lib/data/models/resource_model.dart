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
    super.whenToUse,
    super.safetyTips,
    super.proTip,
    required super.price,
    required super.createdAt,
    required super.updatedAt,
    required super.isFeatured,
  });

  /// Factory from JSON (Firebase/REST API)
  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    final List<String> categories = [];
    final rawCategories = json['category'] as List<dynamic>? ?? [];
    for (final item in rawCategories) {
      if (item is String) {
        categories.add(item);
      } else if (item is Map<String, dynamic>) {
        final name = item['name'];
        if (name is String && name.isNotEmpty) categories.add(name);

        final aliases = item['aliases'];
        if (aliases is List) {
          for (final alias in aliases) {
            if (alias is String && alias.isNotEmpty) categories.add(alias);
          }
        }
      }
    }

    return ResourceModel(
      id: json['id'] as String,
      name: json['name'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      description: json['description'] as String? ?? '',
      category: categories,
      tags: List<String>.from(json['tags'] ?? []),
      whenToUse: json['whenToUse'] as String? ?? '',
      safetyTips: json['safetyTips'] as String? ?? '',
      proTip: json['proTip'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
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
      'whenToUse': whenToUse,
      'safetyTips': safetyTips,
      'proTip': proTip,
      'price': price,
      // ✅ When saving back, use Firestore Timestamp
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isFeatured': isFeatured,
    };
  }
}

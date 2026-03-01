// category_model.dart

import 'package:resqnow/domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconAsset;
  final List<String> aliases; // Add aliases for search
  final List<String> imageUrls;
  final int order;       // Added for sorting categories
  final bool isVisible; // Added for showing/hiding categories

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconAsset,
    this.aliases = const [],
    this.imageUrls = const [],
    this.order = 999,
    this.isVisible = true,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId ?? 'unknown',
      name: (map['name'] as String?) ?? '',
      iconAsset: (map['iconAsset'] as String?) ?? '',
      aliases: (map['aliases'] as List?)?.whereType<String>().toList() ?? [],
      imageUrls: (map['imageUrls'] as List?)?.whereType<String>().toList() ?? [],
      order: (map['order'] as int?) ?? 999,
      isVisible: (map['isVisible'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'iconAsset': iconAsset,
      'aliases': aliases,
      'imageUrls': imageUrls,
      'order': order,
      'isVisible': isVisible,
    };
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      iconAsset: iconAsset,
      aliases: aliases,
      imageUrls: imageUrls,
      order: order,
      isVisible: isVisible,
    );
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconAsset: category.iconAsset,
      aliases: category.aliases,
      imageUrls: category.imageUrls,
      order: category.order,
      isVisible: category.isVisible,
    );
  }
}

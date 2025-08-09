// category_model.dart

import 'package:resqnow/domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconAsset;
  final List<String> aliases; // Add aliases for search

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconAsset,
    this.aliases = const [],
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      iconAsset: map['iconAsset'] ?? '',
      aliases: List<String>.from(map['aliases'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconAsset': iconAsset, 'aliases': aliases};
  }

  Category toEntity() {
    return Category(id: id, name: name, iconAsset: iconAsset, aliases: aliases);
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconAsset: category.iconAsset,
      aliases: category.aliases,
    );
  }
}

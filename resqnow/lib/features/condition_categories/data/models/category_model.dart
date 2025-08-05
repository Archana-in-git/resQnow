// category_model.dart

import 'package:resqnow/domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String iconAsset;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconAsset,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return CategoryModel(
      id: docId,
      name: map['name'] ?? '',
      iconAsset: map['iconAsset'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'iconAsset': iconAsset};
  }

  Category toEntity() {
    return Category(id: id, name: name, iconAsset: iconAsset);
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      iconAsset: category.iconAsset,
    );
  }
}

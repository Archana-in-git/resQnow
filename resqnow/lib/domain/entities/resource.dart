import 'package:equatable/equatable.dart';

class Resource extends Equatable {
  final String id;
  final String name;
  final List<String> imageUrls;
  final String description;
  final List<String> category;
  final List<String> tags;
  final String? whenToUse;
  final String? safetyTips;
  final String? proTip;
  final double price;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFeatured;

  const Resource({
    required this.id,
    required this.name,
    required this.imageUrls,
    required this.description,
    required this.category,
    required this.tags,
    this.whenToUse,
    this.safetyTips,
    this.proTip,
    required this.price,
    required this.createdAt,
    required this.updatedAt,
    required this.isFeatured,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    imageUrls,
    description,
    category,
    tags,
    whenToUse,
    safetyTips,
    proTip,
    price,
    createdAt,
    updatedAt,
    isFeatured,
  ];
}

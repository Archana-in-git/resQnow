// category.dart

class Category {
  final String id;
  final String name;
  final String iconAsset;
  final List<String> aliases;
  final List<String> imageUrls;
  final int order;       // Added for sorting categories
  final bool isVisible; // Added for showing/hiding categories

  Category({
    required this.id,
    required this.name,
    required this.iconAsset,
    this.aliases = const [],
    this.imageUrls = const [],
    this.order = 999,        // Default order value
    this.isVisible = true,    // Default visibility
  });
}

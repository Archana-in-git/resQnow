// category.dart

class Category {
  final String id;
  final String name;
  final String iconAsset;
  final List<String> aliases;

  Category({
    required this.id,
    required this.name,
    required this.iconAsset,
    this.aliases = const [],
  });
}

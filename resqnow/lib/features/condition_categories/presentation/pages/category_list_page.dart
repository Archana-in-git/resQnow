import 'package:flutter/material.dart';
import 'package:resqnow/features/condition_categories/presentation/widgets/category_card.dart';
import '../controllers/category_controller.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';
import 'package:resqnow/features/categories/widgets/expandable_search_bar.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late final CategoryController _controller;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _controller = CategoryController(_categoryService);
    _controller.loadCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text("Explore Conditions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // You can still use this if you want full-page search later
              // context.push('/category-search');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            child: ExpandableSearchBar(onSearch: _controller.filterCategories),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (_controller.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (_controller.error != null) {
                  return Center(
                    child: Text(
                      'Something went wrong!\n${_controller.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final categoryList = _controller.categories;

                if (categoryList.isEmpty) {
                  return const Center(child: Text("No categories found."));
                }

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    itemCount: categoryList.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                    itemBuilder: (context, index) {
                      final category = categoryList[index];
                      return CategoryCard(
                        category: category,
                        onTap: () {
                          // TODO: Navigate to CategoryDetailPage using category.id
                          // context.push('/category/${category.id}');
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// category_list_page.dart

import 'package:flutter/material.dart';
import 'package:resqnow/features/condition_categories/presentation/widgets/category_card.dart';
import '../controllers/category_controller.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  late CategoryController _controller;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _controller = CategoryController(_categoryService);
    _controller.loadCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop(); // Back to Home
          },
        ),
        title: const Text("Explore Conditions"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Add search functionality later
            },
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.error != null) {
            return Center(child: Text('Error: ${_controller.error}'));
          }

          final categoryList = _controller.categories;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: categoryList.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                    // TODO: Connect to actual category detail route later
                    // Navigator.pushNamed(context, '/condition-detail', arguments: category.id);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/features/condition_categories/controllers/category_controller.dart';
import 'package:resqnow/features/condition_categories/presentation/widgets/search_bar_widget.dart';
import 'package:resqnow/features/condition_categories/presentation/widgets/category_tile.dart'; // CategoryTile widget
import 'package:resqnow/domain/entities/category.dart'; // Your real model

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<Category> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    final controller = Provider.of<CategoryController>(context, listen: false);
    controller.loadCategories().then((_) {
      setState(() {
        filteredCategories = controller.categories;
      });
    });
  }

  void _onSearchChanged(String query) {
    final controller = Provider.of<CategoryController>(context, listen: false);
    setState(() {
      filteredCategories = query.isEmpty
          ? controller.categories
          : controller.categories
                .where(
                  (category) =>
                      category.name.toLowerCase().contains(query.toLowerCase()),
                )
                .toList();
    });
  }

  void _onSearchClosed() {
    final controller = Provider.of<CategoryController>(context, listen: false);
    setState(() => filteredCategories = controller.categories);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<CategoryController>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Explore Categories")),
      body: controller.isLoading
          ? const Center(child: CircularProgressIndicator())
          : controller.error != null
          ? Center(child: Text("Error: ${controller.error}"))
          : Column(
              children: [
                AnimatedSearchBar(
                  onChanged: _onSearchChanged,
                  onClosed: _onSearchClosed,
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: filteredCategories.isEmpty
                      ? const Center(child: Text("No categories found."))
                      : GridView.builder(
                          padding: const EdgeInsets.all(12),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                          itemCount: filteredCategories.length,
                          itemBuilder: (context, index) {
                            final category = filteredCategories[index];
                            return CategoryTile(category: category);
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

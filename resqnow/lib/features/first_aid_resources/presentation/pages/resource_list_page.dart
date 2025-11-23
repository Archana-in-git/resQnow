import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:resqnow/core/constants/app_text_styles.dart';
import 'package:resqnow/features/first_aid_resources/presentation/controllers/resource_controller.dart';
import 'package:resqnow/features/first_aid_resources/presentation/widgets/resource_card.dart';
import 'package:go_router/go_router.dart';

class ResourceListPage extends StatefulWidget {
  const ResourceListPage({super.key});

  @override
  State<ResourceListPage> createState() => _ResourceListPageState();
}

class _ResourceListPageState extends State<ResourceListPage> {
  late final TextEditingController _searchController;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query == _lastQuery) return;
      _lastQuery = query;
      context.read<ResourceController>().searchResources(query);
    });

    Future.microtask(() async {
      if (!mounted) return;
      await Provider.of<ResourceController>(
        context,
        listen: false,
      ).fetchResources();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResourceController>();
    final hasFilters = controller.activeCategories.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text("Resources", style: AppTextStyles.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: AppColors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved resources coming soon.')),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search + Filter Row (UI only, no logic yet)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Search resources...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _lastQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<ResourceController>()
                                    .clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) => context
                        .read<ResourceController>()
                        .searchResources(query),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: hasFilters
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                  onPressed: _showFilterSheet,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Resources Grid
            Expanded(
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : controller.error != null
                  ? Center(child: Text("Error: ${controller.error}"))
                  : controller.resources.isEmpty
                  ? const Center(
                      child: Text(
                        "No resources found.",
                        style: AppTextStyles.bodyText,
                      ),
                    )
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.8,
                          ),
                      itemCount: controller.resources.length,
                      itemBuilder: (context, index) {
                        final resource = controller.resources[index];
                        return ResourceCard(
                          resource: resource,
                          onTap: () {
                            // Navigate to detail page
                            context.push('/resource-detail', extra: resource);
                          },
                          onActionTap: () {
                            // Action button logic (Save / Info)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("${resource.name} clicked!"),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Consumer<ResourceController>(
          builder: (context, controller, _) {
            final categories = controller.availableCategories;
            final active = controller.activeCategories;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by category',
                        style: AppTextStyles.sectionTitle,
                      ),
                      TextButton(
                        onPressed: () {
                          controller.clearCategoryFilters();
                          Navigator.of(context).pop();
                        },
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((category) {
                      final selected = active.any(
                        (value) =>
                            value.toLowerCase() == category.toLowerCase(),
                      );
                      return FilterChip(
                        label: Text(category),
                        selected: selected,
                        selectedColor: AppColors.accent,
                        checkmarkColor: AppColors.white,
                        onSelected: (_) {
                          controller.toggleCategory(category);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

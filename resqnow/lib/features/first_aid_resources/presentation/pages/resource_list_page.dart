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
    debugPrint('ResourceListPage built');
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final controller = context.watch<ResourceController>();
    final hasFilters = controller.activeCategories.isNotEmpty;

    return Scaffold(
      backgroundColor: isDarkMode
          ? const Color(0xFF121212)
          : AppColors.background,
      appBar: AppBar(
        backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
          onPressed: () {
            // Clear filters and search before navigating back
            context.read<ResourceController>().clearCategoryFilters();
            context.read<ResourceController>().clearSearch();
            context.pop();
          },
        ),
        title: Text(
          "Resources",
          style: AppTextStyles.appTitle.copyWith(
            color: isDarkMode ? Colors.white : AppColors.textPrimary,
          ),
        ),
        actions: [],
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
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search resources...",
                      hintStyle: TextStyle(
                        color: isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: isDarkMode
                            ? Colors.grey.shade500
                            : Colors.grey.shade600,
                      ),
                      suffixIcon: _lastQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: isDarkMode
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade600,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                context
                                    .read<ResourceController>()
                                    .clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDarkMode
                          ? const Color(0xFF2A2A2A)
                          : AppColors.white,
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
                        : (isDarkMode
                              ? Colors.grey.shade500
                              : AppColors.textPrimary),
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
                  ? Center(
                      child: Text(
                        "Error: ${controller.error}",
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                    )
                  : controller.resources.isEmpty
                  ? Center(
                      child: Text(
                        "No resources found.",
                        style: AppTextStyles.bodyText.copyWith(
                          color: isDarkMode
                              ? Colors.grey.shade400
                              : AppColors.textPrimary,
                        ),
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter sheet',
      barrierColor: Colors.black.withOpacity(0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return const SizedBox.shrink();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: Consumer<ResourceController>(
            builder: (context, controller, _) {
              final categories = controller.availableCategories;
              final active = controller.activeCategories;

              return Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.75,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1E1E1E)
                          : Colors.white,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        bottomLeft: Radius.circular(24),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.primary.withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomRight: Radius.circular(24),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Filter Categories',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => Navigator.pop(context),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Active: ${active.length}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Filters List
                          Expanded(
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: categories.map((category) {
                                    final selected = active.any(
                                      (value) =>
                                          value.toLowerCase() ==
                                          category.toLowerCase(),
                                    );
                                    return FilterChip(
                                      label: Text(
                                        category,
                                        style: TextStyle(
                                          color: selected
                                              ? Colors.white
                                              : (isDarkMode
                                                    ? Colors.white
                                                    : AppColors.textPrimary),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      selected: selected,
                                      selectedColor: AppColors.primary,
                                      backgroundColor: isDarkMode
                                          ? AppColors.primary.withOpacity(0.2)
                                          : AppColors.primary.withOpacity(0.1),
                                      checkmarkColor: Colors.white,
                                      side: BorderSide(
                                        color: AppColors.primary.withOpacity(
                                          0.3,
                                        ),
                                        width: 1.5,
                                      ),
                                      onSelected: (_) {
                                        controller.toggleCategory(category);
                                      },
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                          // Footer Section
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: isDarkMode
                                      ? Colors.grey.shade800
                                      : Colors.grey.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Apply Filters',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      controller.clearCategoryFilters();
                                      Navigator.pop(context);
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.primary,
                                      side: BorderSide(
                                        color: AppColors.primary.withOpacity(
                                          0.5,
                                        ),
                                        width: 1.5,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 14,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: const Text(
                                      'Clear All',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

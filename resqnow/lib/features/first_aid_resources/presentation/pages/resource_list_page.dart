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
      debugPrint('📥 [LOAD] Fetching resources...');
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
            // Search + Filter Row
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
                  onPressed: () {
                    _showFilterSheet();
                  },
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
                            context.push('/resource-detail', extra: resource);
                          },
                          onActionTap: () {
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
    final controller = context.read<ResourceController>();

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Filter sheet',
      barrierColor: Colors.black.withValues(alpha: 0.3),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation1, animation2) {
        return _FilterSheetWidget(
          availableCategories: List.from(controller.availableCategories),
          initialActiveCategories: List.from(controller.activeCategories),
          onApplyFilters: (selectedCategories) {
            controller.clearCategoryFilters();

            for (final category in selectedCategories) {
              controller.toggleCategory(category);
            }
          },
          onClearFilters: () {
            controller.clearCategoryFilters();
          },
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        );
      },
    );
  }
}

/// ============================================================
/// COMPLETELY ISOLATED FILTER SHEET WIDGET
/// NO external state, NO controller dependency during build
/// ============================================================
class _FilterSheetWidget extends StatefulWidget {
  final List<String> availableCategories;
  final List<String> initialActiveCategories;
  final Function(List<String>) onApplyFilters;
  final VoidCallback onClearFilters;

  const _FilterSheetWidget({
    required this.availableCategories,
    required this.initialActiveCategories,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<_FilterSheetWidget> createState() => _FilterSheetWidgetState();
}

class _FilterSheetWidgetState extends State<_FilterSheetWidget> {
  late List<String> _localSelectedCategories;

  @override
  void initState() {
    super.initState();
    _localSelectedCategories = List.from(widget.initialActiveCategories);
  }

  void _toggleCategory(String category) {
    setState(() {
      if (_localSelectedCategories.contains(category)) {
        _localSelectedCategories.remove(category);
      } else {
        _localSelectedCategories.add(category);
      }
    });

    // Apply filter in real-time
    widget.onApplyFilters(_localSelectedCategories);
  }

  void _applyAndClose() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _clearAndClose() {
    setState(() {
      _localSelectedCategories.clear();
    });
    widget.onClearFilters();

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              bottomLeft: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER - Minimal and Simple with Solid Teal Background
                Container(
                  color: AppColors.primary,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        'Filter Resources',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Active count
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white.withValues(alpha: 0.15),
                        ),
                        child: Text(
                          'Active: ${_localSelectedCategories.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // FILTER CHIPS LIST
                Expanded(
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: NoSplash.splashFactory,
                      colorScheme: Theme.of(context).colorScheme.copyWith(
                        secondary: AppColors.primary, // Teal
                        secondaryContainer: AppColors.primary,
                        error: AppColors.primary,
                        errorContainer: AppColors.primary,
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 2.0,
                              ),
                          itemCount: widget.availableCategories.length,
                          itemBuilder: (context, index) {
                            final category = widget.availableCategories[index];
                            final isSelected = _localSelectedCategories
                                .contains(category);

                            return GestureDetector(
                              onTap: () {
                                _toggleCategory(category);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors
                                            .primary // TEAL when selected
                                      : (isDarkMode
                                            ? AppColors.primary.withValues(
                                                alpha: 0.2,
                                              )
                                            : AppColors.primary.withValues(
                                                alpha: 0.1,
                                              )),
                                  border: Border.all(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.3,
                                    ),
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : (isDarkMode
                                                    ? Colors.white
                                                    : AppColors.textPrimary),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isSelected)
                                      const Padding(
                                        padding: EdgeInsets.only(left: 8),
                                        child: Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                // FOOTER - Action Buttons
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDarkMode
                            ? Colors.grey.shade800
                            : Colors.grey.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _applyAndClose,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary, // TEAL
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
                          onPressed: _clearAndClose,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary, // TEAL
                            side: BorderSide(
                              color: AppColors.primary.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
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
  }
}

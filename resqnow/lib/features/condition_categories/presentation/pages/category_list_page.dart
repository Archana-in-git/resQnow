import 'dart:io';
import 'package:flutter/material.dart';
import 'package:resqnow/features/condition_categories/presentation/widgets/category_card.dart';
import '../controllers/category_controller.dart';
import 'package:resqnow/features/condition_categories/data/services/category_service.dart';
import 'package:resqnow/core/constants/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryListPage extends StatefulWidget {
  const CategoryListPage({super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final CategoryController _controller;
  final CategoryService _categoryService = CategoryService();
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  File? _selectedImage;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _controller = CategoryController(_categoryService);
    _controller.loadCategories();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _expandAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
    });

    if (_isSearchExpanded) {
      _animationController.forward();
    } else {
      _animationController.reverse();
      _searchController.clear();
      _controller.clearSearch();
    }
  }

  void _onSearchChanged(String query) {
    _controller.searchCategories(query);
  }

  // 📸 Pick and analyze image logic
  Future<void> _pickAndAnalyzeImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked == null) return;

    setState(() {
      _selectedImage = File(picked.path);
      _isAnalyzing = true;
    });

    final inputImage = InputImage.fromFile(_selectedImage!);
    final labeler = ImageLabeler(
      options: ImageLabelerOptions(confidenceThreshold: 0.6),
    );

    final labels = await labeler.processImage(inputImage);
    // 👇 Add this
    for (final l in labels) {
      debugPrint(
        '🧠 Detected label: ${l.label} (conf: ${l.confidence.toStringAsFixed(2)})',
      );
    }
    labeler.close();

    if (labels.isEmpty) {
      _showSnack('No recognizable condition found.');
      setState(() => _isAnalyzing = false);
      return;
    }

    final keywords = labels.take(3).map((e) => e.label.toLowerCase()).toList();
    await _searchCategoryByAliases(keywords);
  }

  // 🔍 Search Firestore categories by aliases
  Future<void> _searchCategoryByAliases(List<String> keywords) async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('categories')
          .where('aliases', arrayContainsAny: keywords)
          .get();

      setState(() => _isAnalyzing = false);

      if (query.docs.isNotEmpty) {
        final category = query.docs.first.data();
        final categoryId = query.docs.first.id;
        _showSnack('Detected: ${category['name']}');

        // ✅ Navigate to that category
        if (mounted) {
          context.push('/categories/condition/$categoryId');
        }
      } else {
        _showSnack('No matching category found.');
      }
    } catch (e) {
      _showSnack('Error analyzing image: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        automaticallyImplyLeading: !_isSearchExpanded,
        leading: _isSearchExpanded
            ? null
            : IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {
                  context.pop();
                },
              ),
        centerTitle: !_isSearchExpanded,
        title: AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Row(
              mainAxisAlignment: _isSearchExpanded
                  ? MainAxisAlignment.spaceBetween
                  : MainAxisAlignment.center,
              children: [
                if (!_isSearchExpanded)
                  const Expanded(
                    child: Text(
                      'Explore Categories',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (_isSearchExpanded)
                  Expanded(
                    child: Container(
                      height: 40,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.2),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              onChanged: _onSearchChanged,
                              autofocus: true,
                              textAlignVertical: TextAlignVertical.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search conditions...',
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: AppColors.primary.withOpacity(0.7),
                              size: 20,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Voice search coming soon'),
                                ),
                              );
                            },
                            iconSize: 20,
                            splashRadius: 20,
                          ),
                          // image analysis
                          IconButton(
                            icon: _isAnalyzing
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.teal,
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    color: AppColors.primary.withOpacity(0.7),
                                    size: 20,
                                  ),
                            onPressed: _isAnalyzing
                                ? null
                                : _pickAndAnalyzeImage,
                            iconSize: 20,
                            splashRadius: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_isSearchExpanded)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _toggleSearch,
                        borderRadius: BorderRadius.circular(12),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                      color: AppColors.textPrimary,
                    ),
                    onPressed: _toggleSearch,
                  ),
              ],
            );
          },
        ),
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          if (_controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (_controller.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${_controller.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _controller.loadCategories,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final categories = _controller.categories;

          if (categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _controller.isSearching ? Icons.search_off : Icons.category,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.isSearching
                        ? 'No categories found for "${_searchController.text}"'
                        : 'No categories available',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.builder(
              key: const PageStorageKey('categoryGridView'),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return CategoryCard(
                  key: ValueKey(category.id),
                  category: category,
                  onTap: () {
                    context.push('/categories/condition/${category.id}');
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

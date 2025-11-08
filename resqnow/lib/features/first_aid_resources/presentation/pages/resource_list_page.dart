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
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      await Provider.of<ResourceController>(
        context,
        listen: false,
      ).fetchResources();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ResourceController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: const Text("Resources", style: AppTextStyles.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark, color: AppColors.primary),
            onPressed: () {
              // TODO: Update this route when Saved Topics page is ready
              Navigator.pushNamed(context, '/saved-topics');
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
                    decoration: InputDecoration(
                      hintText: "Search resources...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: AppColors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.filter_list,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    // TODO: Implement filter logic
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
                  ? Center(child: Text("Error: ${controller.error}"))
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
                            Navigator.pushNamed(
                              context,
                              '/resource-detail',
                              arguments: resource,
                            );
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
}

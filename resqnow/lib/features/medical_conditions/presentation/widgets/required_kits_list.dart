import 'package:flutter/material.dart';
import '../../data/models/condition_model.dart';
import 'kit_item_tile.dart';

class RequiredKitsList extends StatelessWidget {
  final List<RequiredKit> kits;

  const RequiredKitsList({super.key, required this.kits});

  @override
  Widget build(BuildContext context) {
    if (kits.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text("No kits listed for this condition."),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: kits.length,
      itemBuilder: (context, index) {
        final RequiredKit kit = kits[index];
        return KitItemTile(name: kit.name, imageUrl: kit.iconUrl);
      },
    );
  }
}

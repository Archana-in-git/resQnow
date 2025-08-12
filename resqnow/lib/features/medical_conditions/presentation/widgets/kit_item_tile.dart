import 'package:flutter/material.dart';

class KitItemTile extends StatelessWidget {
  final String name;
  final String imageUrl;

  const KitItemTile({super.key, required this.name, required this.imageUrl});

  bool get isNetworkImage => imageUrl.startsWith('http');

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (imageUrl.isEmpty) {
      imageWidget = Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, size: 48),
      );
    } else {
      imageWidget = isNetworkImage
          ? Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 48),
                );
              },
            )
          : Image.asset(imageUrl, fit: BoxFit.cover);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: imageWidget,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class AnimatedSearchBar extends StatefulWidget {
  final Function(String) onChanged;
  final VoidCallback onClosed;

  const AnimatedSearchBar({
    Key? key,
    required this.onChanged,
    required this.onClosed,
  }) : super(key: key);

  @override
  State<AnimatedSearchBar> createState() => _AnimatedSearchBarState();
}

class _AnimatedSearchBarState extends State<AnimatedSearchBar> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleSearchBar() {
    setState(() => _isExpanded = !_isExpanded);
    if (!_isExpanded) {
      _controller.clear();
      widget.onChanged('');
      widget.onClosed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      width: double.infinity,
      child: _isExpanded
          ? Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onChanged: widget.onChanged,
                      autofocus: true,
                      decoration: const InputDecoration(
                        hintText: 'Search categories...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.mic_none),
                    onPressed: () {
                      // Voice feature (future)
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.image_search),
                    onPressed: () {
                      // Image analysis (future)
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _toggleSearchBar,
                  ),
                ],
              ),
            )
          : Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: const Icon(Icons.search),
                onPressed: _toggleSearchBar,
              ),
            ),
    );
  }
}

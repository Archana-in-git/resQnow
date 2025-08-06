import 'package:flutter/material.dart';

class ExpandableSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const ExpandableSearchBar({
    super.key,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<ExpandableSearchBar> createState() => _ExpandableSearchBarState();
}

class _ExpandableSearchBarState extends State<ExpandableSearchBar> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  void _toggleSearch() {
    setState(() => _isExpanded = !_isExpanded);
    if (!_isExpanded) {
      _controller.clear();
      widget.onClear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(_isExpanded ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (_isExpanded) ...[
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: widget.onChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.mic_none),
              onPressed: () {
                // Future: Voice input
              },
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              onPressed: () {
                // Future: Image input
              },
            ),
          ],
        ],
      ),
    );
  }
}

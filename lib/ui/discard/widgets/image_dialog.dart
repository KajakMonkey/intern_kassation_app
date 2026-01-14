import 'dart:io';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/core/extensions/image_cache_size_extension.dart';

class ImageDialog extends StatefulWidget {
  const ImageDialog({
    required this.imagePaths,
    this.initialIndex = 0,
    super.key,
  });

  final List<String> imagePaths;
  final int initialIndex;

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  late PageController _pageController;
  var _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _goToPage(int index) {
    if (index >= 0 && index < widget.imagePaths.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity != null && details.primaryVelocity!.abs() > 300) {
          context.pop(); // Dismiss if swipe is fast enough
        }
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.imagePaths.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    return InteractiveViewer(
                      minScale: 0.5,
                      maxScale: 4,
                      child: Image.file(
                        File(widget.imagePaths[index]),
                        fit: BoxFit.contain,
                        cacheHeight: constraints.maxHeight.cacheSize(context),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                ),
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
            if (widget.imagePaths.length > 1) ...[
              if (_currentIndex > 0)
                Positioned(
                  left: 16,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    onPressed: () => _goToPage(_currentIndex - 1),
                  ),
                ),
              if (_currentIndex < widget.imagePaths.length - 1)
                Positioned(
                  right: 16,
                  child: IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                    ),
                    icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    onPressed: () => _goToPage(_currentIndex + 1),
                  ),
                ),
            ],
            if (widget.imagePaths.length > 1)
              Positioned(
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentIndex + 1} / ${widget.imagePaths.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

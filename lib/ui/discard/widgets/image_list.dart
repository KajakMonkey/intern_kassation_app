import 'dart:io';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/core/extensions/image_cache_size_extension.dart';
import 'package:intern_kassation_app/ui/core/ui/responsive.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/widgets/image_dialog.dart';

class ImageList extends StatelessWidget {
  const ImageList({super.key});

  void _removeImage(int index, BuildContext context) {
    context.read<DiscardCubit>().removeImageAt(index);
  }

  void _showImageDialog(List<String> imagePaths, int initialIndex, BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return ImageDialog(imagePaths: imagePaths, initialIndex: initialIndex);
      },
    );
  }

  int getImageCacheSize(BuildContext context) {
    if (Responsive.isTablet(context)) {
      return 195.cacheSize(context);
    } else {
      return 240.cacheSize(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiscardCubit, DiscardState>(
      buildWhen: (previous, current) => previous.imageState != current.imageState,
      builder: (context, discardState) {
        final state = discardState.imageState;
        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: Responsive.isTablet(context) ? 6 : 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: state.imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = state.imagePaths[index];
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => _showImageDialog(state.imagePaths, index, context),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: ResizeImage(
                          FileImage(File(imagePath)),
                          width: getImageCacheSize(context),
                          height: getImageCacheSize(context),
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: InkWell(
                    onTap: () => _removeImage(index, context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

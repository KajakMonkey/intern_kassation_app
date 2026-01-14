import 'dart:io';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';
import 'package:intern_kassation_app/ui/discard/widgets/image_list.dart';

class ImageStep extends StatefulWidget {
  const ImageStep({
    super.key,
    required this.onNext,
    required this.onNavConfigChanged,
  });

  final VoidCallback onNext;
  final ValueChanged<StepNavigationConfig> onNavConfigChanged;

  @override
  State<ImageStep> createState() => _ImageStepState();
}

class _ImageStepState extends State<ImageStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavConfigChanged(StepNavigationConfig.standard);
    });
  }

  void _takePicture(BuildContext context) {
    context.read<DiscardCubit>().takePicture();
  }

  void _pickImage(BuildContext context) {
    context.read<DiscardCubit>().pickImages();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocBuilder<DiscardCubit, DiscardState>(
      buildWhen: (previous, current) => previous.imageState != current.imageState,
      builder: (context, discardState) {
        final state = discardState.imageState;
        return Padding(
          padding: const EdgeInsets.all(Gap.m),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                children: [
                  Text(
                    l10n.attach_images,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  Gap.vl,
                  Row(
                    children: [
                      if (Platform.isIOS || Platform.isAndroid) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: state.status == ImageStatus.loading ? null : () => _takePicture(context),
                            icon: const Icon(Icons.camera_alt),
                            label: Text(l10n.take_picture),
                          ),
                        ),
                        Gap.hm,
                      ],

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: state.status == ImageStatus.loading ? null : () => _pickImage(context),
                          icon: const Icon(Icons.photo_library),
                          label: Text(l10n.pick_from_gallery),
                        ),
                      ),
                    ],
                  ),
                  Gap.vm,

                  if (state.status == ImageStatus.loading && state.imagePaths.isEmpty)
                    const Center(child: CircularProgressIndicator()),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text.rich(
                      TextSpan(
                        text: l10n.images_selected(state.imagePaths.length),
                        style: context.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w500),
                        children: [
                          TextSpan(
                            text: ' (${l10n.max_images(AppConfig.maxImages)})',
                            style: context.textTheme.bodyMedium?.copyWith(
                              color: context.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.start,
                    ),
                  ),

                  if (state.imagePaths.isNotEmpty)
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const ImageList(),
                            const SizedBox(height: 8),
                            Text(
                              l10n.large_image_upload_warning,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: context.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                        if (state.status == ImageStatus.loading)
                          Positioned.fill(
                            child: ColoredBox(
                              color: context.isDarkMode
                                  ? Colors.black.withValues(alpha: 0.5)
                                  : Colors.white.withValues(alpha: 0.5),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

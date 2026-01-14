import 'dart:io';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/discard_form_config.dart';
import 'package:intern_kassation_app/ui/discard/models/discard_form_step.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';
import 'package:intern_kassation_app/ui/discard/widgets/image_dialog.dart';

class OverviewStep extends StatefulWidget {
  const OverviewStep({
    super.key,
    required this.onSubmit,
    required this.onNavConfigChanged,
    required this.isLastStep,
  });

  final VoidCallback onSubmit;
  final ValueChanged<StepNavigationConfig> onNavConfigChanged;
  final bool isLastStep;

  @override
  State<OverviewStep> createState() => _OverviewStepState();
}

class _OverviewStepState extends State<OverviewStep> {
  List<DiscardFormStep>? steps;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavConfigChanged(
        StepNavigationConfig.standard.copyWith(
          showFab: false,
        ),
      );
      final discardState = context.read<DiscardCubit>().state;
      setState(() {
        steps = DiscardFormConfig.getStepsForProduct(discardState.formData.productType);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final discardState = context.watch<DiscardCubit>().state;
    final l10n = context.l10n;
    final steps = DiscardFormConfig.getStepsForProduct(discardState.formData.productType);

    final bool isSubmitting = discardState.submitState.maybeWhen(orElse: () => false, submitting: () => true);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.overview,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // General info card (always shown)
            _buildInfoCard(
              context,
              title: l10n.order_information,
              children: [
                _buildInfoRow(l10n.sales_id, discardState.formData.salesId),
                _buildInfoRow(l10n.production_order, discardState.formData.productionOrder),
                _buildInfoRow(l10n.worktop, discardState.formData.worktop),
                _buildInfoRow(l10n.date, discardState.formData.date),
              ],
            ),

            if (steps.contains(DiscardFormStep.employeeId)) _buildEmployeeSection(context),

            if (steps.contains(DiscardFormStep.discardReason)) _buildDiscardReasonSection(context, discardState),

            if (steps.contains(DiscardFormStep.images)) _buildImagesSection(context),

            if (steps.contains(DiscardFormStep.note)) _buildNoteSection(context, discardState),

            Gap.vm,

            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isSubmitting ? null : widget.onSubmit,
                label: isSubmitting ? const CircularProgressIndicator() : Text(context.l10n.submit),
                icon: isSubmitting ? null : const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value.isNotEmpty ? value : '-'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeSection(BuildContext context) {
    final employeeState = context.watch<DiscardCubit>().state.employeeState;
    final l10n = context.l10n;

    final (String employeeName, String employeeId) = employeeState.maybeWhen(
      loaded: (employeeNameState, employeeIdState) => (employeeNameState, employeeIdState),
      orElse: () => ('-', '-'),
    );

    return _buildInfoCard(
      context,
      title: l10n.employee,
      children: [
        _buildInfoRow(l10n.employee, employeeName),
        _buildInfoRow(l10n.employee_number, employeeId),
      ],
    );
  }

  Widget _buildDiscardReasonSection(BuildContext context, DiscardState discardState) {
    final l10n = context.l10n;
    final reason = discardState.discardReasonState.selectedReason;
    final dropdownValue = discardState.dropdownValuesState.selectedDropdownValue;

    return _buildInfoCard(
      context,
      title: l10n.reason_for_discard,
      children: [
        _buildInfoRow(
          l10n.code,
          reason?.errorCode ?? '-',
        ),
        _buildInfoRow(
          l10n.description,
          reason?.description ?? '-',
        ),
        if (dropdownValue != null)
          _buildInfoRow(
            l10n.machine,
            dropdownValue.dropdownItem,
          ),
      ],
    );
  }

  Widget _buildImagesSection(BuildContext context) {
    final imageState = context.watch<DiscardCubit>().state.imageState;
    final l10n = context.l10n;
    final imageCount = imageState.imagePaths.length;

    void showImageDialog(List<String> imagePaths, int initialIndex, BuildContext context) {
      showDialog<void>(
        context: context,
        builder: (context) {
          return ImageDialog(imagePaths: imagePaths, initialIndex: initialIndex);
        },
      );
    }

    return _buildInfoCard(
      context,
      title: l10n.attach_images,
      children: [
        _buildInfoRow(
          l10n.images_attached,
          imageCount.toString(),
        ),
        if (imageCount > 0) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageState.imagePaths.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: GestureDetector(
                    onTap: () => showImageDialog(imageState.imagePaths, index, context),
                    child: Image.file(
                      File(imageState.imagePaths[index]),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildNoteSection(BuildContext context, DiscardState discardState) {
    final l10n = context.l10n;

    return _buildInfoCard(
      context,
      title: l10n.free_text_elaboration,
      children: [
        Text(discardState.formData.note.isNotEmpty ? discardState.formData.note : '-'),
      ],
    );
  }
}

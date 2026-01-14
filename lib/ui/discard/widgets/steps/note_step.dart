import 'package:flutter/foundation.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/app_config.dart';
import 'package:intern_kassation_app/config/env.dart';
import 'package:intern_kassation_app/ui/core/extensions/buildcontext_extension.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';
import 'package:intern_kassation_app/utils/extensions/date_extension.dart';

class NoteStep extends StatefulWidget {
  const NoteStep({
    super.key,
    required this.onNext,
    required this.onNavConfigChanged,
  });

  final VoidCallback onNext;
  final ValueChanged<StepNavigationConfig> onNavConfigChanged;

  @override
  State<NoteStep> createState() => _NoteStepState();
}

class _NoteStepState extends State<NoteStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onNavConfigChanged(StepNavigationConfig.standard);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.unfocus(),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.more_details,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              const _ExtraTextFormField(),
              const _DevDatePicker(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExtraTextFormField extends StatefulWidget {
  const _ExtraTextFormField();

  @override
  State<_ExtraTextFormField> createState() => _ExtraTextFormFieldState();
}

class _ExtraTextFormFieldState extends State<_ExtraTextFormField> {
  late final TextEditingController _controller;
  final int _maxLength = AppConfig.maxNoteLength;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final state = context.read<DiscardCubit>().state;
      _controller.text = state.formData.note;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return TextField(
      controller: _controller,
      minLines: 4,
      maxLines: 12,
      maxLength: _maxLength,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: l10n.free_text_elaboration,
        alignLabelWithHint: true,
        contentPadding: const EdgeInsets.all(16),
        counterStyle: context.textTheme.bodySmall?.copyWith(
          color: _controller.text.length > _maxLength * 0.9
              ? theme.colorScheme.error
              : theme.colorScheme.onSurface.withValues(alpha: 0.7),
        ),
      ),
      onChanged: (value) {
        setState(() {});
        context.read<DiscardCubit>().onNoteChanged(value);
      },
    );
  }
}

class _DevDatePicker extends StatelessWidget {
  const _DevDatePicker();

  @override
  Widget build(BuildContext context) {
    if (EnvManager.showDataPicker && kDebugMode) {
      return Column(
        children: [
          Card(
            color: context.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    context.l10n.dev_date_picker_warning,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (pickedDate != null && context.mounted) {
                context.read<DiscardCubit>().onDateChanged(pickedDate, pickedDate.formatDate());
              }
            },
            child: const Text('Pick a date'),
          ),
          const SizedBox(height: 20),
          Text('Selected date: ${context.watch<DiscardCubit>().state.formData.date}'),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/core/ui/responsive.dart';

class DiscardReasonDialog extends StatefulWidget {
  const DiscardReasonDialog({required this.reasons, super.key});
  final List<DiscardReason> reasons;

  @override
  State<DiscardReasonDialog> createState() => _DiscardReasonDialogState();
}

class _DiscardReasonDialogState extends State<DiscardReasonDialog> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final value = _controller.text;
      final selectedReason = widget.reasons.firstWhere(
        (reason) => reason.errorCode.toUpperCase() == value.toUpperCase(),
      );
      context.pop(selectedReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Responsive.dialogMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.enter_error_code, style: context.textTheme.titleMedium),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: l10n.enter_error_code,
                    border: const OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.done,
                  controller: _controller,
                  onFieldSubmitted: (value) {
                    _submit();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.field_cannot_be_empty;
                    }
                    final exists = widget.reasons.any(
                      (reason) => reason.errorCode.toUpperCase() == value.toUpperCase(),
                    );
                    if (!exists) {
                      return l10n.error_code_not_found;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        context.pop();
                      },
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submit,
                      child: Text(l10n.ok),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

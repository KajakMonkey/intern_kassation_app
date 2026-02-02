import 'dart:convert';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/routing/navigator.dart';

extension ErrorSheetX on BuildContext {
  Future<void> showErrorSheet({
    String? title,
    required AppFailure failure,
  }) {
    return showModalBottomSheet(
      context: this,
      isScrollControlled: true,

      backgroundColor: Colors.transparent,
      builder: (context) {
        return ErrorSheet(
          title: title,
          failure: failure,
        );
      },
    );
  }
}

class ErrorSheet extends StatelessWidget {
  const ErrorSheet({super.key, this.title, required this.failure});
  final String? title;
  final AppFailure failure;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(title!, style: textTheme.titleMedium),
                Gap.vs,
              ],

              Text(failure.getMessage(context.l10n), style: textTheme.bodyMedium),
              Gap.vm,

              Tag(
                text: failure.code.toString(),
                backgroundColor: colorScheme.errorContainer,
                textColor: colorScheme.onErrorContainer,
              ),

              Gap.vm,
              const Divider(),

              ElevatedButton(
                onPressed: () {
                  context.navigator.pushTechnicalDetailsPage(failure);
                },
                child: Text(context.l10n.view_technical_details),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LabeledValue extends StatelessWidget {
  const LabeledValue(this.label, this.value, {super.key, this.style});

  final String label;
  final String value;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final labelStyle = style ?? Theme.of(context).textTheme.bodySmall;
    final valueStyle = style ?? Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: labelStyle?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value, style: valueStyle)),
        ],
      ),
    );
  }
}

class PreformattedBlock extends StatelessWidget {
  const PreformattedBlock(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      fontFamily: 'monospace',
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(text, style: style),
      ),
    );
  }
}

class ErrorList extends StatelessWidget {
  const ErrorList(this.errors, {super.key});

  final Map<String, List<String>> errors;

  @override
  Widget build(BuildContext context) {
    final items = errors.entries
        .where((e) => e.value.isNotEmpty)
        .map((e) => _ErrorItem(field: e.key, messages: e.value))
        .toList();
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Field errors', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        ...items,
      ],
    );
  }
}

class Tag extends StatelessWidget {
  const Tag({required this.text, super.key, this.backgroundColor, this.textColor});
  final String text;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: textColor ?? colorScheme.onSurfaceVariant),
      ),
    );
  }
}

class _ErrorItem extends StatelessWidget {
  const _ErrorItem({required this.field, required this.messages});

  final String field;
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    final bulletStyle = Theme.of(context).textTheme.bodySmall;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(field, style: bulletStyle?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          ...messages.map(
            (m) => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(child: Text(m, style: bulletStyle)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

String prettyJson(Object? data, {String indent = '  '}) {
  final normalized = _normalizeForJson(data);
  const encoder = JsonEncoder.withIndent('  ');
  try {
    return encoder.convert(normalized);
  } catch (_) {
    // Fallback to a safe string when something isn't JSON-serializable
    return normalized?.toString() ?? '';
  }
}

dynamic _normalizeForJson(Object? value) {
  if (value == null) return null;

  if (value is Map) {
    return value.map((k, v) => MapEntry(k.toString(), _normalizeForJson(v)));
  }
  if (value is Iterable) {
    return value.map(_normalizeForJson).toList();
  }
  if (value is DateTime) {
    return value.toIso8601String();
  }
  if (value is Enum) {
    return value.name;
  }
  return value;
}

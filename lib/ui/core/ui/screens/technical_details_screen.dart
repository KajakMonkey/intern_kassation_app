import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/ui/core/ui/code_block.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/error_sheet.dart';

class TechnicalDetailsScreen extends StatefulWidget {
  const TechnicalDetailsScreen({
    super.key,
    required this.failure,
    this.redactKeys = const {'authorization', 'token', 'password', 'secret', 'apiKey'},
    this.title,
  });

  final AppFailure failure;
  final Set<String> redactKeys;
  final String? title;

  @override
  State<TechnicalDetailsScreen> createState() => _TechnicalDetailsPageState();
}

class _TechnicalDetailsPageState extends State<TechnicalDetailsScreen> {
  final _primaryController = ScrollController();

  @override
  void dispose() {
    _primaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final message = widget.failure.getMessage(context.l10n);
    final codeText = widget.failure.code.toString();

    // Prepare pretty JSON strings
    final contextPretty = prettyJson(
      widget.failure.context,
      redactKeys: widget.redactKeys,
    );

    final problemPretty = prettyJson(
      widget.failure.problemDetails?.toMap(),
      redactKeys: widget.redactKeys,
    );

    final errorsMap = widget.failure.problemDetails?.errors ?? const <String, List<String>>{};

    void copyAll() {
      final buffer = StringBuffer()
        ..writeln('Message: $message')
        ..writeln('Code: $codeText')
        ..writeln('\nContext:')
        ..writeln(contextPretty.isEmpty ? '(empty)' : contextPretty)
        ..writeln('\nProblemDetails:')
        ..writeln(problemPretty.isEmpty ? '(empty)' : problemPretty);
      Clipboard.setData(ClipboardData(text: buffer.toString()));
    }

    return Scaffold(
      //scrollable: false,
      appBar: AppBar(
        title: Text(widget.title ?? 'Error Details'),
        actions: [
          IconButton(
            tooltip: 'Copy',
            icon: const Icon(Icons.copy),
            onPressed: copyAll,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(message, style: textTheme.titleMedium),
            Gap.vs,
            Tag(
              text: codeText,
              backgroundColor: theme.colorScheme.errorContainer,
              textColor: theme.colorScheme.onErrorContainer,
            ),

            Gap.vm,
            const Divider(),

            const _SectionTitle('Context'),
            if ((widget.failure.context).isEmpty)
              const _Muted('No extra context provided.')
            else
              CodeBlock(contextPretty),

            Gap.vm,

            // ProblemDetails key fields
            const _SectionTitle('Problem Details'),
            if (widget.failure.problemDetails == null)
              const _Muted('No problem details available.')
            else ...[
              _keyValue(textTheme, 'type', widget.failure.problemDetails?.type),
              _keyValue(textTheme, 'title', widget.failure.problemDetails?.title),
              _keyValue(textTheme, 'status', widget.failure.problemDetails?.status?.toString()),
              _keyValue(textTheme, 'instance', widget.failure.problemDetails?.instance),
              _keyValue(textTheme, 'detail', widget.failure.problemDetails?.detail),
              _keyValue(textTheme, 'errorCode', widget.failure.problemDetails?.errorCode),
              Gap.vs,
              if (errorsMap.isNotEmpty) ...[
                const _SectionTitle('Field Errors'),
                ErrorList(errorsMap),
                Gap.vm,
              ],
              CodeBlock(problemPretty),
            ],
          ],
        ),
      ),
    );
  }

  Widget _keyValue(TextTheme textTheme, String key, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$key: ', style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
          Expanded(
            child: Text(value ?? '', style: textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

// -----------------------------
// Widgets
// -----------------------------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(text, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant));
  }
}

class ErrorList extends StatelessWidget {
  const ErrorList(this.errors, {super.key});
  final Map<String, List<String>> errors;

  @override
  Widget build(BuildContext context) {
    final items = errors.entries.where((e) => e.value.isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((e) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.key, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              Gap.vxs,
              ...e.value.map(
                (m) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(m, style: tt.bodySmall)),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// -----------------------------
// Pretty JSON helpers
// -----------------------------

String prettyJson(
  Object? data, {
  String indent = '  ',
  Set<String> redactKeys = const {},
}) {
  final normalized = _normalizeForJson(data, redactKeys: redactKeys.map((k) => k.toLowerCase()).toSet());
  final encoder = JsonEncoder.withIndent(indent);
  try {
    return encoder.convert(normalized);
  } catch (_) {
    return normalized?.toString() ?? '';
  }
}

dynamic _normalizeForJson(Object? value, {required Set<String> redactKeys}) {
  if (value == null) return null;

  if (value is Map) {
    return value.map((k, v) {
      final keyStr = k.toString();
      final shouldRedact = redactKeys.contains(keyStr.toLowerCase());
      return MapEntry(keyStr, shouldRedact ? '•••' : _normalizeForJson(v, redactKeys: redactKeys));
    });
  }
  if (value is Iterable) {
    return value.map((v) => _normalizeForJson(v, redactKeys: redactKeys)).toList();
  }
  if (value is DateTime) {
    return value.toIso8601String();
  }
  if (value is Enum) {
    return value.name;
  }
  return value;
}

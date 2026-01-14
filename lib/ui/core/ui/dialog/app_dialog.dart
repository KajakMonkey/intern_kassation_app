import 'package:intern_kassation_app/common_index.dart';

extension AppConfirmationDialogX on BuildContext {
  Future<bool> showConfirmationDialog({
    required String title,
    String? content,
    String? confirmText,
    String? cancelText,
    bool barrierDismissible = true,
    bool highlightCancelButton = false,
  }) async {
    final result = await showDialog<bool?>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AppConfirmationDialog(
          title: title,
          content: content,
          confirmButtonText: confirmText,
          cancelButtonText: cancelText,
          highlightCancelButton: highlightCancelButton,
        );
      },
    );

    return result ?? false;
  }
}

class AppConfirmationDialog extends StatelessWidget {
  const AppConfirmationDialog({
    super.key,
    required this.title,
    this.content,
    this.confirmButtonText,
    this.cancelButtonText,
    this.highlightCancelButton = false,
  });

  final String title;
  final String? content;
  final String? confirmButtonText;
  final String? cancelButtonText;
  final bool highlightCancelButton;

  @override
  Widget build(BuildContext context) {
    Widget cancelButton() {
      final label = cancelButtonText ?? context.l10n.no;
      if (highlightCancelButton) {
        return ElevatedButton(
          onPressed: () => context.pop(false),
          child: Text(label),
        );
      } else {
        return TextButton(
          onPressed: () => context.pop(false),
          child: Text(label),
        );
      }
    }

    Widget confirmButton() {
      final label = confirmButtonText ?? context.l10n.yes;
      if (highlightCancelButton) {
        return TextButton(
          onPressed: () => context.pop(true),
          child: Text(label),
        );
      } else {
        return ElevatedButton(
          onPressed: () => context.pop(true),
          child: Text(label),
        );
      }
    }

    return AlertDialog(
      title: Text(title),
      content: content != null ? Text(content!) : null,
      actions: [
        cancelButton(),
        confirmButton(),
      ],
    );
  }
}

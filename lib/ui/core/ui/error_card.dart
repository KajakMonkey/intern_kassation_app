import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.errorMessage, this.failure}) : onRetry = null;

  const ErrorCard.retry({
    super.key,
    required this.errorMessage,
    required this.onRetry,
    this.failure,
  });

  final String errorMessage;
  final AppFailure? failure;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: context.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              errorMessage,
              style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onErrorContainer),
            ),

            if (onRetry != null) ...[
              Gap.vs,
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onRetry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colorScheme.onErrorContainer,
                    foregroundColor: context.colorScheme.errorContainer,
                  ),
                  child: Text(context.l10n.try_again),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

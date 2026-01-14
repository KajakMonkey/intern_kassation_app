import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';

/// Shared header widget for discard reason selection
class DiscardReasonHeader extends StatelessWidget {
  const DiscardReasonHeader({
    required this.selectedReason,
    required this.reasons,
    required this.onManualSelect,
    this.showStaleWarning = false,
    super.key,
  });

  final DiscardReason? selectedReason;
  final List<DiscardReason> reasons;
  final Future<void> Function(List<DiscardReason>) onManualSelect;
  final bool showStaleWarning;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.select_reason_for_discard}: ${selectedReason?.errorCode ?? 'N/A'}',
            style: context.textTheme.titleMedium,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: () => onManualSelect(reasons),
                child: Text(l10n.enter_error_code),
              ),
              IconButton(
                onPressed: () {
                  final productType = context.read<DiscardCubit>().state.formData.productType;
                  context.read<DiscardCubit>().loadDiscardReasons(productType, forceRefresh: true);
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (showStaleWarning) _buildStaleWarning(context, l10n),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildStaleWarning(BuildContext context, AppLocalizations l10n) {
    return BlocBuilder<DiscardCubit, DiscardState>(
      buildWhen: (previous, current) => previous.discardReasonState != current.discardReasonState,
      builder: (context, state) {
        if (state.discardReasonState.status != DiscardReasonStatus.failure ||
            state.discardReasonState.failure == null) {
          return const SizedBox.shrink();
        }

        return Card(
          color: context.colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.using_stale_reasons_warning, style: context.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(
                  state.discardReasonState.failure!.getMessage(l10n),
                  style: context.textTheme.bodySmall!.copyWith(
                    color: context.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

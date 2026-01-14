import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/grouped_reason_item.dart';

/// Shared properties for layout widgets
class DiscardReasonLayoutProps {
  const DiscardReasonLayoutProps({
    required this.items,
    required this.discardState,
    required this.reasons,
    required this.manuallySelectErrorCode,
  });

  final List<GroupedReasonItem> items;
  final DiscardState discardState;
  final List<DiscardReason> reasons;
  final Future<void> Function(List<DiscardReason>) manuallySelectErrorCode;
}

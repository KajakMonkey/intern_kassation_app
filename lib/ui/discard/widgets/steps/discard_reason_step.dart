import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/core/ui/responsive.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/discard_reason_layout_props.dart';
import 'package:intern_kassation_app/ui/discard/models/grouped_reason_item.dart';
import 'package:intern_kassation_app/ui/discard/models/step_navigation_config.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_dialog.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_mobile_layout.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_tablet_layout.dart';

class DiscardReasonStep extends StatefulWidget {
  const DiscardReasonStep({
    required this.onNext,
    required this.onNavConfigChanged,
    super.key,
  });

  final VoidCallback onNext;
  final ValueChanged<StepNavigationConfig> onNavConfigChanged;

  @override
  State<DiscardReasonStep> createState() => _DiscardReasonStepState();
}

class _DiscardReasonStepState extends State<DiscardReasonStep> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNavConfig();
      _loadReasonsIfNeeded();
    });
  }

  void _syncNavConfig() {
    final hasSelection = context.read<DiscardCubit>().state.discardReasonState.selectedReason != null;
    widget.onNavConfigChanged(StepNavigationConfig.standard.copyWith(canProceed: hasSelection));
  }

  void _loadReasonsIfNeeded() {
    final state = context.read<DiscardCubit>().state;
    if (state.discardReasonState.status == DiscardReasonStatus.initial ||
        state.discardReasonState.status == DiscardReasonStatus.failure) {
      context.read<DiscardCubit>().loadDiscardReasons(state.formData.productType);
    }
  }

  List<GroupedReasonItem> _groupAndSortReasons(List<DiscardReason> reasons, AppLocalizations l10n) {
    final groupedReasons = <String?, List<DiscardReason>>{};
    for (final reason in reasons) {
      groupedReasons.putIfAbsent(reason.displayCategory, () => []).add(reason);
    }

    final items = <GroupedReasonItem>[const HeaderItem()];

    final categories = groupedReasons.keys.whereType<String>().toList()
      ..sort((a, b) => _compareByMinErrorCode(groupedReasons[a]!, groupedReasons[b]!));

    for (final category in categories) {
      items
        ..add(CategoryItem(category))
        ..addAll(groupedReasons[category]!.map(ReasonItem.new));
    }

    final uncategorized = groupedReasons[null];
    if (uncategorized != null) {
      final sorted = [...uncategorized]..sort((a, b) => _getMinErrorCode([a]).compareTo(_getMinErrorCode([b])));
      if (categories.isEmpty) {
        items.addAll(sorted.map(ReasonItem.new));
      } else {
        items
          ..add(CategoryItem(l10n.other))
          ..addAll(sorted.map(ReasonItem.new));
      }
    }

    return items;
  }

  int _compareByMinErrorCode(List<DiscardReason> a, List<DiscardReason> b) {
    return _getMinErrorCode(a).compareTo(_getMinErrorCode(b));
  }

  int _getMinErrorCode(List<DiscardReason> reasons) {
    return reasons
        .map((r) => int.tryParse(r.errorCode.replaceAll(RegExp('[^0-9]'), '')) ?? 0)
        .reduce((min, code) => code < min ? code : min);
  }

  Future<void> _manuallySelectErrorCode(List<DiscardReason> reasons) async {
    final selectedReason = await showDialog<DiscardReason?>(
      context: context,
      builder: (context) => DiscardReasonDialog(reasons: reasons),
    );
    if (selectedReason != null && mounted) {
      context.read<DiscardCubit>().onDiscardReasonSelected(selectedReason);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DiscardCubit, DiscardState>(
      listenWhen: (previous, current) => previous.discardReasonState != current.discardReasonState,
      listener: (context, state) {
        if (state.discardReasonState.status == DiscardReasonStatus.loading) {
          context.read<DiscardCubit>().onDiscardReasonSelected(null);
        }
        _syncNavConfig();
      },
      buildWhen: (previous, current) => previous.discardReasonState != current.discardReasonState,
      builder: (context, state) {
        return switch (state.discardReasonState.status) {
          DiscardReasonStatus.loading => const Center(child: CircularProgressIndicator()),
          DiscardReasonStatus.failure => _buildErrorState(context, state.discardReasonState),
          DiscardReasonStatus.loaded => _buildLoadedState(context, state.discardReasonState),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }

  Widget _buildErrorState(BuildContext context, DiscardReasonState state) {
    return Center(
      child: Text(state.failure!.getMessage(context.l10n)),
    );
  }

  Widget _buildLoadedState(BuildContext context, DiscardReasonState discardReasonState) {
    final discardState = context.watch<DiscardCubit>().state;
    final reasons = discardReasonState.reasons;
    final items = _groupAndSortReasons(reasons, context.l10n);

    final layoutProps = DiscardReasonLayoutProps(
      items: items,
      discardState: discardState,
      reasons: reasons,
      manuallySelectErrorCode: _manuallySelectErrorCode,
    );

    return Responsive.isTablet(context)
        ? DiscardReasonTabletLayout(props: layoutProps)
        : DiscardReasonMobileLayout(props: layoutProps);
  }
}

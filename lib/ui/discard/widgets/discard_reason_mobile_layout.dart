import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/models/models_index.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_category_header.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_dropdown.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_header.dart';

class DiscardReasonMobileLayout extends StatelessWidget {
  const DiscardReasonMobileLayout({required this.props, super.key});

  final DiscardReasonLayoutProps props;

  @override
  Widget build(BuildContext context) {
    return RadioGroup<DiscardReason>(
      onChanged: (value) => handleReasonSelection(context, value, props.discardState.dropdownValuesState),
      groupValue: props.discardState.discardReasonState.selectedReason,
      child: ListView.builder(
        itemCount: props.items.length,
        itemBuilder: (context, index) => _buildItem(context, props.items[index]),
      ),
    );
  }

  Widget _buildItem(BuildContext context, GroupedReasonItem item) {
    return switch (item) {
      HeaderItem() => DiscardReasonHeader(
        selectedReason: props.discardState.discardReasonState.selectedReason,
        reasons: props.reasons,
        onManualSelect: props.manuallySelectErrorCode,
      ),
      CategoryItem(:final name) => CategoryHeader(name: name),
      ReasonItem(:final reason) => _buildReasonTile(context, reason),
    };
  }

  Widget _buildReasonTile(BuildContext context, DiscardReason reason) {
    final isSelected = props.discardState.discardReasonState.selectedReason == reason;
    final showDropdown = reason.shownDropdownCategory != null && isSelected;

    return RadioListTile<DiscardReason>(
      title: Text(
        '${reason.errorCode} - ${reason.description}',
        style: isSelected
            ? context.textTheme.bodyLarge!.copyWith(
                color: context.colorScheme.onSecondaryContainer,
              )
            : null,
      ),
      subtitle: showDropdown ? DiscardReasonDropdown(reason: reason) : null,
      value: reason,
      selected: isSelected,
      selectedTileColor: context.colorScheme.secondaryContainer,
    );
  }
}

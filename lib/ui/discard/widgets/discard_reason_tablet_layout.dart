import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/models/discard_reason_layout_props.dart';
import 'package:intern_kassation_app/ui/discard/models/grouped_reason_item.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_category_header.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_dropdown.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_reason_header.dart';

class DiscardReasonTabletLayout extends StatelessWidget {
  const DiscardReasonTabletLayout({required this.props, super.key});

  final DiscardReasonLayoutProps props;

  @override
  Widget build(BuildContext context) {
    final widgets = _buildWidgetList(context);

    return RadioGroup<DiscardReason>(
      onChanged: (value) => handleReasonSelection(context, value, props.discardState.dropdownValuesState),
      groupValue: props.discardState.discardReasonState.selectedReason,
      child: ListView(children: widgets),
    );
  }

  List<Widget> _buildWidgetList(BuildContext context) {
    final widgets = <Widget>[];
    final categoryReasons = <DiscardReason>[];

    for (final item in props.items) {
      switch (item) {
        case HeaderItem():
          widgets.add(
            DiscardReasonHeader(
              selectedReason: props.discardState.discardReasonState.selectedReason,
              reasons: props.reasons,
              onManualSelect: props.manuallySelectErrorCode,
              showStaleWarning: true,
            ),
          );
        case CategoryItem(:final name):
          if (categoryReasons.isNotEmpty) {
            widgets.add(_buildReasonGrid(context, List.of(categoryReasons)));
            categoryReasons.clear();
          }
          widgets.add(CategoryHeader(name: name));
        case ReasonItem(:final reason):
          categoryReasons.add(reason);
      }
    }

    // Don't forget the last category's reasons
    if (categoryReasons.isNotEmpty) {
      widgets.add(_buildReasonGrid(context, categoryReasons));
    }

    return widgets;
  }

  Widget _buildReasonGrid(BuildContext context, List<DiscardReason> reasons) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemsPerRow = screenWidth > 800 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: itemsPerRow,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        mainAxisExtent: 110,
      ),
      itemCount: reasons.length,
      itemBuilder: (context, index) => _buildGridTile(context, reasons[index]),
    );
  }

  Widget _buildGridTile(BuildContext context, DiscardReason reason) {
    final isSelected = props.discardState.discardReasonState.selectedReason == reason;
    final showDropdown = reason.shownDropdownCategory != null && isSelected;

    return RadioListTile<DiscardReason>(
      title: Text(
        '${reason.errorCode} - ${reason.description}',
        style: context.textTheme.bodyMedium?.copyWith(
          color: isSelected ? context.colorScheme.onSecondaryContainer : null,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      value: reason,
      selected: isSelected,
      tileColor: isSelected ? context.colorScheme.secondaryContainer : Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? context.colorScheme.primary : context.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
      ),
      selectedTileColor: context.colorScheme.secondaryContainer,
      contentPadding: const EdgeInsets.all(4),
      subtitle: showDropdown ? DiscardReasonDropdown(reason: reason) : null,
    );
  }
}

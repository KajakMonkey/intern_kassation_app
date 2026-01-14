import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';

sealed class GroupedReasonItem {
  const GroupedReasonItem();
}

class HeaderItem extends GroupedReasonItem {
  const HeaderItem();
}

class CategoryItem extends GroupedReasonItem {
  const CategoryItem(this.name);
  final String name;
}

class ReasonItem extends GroupedReasonItem {
  const ReasonItem(this.reason);
  final DiscardReason reason;
}

void handleReasonSelection(
  BuildContext context,
  DiscardReason? value,
  DropdownValuesState dropdownState,
) {
  context.read<DiscardCubit>().onDiscardReasonSelected(value);

  if (value == null) return;

  final hasDropdown = value.shownDropdownCategory != null;
  final currentDropdown = dropdownState.selectedDropdownValue;

  if (hasDropdown) {
    // Clear dropdown if category changed
    if (currentDropdown != null && currentDropdown.category != value.shownDropdownCategory) {
      context.read<DiscardCubit>().onDropdownValueSelected(null);
    }
    context.read<DiscardCubit>().loadDropdownItems(value.shownDropdownCategory!);
  } else if (currentDropdown != null) {
    // Clear dropdown if new reason doesn't need one
    context.read<DiscardCubit>().onDropdownValueSelected(null);
  }
}

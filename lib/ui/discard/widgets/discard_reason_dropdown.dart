import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/discard/discard_reason.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/models/dropdown_value.dart';

class DiscardReasonDropdown extends StatelessWidget {
  const DiscardReasonDropdown({
    required this.reason,
    super.key,
  });

  final DiscardReason reason;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<DiscardCubit, DiscardState>(
      buildWhen: (previous, current) => previous.dropdownValuesState != current.dropdownValuesState,
      builder: (context, state) {
        return switch (state.dropdownValuesState.status) {
          DropdownValuesStatus.loaded => _buildDropdown(context, state.dropdownValuesState.items, l10n, state),
          DropdownValuesStatus.failure => _buildError(context, state.dropdownValuesState, l10n),
          _ => _buildLoading(context),
        };
      },
    );
  }

  Widget _buildDropdown(BuildContext context, List<String> items, AppLocalizations l10n, DiscardState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: InputDecorator(
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Text(l10n.select_a_machine),
            value: state.dropdownValuesState.selectedDropdownValue?.dropdownItem,
            items: items.map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
            onChanged: (selectedValue) {
              if (selectedValue == null) return;
              final category = reason.shownDropdownCategory!;

              context.read<DiscardCubit>().onDropdownValueSelected(
                DropdownValue(category: category, dropdownItem: selectedValue),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, DropdownValuesState state, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            state.failure?.getMessage(l10n) ?? l10n.an_error_occurred,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.error,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              context.read<DiscardCubit>().loadDropdownItems(reason.shownDropdownCategory!);
            },
            child: Text(l10n.try_again),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircularProgressIndicator(color: context.colorScheme.primary),
      ),
    );
  }
}

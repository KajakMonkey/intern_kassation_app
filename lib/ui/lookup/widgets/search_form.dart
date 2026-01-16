import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/lookup/cubits/lookup_cubit/lookup_cubit.dart';

class SearchForm extends StatelessWidget {
  const SearchForm({
    super.key,
    required this.textController,
    required this.formKey,
    required this.onSubmit,
    required this.readOnly,
  });
  final TextEditingController textController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSubmit;
  final bool readOnly;

  String? _validateOrderNumber(String? value, BuildContext context) {
    if (value == null || value.trim().isEmpty) {
      return context.l10n.field_cannot_be_empty;
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length < 3) {
      return context.l10n.minimum_three_letters_or_numbers;
    }

    final alphanumericCount = trimmedValue.replaceAll(RegExp('[^a-zA-Z0-9]'), '').length;
    if (alphanumericCount < 3) {
      return context.l10n.minimum_three_letters_or_numbers;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BlocBuilder<LookupCubit, LookupState>(
            builder: (context, state) {
              return Form(
                key: formKey,
                child: TextFormField(
                  controller: textController,
                  validator: (value) => _validateOrderNumber(value, context),
                  enabled: state != const LookupState.loading(),
                  readOnly: readOnly,
                  decoration: InputDecoration(
                    labelText: '${context.l10n.sales_id} / ${context.l10n.production_order}',
                    border: const OutlineInputBorder(),
                    helperText: context.l10n.minimum_three_letters_or_numbers,
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: onSubmit,
                    ),
                  ),
                  onFieldSubmitted: (value) {
                    if (formKey.currentState?.validate() ?? false) {
                      onSubmit();
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

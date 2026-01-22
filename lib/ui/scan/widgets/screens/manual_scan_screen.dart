import 'dart:async';

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/routing/navigator.dart';
import 'package:intern_kassation_app/ui/core/extensions/navigation_extension.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/app_dialog.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/error_sheet.dart';
import 'package:intern_kassation_app/ui/scan/cubit/scan_cubit.dart';

// TODO: on the scan screen, if this screen failed and then we go back, the error text remains.
class ManualScanScreen extends StatefulWidget {
  const ManualScanScreen({super.key});

  @override
  State<ManualScanScreen> createState() => _ManualScanScreenState();
}

class _ManualScanScreenState extends State<ManualScanScreen> {
  late final TextEditingController _ordrenrController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _ordrenrController = TextEditingController();
  }

  @override
  void dispose() {
    _ordrenrController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    final latestReportState = context.read<ScanCubit>().state.latestDiscardedStatus;
    final prodId = _ordrenrController.text.toUpperCase().trim();

    await latestReportState.maybeWhen(
      success: (discardedOrders) async {
        final alreadyDiscarded = discardedOrders.any((stateId) => stateId == prodId);

        if (!alreadyDiscarded) {
          unawaited(context.read<ScanCubit>().fetchOrderDetails(prodId));
          return;
        }

        if (!mounted) {
          return;
        }

        final result = await context.showConfirmationDialog(
          title: context.l10n.production_order_already_discarded_recently,
          content: '${context.l10n.production_order}: ${_ordrenrController.text}',
          confirmText: context.l10n.discard_again,
          cancelText: context.l10n.cancel,
        );

        if (result != true) {
          return;
        }

        if (!mounted) {
          return;
        }

        unawaited(context.read<ScanCubit>().fetchOrderDetails(prodId));
      },
      orElse: () {
        if (!mounted) {
          return;
        }

        unawaited(context.read<ScanCubit>().fetchOrderDetails(prodId));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocConsumer<ScanCubit, ScanState>(
      listenWhen: (previous, current) => previous.orderStatus != current.orderStatus,
      listener: (context, state) {
        state.orderStatus.maybeWhen(
          success: (details) {
            _ordrenrController.clear();
            context.navigator.pushDiscardPage(
              salesId: details.salesId,
              worktop: details.worktop,
              productType: details.productType,
              productGroup: details.productGroup,
              produktionsOrder: details.productionOrder,
            );
          },
          failure: (failure) {
            if (failure.code == OrderErrorCodes.orderNotFound ||
                failure.code == ProductErrorCodes.invalidProductType ||
                failure.code == ProductErrorCodes.invalidProductGroup) {
              setState(() {
                _errorText = failure.getMessage(l10n);
              });
              return;
            }
            context.showErrorSheet(failure: failure);
          },
          orElse: () {},
        );
      },
      buildWhen: (previous, current) => previous.orderStatus != current.orderStatus,
      builder: (context, state) {
        return PopScope(
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            if (state.orderStatus == const OrderState.loading()) {
              return;
            }

            context.read<ScanCubit>().clearOrderStatus();
            context.maybePopElse(Routes.scan.name);
          },
          child: AppScaffold.withLoadingIndicator(
            appBar: AppBar(
              title: Text(context.l10n.manual_entry),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: state.orderStatus != const OrderState.loading()
                    ? () {
                        context.read<ScanCubit>().clearOrderStatus();
                        context.maybePopElse(Routes.scan.name);
                      }
                    : null,
              ),
            ),
            scrollable: true,
            isLoading: state.orderStatus == const OrderState.loading(),
            body: Column(
              children: [
                Text(
                  context.l10n.enter_a_production_order,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
                Gap.vm,
                TextField(
                  decoration: InputDecoration(
                    labelText: context.l10n.production_order,
                    border: const OutlineInputBorder(),
                    errorText: _errorText,
                    suffixIcon: state.orderStatus != const OrderState.loading() && _ordrenrController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _ordrenrController.clear();
                              setState(() {
                                _errorText = null;
                              });
                            },
                          )
                        : null,
                  ),
                  enabled: state.orderStatus != const OrderState.loading(),
                  controller: _ordrenrController,
                  onChanged: (value) {
                    setState(() {
                      _errorText = null;
                    });
                  },
                ),
                Gap.vl,
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _ordrenrController.text.isNotEmpty && state.orderStatus != const OrderState.loading()
                        ? _submitForm
                        : null,
                    label: Text(context.l10n.next),
                    icon: const Icon(Icons.arrow_forward),
                    iconAlignment: IconAlignment.end,
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

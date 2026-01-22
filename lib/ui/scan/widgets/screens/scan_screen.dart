import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/error_codes_index.dart';
import 'package:intern_kassation_app/routing/navigator.dart';
import 'package:intern_kassation_app/routing/router.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/app_dialog.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/error_sheet.dart';
import 'package:intern_kassation_app/ui/scan/cubit/scan_cubit.dart';
import 'package:intern_kassation_app/ui/scan/widgets/latest_discarded_list.dart';
import 'package:intern_kassation_app/ui/scan/widgets/scan_drawer.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with RouteAware {
  late final TextEditingController _ordrenrController;
  late final FocusNode _keyboardFocusNode;
  String? _errorText;

  final _scanBuffer = StringBuffer();
  Timer? _scanDebounce;
  DateTime? _lastKeyTs;

  static const _scanInterKeyMax = Duration(milliseconds: 40); // keys closer than this -> likely scanner
  static const _scanTimeout = Duration(milliseconds: 120); // no key for this long -> flush (human typing)

  @override
  void initState() {
    super.initState();
    _ordrenrController = TextEditingController();
    _keyboardFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scanRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    scanRouteObserver.unsubscribe(this);
    _scanDebounce?.cancel();
    _ordrenrController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    // Called when returning to this screen (covering route was popped)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void didPush() {
    // Called when this route is pushed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _keyboardFocusNode.requestFocus();
      }
    });
  }

  @override
  void didPushNext() {
    // Called when a new route is pushed on top of this one
    _keyboardFocusNode.unfocus();
  }

  void _onKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || key == LogicalKeyboardKey.tab) {
      _commitScan();
      return;
    }

    final character = event.character;
    if (character == null || character.isEmpty) {
      return;
    }

    final now = DateTime.now();
    if (_lastKeyTs != null && now.difference(_lastKeyTs!) > _scanInterKeyMax) {
      _scanBuffer.clear();
    }
    _lastKeyTs = now;

    _scanBuffer.write(character);

    _scanDebounce?.cancel();
    _scanDebounce = Timer(_scanTimeout, _commitScan);
  }

  void _commitScan() {
    _scanDebounce?.cancel();
    final value = _scanBuffer.toString().trim();
    _scanBuffer.clear();
    _lastKeyTs = null;

    if (value.isEmpty) {
      return;
    }

    _ordrenrController.text = value;
    setState(() {});
    _submitForm();
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
            context.navigator.goDiscardPage(
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
        return KeyboardListener(
          focusNode: _keyboardFocusNode,
          autofocus: true,
          onKeyEvent: _onKeyEvent,
          child: AppScaffold.withLoadingIndicator(
            appBar: AppBar(
              title: Text(l10n.app_name),
              actions: [
                if (!Platform.isWindows)
                  IconButton(
                    icon: const Icon(Icons.qr_code_2),
                    onPressed: state.orderStatus != const OrderState.loading()
                        ? () async {
                            final result = await context.pushNamed(Routes.cameraScan.name);

                            if (result is String && result.isNotEmpty) {
                              _ordrenrController.text = result;
                              setState(() {});
                              unawaited(_submitForm());
                            }
                          }
                        : null,
                  ),
              ],
            ),
            drawer: state.orderStatus != const OrderState.loading()
                ? ScanDrawer(
                    onResetScanner: () {
                      context.read<ScanCubit>().clearOrderStatus();

                      _keyboardFocusNode.requestFocus();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.l10n.scanner_reset),
                        ),
                      );
                    },
                  )
                : null,
            scrollable: true,
            isLoading: state.orderStatus == const OrderState.loading(),
            body: GestureDetector(
              onTap: () => _keyboardFocusNode.requestFocus(),
              behavior: HitTestBehavior.translucent,
              child: Column(
                children: [
                  Text(
                    context.l10n.scan_entry,
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
                                _keyboardFocusNode.requestFocus();
                              },
                            )
                          : null,
                    ),
                    readOnly: true,
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
                  Gap.vl,
                  ElevatedButton(
                    onPressed: () {
                      context.navigator.pushDiscardPage(
                        salesId: 'tst123',
                        worktop: 'A',
                        productType: ProductType.unknown,
                        productGroup: 'GA',
                        produktionsOrder: 'test123',
                      );
                    },
                    child: Text('to test page'),
                  ),
                  const LatestDiscardedList(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

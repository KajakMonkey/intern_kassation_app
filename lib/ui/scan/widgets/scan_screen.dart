import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/env.dart';
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
  String? _errorText;
  bool _useHardwareScanner = EnvManager.useHardwareScanner;

  final _scanBuffer = StringBuffer();
  Timer? _scanDebounce;
  DateTime? _lastKeyTs;

  static const _scanInterKeyMax = Duration(milliseconds: 40); // keys closer than this -> likely scanner
  static const _scanTimeout = Duration(milliseconds: 120); // no key for this long -> flush (human typing)

  @override
  void initState() {
    super.initState();
    _ordrenrController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    scanRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    scanRouteObserver.unsubscribe(this);

    if (_useHardwareScanner) {
      HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    }
    _scanDebounce?.cancel();
    _ordrenrController.dispose();

    super.dispose();
  }

  @override
  void didPush() {
    // Route was pushed onto navigator and is now current.
    if (_useHardwareScanner) {
      HardwareKeyboard.instance.addHandler(_onHardwareKey);
    }
  }

  @override
  void didPopNext() {
    // Covering route was popped off the navigator.
    if (_useHardwareScanner) {
      HardwareKeyboard.instance.addHandler(_onHardwareKey);
    }
  }

  @override
  void didPop() {
    // Route was popped off the navigator.
    if (_useHardwareScanner) {
      HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    }
  }

  @override
  void didPushNext() {
    // Another route was pushed onto the navigator.
    if (_useHardwareScanner) {
      HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    }
  }

  bool _onHardwareKey(KeyEvent event) {
    if (event is! KeyDownEvent) {
      return false;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter || key == LogicalKeyboardKey.tab) {
      _commitScan();
      return true;
    }

    final character = event.character;
    if (character == null || character.isEmpty) {
      return false;
    }

    final now = DateTime.now();
    if (_lastKeyTs != null && now.difference(_lastKeyTs!) > _scanInterKeyMax) {
      _scanBuffer.clear();
    }
    _lastKeyTs = now;

    _scanBuffer.write(character);

    _scanDebounce?.cancel();
    _scanDebounce = Timer(_scanTimeout, _commitScan);

    return true;
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
            context.navigator.pushDiscardPage(
              salesId: details.salesId,
              worktop: details.worktop,
              productType: details.productType,
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
        return AppScaffold.withLoadingIndicator(
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
          drawer: state.orderStatus != const OrderState.loading() ? const ScanDrawer() : null,
          scrollable: true,
          isLoading: state.orderStatus == const OrderState.loading(),
          body: Column(
            children: [
              Text(
                context.l10n.scan_or_manual_entry,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              Gap.vs,
              SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(context.l10n.scan_use_hardware_scanner),
                    icon: const Icon(Icons.scanner),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(context.l10n.scan_manual_entry),
                    icon: const Icon(Icons.keyboard),
                  ),
                ],
                selected: {_useHardwareScanner},
                onSelectionChanged: state.orderStatus != const OrderState.loading()
                    ? (newSelection) {
                        final useScanner = newSelection.first;
                        if (useScanner) {
                          HardwareKeyboard.instance.addHandler(_onHardwareKey);
                        } else {
                          HardwareKeyboard.instance.removeHandler(_onHardwareKey);
                        }
                        setState(() {
                          _useHardwareScanner = useScanner;
                        });
                      }
                    : null,
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
                readOnly: state.orderStatus == const OrderState.loading() || _useHardwareScanner,
                enabled: state.orderStatus != const OrderState.loading(),
                controller: _ordrenrController,
                textInputAction: .done,
                onChanged: (value) {
                  setState(() {
                    _errorText = null;
                  });
                },
                onSubmitted: (value) {
                  if (value.isNotEmpty && state.orderStatus != const OrderState.loading()) {
                    unawaited(_submitForm());
                  }
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
                  iconAlignment: .end,
                ),
              ),
              Gap.vl,
              const LatestDiscardedList(),
            ],
          ),
        );
      },
    );
  }
}

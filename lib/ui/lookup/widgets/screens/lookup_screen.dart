import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/routing/router.dart';
import 'package:intern_kassation_app/ui/core/ui/dialog/error_sheet.dart';
import 'package:intern_kassation_app/ui/core/ui/shimmer_effect.dart';
import 'package:intern_kassation_app/ui/lookup/cubits/lookup_cubit/lookup_cubit.dart';
import 'package:intern_kassation_app/ui/lookup/widgets/discarded_orders_list.dart';
import 'package:intern_kassation_app/ui/lookup/widgets/search_form.dart';

class LookupScreen extends StatefulWidget {
  const LookupScreen({super.key});

  @override
  State<LookupScreen> createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> with RouteAware {
  late final TextEditingController _controller;
  late final FocusNode _keyboardFocusNode;
  final _formKey = GlobalKey<FormState>();

  var _useHardwareScanner = false;

  final _scanBuffer = StringBuffer();
  Timer? _scanDebounce;
  DateTime? _lastKeyTs;

  static const _scanInterKeyMax = Duration(milliseconds: 40);
  static const _scanTimeout = Duration(milliseconds: 120);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _keyboardFocusNode = FocusNode();

    if (_useHardwareScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _keyboardFocusNode.requestFocus();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    orderLookupRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    orderLookupRouteObserver.unsubscribe(this);
    _scanDebounce?.cancel();
    _controller.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    if (_useHardwareScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _keyboardFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didPush() {
    if (_useHardwareScanner) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _keyboardFocusNode.requestFocus();
        }
      });
    }
  }

  @override
  void didPushNext() {
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

    if (value.isNotEmpty) {
      _controller.text = value;
    }

    _lookupOrders();
  }

  void _lookupOrders() {
    if (_formKey.currentState?.validate() ?? false) {
      final query = _controller.text.trim();
      unawaited(context.read<LookupCubit>().lookupDiscardedOrders(query));
    }
  }

  void _toggleScannerMode(bool useScanner) {
    setState(() {
      _useHardwareScanner = useScanner;
    });

    if (useScanner) {
      _keyboardFocusNode.requestFocus();
    } else {
      _keyboardFocusNode.unfocus();
    }

    // Clear scan buffer when switching modes
    _scanBuffer.clear();
    _lastKeyTs = null;
    _scanDebounce?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: _useHardwareScanner,
      onKeyEvent: _useHardwareScanner ? _onKeyEvent : null,
      child: AppScaffold(
        appBar: AppBar(
          title: Text(context.l10n.discard_lookup_page_title),
        ),
        padding: EdgeInsets.zero,
        scrollable: false,
        body: GestureDetector(
          onTap: _useHardwareScanner ? () => _keyboardFocusNode.requestFocus() : null,
          behavior: HitTestBehavior.translucent,
          child: Column(
            children: [
              BlocBuilder<LookupCubit, LookupState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Gap.m),
                    child: SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(
                          value: false,
                          label: Text(context.l10n.manual_entry),
                          icon: const Icon(Icons.keyboard),
                        ),
                        ButtonSegment(
                          value: true,
                          label: Text(context.l10n.scan_use_hardware_scanner),
                          icon: const Icon(Icons.scanner),
                        ),
                      ],
                      selected: {_useHardwareScanner},
                      onSelectionChanged: state != const LookupState.loading()
                          ? (newSelection) => _toggleScannerMode(newSelection.first)
                          : null,
                    ),
                  );
                },
              ),
              Gap.vs,
              SearchForm(
                textController: _controller,
                formKey: _formKey,
                onSubmit: _lookupOrders,
                readOnly: _useHardwareScanner,
              ),
              Gap.vs,
              Expanded(
                child: BlocBuilder<LookupCubit, LookupState>(
                  builder: (context, state) {
                    return state.when(
                      initial: () {
                        return const SizedBox.shrink();
                      },
                      loading: () {
                        return ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) => const ShimmerEffect.listTile(),
                        );
                      },
                      loaded: (data, query) {
                        if (data.items.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(Gap.m),
                            child: Column(
                              crossAxisAlignment: .center,
                              mainAxisAlignment: .center,
                              children: [
                                Icon(Icons.search_off, size: 48, color: context.theme.hintColor),
                                Gap.vs,
                                Text(
                                  context.l10n.discard_lookup_no_results,
                                  textAlign: .center,
                                ),
                              ],
                            ),
                          );
                        }

                        final hasNextPage = data.nextCursor != null;
                        final hasPreviousPage = data.previousCursor != null;

                        return DiscardedOrdersList(
                          query: query,
                          items: data.items,
                          canGoNext: hasNextPage,
                          canGoPrevious: hasPreviousPage,
                        );
                      },
                      failure: (failure) {
                        return Center(
                          child: Column(
                            children: [
                              Text(
                                failure.getMessage(context.l10n),
                                style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.error),
                              ),
                              Gap.vs,
                              ElevatedButton(
                                onPressed: () {
                                  context.showErrorSheet(failure: failure);
                                },
                                child: Text(context.l10n.view_error_details),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

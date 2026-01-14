import 'dart:async';

import 'package:flutter/services.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/env.dart';
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
  final _formKey = GlobalKey<FormState>();

  bool _useHardwareScanner = EnvManager.useHardwareScanner;

  final _scanBuffer = StringBuffer();
  Timer? _scanDebounce;
  DateTime? _lastKeyTs;

  static const _scanInterKeyMax = Duration(milliseconds: 40); // keys closer than this -> likely scanner
  static const _scanTimeout = Duration(milliseconds: 120); // no key for this long -> flush (human typing)

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    orderLookupRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    if (_useHardwareScanner) {
      HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    }
    _scanDebounce?.cancel();
    orderLookupRouteObserver.unsubscribe(this);
    _controller.dispose();
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
      _lookupOrders();
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
    _scanDebounce = Timer(_scanTimeout, _lookupOrders);

    return true;
  }

  void _lookupOrders() {
    if (_formKey.currentState?.validate() ?? false) {
      final query = _controller.text.trim();
      unawaited(context.read<LookupCubit>().lookupDiscardedOrders(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.l10n.discard_lookup_page_title),
      ),
      padding: EdgeInsets.zero,
      scrollable: false,
      body: Column(
        children: [
          BlocBuilder<LookupCubit, LookupState>(
            builder: (context, state) {
              return SegmentedButton<bool>(
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
                onSelectionChanged: state != const LookupState.loading()
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
              );
            },
          ),
          Gap.vs,
          SearchForm(
            textController: _controller,
            formKey: _formKey,
            onSubmit: _lookupOrders,
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
                      return Column(
                        children: [
                          Icon(Icons.info, size: 48, color: context.theme.hintColor),
                          Gap.vs,
                          Text(context.l10n.discard_lookup_no_results),
                        ],
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
    );
  }
}

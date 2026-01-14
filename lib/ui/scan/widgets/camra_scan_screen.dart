import 'package:intern_kassation_app/common_index.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraScanScreen extends StatefulWidget {
  const CameraScanScreen({super.key});

  @override
  State<CameraScanScreen> createState() => _CameraScanScreenState();
}

class _CameraScanScreenState extends State<CameraScanScreen> {
  late final MobileScannerController _controller;
  var hasScanned = false;
  var isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Size layoutSize = constraints.biggest;

            final double scanWindowWidth = layoutSize.width * 0.9;
            final double scanWindowHeight = layoutSize.height * 0.25;
            final scanWindow = Rect.fromCenter(
              center: layoutSize.center(Offset.zero),
              width: scanWindowWidth,
              height: scanWindowHeight,
            );
            return Stack(
              children: [
                MobileScanner(
                  scanWindow: isFullScreen ? null : scanWindow,
                  controller: _controller,
                  onDetect: (result) async {
                    if (hasScanned) {
                      return;
                    }
                    final String code = result.barcodes.first.rawValue ?? '';
                    if (code.isEmpty) {
                      return;
                    }
                    hasScanned = true;

                    final bottomSheetResult = await showModalBottomSheet<bool>(
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.correct_barcode_dialog,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(code, style: context.textTheme.bodyLarge),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.pop(false);
                                        },
                                        child: Text(context.l10n.no),
                                      ),
                                    ),
                                    Gap.hm,
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          context.pop(true);
                                        },
                                        child: Text(context.l10n.yes),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );

                    if (bottomSheetResult != null && bottomSheetResult && context.mounted) {
                      context.pop(code);
                    } else {
                      hasScanned = false;
                    }
                  },
                  onDetectError: (error, stackTrace) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(context.l10n.barcode_scan_error),
                      ),
                    );
                  },
                ),
                if (!isFullScreen)
                  ScanWindowOverlay(
                    scanWindow: scanWindow,
                    controller: _controller,
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      context.l10n.scan_a_barcode,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          isFullScreen = !isFullScreen;
                        });
                      },
                      icon: Icon(
                        isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

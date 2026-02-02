import 'dart:io';

import 'package:flutter/services.dart';

class BarcodeStream {
  static const _channel = EventChannel('com.geisler.intern_kassation_app/barcode');

  // Only works on Android
  static Stream<String> get stream {
    assert(Platform.isAndroid, 'BarcodeStream is only available on Android');
    return _channel.receiveBroadcastStream().map((event) => event.toString());
  }
}

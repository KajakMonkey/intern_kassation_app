import 'dart:io';

import 'package:flutter/services.dart';

Future<void> setTrustedCertificates() async {
  final ByteData data = await PlatformAssetBundle().load('assets/certs/rootCA.cer');
  SecurityContext.defaultContext.setTrustedCertificatesBytes(data.buffer.asUint8List());
}

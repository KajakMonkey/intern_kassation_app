import 'package:flutter/foundation.dart';
import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/dependencies.dart';
import 'package:intern_kassation_app/config/env.dart';
import 'package:intern_kassation_app/main.dart';
import 'package:intern_kassation_app/utils/app_bloc_observer.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

void main() async {
  await EnvManager.init(Environment.development);
  await setTrustedCertificates();
  Logger.root.level = Level.ALL;

  Logger('MainDevelopment').info('Starting app in DEVELOPMENT mode with API URL: ${EnvManager.apiUrl}');

  if (!kReleaseMode) {
    Bloc.observer = AppBlocObserver();
  }

  runApp(MultiProvider(providers: sharedProviders, child: const MainApp()));
}

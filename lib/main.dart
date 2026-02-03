import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/dependencies.dart';
import 'package:intern_kassation_app/config/env/env.dart';
import 'package:intern_kassation_app/routing/router.dart';
import 'package:intern_kassation_app/ui/core/themes/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  await EnvManager.init(Environment.production);
  await setTrustedCertificates();
  runApp(MultiProvider(providers: sharedProviders, child: const MainApp()));
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = router(context.read());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      routerConfig: _router,
    );
  }
}

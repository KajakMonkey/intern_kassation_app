import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/assets.dart';
import 'package:intern_kassation_app/ui/core/extensions/image_cache_size_extension.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Assets.logo,
              fit: BoxFit.contain,
              cacheHeight: 94.cacheSize(context),
              height: 94,
            ),
            Gap.vs,
            Text(
              context.l10n.app_name,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Gap.vl,
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

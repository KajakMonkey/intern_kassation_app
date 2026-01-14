import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/assets.dart';
import 'package:intern_kassation_app/ui/core/extensions/buildcontext_extension.dart';
import 'package:intern_kassation_app/ui/core/extensions/navigation_extension.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ScanDrawer extends StatelessWidget {
  const ScanDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              context.l10n.app_name,
              style: const TextStyle(fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: Text(context.l10n.account_page_title),
            onTap: () {
              context
                ..unfocus()
                ..maybePop()
                ..pushNamed(Routes.account.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Tidligere Kassationer'),
            onTap: () {
              context
                ..unfocus()
                ..maybePop()
                ..pushNamed(Routes.lookup.name);
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(context.l10n.about_app),
            onTap: () async {
              final PackageInfo packageInfo = await PackageInfo.fromPlatform();
              if (context.mounted) {
                showAboutDialog(
                  context: context,
                  applicationIcon: Image.asset(
                    Assets.logo,
                    width: 48,
                    height: 48,
                  ),
                  applicationName: packageInfo.appName,
                  applicationVersion: '${packageInfo.version} - build ${packageInfo.buildNumber}',
                  applicationLegalese: '©2025 DFI-Geisler A/S',
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

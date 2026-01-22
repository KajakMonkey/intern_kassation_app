import 'package:intern_kassation_app/common_index.dart';

class PageNotFoundScreen extends StatelessWidget {
  const PageNotFoundScreen({super.key, this.error, this.uri});
  final GoException? error;
  final Uri? uri;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.l10n.page_not_found_title),
        leading: IconButton(
          onPressed: () {
            context.goNamed(Routes.scan.name);
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: .center,
          children: [
            Gap.vxl,
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            Gap.vm,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.m),
              child: Text(
                context.l10n.page_not_found_description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            if (uri != null) ...[
              Gap.vl,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Gap.m),
                child: Text(
                  context.l10n.page_not_found_requested_uri(uri!.toString()),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
            Gap.vl,
            FilledButton.icon(
              onPressed: () {
                context.goNamed(Routes.scan.name);
              },
              label: Text(context.l10n.go_to_main_menu),
              icon: const Icon(Icons.home),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/core/ui/shimmer_effect.dart';
import 'package:intern_kassation_app/ui/scan/cubit/scan_cubit.dart';

class LatestDiscardedList extends StatelessWidget {
  const LatestDiscardedList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ScanCubit, ScanState>(
      buildWhen: (previous, current) => previous.latestDiscardedStatus != current.latestDiscardedStatus,
      builder: (context, state) {
        final List<String> items = state.latestDiscardedStatus.maybeWhen(
          success: (discardedList) => discardedList,
          orElse: () => [],
        );
        if (state.latestDiscardedStatus == const LatestDiscardedState.loading()) {
          return ShimmerEffect(
            child: Card(
              child: Column(
                children: List.generate(
                  3,
                  (index) => const ListTile(),
                ),
              ),
            ),
          );
        }
        if (items.isEmpty) {
          return const SizedBox.shrink();
        }
        return Card(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                child: Text(
                  context.l10n.latest_discarded_items,
                  style: context.textTheme.bodyLarge,
                ),
              ),
              const Divider(endIndent: 8, indent: 8),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(endIndent: 8, indent: 8),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final discarded = items[index];
                  if (discarded.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(title: SelectableText(discarded));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

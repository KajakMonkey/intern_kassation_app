import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_preview.dart';
import 'package:intern_kassation_app/routing/navigator.dart';
import 'package:intern_kassation_app/ui/core/extensions/buildcontext_extension.dart';
import 'package:intern_kassation_app/ui/lookup/cubits/lookup_cubit/lookup_cubit.dart';
import 'package:intern_kassation_app/utils/extensions/date_extension.dart';

class DiscardedOrdersList extends StatelessWidget {
  const DiscardedOrdersList({
    required this.query,
    required this.items,
    required this.canGoNext,
    required this.canGoPrevious,
    super.key,
  });
  final String query;
  final List<DiscardedOrderPreview> items;
  final bool canGoNext;
  final bool canGoPrevious;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverList.separated(
            separatorBuilder: (context, index) => const Divider(height: 0),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final discard = items[index];
              return ListTile(
                title: Text('${discard.prodId} - ${discard.discardedAtUtc.formatFromUtc()}'),
                subtitle: Text(
                  '${context.l10n.product_group}: ${discard.productType}\n${context.l10n.error_code}: ${discard.errorCode}\n${context.l10n.description}: ${discard.errorDescription ?? '???'}',
                ),
                isThreeLine: true,
                onTap: () {
                  context.unfocus();
                  context.navigator.pushLookupDetails(discard.id);
                },
              );
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.s, vertical: Gap.m),
              child: Row(
                mainAxisAlignment: .spaceBetween,

                children: [
                  Expanded(
                    child: canGoPrevious
                        ? FilledButton.icon(
                            onPressed: () {
                              context.read<LookupCubit>().lookupPreviousPage(query);
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                            label: Text(context.l10n.previous_page),
                          )
                        : const SizedBox.shrink(),
                  ),
                  Gap.hm,
                  Expanded(
                    child: canGoNext
                        ? FilledButton.icon(
                            onPressed: () {
                              context.read<LookupCubit>().lookupNextPage(query);
                            },
                            iconAlignment: IconAlignment.end,
                            icon: const Icon(Icons.arrow_forward_ios),
                            label: Text(context.l10n.next_page),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

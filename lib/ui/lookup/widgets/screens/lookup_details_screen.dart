import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/domain/models/order/discarded_order_details.dart';
import 'package:intern_kassation_app/ui/core/ui/shimmer_effect.dart';
import 'package:intern_kassation_app/ui/lookup/cubits/lookup_details_cubit/lookup_details_cubit.dart';
import 'package:intern_kassation_app/utils/extensions/date_extension.dart';

class LookupDetailsScreen extends StatelessWidget {
  const LookupDetailsScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(context.l10n.discard_details_title),
      ),
      scrollable: true,
      body: BlocBuilder<LookupDetailsCubit, LookupDetailsState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (details) {
              return DetailsWidget(details: details);
            },
            failure: (failure) {
              return Center(child: Text(failure.getMessage(context.l10n)));
            },
            orElse: () => const DetailsShimmer(),
          );
        },
      ),
    );
  }
}

class DetailsWidget extends StatelessWidget {
  const DetailsWidget({super.key, required this.details});
  final DiscardedOrderDetails details;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        _buildInfoCard(
          context,
          title: l10n.order_information,
          children: [
            _buildInfoRow(l10n.sales_id, details.salesId),
            _buildInfoRow(l10n.production_order, details.prodId),
            _buildInfoRow(l10n.worktop, details.worktop),
            _buildInfoRow(l10n.date, details.discardedAtUtc.formatFromUtc()),
          ],
        ),

        _buildInfoCard(
          context,
          title: l10n.employee,
          children: [
            _buildInfoRow(l10n.employee_number, details.employeeId),
          ],
        ),

        _buildInfoCard(
          context,
          title: l10n.reason_for_discard,
          children: [
            _buildInfoRow(l10n.code, details.errorCode),
            _buildInfoRow(
              l10n.description,
              details.errorDescription ?? '???',
            ),
            if (details.machineName != null && details.machineName!.isNotEmpty)
              _buildInfoRow(l10n.machine, details.machineName!),
          ],
        ),

        _buildInfoCard(
          context,
          title: l10n.free_text_elaboration,
          children: [
            Text(details.note.isNotEmpty ? details.note : ''),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 3,
            child: SelectableText(value.isNotEmpty ? value : '-'),
          ),
        ],
      ),
    );
  }
}

class DetailsShimmer extends StatelessWidget {
  const DetailsShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        _ShimmerCard(lines: 4),
        _ShimmerCard(lines: 1),
        _ShimmerCard(lines: 2),
        _ShimmerCard(lines: 2),
      ],
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard({required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerEffect(
              child: SizedBox(
                width: 160,
                height: 14,
                child: DecoratedBox(
                  decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 4),
            ...List.generate(lines, (_) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: ShimmerEffect(
                        child: SizedBox(
                          height: 12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFE0E0E0)),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: ShimmerEffect(
                        child: SizedBox(
                          height: 12,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Color(0xFFE0E0E0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

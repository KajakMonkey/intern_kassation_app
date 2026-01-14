import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/ui/core/ui/shimmer_effect.dart';

class AccountLoading extends StatelessWidget {
  const AccountLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerEffect(
      child: Column(
        children: [
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(context.l10n.username_label),
                  subtitle: Text(context.l10n.account_page_anonymous),
                  trailing: const IconButton(
                    icon: Icon(Icons.copy),
                    onPressed: null,
                  ),
                ),
                const Divider(height: 0, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.vpn_key),
                  title: Text(context.l10n.account_page_session_id_label),
                  subtitle: Text(context.l10n.account_page_no_session),
                ),
              ],
            ),
          ),
          Gap.vl,
          SizedBox(
            width: double.infinity,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:intern_kassation_app/common_index.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/routing/parameters.dart';

class AppNavigator {
  const AppNavigator(this.context);
  final BuildContext context;

  void pushTechnicalDetailsPage(AppFailure failure) => context.pushNamed(Routes.technicalDetails.name, extra: failure);

  void pushDiscardPage({
    required String salesId,
    required String worktop,
    required ProductType productType,
    required String productGroup,
    required String produktionsOrder,
  }) {
    context.pushNamed(
      Routes.discard.name,
      queryParameters: {
        DiscardRouteParams.salesId: salesId,
        DiscardRouteParams.worktop: worktop,
        DiscardRouteParams.productType: productType.code,
        DiscardRouteParams.productGroup: productGroup,
        DiscardRouteParams.produktionsOrder: produktionsOrder,
      },
    );
  }

  void goDiscardPage({
    required String salesId,
    required String worktop,
    required ProductType productType,
    required String productGroup,
    required String produktionsOrder,
  }) {
    context.goNamed(
      Routes.discard.name,
      queryParameters: {
        DiscardRouteParams.salesId: salesId,
        DiscardRouteParams.worktop: worktop,
        DiscardRouteParams.productType: productType.code,
        DiscardRouteParams.productGroup: productGroup,
        DiscardRouteParams.produktionsOrder: produktionsOrder,
      },
    );
  }

  void goToAccountPage({String? redirectToUrl}) {
    context.goNamed(
      Routes.account.name,
      queryParameters: {
        AccountRouteParams.redirectToUrl: redirectToUrl,
      },
    );
  }

  void pushLookupDetails(int id) {
    context.pushNamed(
      Routes.lookupDetails.name,
      queryParameters: {
        DiscardRouteParams.id: id.toString(),
      },
    );
  }
}

extension NavigationHelpersExt on BuildContext {
  AppNavigator get navigator => AppNavigator(this);
}

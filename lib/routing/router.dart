import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intern_kassation_app/config/constants/product_type.dart';
import 'package:intern_kassation_app/data/repositories/auth_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/auth/auth_repo_response.dart';
import 'package:intern_kassation_app/routing/parameters.dart';
import 'package:intern_kassation_app/routing/routes.dart';
import 'package:intern_kassation_app/ui/auth/widgets/account_screen.dart';
import 'package:intern_kassation_app/ui/core/ui/screens/technical_details_screen.dart';
import 'package:intern_kassation_app/ui/discard/cubit/discard_cubit.dart';
import 'package:intern_kassation_app/ui/discard/widgets/discard_form_screen.dart';
import 'package:intern_kassation_app/ui/lookup/cubits/lookup_cubit/lookup_cubit.dart';
import 'package:intern_kassation_app/ui/lookup/cubits/lookup_details_cubit/lookup_details_cubit.dart';
import 'package:intern_kassation_app/ui/lookup/widgets/lookup_details_screen.dart';
import 'package:intern_kassation_app/ui/lookup/widgets/lookup_screen.dart';
import 'package:intern_kassation_app/ui/scan/widgets/camra_scan_screen.dart';
import 'package:intern_kassation_app/ui/scan/widgets/scan_screen.dart';
import 'package:intern_kassation_app/ui/splash/widgets/splash_screen.dart';
import 'package:intern_kassation_app/utils/stream_listenable.dart';

final scanRouteObserver = RouteObserver<ModalRoute<void>>();
final orderLookupRouteObserver = RouteObserver<ModalRoute<void>>();

GoRouter router(AuthRepository authRepository) => GoRouter(
  initialLocation: Routes.splash.path,
  observers: [scanRouteObserver, orderLookupRouteObserver],
  debugLogDiagnostics: true,
  routes: _appRoutes,
  refreshListenable: StreamListenable(authRepository.stream),
  redirect: (context, state) => _redirect(context, state, authRepository),
);

final _appRoutes = <GoRoute>[
  GoRoute(
    name: Routes.splash.name,
    path: Routes.splash.path,
    builder: (context, state) => const SplashScreen(),
  ),
  GoRoute(
    name: Routes.account.name,
    path: Routes.account.path,
    builder: (context, state) => AccountScreen(
      redirectToUrl: state.uri.queryParameters[AccountRouteParams.redirectToUrl],
    ),
  ),
  GoRoute(
    name: Routes.scan.name,
    path: Routes.scan.path,
    builder: (context, state) => const ScanScreen(),
    routes: [
      GoRoute(
        name: Routes.cameraScan.name,
        path: Routes.cameraScan.path,
        builder: (context, state) => const CameraScanScreen(),
      ),
    ],
  ),
  GoRoute(
    path: Routes.discard.path,
    name: Routes.discard.name,
    builder: (context, state) {
      final salesId = state.uri.queryParameters[DiscardRouteParams.salesId];
      final worktop = state.uri.queryParameters[DiscardRouteParams.worktop];
      final productTypeCode = state.uri.queryParameters[DiscardRouteParams.productType];
      final productionOrder = state.uri.queryParameters[DiscardRouteParams.produktionsOrder];

      final productType = productTypeCode != null ? ProductType.fromCode(productTypeCode) : ProductType.unknown;

      if (salesId == null || worktop == null || productionOrder == null || productType == ProductType.unknown) {
        throw Exception(
          'Missing or invalid parameters for DiscardPage: salesId: $salesId, worktop: $worktop, productionOrder: $productionOrder, productType: $productTypeCode',
        );
      }

      return BlocProvider(
        create: (context) => DiscardCubit(
          discardReasonsRepository: context.read(),
          employeeRepository: context.read(),
          imageRepository: context.read(),
          orderRepository: context.read(),
        ),
        child: DiscardFormScreen(
          salesId: salesId,
          worktop: worktop,
          productType: productType,
          productionOrder: productionOrder,
        ),
      );
    },
  ),
  GoRoute(
    path: Routes.technicalDetails.path,
    name: Routes.technicalDetails.name,
    builder: (context, state) {
      final failure = state.extra as AppFailure?;
      if (failure == null) {
        throw Exception('AppFailure is required to navigate to TechnicalDetailsPage');
      }
      return TechnicalDetailsScreen(failure: failure);
    },
  ),
  GoRoute(
    path: Routes.lookup.path,
    name: Routes.lookup.name,
    builder: (context, state) => BlocProvider(
      create: (context) => LookupCubit(orderRepository: context.read()),
      child: const LookupScreen(),
    ),
    routes: [
      GoRoute(
        path: Routes.lookupDetails.path,
        name: Routes.lookupDetails.name,
        builder: (context, state) {
          final id = state.uri.queryParameters[DiscardRouteParams.id];
          if (id == null) {
            throw Exception('Missing id parameter for LookupPage');
          }

          final intId = int.tryParse(id);
          if (intId == null) {
            throw Exception('Invalid id parameter for LookupPage: $id');
          }

          return BlocProvider(
            create: (context) => LookupDetailsCubit(orderRepository: context.read())..fetchDiscardedOrderDetails(intId),
            child: LookupDetailsScreen(id: intId),
          );
        },
      ),
    ],
  ),
];

final _excludedRedirectPaths = <String>{
  Routes.account.path,
};

Future<String?> _redirect(BuildContext context, GoRouterState state, AuthRepository authRepository) async {
  final current = authRepository.currentResponse;
  if (current == null ||
      current.status == AuthResponseStatus.loading ||
      current.status == AuthResponseStatus.initial ||
      _excludedRedirectPaths.contains(state.fullPath)) {
    return null;
  }

  String accountWithRedirect(String to) => state.namedLocation(
    Routes.account.name,
    queryParameters: {
      AccountRouteParams.redirectToUrl: to,
    },
  );

  if (state.fullPath == Routes.splash.path) {
    if (current.status == AuthResponseStatus.unauthenticated && current.hasRefreshToken) {
      return accountWithRedirect(Routes.scan.path);
    }
    if (current.status == AuthResponseStatus.unauthenticated || current.status == AuthResponseStatus.failure) {
      return Routes.account.path;
    }
    if (current.status == AuthResponseStatus.authenticated) {
      return Routes.scan.path;
    }
  }

  if (state.fullPath == Routes.scan.path) {
    if (current.status == AuthResponseStatus.unauthenticated || current.status == AuthResponseStatus.failure) {
      return accountWithRedirect(Routes.scan.path);
    }
  }

  return null;
}

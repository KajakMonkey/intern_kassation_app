import 'package:intern_kassation_app/config/env.dart';

class ApiEndpoints {
  static final String baseAPIUrl = EnvManager.apiUrl;

  // * Auth endpoints
  static const authBase = '/auth';
  static const login = '$authBase/login';
  static const refresh = '$authBase/refresh';
  static const logout = '$authBase/logout';

  // * Employee endpoints
  static String getEmployeeDetails(String employeeId) => '/employees/$employeeId';

  // * Order endpoints
  static const ordersBase = '/orders';
  static String getOrderDetails(String productionOrder) => '$ordersBase/$productionOrder';

  static String discardOrder(String productionOrder) => '$ordersBase/$productionOrder/discard';
  static String discardOrderImages(String productionOrder) => '$ordersBase/$productionOrder/discard/images';

  // * Discarded orders endpoints
  static const discardedOrdersBase = '/orders/discarded';
  static const String getDiscardedOrders = discardedOrdersBase;
  static String getDiscardedOrderDetails(int id) => '$discardedOrdersBase/details/$id';

  // * Products endpoints
  static const productsBase = '/products';
  static String getDiscardReasons(String productType) => '$productsBase/$productType/defects';
  static String getDropdown(String category) => '$productsBase/dropdown/$category';

  // * Logging endpoints
  static const log = '/log';

  // * User endpoints
  static const usersBase = '/users';
  static const getUserDetails = '$usersBase/details';
}

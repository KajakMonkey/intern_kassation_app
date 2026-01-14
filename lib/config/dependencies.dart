import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intern_kassation_app/data/repositories/auth_repository.dart';
import 'package:intern_kassation_app/data/repositories/discard_reasons_repository.dart';
import 'package:intern_kassation_app/data/repositories/employee_repository.dart';
import 'package:intern_kassation_app/data/repositories/image_repository.dart';
import 'package:intern_kassation_app/data/repositories/order_repository.dart';
import 'package:intern_kassation_app/data/repositories/user_repository.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/api/auth_api_client.dart';
import 'package:intern_kassation_app/data/services/caching_service.dart';
import 'package:intern_kassation_app/data/services/image_service.dart';
import 'package:intern_kassation_app/data/services/secure_storage_service.dart';
import 'package:intern_kassation_app/data/services/shared_preferences_service.dart';
import 'package:intern_kassation_app/data/services/uuid_service.dart';
import 'package:intern_kassation_app/ui/auth/bloc/account_bloc.dart';
import 'package:intern_kassation_app/ui/scan/cubit/scan_cubit.dart';
import 'package:provider/single_child_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared providers for all configurations.
List<SingleChildWidget> sharedProviders = [
  ..._repositories,
  ..._blocs,
];

List<SingleChildWidget> _repositories = [
  RepositoryProvider<AuthApiClient>(create: (context) => AuthApiClient()),
  RepositoryProvider<ApiClient>(create: (context) => ApiClient()),
  RepositoryProvider<SecureStorageService>(create: (context) => const SecureStorageService()),
  RepositoryProvider<SharedPreferencesService>(create: (context) => SharedPreferencesService(SharedPreferencesAsync())),
  RepositoryProvider<CachingService>(create: (context) => CachingService(sharedPreferencesService: context.read())),
  RepositoryProvider<UuidService>(create: (context) => UuidService()),
  RepositoryProvider<AuthRepository>(
    lazy: false,
    create: (context) => AuthRepository(
      apiClient: context.read(),
      authApiClient: context.read(),
      secureStorageService: context.read(),
      uuidService: context.read(),
    ),
  ),
  RepositoryProvider<UserRepository>(
    create: (context) => UserRepository(
      apiClient: context.read(),
      cachingService: context.read(),
    ),
  ),
  RepositoryProvider<OrderRepository>(
    create: (context) => OrderRepository(
      apiClient: context.read(),
      sharedPreferencesService: context.read(),
    ),
  ),
  RepositoryProvider<EmployeeRepository>(create: (context) => EmployeeRepository(apiClient: context.read())),
  RepositoryProvider<DiscardReasonsRepository>(
    create: (context) => DiscardReasonsRepository(
      apiClient: context.read(),
      cachingService: context.read(),
    ),
  ),
  RepositoryProvider<ImageService>(create: (context) => ImageService(imagePicker: ImagePicker())),
  RepositoryProvider<ImageRepository>(create: (context) => ImageRepository(context.read())),
];

List<SingleChildWidget> _blocs = [
  BlocProvider(
    lazy: false,
    create: (context) =>
        AccountBloc(authRepository: context.read(), userRepository: context.read())
          ..add(const AccountEvent.subscribeToAuthChanges()),
  ),
  BlocProvider(create: (context) => ScanCubit(orderRepository: context.read())..fetchLatestDiscardedOrders()),
];

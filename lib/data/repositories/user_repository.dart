import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/config/constants/shared_preferences_keys.dart';
import 'package:intern_kassation_app/data/services/api/api_client.dart';
import 'package:intern_kassation_app/data/services/storage/caching_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/models/user.dart';
import 'package:logging/logging.dart';

class UserRepository {
  UserRepository({required ApiClient apiClient, required CachingService cachingService})
    : _apiClient = apiClient,
      _cachingService = cachingService;

  final ApiClient _apiClient;
  final CachingService _cachingService;

  final _logger = Logger('UserRepository');

  Future<Either<AppFailure, User>> fetchUserData({bool returnIfExpired = false}) async {
    final cachedUser = await getCachedUserData(returnIfExpired: returnIfExpired);
    if (cachedUser != null) {
      return right(cachedUser);
    }

    final response = await _apiClient.getUserDetails();
    return await response.fold(
      (failure) async {
        final cachedUser = await getCachedUserData(returnIfExpired: true);
        if (cachedUser != null) {
          return right(cachedUser);
        }
        return left(failure);
      },
      (user) async {
        await cacheUserData(user);
        return right(user);
      },
    );
  }

  Future<User?> getCachedUserData({bool returnIfExpired = false}) async {
    final result = await _cachingService.read(SharedPreferencesKeys.userData.name, returnIfExpired: returnIfExpired);
    return await result.fold(
      (failure) => null,
      (data) async {
        if (data == null) return null;
        try {
          final user = User.fromJson(data);
          return user;
        } catch (e) {
          _logger.warning('Error deserializing cached user data: $e');
          await _cachingService.delete(SharedPreferencesKeys.userData.name);
          return null;
        }
      },
    );
  }

  Future<void> cacheUserData(User user) async {
    final userJson = user.toJson();
    await _cachingService.write(SharedPreferencesKeys.userData.name, userJson, ttl: const Duration(hours: 2));
  }

  Future<void> clearCachedUserData() async {
    await _cachingService.delete(SharedPreferencesKeys.userData.name);
  }
}

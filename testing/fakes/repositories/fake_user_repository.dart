import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/repositories/user_repository.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';
import 'package:intern_kassation_app/domain/errors/error_codes/network_error_codes.dart';
import 'package:intern_kassation_app/domain/models/user.dart';

import '../../models/fake_user_data.dart';

class FakeUserRepository implements UserRepository {
  var shouldReturnFailure = false;

  @override
  Future<void> clearCachedUserData() async {}

  @override
  Future<Either<AppFailure, User>> fetchUserData({bool returnIfExpired = false}) async {
    if (shouldReturnFailure) {
      return left(AppFailure(code: NetworkErrorCodes.connectionError));
    }
    return right(kUser);
  }

  @override
  Future<User?> getCachedUserData({bool returnIfExpired = false}) async {
    if (shouldReturnFailure) {
      return null;
    }
    return kUser;
  }
}

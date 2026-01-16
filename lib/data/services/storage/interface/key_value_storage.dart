import 'package:fpdart/fpdart.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

abstract interface class KeyValueStorage {
  Future<Either<AppFailure, void>> write(String key, String value);
  Future<Either<AppFailure, String?>> read(String key);
  Future<Either<AppFailure, void>> delete(String key);

  Future<Either<AppFailure, void>> setInt(String key, int value);
  Future<Either<AppFailure, int?>> getInt(String key);
}

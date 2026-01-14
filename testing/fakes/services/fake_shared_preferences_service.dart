import 'package:fpdart/src/either.dart';
import 'package:intern_kassation_app/data/services/shared_preferences_service.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

class FakeSharedPreferencesService implements SharedPreferencesService {
  final Map<String, String> _storage = {};
  String? overrideStringValue;
  int? overrideIntValue;
  List<String>? overrideStringListValue;

  @override
  Future<Either<AppFailure, int?>> getInt(String key) async {
    if (overrideIntValue != null) {
      return right(overrideIntValue);
    }
    final value = _storage[key];
    if (value == null) {
      return right(null);
    }
    return right(int.tryParse(value));
  }

  @override
  Future<Either<AppFailure, String?>> getString(String key) async {
    if (overrideStringValue != null) {
      return right(overrideStringValue);
    }
    final value = _storage[key];
    return right(value);
  }

  @override
  Future<Either<AppFailure, List<String>?>> getStringList(String key) async {
    if (overrideStringListValue != null) {
      return right(overrideStringListValue);
    }
    final value = _storage[key];
    if (value == null) {
      return right(null);
    }
    return right(value.split('|'));
  }

  @override
  Future<Either<AppFailure, void>> remove(String key) async {
    _storage.remove(key);
    return right(null);
  }

  @override
  Future<Either<AppFailure, void>> setInt(String key, int value) async {
    _storage[key] = value.toString();
    return right(null);
  }

  @override
  Future<Either<AppFailure, void>> setString(String key, String value) async {
    _storage[key] = value;
    return right(null);
  }

  @override
  Future<Either<AppFailure, void>> setStringList(String key, List<String> value) async {
    _storage[key] = value.join('|');
    return right(null);
  }
}

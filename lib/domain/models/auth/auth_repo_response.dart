import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/domain/errors/app_failure.dart';

part 'auth_repo_response.mapper.dart';

enum AuthResponseStatus { initial, authenticated, unauthenticated, failure, loading }

@MappableClass()
class AuthRepoResponse with AuthRepoResponseMappable {
  final AuthResponseStatus status;
  final bool hasRefreshToken;
  final AppFailure? failure;

  const AuthRepoResponse({
    this.status = AuthResponseStatus.initial,
    this.hasRefreshToken = false,
    this.failure,
  });
}

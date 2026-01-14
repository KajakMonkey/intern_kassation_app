import 'package:dart_mappable/dart_mappable.dart';

part 'logout_request.mapper.dart';

@MappableClass()
class LogoutRequest with LogoutRequestMappable {
  final String refreshToken;

  LogoutRequest({
    required this.refreshToken,
  });
}

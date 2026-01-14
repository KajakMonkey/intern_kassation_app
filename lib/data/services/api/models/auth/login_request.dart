import 'package:dart_mappable/dart_mappable.dart';

part 'login_request.mapper.dart';

@MappableClass()
class LoginRequest with LoginRequestMappable {
  final String username;
  final String password;
  final String? deviceId;

  LoginRequest({
    required this.username,
    required this.password,
    this.deviceId,
  });
  /* 
  static const fromMap = LoginRequestMapper.fromMap;
  static const fromJson = LoginRequestMapper.fromJson; */
}

import 'package:dart_mappable/dart_mappable.dart';

part 'refresh_request.mapper.dart';

@MappableClass()
class RefreshRequest with RefreshRequestMappable {
  final String refreshToken;
  final String? deviceId;

  RefreshRequest({
    required this.refreshToken,
    this.deviceId,
  });
}

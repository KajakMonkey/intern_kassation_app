import 'package:dart_mappable/dart_mappable.dart';
import 'package:intern_kassation_app/config/app_config.dart';

part 'token.mapper.dart';

@MappableClass()
class Token with TokenMappable {
  final String accessToken;
  final DateTime accessTokenExpiresUtc;
  final String refreshToken;
  final DateTime refreshTokenExpiresUtc;

  const Token({
    required this.accessToken,
    required this.accessTokenExpiresUtc,
    required this.refreshToken,
    required this.refreshTokenExpiresUtc,
  });

  static const _gracePeriod = AppConfig.tokenRefreshGracePeriod;

  bool get hasValidAccessToken {
    final nowUtc = DateTime.now().toUtc();
    return accessTokenExpiresUtc.isAfter(nowUtc.add(_gracePeriod));
  }

  bool get hasValidRefreshToken {
    final nowUtc = DateTime.now().toUtc();
    return refreshTokenExpiresUtc.isAfter(nowUtc.add(_gracePeriod));
  }

  static const fromMap = TokenMapper.fromMap;
  static const fromJson = TokenMapper.fromJson;
}

import 'package:dart_mappable/dart_mappable.dart';

part 'user.mapper.dart';

@MappableClass()
class User with UserMappable {
  final String username;
  final String sessionId;

  User({
    required this.username,
    required this.sessionId,
  });

  static const fromMap = UserMapper.fromMap;
  static const fromJson = UserMapper.fromJson;
}

import 'package:uuid/uuid.dart';

class UuidService {
  String generateUuid() {
    final id = const Uuid().v7();
    return id;
  }
}

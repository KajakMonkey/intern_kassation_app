import 'package:intern_kassation_app/data/services/uuid_service.dart';

class FakeUuidService implements UuidService {
  @override
  String generateUuid() {
    return '123e4567-e89b-12d3-a456-426614174000';
  }
}

import 'package:intern_kassation_app/config/env/env_provider.dart';

class FakeEnvProvider implements EnvProvider {
  @override
  final Map<String, String> env = {};
  String? lastLoaded;

  @override
  Future<void> load(String fileName) async {
    lastLoaded = fileName;
  }
}

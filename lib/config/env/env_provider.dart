import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class EnvProvider {
  Future<void> load(String fileName);
  Map<String, String> get env;
}

class DotenvEnvProvider implements EnvProvider {
  @override
  Future<void> load(String fileName) => dotenv.load(fileName: fileName);

  @override
  Map<String, String> get env => dotenv.env;
}

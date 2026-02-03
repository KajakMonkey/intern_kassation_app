import 'package:flutter_test/flutter_test.dart';
import 'package:intern_kassation_app/config/env/env.dart';

import '../../testing/fakes/config/fake_env_provider.dart';

void main() {
  late FakeEnvProvider fake;

  setUp(() {
    fake = FakeEnvProvider();
    EnvManager.setProvider(fake);
  });

  tearDown(() {
    EnvManager.resetProvider();
  });

  group('EnvManager', () {
    test('apiUrl returns value', () {
      fake.env[EnvKey.baseApiUrl.key] = 'https://example';
      expect(EnvManager.apiUrl, 'https://example');
    });

    test('apiUrl throws when missing', () {
      fake.env.remove(EnvKey.baseApiUrl.key);
      expect(() => EnvManager.apiUrl, throwsArgumentError);
    });

    test('useHardwareScanner defaults to true when missing and respects values', () {
      fake.env.remove(EnvKey.useHardwareScanner.key);
      expect(EnvManager.useHardwareScanner, true);

      fake.env[EnvKey.useHardwareScanner.key] = 'false';
      expect(EnvManager.useHardwareScanner, false);

      fake.env[EnvKey.useHardwareScanner.key] = 'TrUe';
      expect(EnvManager.useHardwareScanner, true);
    });

    test('showDataPicker default false and true when set', () {
      fake.env.remove(EnvKey.showDataPicker.key);
      expect(EnvManager.showDataPicker, false);

      fake.env[EnvKey.showDataPicker.key] = 'TRUE';
      expect(EnvManager.showDataPicker, true);
    });

    test('validateEnv throws when BASE_API_URL missing in non-release', () {
      fake.env.remove(EnvKey.baseApiUrl.key);
      expect(() => EnvManager.validateEnv(), throwsArgumentError);

      fake.env[EnvKey.baseApiUrl.key] = 'https://example';
      expect(() => EnvManager.validateEnv(), returnsNormally);
    });

    test('init loads correct file and validates', () async {
      // missing BASE_API_URL -> validateEnv should throw
      fake.env.remove(EnvKey.baseApiUrl.key);
      await expectLater(EnvManager.init(Environment.development), throwsArgumentError);
      expect(fake.lastLoaded, '.env.development');

      // present -> should succeed
      fake.env[EnvKey.baseApiUrl.key] = 'https://example';
      await EnvManager.init(Environment.production);
      expect(fake.lastLoaded, '.env.production');
    });
  });
}

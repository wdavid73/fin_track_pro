import 'package:fin_track_pro/core/config/env_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Initialize dotenv with an empty string so _isInitialized = true but no
    // keys are set → all EnvConfig getters return their hardcoded fallbacks.
    dotenv.loadFromString(envString: '', isOptional: true);
  });

  group('EnvConfig', () {
    group('fallback values (no .env keys set)', () {
      test('appName returns FinTrack Pro fallback', () {
        expect(EnvConfig.appName, 'FinTrack Pro');
      });

      test('appSuffix returns empty string fallback', () {
        expect(EnvConfig.appSuffix, '');
      });

      test('bundleId returns com.fintrackpro fallback', () {
        expect(EnvConfig.bundleId, 'com.fintrackpro');
      });

      test('apiBaseUrl returns empty string fallback', () {
        expect(EnvConfig.apiBaseUrl, '');
      });

      test('apiTimeout returns 30000 fallback', () {
        expect(EnvConfig.apiTimeout, 30000);
      });

      test('enableLogging returns false fallback', () {
        expect(EnvConfig.enableLogging, false);
      });

      test('enableDebugBanner returns false fallback', () {
        expect(EnvConfig.enableDebugBanner, false);
      });

      test('environment returns development fallback', () {
        expect(EnvConfig.environment, 'development');
      });
    });

    group('values from env', () {
      setUp(() {
        dotenv.loadFromString(
          envString: '''
APP_NAME=TestApp
ENVIRONMENT=staging
API_TIMEOUT=5000
ENABLE_LOGGING=true
ENABLE_DEBUG_BANNER=true
''',
        );
      });

      test('appName reads from env', () {
        expect(EnvConfig.appName, 'TestApp');
      });

      test('environment reads from env', () {
        expect(EnvConfig.environment, 'staging');
      });

      test('apiTimeout reads and parses from env', () {
        expect(EnvConfig.apiTimeout, 5000);
      });

      test('enableLogging returns true from env', () {
        expect(EnvConfig.enableLogging, true);
      });

      test('enableDebugBanner returns true from env', () {
        expect(EnvConfig.enableDebugBanner, true);
      });
    });

    group('load()', () {
      test('does not throw when file does not exist', () async {
        // The catch block in EnvConfig.load() absorbs the error silently.
        // No exception should propagate — this exercises both the try (await
        // dotenv.load) and catch (print warning) lines flagged by Codecov.
        await expectLater(
          EnvConfig.load('non_existent_file_xyz.env'),
          completes,
        );
      });
    });
  });
}

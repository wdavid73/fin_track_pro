import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get appName => dotenv.get('APP_NAME', fallback: 'FinTrack Pro');

  static String get appSuffix => dotenv.get('APP_SUFFIX', fallback: '');

  static String get bundleId =>
      dotenv.get('BUNDLE_ID', fallback: 'com.fintrackpro');

  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: '');

  static int get apiTimeout =>
      int.tryParse(dotenv.get('API_TIMEOUT', fallback: '30000')) ?? 30000;

  static bool get enableLogging =>
      dotenv.get('ENABLE_LOGGING', fallback: 'false').toLowerCase() == 'true';

  static bool get enableDebugBanner =>
      dotenv.get('ENABLE_DEBUG_BANNER', fallback: 'false').toLowerCase() ==
      'true';

  static String get environment =>
      dotenv.get('ENVIRONMENT', fallback: 'development');

  /// Load environment variables from the specified file
  ///
  /// If the file is not found or cannot be loaded, fallback values will be used.
  /// This is expected in CI/CD environments where .env files are not available.
  static Future<void> load(String fileName) async {
    try {
      await dotenv.load(fileName: fileName);
    } catch (e) {
      // File not found or error loading - use fallback values
      // This is expected in CI/CD environments
      // ignore: avoid_print
      print('⚠️  Could not load $fileName - using fallback values');
    }
  }
}

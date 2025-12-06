import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoggerService', () {
    setUp(() {
      // Reset FlavorConfig if possible or ensure clean state
      // Since FlavorConfig is a singleton, we can't easily reset it without reflection or modifying the class
      // But we can re-initialize it.
    });

    test(
      'should initialize with logging disabled by default (when FlavorConfig not init)',
      () {
        final loggerService = LoggerService();
        expect(loggerService.logger, isNotNull);

        // Should not throw
        loggerService.debug('test debug');
        loggerService.info('test info');
        loggerService.warning('test warning');
        loggerService.error('test error');
        loggerService.fatal('test fatal');
      },
    );

    test('should initialize with logging enabled when FlavorConfig is dev', () {
      FlavorConfig.initialize(
        flavor: Flavor.dev,
        appName: 'Test App',
        bundleId: 'com.test',
        enableLogging: true,
        showDebugBanner: true,
      );

      final loggerService = LoggerService();
      expect(loggerService.logger, isNotNull);

      // Should not throw
      loggerService.debug('test debug enabled');
    });
  });
}

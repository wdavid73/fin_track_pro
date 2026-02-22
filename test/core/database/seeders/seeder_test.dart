import 'package:fin_track_pro/core/database/seeders/seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class MockLoggerService extends Mock implements LoggerService {}

/// Minimal fake Box — only overrides what Seeder uses.
class _FakeBox extends Fake implements Box {
  final List<dynamic> _data;
  _FakeBox([List<dynamic>? data]) : _data = data ?? [];

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Iterable get values => _data;

  @override
  int get length => _data.length;
}

/// Concrete subclass so we can instantiate the abstract Seeder.
class _ConcreteSeeder extends Seeder {
  _ConcreteSeeder(super.logger);

  @override
  String get name => 'TestSeeder';

  @override
  Future<void> seed() async {}
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockLoggerService logger;
  late _ConcreteSeeder seeder;

  setUp(() {
    logger = MockLoggerService();
    seeder = _ConcreteSeeder(logger);
  });

  group('Seeder', () {
    group('isBoxEmpty()', () {
      test('returns true when box has no data', () {
        expect(seeder.isBoxEmpty(_FakeBox()), isTrue);
      });

      test('returns false when box has data', () {
        expect(seeder.isBoxEmpty(_FakeBox(['item'])), isFalse);
      });
    });

    group('hasData()', () {
      test('returns false when box is empty', () {
        expect(seeder.hasData(_FakeBox()), isFalse);
      });

      test('returns true when box has data', () {
        expect(seeder.hasData(_FakeBox(['item'])), isTrue);
      });
    });

    test('name getter returns the seeder name', () {
      expect(seeder.name, 'TestSeeder');
    });
  });
}

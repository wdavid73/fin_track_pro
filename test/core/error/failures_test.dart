import 'package:fin_track_pro/core/error/failures.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failures', () {
    group('ServerFailure', () {
      test('holds the message', () {
        const f = ServerFailure('Server error');
        expect(f.message, 'Server error');
      });

      test('two instances with the same message are equal', () {
        const a = ServerFailure('oops');
        const b = ServerFailure('oops');
        expect(a, equals(b));
      });

      test('two instances with different messages are not equal', () {
        const a = ServerFailure('error A');
        const b = ServerFailure('error B');
        expect(a, isNot(equals(b)));
      });

      test('props contains the message', () {
        const f = ServerFailure('msg');
        expect(f.props, ['msg']);
      });
    });

    group('CacheFailure', () {
      test('holds the message', () {
        const f = CacheFailure('Cache miss');
        expect(f.message, 'Cache miss');
      });

      test('two instances with the same message are equal', () {
        const a = CacheFailure('miss');
        const b = CacheFailure('miss');
        expect(a, equals(b));
      });

      test('props contains the message', () {
        const f = CacheFailure('msg');
        expect(f.props, ['msg']);
      });
    });

    group('DatabaseFailure', () {
      test('holds the message', () {
        const f = DatabaseFailure('DB error');
        expect(f.message, 'DB error');
      });

      test('two instances with the same message are equal', () {
        const a = DatabaseFailure('fail');
        const b = DatabaseFailure('fail');
        expect(a, equals(b));
      });

      test('props contains the message', () {
        const f = DatabaseFailure('msg');
        expect(f.props, ['msg']);
      });

      test('different failure types with same message are not equal', () {
        const server = ServerFailure('msg');
        const cache = CacheFailure('msg');
        const db = DatabaseFailure('msg');
        expect(server, isNot(equals(cache)));
        expect(cache, isNot(equals(db)));
      });
    });
  });
}

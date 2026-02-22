import 'package:fin_track_pro/core/extensions/currency_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyFormatter', () {
    group('toCurrency', () {
      test('should format double as currency with default parameters', () {
        const value = 1234.56;
        final result = value.toCurrency();
        expect(result, contains('1'));
        expect(result, contains('234'));
        expect(result, contains('56'));
      });

      test('should format double with custom symbol', () {
        const value = 1234.56;
        final result = value.toCurrency(symbol: '€');
        expect(result, contains('€'));
        expect(result, contains('1'));
        expect(result, contains('234'));
      });

      test('should format double with custom decimal digits', () {
        const value = 1234.567;
        final result = value.toCurrency(decimalDigits: 3);
        expect(result, contains('567'));
      });

      test('should format zero correctly', () {
        const value = 0.0;
        final result = value.toCurrency();
        expect(result, contains('0'));
      });

      test('should format negative numbers correctly', () {
        const value = -1234.56;
        final result = value.toCurrency();
        expect(result, contains('1'));
        expect(result, contains('234'));
      });
    });

    group('toCompactCurrency', () {
      test('should format thousands as compact currency', () {
        const value = 1234.56;
        final result = value.toCompactCurrency();
        expect(result, contains('1'));
        expect(result, contains('K'));
      });

      test('should format millions as compact currency', () {
        const value = 1234567.89;
        final result = value.toCompactCurrency();
        expect(result, contains('1'));
        expect(result, contains('M'));
      });

      test('should format compact currency with custom symbol', () {
        const value = 5000.0;
        final result = value.toCompactCurrency(symbol: '£');
        expect(result, contains('£'));
        expect(result, contains('5'));
      });
    });

    group('toCurrencyInt', () {
      test('should format double as currency without decimals', () {
        const value = 1234.56;
        final result = value.toCurrencyInt();
        expect(result, contains('1'));
        expect(result, contains('235')); // Should round up
        expect(result, isNot(contains('.56')));
      });

      test('should format with custom symbol and no decimals', () {
        const value = 999.99;
        final result = value.toCurrencyInt(symbol: '¥');
        expect(result, contains('¥'));
        expect(result, contains('1')); // Should round to 1000
        expect(result, isNot(contains('.99')));
      });
    });
  });
}

import 'package:fin_track_pro/core/widgets/formatters/money_input_formatter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';

void main() {
  group('MoneyInputFormatter', () {
    late MoneyInputFormatter formatter;

    setUp(() {
      formatter = MoneyInputFormatter();
    });

    test('should format number with thousand separators', () {
      const oldValue = TextEditingValue(text: '');
      const newValue = TextEditingValue(
        text: '1000',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1.000');
      expect(result.selection.baseOffset, 5);
    });

    test('should format large number with multiple separators', () {
      const oldValue = TextEditingValue(text: '1.000');
      const newValue = TextEditingValue(
        text: '1.000000',
        selection: TextSelection.collapsed(offset: 8),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '1.000.000');
      expect(result.selection.baseOffset, 9);
    });

    test('should remove non-numeric characters', () {
      const oldValue = TextEditingValue(text: '100');
      const newValue = TextEditingValue(
        text: '100a',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '100');
      expect(result.selection.baseOffset, 3);
    });

    test('should handle empty input', () {
      const oldValue = TextEditingValue(text: '100');
      const newValue = TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '');
      expect(result.selection.baseOffset, 0);
    });

    test('should maintain cursor position when inserting in middle', () {
      // 1.2|34 -> 1.25|34 (insert 5)
      // 1.234 -> 1.253.4
      const oldValue = TextEditingValue(
        text: '1.234',
        selection: TextSelection.collapsed(offset: 3),
      );
      const newValue = TextEditingValue(
        text: '1.2534',
        selection: TextSelection.collapsed(offset: 4),
      );

      final result = formatter.formatEditUpdate(oldValue, newValue);

      expect(result.text, '12.534');
      expect(result.selection.baseOffset, 4); // 12.5|34
    });
  });
}

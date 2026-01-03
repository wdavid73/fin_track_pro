import 'package:flutter/services.dart';

/// A text input formatter that formats numeric input as money with thousand separators.
///
/// This formatter automatically adds dots (.) as thousand separators while the user types.
/// For example: "1000" becomes "1.000", "1000000" becomes "1.000.000".
///
/// Features:
/// - Only allows numeric input (0-9)
/// - Automatically adds thousand separators (dots)
/// - Maintains cursor position during editing
/// - Supports editing in the middle of the text
///
/// Example usage:
/// ```dart
/// TextField(
///   keyboardType: TextInputType.number,
///   inputFormatters: [
///     MoneyInputFormatter(),
///   ],
///   decoration: const InputDecoration(
///     labelText: 'Amount',
///     prefixText: '\$ ',
///   ),
/// )
/// ```
///
/// To get the numeric value from formatted text:
/// ```dart
/// String formattedValue = "1.000.000";
/// int numericValue = int.parse(formattedValue.replaceAll('.', ''));
/// // numericValue = 1000000
/// ```
class MoneyInputFormatter extends TextInputFormatter {
  /// Formats the input text with thousand separators and manages cursor position.
  ///
  /// This method is called automatically by the TextField whenever the text changes.
  /// It removes all non-numeric characters, formats the number with dots as thousand
  /// separators, and calculates the correct cursor position.
  ///
  /// Parameters:
  /// - [oldValue]: The previous text value before the change
  /// - [newValue]: The new text value after the user's input
  ///
  /// Returns a [TextEditingValue] with the formatted text and updated cursor position.
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Return empty value if user clears the field
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Extract only numeric characters from old and new values
    // final oldNumbers = oldValue.text.replaceAll(RegExp(r'[^\d]'), '');
    final newNumbers = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    // Return empty if no numbers remain after filtering
    if (newNumbers.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Format the numeric string with thousand separators
    final formattedText = _formatWithThousandsSeparator(newNumbers);

    // Count how many digits are before the cursor position in the new value
    final digitsBeforeCursor = newValue.text
        .substring(0, newValue.selection.baseOffset)
        .replaceAll(RegExp(r'[^\d]'), '')
        .length;

    // Find the cursor position in the formatted text
    // by counting digits until we reach the same number of digits that were before cursor
    int cursorPosition = 0;
    int digitCount = 0;

    for (int i = 0; i < formattedText.length; i++) {
      if (formattedText[i] != '.') {
        digitCount++;
      }
      if (digitCount == digitsBeforeCursor) {
        cursorPosition = i + 1;
        break;
      }
    }

    // If cursor is at the end, place it at the end of formatted text
    if (digitsBeforeCursor >= newNumbers.length) {
      cursorPosition = formattedText.length;
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(
        offset: cursorPosition.clamp(0, formattedText.length),
      ),
    );
  }

  /// Formats a numeric string with thousand separators (dots).
  ///
  /// This method takes a string containing only digits and adds a dot
  /// every three digits from right to left.
  ///
  /// Example:
  /// - "1000" → "1.000"
  /// - "1000000" → "1.000.000"
  /// - "123456789" → "123.456.789"
  ///
  /// Parameters:
  /// - [number]: A string containing only numeric characters
  ///
  /// Returns the formatted string with thousand separators.
  String _formatWithThousandsSeparator(String number) {
    final buffer = StringBuffer();
    final length = number.length;

    for (int i = 0; i < length; i++) {
      // Add a dot separator every 3 digits from the right
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(number[i]);
    }

    return buffer.toString();
  }
}

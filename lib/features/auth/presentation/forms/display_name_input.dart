import 'package:formz/formz.dart';

enum DisplayNameValidationError { tooLong }

/// Optional field — empty is valid. Max 50 characters.
class DisplayNameInput extends FormzInput<String, DisplayNameValidationError> {
  const DisplayNameInput.pure() : super.pure('');
  const DisplayNameInput.dirty([super.value = '']) : super.dirty();

  static const int maxLength = 50;

  @override
  DisplayNameValidationError? validator(String value) {
    if (value.length > maxLength) return DisplayNameValidationError.tooLong;
    return null;
  }
}

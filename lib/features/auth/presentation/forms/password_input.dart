import 'package:formz/formz.dart';

enum PasswordValidationError { empty, tooShort }

/// Minimum 6 characters — matches Firebase Auth's minimum requirement.
class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  static const int minLength = 6;

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < minLength) return PasswordValidationError.tooShort;
    return null;
  }
}

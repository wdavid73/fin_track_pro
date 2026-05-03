import 'package:formz/formz.dart';

enum ConfirmPasswordValidationError { empty, mismatch }

/// Validates that the confirmation value matches the original password.
///
/// Usage:
/// ```dart
/// ConfirmPasswordInput.dirty(value: confirmValue, password: originalPassword)
/// ```
class ConfirmPasswordInput
    extends FormzInput<String, ConfirmPasswordValidationError> {
  const ConfirmPasswordInput.pure({this.password = ''}) : super.pure('');
  const ConfirmPasswordInput.dirty({
    required String value,
    required this.password,
  }) : super.dirty(value);

  /// The original password to compare against.
  final String password;

  @override
  ConfirmPasswordValidationError? validator(String value) {
    if (value.isEmpty) return ConfirmPasswordValidationError.empty;
    if (value != password) return ConfirmPasswordValidationError.mismatch;
    return null;
  }
}

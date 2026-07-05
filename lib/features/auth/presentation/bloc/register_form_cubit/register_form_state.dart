part of 'register_form_cubit.dart';

class RegisterFormState extends Equatable {
  const RegisterFormState({
    this.displayName = const DisplayNameInput.pure(),
    this.email = const EmailInput.pure(),
    this.password = const PasswordInput.pure(),
    this.confirmPassword = const ConfirmPasswordInput.pure(),
    this.isValid = false,
    this.isFormPosted = false,
    this.isPosting = false,
    this.registrationComplete = false,
    this.errorMessage,
  });

  final DisplayNameInput displayName;
  final EmailInput email;
  final PasswordInput password;
  final ConfirmPasswordInput confirmPassword;

  /// Whether the form is currently valid (recomputed on every field change).
  final bool isValid;

  /// True after the first submit attempt — gates error display for fields
  /// that should only validate on submit (e.g. confirmPassword).
  final bool isFormPosted;

  /// True while the auth operation is in-flight.
  final bool isPosting;

  /// True once the account has been created successfully.
  /// The UI listens to this to trigger navigation.
  final bool registrationComplete;

  /// Non-null when the last sign-up attempt failed.
  final String? errorMessage;

  RegisterFormState copyWith({
    DisplayNameInput? displayName,
    EmailInput? email,
    PasswordInput? password,
    ConfirmPasswordInput? confirmPassword,
    bool? isValid,
    bool? isFormPosted,
    bool? isPosting,
    bool? registrationComplete,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RegisterFormState(
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isValid: isValid ?? this.isValid,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isPosting: isPosting ?? this.isPosting,
      registrationComplete: registrationComplete ?? this.registrationComplete,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        email,
        password,
        confirmPassword,
        isValid,
        isFormPosted,
        isPosting,
        registrationComplete,
        errorMessage,
      ];
}

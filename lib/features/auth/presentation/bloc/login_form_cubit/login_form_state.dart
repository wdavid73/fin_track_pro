part of 'login_form_cubit.dart';

class LoginFormState extends Equatable {
  const LoginFormState({
    this.email = const EmailInput.pure(),
    this.password = const PasswordInput.pure(),
    this.isValid = false,
    this.isFormPosted = false,
    this.isPosting = false,
    this.errorMessage,
  });

  final EmailInput email;
  final PasswordInput password;

  /// Whether the form is currently valid (recomputed on every field change).
  final bool isValid;

  /// True after the first submit attempt — gates error display in the UI.
  final bool isFormPosted;

  /// True while the auth operation is in-flight.
  final bool isPosting;

  /// Non-null when the last sign-in attempt failed.
  /// The page listens to this to show the error snackbar.
  final String? errorMessage;

  LoginFormState copyWith({
    EmailInput? email,
    PasswordInput? password,
    bool? isValid,
    bool? isFormPosted,
    bool? isPosting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isValid: isValid ?? this.isValid,
      isFormPosted: isFormPosted ?? this.isFormPosted,
      isPosting: isPosting ?? this.isPosting,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [email, password, isValid, isFormPosted, isPosting, errorMessage];
}

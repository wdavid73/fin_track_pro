import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/confirm_password_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/display_name_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/email_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/password_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'register_form_state.dart';

class RegisterFormCubit extends Cubit<RegisterFormState> {
  RegisterFormCubit({required this.authBloc}) : super(const RegisterFormState());

  final AuthBloc authBloc;

  void displayNameChanged(String value) {
    final displayName = DisplayNameInput.dirty(value);
    emit(state.copyWith(
      displayName: displayName,
      isValid: Formz.validate([state.email, state.password, state.confirmPassword]),
    ));
  }

  void emailChanged(String value) {
    final email = EmailInput.dirty(value);
    emit(state.copyWith(
      email: email,
      isValid: Formz.validate([email, state.password, state.confirmPassword]),
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordInput.dirty(value);
    // Re-validate confirm password against the new password value.
    final confirm = state.confirmPassword.isPure
        ? state.confirmPassword
        : ConfirmPasswordInput.dirty(
            value: state.confirmPassword.value,
            password: value,
          );
    emit(state.copyWith(
      password: password,
      confirmPassword: confirm,
      isValid: Formz.validate([state.email, password, confirm]),
    ));
  }

  void confirmPasswordChanged(String value) {
    final confirm = ConfirmPasswordInput.dirty(
      value: value,
      password: state.password.value,
    );
    emit(state.copyWith(
      confirmPassword: confirm,
      isValid: Formz.validate([state.email, state.password, confirm]),
    ));
  }

  Future<void> onSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    // Clear any previous error before starting the request.
    emit(state.copyWith(isPosting: true, clearError: true));

    authBloc.add(AuthSignUpWithEmailRequested(
      email: state.email.value.trim(),
      password: state.password.value,
      displayName: state.displayName.value.trim().isEmpty
          ? null
          : state.displayName.value.trim(),
    ));

    // Wait until AuthBloc settles to a final status.
    final result = await authBloc.stream.firstWhere(
      (s) =>
          s.status == AuthStatus.authenticated ||
          s.status == AuthStatus.unauthenticated ||
          s.status == AuthStatus.error,
    );

    if (isClosed) return;

    if (result.status == AuthStatus.authenticated) {
      // Registration succeeded — signal the UI to navigate to login.
      emit(state.copyWith(isPosting: false, registrationComplete: true));
    } else {
      emit(state.copyWith(isPosting: false, errorMessage: result.errorMessage));
    }
  }

  void _touchEveryField() {
    final email = EmailInput.dirty(state.email.value);
    final password = PasswordInput.dirty(state.password.value);
    final confirm = ConfirmPasswordInput.dirty(
      value: state.confirmPassword.value,
      password: state.password.value,
    );
    final displayName = DisplayNameInput.dirty(state.displayName.value);
    emit(state.copyWith(
      isFormPosted: true,
      displayName: displayName,
      email: email,
      password: password,
      confirmPassword: confirm,
      isValid: Formz.validate([email, password, confirm]),
    ));
  }
}

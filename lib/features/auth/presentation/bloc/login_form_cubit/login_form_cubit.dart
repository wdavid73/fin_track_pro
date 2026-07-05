import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/core/utils/stream_helper.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/email_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/password_input.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

part 'login_form_state.dart';

class LoginFormCubit extends Cubit<LoginFormState> {
  LoginFormCubit({required this.authBloc}) : super(const LoginFormState());

  final AuthBloc authBloc;

  void emailChanged(String value) {
    final email = EmailInput.dirty(value);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([email, state.password]),
      ),
    );
  }

  void passwordChanged(String value) {
    final password = PasswordInput.dirty(value);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> onSubmit() async {
    _touchEveryField();

    if (!state.isValid) return;

    // Clear any previous error before starting the request.
    emit(state.copyWith(isPosting: true, clearError: true));

    authBloc.add(
      AuthSignInWithEmailRequested(
        email: state.email.value.trim(),
        password: state.password.value,
      ),
    );

    // Wait until AuthBloc settles to a final status.
    // On success, navigation to home is handled by the router redirect.
    await waitForState(
      stream: authBloc.stream,
      condition: (state) =>
          state.status == AuthStatus.authenticated ||
          state.status == AuthStatus.unauthenticated ||
          state.status == AuthStatus.error,
    );

    // Guard against emitting on a closed cubit (widget already unmounted
    // because the router redirected to home on AuthStatus.authenticated).
    if (isClosed) return;

    emit(state.copyWith(isPosting: false, errorMessage: state.errorMessage));
  }

  void _touchEveryField() {
    final email = EmailInput.dirty(state.email.value);
    final password = PasswordInput.dirty(state.password.value);
    emit(
      state.copyWith(
        isFormPosted: true,
        email: email,
        password: password,
        isValid: Formz.validate([email, password]),
      ),
    );
  }
}

import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/register_form_cubit/register_form_cubit.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/confirm_password_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/display_name_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/email_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/password_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  const tEmail = 'user@example.com';
  const tPassword = 'secret123';
  const tDisplayName = 'Test User';

  const tValidEmail = EmailInput.dirty(tEmail);
  const tValidPassword = PasswordInput.dirty(tPassword);
  const tMatchingConfirm =
      ConfirmPasswordInput.dirty(value: tPassword, password: tPassword);

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    whenListen(
      mockAuthBloc,
      const Stream<AuthState>.empty(),
      initialState: const AuthState(),
    );
  });

  group('RegisterFormCubit', () {
    group('displayNameChanged', () {
      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits updated displayName with no error for valid name',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.displayNameChanged(tDisplayName),
        expect: () => [
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(tDisplayName),
          ),
        ],
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits tooLong error for name exceeding 50 characters',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.displayNameChanged('A' * 51),
        expect: () => [
          RegisterFormState(
            displayName: DisplayNameInput.dirty('A' * 51),
          ),
        ],
        verify: (cubit) {
          expect(
            cubit.state.displayName.displayError,
            DisplayNameValidationError.tooLong,
          );
        },
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits no error for name of exactly 50 characters',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.displayNameChanged('A' * 50),
        verify: (cubit) {
          expect(cubit.state.displayName.displayError, isNull);
        },
      );
    });

    group('emailChanged', () {
      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits updated email and isValid true when all other fields are valid',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(
          password: tValidPassword,
          confirmPassword: tMatchingConfirm,
        ),
        act: (cubit) => cubit.emailChanged(tEmail),
        expect: () => [
          const RegisterFormState(
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
          ),
        ],
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits isValid false for invalid email format',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.emailChanged('not-an-email'),
        expect: () => [
          const RegisterFormState(
            email: EmailInput.dirty('not-an-email'),
            isValid: false,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits updated password and re-validates confirmPassword',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(
          email: tValidEmail,
          confirmPassword: ConfirmPasswordInput.dirty(
            value: tPassword,
            password: 'old_password',
          ),
        ),
        act: (cubit) => cubit.passwordChanged(tPassword),
        expect: () => [
          const RegisterFormState(
            email: tValidEmail,
            password: tValidPassword,
            // confirmPassword re-validated: value matches new password
            confirmPassword: tMatchingConfirm,
            isValid: true,
          ),
        ],
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'does not re-validate confirmPassword when it is still pure',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(email: tValidEmail),
        act: (cubit) => cubit.passwordChanged(tPassword),
        verify: (cubit) {
          expect(cubit.state.confirmPassword.isPure, isTrue);
        },
      );
    });

    group('confirmPasswordChanged', () {
      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits isValid true when confirm matches password',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(
          email: tValidEmail,
          password: tValidPassword,
        ),
        act: (cubit) => cubit.confirmPasswordChanged(tPassword),
        expect: () => [
          const RegisterFormState(
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
          ),
        ],
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits mismatch error when confirm does not match password',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(
          email: tValidEmail,
          password: tValidPassword,
        ),
        act: (cubit) => cubit.confirmPasswordChanged('different'),
        verify: (cubit) {
          expect(
            cubit.state.confirmPassword.displayError,
            ConfirmPasswordValidationError.mismatch,
          );
          expect(cubit.state.isValid, isFalse);
        },
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits empty error when confirm is empty',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(password: tValidPassword),
        act: (cubit) => cubit.confirmPasswordChanged(''),
        verify: (cubit) {
          expect(
            cubit.state.confirmPassword.displayError,
            ConfirmPasswordValidationError.empty,
          );
        },
      );
    });

    group('onSubmit', () {
      blocTest<RegisterFormCubit, RegisterFormState>(
        'only marks form as posted when form is invalid',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.onSubmit(),
        verify: (_) {
          verifyNever(() => mockAuthBloc.add(any()));
          // All fields are touched and form is invalid
        },
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'does not add to AuthBloc when email is invalid',
        build: () => RegisterFormCubit(authBloc: mockAuthBloc),
        seed: () => const RegisterFormState(
          email: EmailInput.dirty('bad'),
          password: tValidPassword,
          confirmPassword: tMatchingConfirm,
          isValid: false,
        ),
        act: (cubit) => cubit.onSubmit(),
        verify: (_) => verifyNever(() => mockAuthBloc.add(any())),
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits [formPosted, posting, registrationComplete] on successful registration',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(status: AuthStatus.authenticated),
            ]),
            initialState: const AuthState(),
          );
          return RegisterFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const RegisterFormState(
          email: tValidEmail,
          password: tValidPassword,
          confirmPassword: tMatchingConfirm,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          // _touchEveryField: always marks displayName dirty (even empty string)
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(''),
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
            isFormPosted: true,
          ),
          // start posting
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(''),
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
            isFormPosted: true,
            isPosting: true,
          ),
          // registration complete
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(''),
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
            isFormPosted: true,
            isPosting: false,
            registrationComplete: true,
          ),
        ],
        verify: (_) {
          verify(() => mockAuthBloc.add(
                const AuthSignUpWithEmailRequested(
                  email: tEmail,
                  password: tPassword,
                  displayName: null,
                ),
              )).called(1);
        },
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'emits [formPosted, posting, error] when auth fails',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(
                status: AuthStatus.error,
                errorMessage: 'Email already in use',
              ),
            ]),
            initialState: const AuthState(),
          );
          return RegisterFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const RegisterFormState(
          email: tValidEmail,
          password: tValidPassword,
          confirmPassword: tMatchingConfirm,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(''),
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
            isFormPosted: true,
          ),
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(''),
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
            isFormPosted: true,
            isPosting: true,
          ),
          const RegisterFormState(
            displayName: DisplayNameInput.dirty(''),
            email: tValidEmail,
            password: tValidPassword,
            confirmPassword: tMatchingConfirm,
            isValid: true,
            isFormPosted: true,
            isPosting: false,
            errorMessage: 'Email already in use',
          ),
        ],
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'passes non-empty trimmed displayName to AuthBloc',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(status: AuthStatus.authenticated),
            ]),
            initialState: const AuthState(),
          );
          return RegisterFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const RegisterFormState(
          displayName: DisplayNameInput.dirty(tDisplayName),
          email: tValidEmail,
          password: tValidPassword,
          confirmPassword: tMatchingConfirm,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        verify: (_) {
          verify(() => mockAuthBloc.add(
                const AuthSignUpWithEmailRequested(
                  email: tEmail,
                  password: tPassword,
                  displayName: tDisplayName,
                ),
              )).called(1);
        },
      );

      blocTest<RegisterFormCubit, RegisterFormState>(
        'passes null displayName when displayName is blank whitespace',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(status: AuthStatus.authenticated),
            ]),
            initialState: const AuthState(),
          );
          return RegisterFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const RegisterFormState(
          displayName: DisplayNameInput.dirty('   '),
          email: tValidEmail,
          password: tValidPassword,
          confirmPassword: tMatchingConfirm,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        verify: (_) {
          verify(() => mockAuthBloc.add(
                const AuthSignUpWithEmailRequested(
                  email: tEmail,
                  password: tPassword,
                  displayName: null,
                ),
              )).called(1);
        },
      );
    });
  });
}

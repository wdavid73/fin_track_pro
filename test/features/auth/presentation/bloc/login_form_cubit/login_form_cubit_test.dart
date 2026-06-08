import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/login_form_cubit/login_form_cubit.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/email_input.dart';
import 'package:fin_track_pro/features/auth/presentation/forms/password_input.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthBloc mockAuthBloc;

  const tEmail = 'test@example.com';
  const tPassword = 'secret123';

  const tValidEmail = EmailInput.dirty(tEmail);
  const tValidPassword = PasswordInput.dirty(tPassword);

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

  group('LoginFormCubit', () {
    group('emailChanged', () {
      blocTest<LoginFormCubit, LoginFormState>(
        'emits updated email and isValid true for a valid email',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        seed: () => const LoginFormState(password: tValidPassword),
        act: (cubit) => cubit.emailChanged(tEmail),
        expect: () => [
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
          ),
        ],
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'emits isValid false for an invalid email',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.emailChanged('not-an-email'),
        expect: () => [
          const LoginFormState(
            email: EmailInput.dirty('not-an-email'),
            isValid: false,
          ),
        ],
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'emits isValid false for an empty email',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.emailChanged(''),
        expect: () => [
          const LoginFormState(
            email: EmailInput.dirty(''),
            isValid: false,
          ),
        ],
      );
    });

    group('passwordChanged', () {
      blocTest<LoginFormCubit, LoginFormState>(
        'emits updated password and isValid true when both fields are valid',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        seed: () => const LoginFormState(email: tValidEmail),
        act: (cubit) => cubit.passwordChanged(tPassword),
        expect: () => [
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
          ),
        ],
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'emits isValid false for a password shorter than 6 characters',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        seed: () => const LoginFormState(email: tValidEmail),
        act: (cubit) => cubit.passwordChanged('123'),
        expect: () => [
          const LoginFormState(
            email: tValidEmail,
            password: PasswordInput.dirty('123'),
            isValid: false,
          ),
        ],
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'emits isValid false for an empty password',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.passwordChanged(''),
        expect: () => [
          const LoginFormState(
            password: PasswordInput.dirty(''),
            isValid: false,
          ),
        ],
      );
    });

    group('onSubmit', () {
      blocTest<LoginFormCubit, LoginFormState>(
        'only marks form as posted when form is invalid',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          const LoginFormState(
            email: EmailInput.dirty(''),
            password: PasswordInput.dirty(''),
            isFormPosted: true,
            isValid: false,
          ),
        ],
        verify: (_) => verifyNever(() => mockAuthBloc.add(any())),
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'does not add to AuthBloc when email is invalid',
        build: () => LoginFormCubit(authBloc: mockAuthBloc),
        seed: () => const LoginFormState(
          email: EmailInput.dirty('bad-email'),
          password: tValidPassword,
          isValid: false,
        ),
        act: (cubit) => cubit.onSubmit(),
        verify: (_) => verifyNever(() => mockAuthBloc.add(any())),
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'emits [formPosted, posting, done] and adds event to AuthBloc on valid form',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(status: AuthStatus.authenticated),
            ]),
            initialState: const AuthState(),
          );
          return LoginFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const LoginFormState(
          email: tValidEmail,
          password: tValidPassword,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          // _touchEveryField: sets isFormPosted = true
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
            isFormPosted: true,
          ),
          // start posting
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
            isFormPosted: true,
            isPosting: true,
          ),
          // posting done (isClosed guard passed, errorMessage remains null)
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
            isFormPosted: true,
            isPosting: false,
          ),
        ],
        verify: (_) {
          verify(() => mockAuthBloc.add(
                const AuthSignInWithEmailRequested(
                  email: tEmail,
                  password: tPassword,
                ),
              )).called(1);
        },
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'emits [formPosted, posting, done] when auth fails — error shown via AuthBloc listener',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(
                status: AuthStatus.error,
                errorMessage: 'Wrong password',
              ),
            ]),
            initialState: const AuthState(),
          );
          return LoginFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const LoginFormState(
          email: tValidEmail,
          password: tValidPassword,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        expect: () => [
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
            isFormPosted: true,
          ),
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
            isFormPosted: true,
            isPosting: true,
          ),
          // cubit errorMessage stays null — error is surfaced via AuthBloc BlocListener in the page
          const LoginFormState(
            email: tValidEmail,
            password: tValidPassword,
            isValid: true,
            isFormPosted: true,
            isPosting: false,
          ),
        ],
      );

      blocTest<LoginFormCubit, LoginFormState>(
        'trims email whitespace before adding event to AuthBloc',
        build: () {
          whenListen(
            mockAuthBloc,
            Stream.fromIterable([
              const AuthState(status: AuthStatus.authenticated),
            ]),
            initialState: const AuthState(),
          );
          return LoginFormCubit(authBloc: mockAuthBloc);
        },
        seed: () => const LoginFormState(
          email: EmailInput.dirty('  $tEmail  '),
          password: tValidPassword,
          isValid: true,
        ),
        act: (cubit) => cubit.onSubmit(),
        verify: (_) {
          verify(() => mockAuthBloc.add(
                const AuthSignInWithEmailRequested(
                  email: tEmail,
                  password: tPassword,
                ),
              )).called(1);
        },
      );
    });
  });
}

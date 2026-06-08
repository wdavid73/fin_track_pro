import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/get_auth_state_changes.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_out.dart';
import 'package:fin_track_pro/features/auth/domain/usecases/sign_up_with_email.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAuthStateChanges extends Mock implements GetAuthStateChanges {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignUpWithEmail extends Mock implements SignUpWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSignOut extends Mock implements SignOut {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockGetAuthStateChanges mockGetAuthStateChanges;
  late MockSignInWithEmail mockSignInWithEmail;
  late MockSignUpWithEmail mockSignUpWithEmail;
  late MockSignInWithGoogle mockSignInWithGoogle;
  late MockSignOut mockSignOut;
  late AuthBloc bloc;

  const tUser = UserEntity(
    id: 'uid-1',
    email: 'test@example.com',
    displayName: 'Test User',
  );

  AuthBloc buildBloc() => AuthBloc(
        getAuthStateChanges: mockGetAuthStateChanges,
        signInWithEmail: mockSignInWithEmail,
        signUpWithEmail: mockSignUpWithEmail,
        signInWithGoogle: mockSignInWithGoogle,
        signOut: mockSignOut,
      );

  setUpAll(() {
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
    registerFallbackValue(FakeAuthEvent());
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockGetAuthStateChanges = MockGetAuthStateChanges();
    mockSignInWithEmail = MockSignInWithEmail();
    mockSignUpWithEmail = MockSignUpWithEmail();
    mockSignInWithGoogle = MockSignInWithGoogle();
    mockSignOut = MockSignOut();

    when(() => mockGetAuthStateChanges())
        .thenAnswer((_) => const Stream.empty());

    bloc = buildBloc();
  });

  tearDown(() => bloc.close());

  group('AuthBloc', () {
    test('initial state is AuthState with status unknown', () {
      expect(bloc.state, const AuthState());
      expect(bloc.state.status, AuthStatus.unknown);
      expect(bloc.state.user, isNull);
      expect(bloc.state.errorMessage, isNull);
    });

    group('AuthStarted', () {
      blocTest<AuthBloc, AuthState>(
        'emits [authenticated] when stream emits a user',
        build: () {
          when(() => mockGetAuthStateChanges())
              .thenAnswer((_) => Stream.fromIterable([tUser]));
          return buildBloc();
        },
        act: (bloc) => bloc.add(AuthStarted()),
        expect: () => [
          const AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when stream emits null',
        build: () {
          when(() => mockGetAuthStateChanges())
              .thenAnswer((_) => Stream.fromIterable([null]));
          return buildBloc();
        },
        act: (bloc) => bloc.add(AuthStarted()),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits states for each user emission from stream',
        build: () {
          when(() => mockGetAuthStateChanges())
              .thenAnswer((_) => Stream.fromIterable([tUser, null]));
          return buildBloc();
        },
        act: (bloc) => bloc.add(AuthStarted()),
        expect: () => [
          const AuthState(status: AuthStatus.authenticated, user: tUser),
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });

    group('AuthUserChanged', () {
      blocTest<AuthBloc, AuthState>(
        'emits [authenticated] when user is non-null',
        build: () => bloc,
        act: (bloc) => bloc.add(const AuthUserChanged(tUser)),
        expect: () => [
          const AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] when user is null',
        build: () => bloc,
        act: (bloc) => bloc.add(const AuthUserChanged(null)),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
      );
    });

    group('AuthSignInWithEmailRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on success',
        build: () {
          when(() => mockSignInWithEmail(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenAnswer((_) async => tUser);
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(
          email: 'test@example.com',
          password: 'secret123',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
        verify: (_) {
          verify(() => mockSignInWithEmail(
                email: 'test@example.com',
                password: 'secret123',
              )).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on failure',
        build: () {
          when(() => mockSignInWithEmail(
                email: any(named: 'email'),
                password: any(named: 'password'),
              )).thenThrow(Exception('Wrong password'));
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSignInWithEmailRequested(
          email: 'test@example.com',
          password: 'wrong',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Wrong password'),
              ),
        ],
      );
    });

    group('AuthSignUpWithEmailRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on success',
        build: () {
          when(() => mockSignUpWithEmail(
                email: any(named: 'email'),
                password: any(named: 'password'),
                displayName: any(named: 'displayName'),
              )).thenAnswer((_) async => tUser);
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpWithEmailRequested(
          email: 'test@example.com',
          password: 'secret123',
          displayName: 'Test User',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on failure',
        build: () {
          when(() => mockSignUpWithEmail(
                email: any(named: 'email'),
                password: any(named: 'password'),
                displayName: any(named: 'displayName'),
              )).thenThrow(Exception('Email already in use'));
          return bloc;
        },
        act: (bloc) => bloc.add(const AuthSignUpWithEmailRequested(
          email: 'test@example.com',
          password: 'secret123',
        )),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.error)
              .having(
                (s) => s.errorMessage,
                'errorMessage',
                contains('Email already in use'),
              ),
        ],
      );
    });

    group('AuthSignInWithGoogleRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [loading, authenticated] on success',
        build: () {
          when(() => mockSignInWithGoogle()).thenAnswer((_) async => tUser);
          return bloc;
        },
        act: (bloc) => bloc.add(AuthSignInWithGoogleRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          const AuthState(status: AuthStatus.authenticated, user: tUser),
        ],
        verify: (_) {
          verify(() => mockSignInWithGoogle()).called(1);
        },
      );

      blocTest<AuthBloc, AuthState>(
        'emits [loading, error] on failure',
        build: () {
          when(() => mockSignInWithGoogle())
              .thenThrow(Exception('Google sign-in aborted'));
          return bloc;
        },
        act: (bloc) => bloc.add(AuthSignInWithGoogleRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.loading),
          isA<AuthState>()
              .having((s) => s.status, 'status', AuthStatus.error),
        ],
      );
    });

    group('AuthSignOutRequested', () {
      blocTest<AuthBloc, AuthState>(
        'emits [unauthenticated] after sign out',
        build: () {
          when(() => mockSignOut()).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(AuthSignOutRequested()),
        expect: () => [
          const AuthState(status: AuthStatus.unauthenticated),
        ],
        verify: (_) {
          verify(() => mockSignOut()).called(1);
        },
      );
    });
  });
}

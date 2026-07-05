import 'package:fin_track_pro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fin_track_pro/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockRemote;
  late AuthRepositoryImpl sut;

  const tUser = UserEntity(id: 'uid-1', email: 'test@example.com');

  setUp(() {
    mockRemote = MockAuthRemoteDataSource();
    sut = AuthRepositoryImpl(mockRemote);
  });

  group('AuthRepositoryImpl', () {
    group('authStateChanges', () {
      test('delegates stream from remote datasource', () {
        final stream = Stream.fromIterable([tUser, null]);
        when(() => mockRemote.authStateChanges).thenAnswer((_) => stream);
        expect(sut.authStateChanges, emitsInOrder([tUser, null]));
      });
    });

    group('getCurrentUser', () {
      test('returns UserEntity when user is signed in', () async {
        when(() => mockRemote.getCurrentUser()).thenAnswer((_) async => tUser);
        final result = await sut.getCurrentUser();
        expect(result, tUser);
        verify(() => mockRemote.getCurrentUser()).called(1);
      });

      test('returns null when no user is signed in', () async {
        when(() => mockRemote.getCurrentUser()).thenAnswer((_) async => null);
        final result = await sut.getCurrentUser();
        expect(result, isNull);
      });
    });

    group('signInWithEmail', () {
      test('returns UserEntity and delegates to remote', () async {
        when(() => mockRemote.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => tUser);

        final result = await sut.signInWithEmail(
          email: 'test@example.com',
          password: 'secret123',
        );

        expect(result, tUser);
        verify(() => mockRemote.signInWithEmail(
              email: 'test@example.com',
              password: 'secret123',
            )).called(1);
      });

      test('rethrows exception from remote datasource', () {
        when(() => mockRemote.signInWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(Exception('auth error'));

        expect(
          () => sut.signInWithEmail(
            email: 'test@example.com',
            password: 'wrong',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signUpWithEmail', () {
      test('returns UserEntity and passes displayName', () async {
        when(() => mockRemote.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: any(named: 'displayName'),
            )).thenAnswer((_) async => tUser);

        final result = await sut.signUpWithEmail(
          email: 'test@example.com',
          password: 'secret123',
          displayName: 'Test User',
        );

        expect(result, tUser);
        verify(() => mockRemote.signUpWithEmail(
              email: 'test@example.com',
              password: 'secret123',
              displayName: 'Test User',
            )).called(1);
      });

      test('passes null displayName when not provided', () async {
        when(() => mockRemote.signUpWithEmail(
              email: any(named: 'email'),
              password: any(named: 'password'),
              displayName: null,
            )).thenAnswer((_) async => tUser);

        final result = await sut.signUpWithEmail(
          email: 'test@example.com',
          password: 'secret123',
        );

        expect(result, tUser);
      });
    });

    group('signInWithGoogle', () {
      test('returns UserEntity and delegates to remote', () async {
        when(() => mockRemote.signInWithGoogle())
            .thenAnswer((_) async => tUser);

        final result = await sut.signInWithGoogle();

        expect(result, tUser);
        verify(() => mockRemote.signInWithGoogle()).called(1);
      });

      test('rethrows exception from remote datasource', () {
        when(() => mockRemote.signInWithGoogle())
            .thenThrow(Exception('Google sign-in aborted'));

        expect(() => sut.signInWithGoogle(), throwsA(isA<Exception>()));
      });
    });

    group('signOut', () {
      test('delegates to remote datasource', () async {
        when(() => mockRemote.signOut()).thenAnswer((_) async {});
        await sut.signOut();
        verify(() => mockRemote.signOut()).called(1);
      });
    });
  });
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fin_track_pro/features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockUserCredential extends Mock implements UserCredential {}

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthRemoteDataSource sut;

  const tUid = 'uid-1';
  const tEmail = 'test@example.com';
  const tDisplayName = 'Test User';
  const tPhotoUrl = 'https://photo.example.com/photo.jpg';

  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    sut = FirebaseAuthRemoteDataSource(mockAuth, mockGoogleSignIn);
  });

  MockUser buildMockUser({
    String uid = tUid,
    String? email = tEmail,
    String? displayName = tDisplayName,
    String? photoURL = tPhotoUrl,
  }) {
    final user = MockUser();
    when(() => user.uid).thenReturn(uid);
    when(() => user.email).thenReturn(email);
    when(() => user.displayName).thenReturn(displayName);
    when(() => user.photoURL).thenReturn(photoURL);
    return user;
  }

  const tUserEntity = UserEntity(
    id: tUid,
    email: tEmail,
    displayName: tDisplayName,
    photoUrl: tPhotoUrl,
  );

  group('FirebaseAuthRemoteDataSource', () {
    group('authStateChanges', () {
      test('maps non-null Firebase User to UserEntity', () {
        final mockUser = buildMockUser();
        when(() => mockAuth.authStateChanges())
            .thenAnswer((_) => Stream.fromIterable([mockUser]));

        expect(sut.authStateChanges, emits(tUserEntity));
      });

      test('maps null Firebase User to null', () {
        when(() => mockAuth.authStateChanges())
            .thenAnswer((_) => Stream.fromIterable([null]));

        expect(sut.authStateChanges, emits(isNull));
      });
    });

    group('getCurrentUser', () {
      test('returns UserEntity when user is signed in', () async {
        final mockUser = buildMockUser();
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final result = await sut.getCurrentUser();

        expect(result, tUserEntity);
      });

      test('returns null when no user is signed in', () async {
        when(() => mockAuth.currentUser).thenReturn(null);

        final result = await sut.getCurrentUser();

        expect(result, isNull);
      });

      test('maps email to empty string when Firebase email is null', () async {
        final mockUser = buildMockUser(email: null);
        when(() => mockAuth.currentUser).thenReturn(mockUser);

        final result = await sut.getCurrentUser();

        expect(result!.email, '');
      });
    });

    group('signInWithEmail', () {
      test('returns UserEntity on successful sign-in', () async {
        final mockUser = buildMockUser();
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        final result = await sut.signInWithEmail(
          email: tEmail,
          password: 'secret123',
        );

        expect(result, tUserEntity);
        verify(() => mockAuth.signInWithEmailAndPassword(
              email: tEmail,
              password: 'secret123',
            )).called(1);
      });

      test('throws when Firebase returns null user', () async {
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(null);
        when(() => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        await expectLater(
          () => sut.signInWithEmail(email: tEmail, password: 'secret'),
          throwsA(isA<Exception>()),
        );
      });

      test('propagates FirebaseAuthException from Firebase', () async {
        when(() => mockAuth.signInWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(FirebaseAuthException(code: 'wrong-password'));

        await expectLater(
          () => sut.signInWithEmail(email: tEmail, password: 'wrong'),
          throwsA(isA<FirebaseAuthException>()),
        );
      });
    });

    group('signUpWithEmail', () {
      test('creates user and calls updateDisplayName when displayName provided',
          () async {
        final mockUser = buildMockUser();
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);
        when(() => mockUser.updateDisplayName(any()))
            .thenAnswer((_) async {});

        final result = await sut.signUpWithEmail(
          email: tEmail,
          password: 'secret123',
          displayName: tDisplayName,
        );

        expect(result, isA<UserEntity>());
        verify(() => mockUser.updateDisplayName(tDisplayName)).called(1);
      });

      test('creates user without calling updateDisplayName when null', () async {
        final mockUser = buildMockUser(displayName: null);
        final mockCredential = MockUserCredential();
        when(() => mockCredential.user).thenReturn(mockUser);
        when(() => mockAuth.createUserWithEmailAndPassword(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenAnswer((_) async => mockCredential);

        await sut.signUpWithEmail(email: tEmail, password: 'secret123');

        verifyNever(() => mockUser.updateDisplayName(any()));
      });
    });

    group('signInWithGoogle', () {
      test('returns UserEntity on successful Google sign-in', () async {
        final mockGoogleAccount = MockGoogleSignInAccount();
        final mockGoogleAuth = MockGoogleSignInAuthentication();
        final mockUser = buildMockUser();
        final mockCredential = MockUserCredential();

        when(() => mockGoogleSignIn.authenticate())
            .thenAnswer((_) async => mockGoogleAccount);
        when(() => mockGoogleAccount.authentication).thenReturn(mockGoogleAuth);
        when(() => mockGoogleAuth.idToken).thenReturn('id_token');
        when(() => mockAuth.signInWithCredential(any()))
            .thenAnswer((_) async => mockCredential);
        when(() => mockCredential.user).thenReturn(mockUser);

        final result = await sut.signInWithGoogle();

        expect(result, tUserEntity);
        verify(() => mockGoogleSignIn.authenticate()).called(1);
        verify(() => mockAuth.signInWithCredential(any())).called(1);
      });

      test('throws when Google sign-in is canceled by user', () async {
        when(() => mockGoogleSignIn.authenticate()).thenThrow(
          const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        );

        await expectLater(
          () => sut.signInWithGoogle(),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('signOut', () {
      test('calls both Firebase signOut and Google signOut', () async {
        when(() => mockAuth.signOut()).thenAnswer((_) async {});
        when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

        await sut.signOut();

        verify(() => mockAuth.signOut()).called(1);
        verify(() => mockGoogleSignIn.signOut()).called(1);
      });
    });
  });
}

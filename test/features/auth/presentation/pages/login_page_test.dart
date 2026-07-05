import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

// LoginPage creates LoginFormCubit internally via BlocProvider(create:...).
// Tests provide a MockAuthBloc in the tree; LoginPage reads it to build the cubit.
Widget _buildTestWidget(MockAuthBloc mockAuthBloc) {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  AppSnackbar().init(scaffoldMessengerKey);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Register')),
        ),
      ),
    ],
  );

  return MaterialApp.router(
    scaffoldMessengerKey: scaffoldMessengerKey,
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

void main() {
  late MockAuthBloc mockAuthBloc;

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

  group('LoginPage', () {
    group('rendering', () {
      testWidgets('shows email field', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('login_email_field')), findsOneWidget);
      });

      testWidgets('shows password field', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('login_password_field')), findsOneWidget);
      });

      testWidgets('shows submit button', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('login_submit_button')), findsOneWidget);
      });

      testWidgets('shows Google sign-in button', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      });

      testWidgets('shows register navigation button', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('go_to_register_button')), findsOneWidget);
      });

      testWidgets('submit button is enabled on initial render', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(
          find.byKey(const Key('login_submit_button')),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('AuthBloc BlocListener', () {
      testWidgets('shows error snackbar when AuthStatus transitions to error', (
        tester,
      ) async {
        final controller = StreamController<AuthState>.broadcast();
        whenListen(
          mockAuthBloc,
          controller.stream,
          initialState: const AuthState(),
        );

        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        controller.add(const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Wrong password',
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Wrong password'), findsOneWidget);

        await controller.close();
      });

    });

    group('Google sign-in button', () {
      testWidgets('adds AuthSignInWithGoogleRequested to AuthBloc on tap', (
        tester,
      ) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const Key('google_sign_in_button')));
        await tester.pump();

        verify(() => mockAuthBloc.add(any(
              that: isA<AuthSignInWithGoogleRequested>(),
            ))).called(1);
      });
    });

    group('submit button loading state', () {
      testWidgets(
        'button is disabled with CircularProgressIndicator while posting',
        (tester) async {
          // Use a StreamController so we can complete waitForState after the check.
          final controller = StreamController<AuthState>.broadcast();
          whenListen(
            mockAuthBloc,
            controller.stream,
            initialState: const AuthState(),
          );

          await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
          await tester.pumpAndSettle();

          // Enter valid credentials so LoginFormCubit considers the form valid.
          await tester.enterText(
            find.byKey(const Key('login_email_field')),
            'test@example.com',
          );
          await tester.pump();
          await tester.enterText(
            find.byKey(const Key('login_password_field')),
            'secret123',
          );
          await tester.pump();

          // Tap submit — cubit.onSubmit() runs synchronously until
          // await waitForState(...), setting isPosting=true.
          await tester.tap(find.byKey(const Key('login_submit_button')));
          await tester.pump();

          final button = tester.widget<FilledButton>(
            find.byKey(const Key('login_submit_button')),
          );
          expect(button.onPressed, isNull);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          // Emit a terminal state so waitForState unblocks and the test can
          // dispose cleanly without leaving a dangling future.
          controller.add(const AuthState(status: AuthStatus.authenticated));
          // Advance past the snackbar duration to avoid pumpAndSettle timeout.
          await tester.pump(const Duration(seconds: 4));

          await controller.close();
        },
      );

    });
  });
}

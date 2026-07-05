import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthBloc extends MockBloc<AuthEvent, AuthState> implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

class FakeAuthState extends Fake implements AuthState {}

// RegisterPage creates RegisterFormCubit internally via BlocProvider(create:...).
// Tests provide a MockAuthBloc; RegisterPage reads it to build the cubit.
Widget _buildTestWidget(MockAuthBloc mockAuthBloc) {
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  AppSnackbar().init(scaffoldMessengerKey);

  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider<AuthBloc>.value(
          value: mockAuthBloc,
          child: const RegisterPage(),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Login')),
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

  group('RegisterPage', () {
    group('rendering', () {
      testWidgets('shows display name field', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('register_name_field')), findsOneWidget);
      });

      testWidgets('shows email field', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('register_email_field')), findsOneWidget);
      });

      testWidgets('shows password field', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('register_password_field')), findsOneWidget);
      });

      testWidgets('shows confirm password field', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const Key('register_confirm_field')),
          findsOneWidget,
        );
      });

      testWidgets('shows submit button', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('register_submit_button')), findsOneWidget);
      });

      testWidgets('shows login navigation button', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('go_to_login_button')), findsOneWidget);
      });

      testWidgets('submit button is enabled on initial render', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        final button = tester.widget<FilledButton>(
          find.byKey(const Key('register_submit_button')),
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('RegisterFormCubit BlocListener', () {
      testWidgets('shows error snackbar when errorMessage changes', (
        tester,
      ) async {
        final controller = StreamController<AuthState>();
        whenListen(
          mockAuthBloc,
          controller.stream,
          initialState: const AuthState(),
        );

        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        // Enter valid form data so the cubit can submit.
        await tester.enterText(
          find.byKey(const Key('register_email_field')),
          'user@example.com',
        );
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'secret123',
        );
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('register_confirm_field')),
          'secret123',
        );
        await tester.pump();

        // Tap submit — cubit.onSubmit() starts and waits on authBloc.stream.
        await tester.tap(find.byKey(const Key('register_submit_button')));
        await tester.pump();

        // Emit an error state to complete firstWhere and trigger error snackbar.
        controller.add(const AuthState(
          status: AuthStatus.error,
          errorMessage: 'Email already in use',
        ));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Email already in use'), findsOneWidget);

        await controller.close();
      });

      testWidgets('navigates to login when registrationComplete becomes true', (
        tester,
      ) async {
        final controller = StreamController<AuthState>();
        whenListen(
          mockAuthBloc,
          controller.stream,
          initialState: const AuthState(),
        );

        await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.byKey(const Key('register_email_field')),
          'user@example.com',
        );
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('register_password_field')),
          'secret123',
        );
        await tester.pump();
        await tester.enterText(
          find.byKey(const Key('register_confirm_field')),
          'secret123',
        );
        await tester.pump();

        await tester.tap(find.byKey(const Key('register_submit_button')));
        await tester.pump();

        // Emit authenticated state → cubit sets registrationComplete = true
        // → BlocListener navigates to /login.
        controller.add(const AuthState(status: AuthStatus.authenticated));
        await tester.pumpAndSettle();

        // Should have navigated to the /login route.
        expect(find.text('Login'), findsOneWidget);

        await controller.close();
      });
    });

    group('submit button loading state', () {
      testWidgets(
        'button is disabled with CircularProgressIndicator while posting',
        (tester) async {
          final controller = StreamController<AuthState>();
          whenListen(
            mockAuthBloc,
            controller.stream,
            initialState: const AuthState(),
          );

          await tester.pumpWidget(_buildTestWidget(mockAuthBloc));
          await tester.pumpAndSettle();

          await tester.enterText(
            find.byKey(const Key('register_email_field')),
            'user@example.com',
          );
          await tester.pump();
          await tester.enterText(
            find.byKey(const Key('register_password_field')),
            'secret123',
          );
          await tester.pump();
          await tester.enterText(
            find.byKey(const Key('register_confirm_field')),
            'secret123',
          );
          await tester.pump();

          await tester.tap(find.byKey(const Key('register_submit_button')));
          await tester.pump();

          final button = tester.widget<FilledButton>(
            find.byKey(const Key('register_submit_button')),
          );
          expect(button.onPressed, isNull);
          expect(find.byType(CircularProgressIndicator), findsOneWidget);

          // Unblock firstWhere so the cubit closes cleanly.
          controller.add(const AuthState(status: AuthStatus.authenticated));
          await tester.pumpAndSettle();

          await controller.close();
        },
      );
    });
  });
}

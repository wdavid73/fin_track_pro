import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockSettingsBloc extends MockBloc<SettingsEvent, SettingsState>
    implements SettingsBloc {}

class _FakeSettingsEvent extends Fake implements SettingsEvent {}

class _FakeSettingsState extends Fake implements SettingsState {}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget(MockSettingsBloc bloc) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => BlocProvider<SettingsBloc>.value(
          value: bloc,
          child: const OnboardingPage(),
        ),
      ),
      GoRoute(path: '/home', builder: (context, state) => const Scaffold()),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockSettingsBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(_FakeSettingsEvent());
    registerFallbackValue(_FakeSettingsState());
  });

  setUp(() {
    mockBloc = MockSettingsBloc();
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockBloc.state).thenReturn(
      const SettingsState(
        status: SettingsStatus.initial,
        settings: SettingsEntity(themeMode: ThemeMode.system),
      ),
    );
  });

  group('OnboardingPage', () {
    group('Page Structure', () {
      testWidgets('renders first page content on load', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        expect(find.text('Welcome to FinTrack Pro'), findsOneWidget);
        expect(find.text('Skip'), findsOneWidget);
        expect(find.text('Next'), findsOneWidget);
      });

      testWidgets('shows 3 dot indicators on first page', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        // 3 AnimatedContainers used as dot indicators
        expect(find.byType(AnimatedContainer), findsNWidgets(3));
      });

      testWidgets('shows wallet icon on first page', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        expect(
          find.byIcon(Icons.account_balance_wallet_rounded),
          findsOneWidget,
        );
      });
    });

    group('Navigation between pages', () {
      testWidgets('tapping Next advances to second page', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Track Expenses easily'), findsOneWidget);
      });

      testWidgets('shows Get Started button on last page', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        // Navigate to page 2
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        // Navigate to page 3
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Get Started'), findsOneWidget);
        expect(find.text('Smart Budgets'), findsOneWidget);
      });

      testWidgets('all 3 pages are reachable via Next', (tester) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        expect(find.text('Welcome to FinTrack Pro'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text('Track Expenses easily'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
        expect(find.text('Smart Budgets'), findsOneWidget);
      });
    });

    group('Completion', () {
      testWidgets('tapping Skip dispatches CompleteOnboardingEvent', (
        tester,
      ) async {
        await tester.pumpWidget(_buildTestWidget(mockBloc));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Skip'));
        await tester.pump();

        verify(
          () => mockBloc.add(any(that: isA<CompleteOnboardingEvent>())),
        ).called(1);
      });

      testWidgets(
        'tapping Get Started on last page dispatches CompleteOnboardingEvent',
        (tester) async {
          await tester.pumpWidget(_buildTestWidget(mockBloc));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Next'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Get Started'));
          await tester.pump();

          verify(
            () => mockBloc.add(any(that: isA<CompleteOnboardingEvent>())),
          ).called(1);
        },
      );
    });
  });
}

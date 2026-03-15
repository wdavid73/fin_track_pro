import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:fin_track_pro/features/settings/presentation/settings_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
  final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  AppSnackbar().init(scaffoldMessengerKey);

  return MaterialApp(
    scaffoldMessengerKey: scaffoldMessengerKey,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<SettingsBloc>.value(
      value: bloc,
      child: const SettingsPage(),
    ),
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
  });

  // ── Page Structure ──────────────────────────────────────────────────────

  group('Page Structure', () {
    testWidgets('renders Scaffold with key "settings_page"', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.byKey(const Key('settings_page')), findsOneWidget);
    });

    testWidgets('renders AppBar with Settings title', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders all 4 section titles', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('ACCOUNT'), findsOneWidget);
      expect(find.text('PREFERENCES'), findsOneWidget);
      expect(find.text('DATA & PRIVACY'), findsOneWidget);
      expect(find.text('SUPPORT'), findsOneWidget);
    });
  });

  // ── Account Section ─────────────────────────────────────────────────────

  group('Account Section', () {
    testWidgets('renders Profile item with correct content', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Manage your profile'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('renders Security item with correct content', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Password, 2FA, Biometrics'), findsOneWidget);
      expect(find.byIcon(Icons.shield), findsOneWidget);
    });

    testWidgets('tapping Profile shows Coming soon snackbar', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Profile'));
      await tester.pump();

      expect(find.text('Coming soon...'), findsOneWidget);
    });

    testWidgets('tapping Security shows Coming soon snackbar', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Security'));
      await tester.pump();

      expect(find.text('Coming soon...'), findsOneWidget);
    });
  });

  // ── Preferences Section ─────────────────────────────────────────────────

  group('Preferences Section', () {
    testWidgets('renders Notifications item', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Budget alerts, reminders'), findsOneWidget);
      expect(find.byIcon(Icons.notifications), findsOneWidget);
    });

    testWidgets('renders Currency item with COP trailing text', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Currency'), findsOneWidget);
      expect(find.text('COP'), findsOneWidget);
      expect(find.byIcon(Icons.attach_money), findsOneWidget);
    });

    testWidgets('renders Appearance item with dark mode icon', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('Appearance shows "System" when state is initial with null settings', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial, settings: null),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Appearance shows "System" when state is loading', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.loading),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Appearance shows "System" when state is error', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.error),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('System'), findsOneWidget);
    });

    testWidgets('Appearance shows "Light" when themeMode is light', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.success,
          settings: SettingsEntity(themeMode: ThemeMode.light),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Light'), findsOneWidget);
    });

    testWidgets('Appearance shows "Dark" when themeMode is dark', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.success,
          settings: SettingsEntity(themeMode: ThemeMode.dark),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('Appearance shows "System" when themeMode is system', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.success,
          settings: SettingsEntity(themeMode: ThemeMode.system),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('System'), findsOneWidget);
    });
  });

  // ── Theme Selection ─────────────────────────────────────────────────────

  group('Theme Selection', () {
    testWidgets('tapping Appearance opens ThemeOptionBottomSheet', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.initial,
          settings: SettingsEntity(themeMode: ThemeMode.system),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsOneWidget);
      expect(find.text('System'), findsNWidgets(2)); // One in list, one in sheet
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });

    testWidgets('theme change is NOT triggered when status is loading', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.loading),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pump();

      // Bottom sheet should NOT open when loading
      expect(find.text('Select Theme'), findsNothing);
    });

    testWidgets('selecting Dark theme dispatches ChangeThemeMode event', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.initial,
          settings: SettingsEntity(themeMode: ThemeMode.system),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(const ChangeThemeMode(ThemeMode.dark))).called(1);
    });

    testWidgets('selecting Light theme dispatches ChangeThemeMode event', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.initial,
          settings: SettingsEntity(themeMode: ThemeMode.dark),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();

      verify(() => mockBloc.add(const ChangeThemeMode(ThemeMode.light))).called(1);
    });

    testWidgets('bottom sheet closes after theme selection', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.initial,
          settings: SettingsEntity(themeMode: ThemeMode.system),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();

      expect(find.text('Select Theme'), findsNothing);
    });

    testWidgets('current theme shows check mark in bottom sheet', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(
          status: SettingsStatus.initial,
          settings: SettingsEntity(themeMode: ThemeMode.dark),
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Appearance'));
      await tester.pumpAndSettle();

      // Find the check icon (should be next to Dark option)
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  // ── Data & Privacy Section ──────────────────────────────────────────────

  group('Data & Privacy Section', () {
    testWidgets('renders Export data item', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Export data'), findsOneWidget);
      expect(find.byIcon(Icons.file_download), findsOneWidget);
    });

    testWidgets('renders Privacy Policy item', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('Privacy Policy'), findsOneWidget);
      expect(find.byIcon(Icons.shield_moon_sharp), findsOneWidget);
    });

    testWidgets('tapping Export data shows Coming soon snackbar', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Ensure visible before tapping
      await tester.ensureVisible(find.text('Export data'));
      await tester.pump();
      await tester.tap(find.text('Export data'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon...'), findsOneWidget);
    });

    testWidgets('tapping Privacy Policy shows Coming soon snackbar', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Ensure visible before tapping
      await tester.ensureVisible(find.text('Privacy Policy'));
      await tester.pump();
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon...'), findsOneWidget);
    });
  });

  // ── Support Section ─────────────────────────────────────────────────────

  group('Support Section', () {
    testWidgets('renders About item', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('About'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('renders FAQ item', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('FAQ'), findsOneWidget);
      expect(find.byIcon(Icons.question_mark), findsOneWidget);
    });

    testWidgets('tapping About shows Coming soon snackbar', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Ensure visible before tapping
      await tester.ensureVisible(find.text('About'));
      await tester.pump();
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon...'), findsOneWidget);
    });

    testWidgets('tapping FAQ shows Coming soon snackbar', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Ensure visible before tapping
      await tester.ensureVisible(find.text('FAQ'));
      await tester.pump();
      await tester.tap(find.text('FAQ'));
      await tester.pumpAndSettle();

      expect(find.text('Coming soon...'), findsOneWidget);
    });
  });

  // ── Logout Button ───────────────────────────────────────────────────────

  group('Logout Button', () {
    testWidgets('renders logout button with red styling', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Scroll down to find the logout button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pump();

      expect(find.text('Logout'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('logout button icon has red color', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Scroll down to find the logout button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pump();

      final iconWidget = tester.widget<Icon>(find.byIcon(Icons.logout));
      expect(iconWidget.color, Colors.red);
    });
  });

  // ── SettingsItem Widget ─────────────────────────────────────────────────

  group('SettingsItem Widget', () {
    testWidgets('renders leading icon in blue circle', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Find container with circle shape (the icon background)
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byType(Container),
        ),
      );

      // At least one container should have BoxShape.circle decoration
      final hasCircleDecoration = containers.any((container) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          return decoration.shape == BoxShape.circle;
        }
        return false;
      });

      expect(hasCircleDecoration, isTrue);
    });

    testWidgets('renders forward arrow icon in trailing', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // There should be multiple forward arrow icons (one per item)
      expect(find.byIcon(Icons.arrow_forward_ios), findsWidgets);
    });

    testWidgets('renders optional trailing text before arrow', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // COP is a trailing text for Currency item
      expect(find.text('COP'), findsOneWidget);
    });
  });

  // ── _SettingsCard Widget ────────────────────────────────────────────────

  group('_SettingsCard Widget', () {
    testWidgets('card has rounded corners', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const SettingsState(status: SettingsStatus.initial),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      // Find containers with rounded decoration
      final containers = tester.widgetList<Container>(
        find.byType(Container),
      );

      final hasRoundedDecoration = containers.any((container) {
        final decoration = container.decoration;
        if (decoration is BoxDecoration) {
          final borderRadius = decoration.borderRadius;
          if (borderRadius is BorderRadius) {
            return borderRadius.topLeft.x == 18;
          }
        }
        return false;
      });

      expect(hasRoundedDecoration, isTrue);
    });
  });
}

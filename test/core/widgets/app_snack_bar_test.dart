import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Builds a minimal app with the AppSnackbar messengerKey wired up.
Widget _buildApp(Widget child) {
  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  AppSnackbar().init(messengerKey);

  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    scaffoldMessengerKey: messengerKey,
    home: Scaffold(body: child),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AppSnackbar', () {
    // ── Singleton ──────────────────────────────────────────────────────────

    test('is a singleton — two instances are the same object', () {
      final a = AppSnackbar();
      final b = AppSnackbar();
      expect(identical(a, b), isTrue);
    });

    // ── show() ────────────────────────────────────────────────────────────

    testWidgets('show() displays the message text', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        _buildApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppSnackbar().show(capturedContext, 'Hello world');
      await tester.pump();

      expect(find.text('Hello world'), findsOneWidget);
    });

    // ── success() ─────────────────────────────────────────────────────────

    testWidgets('success() displays the message text', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        _buildApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppSnackbar().success(capturedContext, 'Saved!');
      await tester.pump();

      expect(find.text('Saved!'), findsOneWidget);

      // Verify green background
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.green);
    });

    // ── error() ───────────────────────────────────────────────────────────

    testWidgets('error() displays the message with red background', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        _buildApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppSnackbar().error(capturedContext, 'Something failed');
      await tester.pump();

      expect(find.text('Something failed'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.red);
    });

    // ── warning() ─────────────────────────────────────────────────────────

    testWidgets('warning() displays the message with orange background', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        _buildApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppSnackbar().warning(capturedContext, 'Check this');
      await tester.pump();

      expect(find.text('Check this'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.orange.shade700);
    });

    // ── custom() ──────────────────────────────────────────────────────────

    testWidgets('custom() displays message with specified colors', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        _buildApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppSnackbar().custom(
        context: capturedContext,
        message: 'Custom message',
        background: Colors.purple,
        textColor: Colors.yellow,
        duration: const Duration(seconds: 5),
      );
      await tester.pump();

      expect(find.text('Custom message'), findsOneWidget);

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, Colors.purple);
      expect(snackBar.duration, const Duration(seconds: 5));
    });

    // ── Floating behavior ─────────────────────────────────────────────────

    testWidgets('snackbar uses floating behavior', (tester) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        _buildApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      AppSnackbar().show(capturedContext, 'Floating');
      await tester.pump();

      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.behavior, SnackBarBehavior.floating);
    });
  });
}

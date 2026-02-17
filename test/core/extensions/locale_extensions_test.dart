import 'package:fin_track_pro/core/extensions/locale_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocaleExtension', () {
    testWidgets('should return correct locale from context', (tester) async {
      Locale? capturedLocale;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en', 'US'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('es', 'ES'),
          ],
          home: Builder(
            builder: (context) {
              capturedLocale = context.locale;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedLocale, isNotNull);
      expect(capturedLocale?.languageCode, 'en');
      expect(capturedLocale?.countryCode, 'US');
    });

    testWidgets('should return Spanish locale when set', (tester) async {
      Locale? capturedLocale;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es', 'ES'),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('es', 'ES'),
          ],
          home: Builder(
            builder: (context) {
              capturedLocale = context.locale;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedLocale, isNotNull);
      expect(capturedLocale?.languageCode, 'es');
      expect(capturedLocale?.countryCode, 'ES');
    });
  });
}

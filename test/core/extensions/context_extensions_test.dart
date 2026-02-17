import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ThemeContext', () {
    testWidgets('should return correct textTheme from context', (tester) async {
      TextTheme? capturedTextTheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(
              bodyLarge: TextStyle(fontSize: 16),
            ),
          ),
          home: Builder(
            builder: (context) {
              capturedTextTheme = context.textTheme;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedTextTheme, isNotNull);
      expect(capturedTextTheme?.bodyLarge?.fontSize, 16);
    });

    testWidgets('should return correct colorScheme from context',
        (tester) async {
      ColorScheme? capturedColorScheme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: Builder(
            builder: (context) {
              capturedColorScheme = context.colorScheme;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedColorScheme, isNotNull);
    });

    testWidgets('should return correct primaryColor from context',
        (tester) async {
      Color? capturedColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
          ),
          home: Builder(
            builder: (context) {
              capturedColor = context.primaryColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedColor, isNotNull);
    });

    testWidgets('should return correct secondaryColor from context',
        (tester) async {
      Color? capturedColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          ),
          home: Builder(
            builder: (context) {
              capturedColor = context.secondaryColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedColor, isNotNull);
    });

    testWidgets('should return correct surfaceColor from context',
        (tester) async {
      Color? capturedColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          ),
          home: Builder(
            builder: (context) {
              capturedColor = context.surfaceColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedColor, isNotNull);
    });

    testWidgets('should return correct errorColor from context',
        (tester) async {
      Color? capturedColor;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          ),
          home: Builder(
            builder: (context) {
              capturedColor = context.errorColor;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedColor, isNotNull);
    });

    testWidgets('should return correct brightness from context',
        (tester) async {
      Brightness? capturedBrightness;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.dark),
          home: Builder(
            builder: (context) {
              capturedBrightness = context.brightness;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedBrightness, Brightness.dark);
    });

    testWidgets('should work with light theme brightness', (tester) async {
      Brightness? capturedBrightness;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(brightness: Brightness.light),
          home: Builder(
            builder: (context) {
              capturedBrightness = context.brightness;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedBrightness, Brightness.light);
    });
  });
}

import 'package:fin_track_pro/core/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shimmer/shimmer.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ShimmerBox', () {
    testWidgets('renders a Shimmer widget', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerBox(width: 100, height: 40)));
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('applies provided width and height', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerBox(width: 150, height: 60)));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, 150);
      expect(container.constraints?.maxHeight, 60);
    });

    testWidgets('uses default borderRadius of 8.0', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerBox(width: 80, height: 30)));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(8.0));
    });

    testWidgets('applies custom borderRadius', (tester) async {
      await tester.pumpWidget(
        _wrap(const ShimmerBox(width: 80, height: 30, borderRadius: 16.0)),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16.0));
    });
  });

  group('ShimmerCircle', () {
    testWidgets('renders a Shimmer widget', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerCircle(size: 64)));
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('uses circular BoxShape', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerCircle(size: 64)));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('applies provided size to width and height', (tester) async {
      await tester.pumpWidget(_wrap(const ShimmerCircle(size: 48)));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(Shimmer),
          matching: find.byType(Container),
        ),
      );
      expect(container.constraints?.maxWidth, 48);
      expect(container.constraints?.maxHeight, 48);
    });
  });
}

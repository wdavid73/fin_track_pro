import 'package:fin_track_pro/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
  home: Scaffold(body: child),
);

void main() {
  group('Skeleton', () {
    testWidgets('renders a Container', (tester) async {
      await tester.pumpWidget(_wrap(const Skeleton(width: 100, height: 24)));
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('uses rectangle shape by default', (tester) async {
      await tester.pumpWidget(_wrap(const Skeleton(width: 100, height: 24)));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.rectangle);
    });

    testWidgets('Skeleton.circle uses circle shape', (tester) async {
      await tester.pumpWidget(_wrap(const Skeleton.circle(size: 48)));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('Skeleton.square renders with rectangle shape', (tester) async {
      await tester.pumpWidget(_wrap(const Skeleton.square(size: 64)));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.rectangle);
    });
  });

  group('SkeletonText', () {
    testWidgets('renders a single Skeleton for lines = 1', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonText(width: 150)));
      expect(find.byType(Skeleton), findsOneWidget);
    });

    testWidgets('renders multiple Skeletons for lines > 1', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonText(width: 150, lines: 3)));
      expect(find.byType(Skeleton), findsNWidgets(3));
    });

    testWidgets('uses Column for multi-line', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonText(width: 150, lines: 2)));
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('SkeletonAvatar', () {
    testWidgets('renders a Skeleton.circle with default size 48', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const SkeletonAvatar()));

      // SkeletonAvatar delegates to Skeleton.circle → Container with circle shape
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(_wrap(const SkeletonAvatar(size: 64)));

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 64);
    });
  });
}

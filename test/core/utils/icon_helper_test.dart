import 'package:fin_track_pro/core/utils/icon_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IconHelper', () {
    group('getIcon', () {
      test('should return correct icon for known icon name', () {
        expect(IconHelper.getIcon('work'), Icons.work_outline);
        expect(IconHelper.getIcon('restaurant'), Icons.restaurant_outlined);
        expect(
          IconHelper.getIcon('shopping_cart'),
          Icons.shopping_cart_outlined,
        );
      });

      test('should return default icon for unknown icon name', () {
        expect(IconHelper.getIcon('unknown_icon'), Icons.receipt_long_outlined);
        expect(IconHelper.getIcon(''), Icons.receipt_long_outlined);
      });
    });

    group('getColor', () {
      test('should return correct Color from int value', () {
        const int colorValue = 0xFF42A5F5;
        final color = IconHelper.getColor(colorValue);

        expect(color, const Color(0xFF42A5F5));
      });
    });
  });
}

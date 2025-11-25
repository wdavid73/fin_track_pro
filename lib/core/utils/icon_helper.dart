import 'package:flutter/material.dart';

/// Helper class to map icon names to Material Icons
class IconHelper {
  /// Get IconData from icon name string
  static IconData getIcon(String iconName) {
    final iconMap = <String, IconData>{
      // Income icons
      'work': Icons.work_outline,
      'laptop': Icons.laptop_mac_outlined,
      'trending_up': Icons.trending_up,
      'attach_money': Icons.attach_money,

      // Expense icons
      'restaurant': Icons.restaurant_outlined,
      'local_dining': Icons.local_dining_outlined,
      'fastfood': Icons.fastfood_outlined,
      'directions_car': Icons.directions_car_outlined,
      'train': Icons.train_outlined,
      'home': Icons.home_outlined,
      'movie': Icons.movie_outlined,
      'theaters': Icons.theaters_outlined,
      'local_hospital': Icons.local_hospital_outlined,
      'school': Icons.school_outlined,
      'shopping_bag': Icons.shopping_bag_outlined,
      'shopping_cart': Icons.shopping_cart_outlined,
      'build': Icons.build_outlined,
      'category': Icons.category_outlined,

      // Default
      'receipt': Icons.receipt_long_outlined,
    };

    return iconMap[iconName] ?? Icons.receipt_long_outlined;
  }

  /// Get color from color int value
  static Color getColor(int colorValue) {
    return Color(colorValue);
  }
}

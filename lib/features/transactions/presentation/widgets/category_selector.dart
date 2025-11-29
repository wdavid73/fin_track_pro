import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import '../../../categories/domain/entities/category.dart';
import 'category_chip.dart';

/// A widget that displays a grid of category chips for selection.
///
/// Filters categories by transaction type and allows single selection.
class CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final String transactionType;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.transactionType,
  });

  IconData _getIconData(String iconName) {
    // Map icon names to IconData
    final iconMap = {
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'shopping_bag': Icons.shopping_bag,
      'receipt': Icons.receipt,
      'favorite': Icons.favorite,
      'movie': Icons.movie,
      'work': Icons.work,
      'home': Icons.home,
      'school': Icons.school,
      'sports': Icons.sports_soccer,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
    };

    return iconMap[iconName] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    // Filter categories by transaction type
    final filteredCategories = categories
        .where((category) => category.type == transactionType)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...filteredCategories.map((category) {
              return CategoryChip(
                label: category.name,
                icon: _getIconData(category.icon),
                color: Color(category.color),
                isSelected: selectedCategoryId == category.id,
                onTap: () => onCategorySelected(category.id),
              );
            }),
            // Add "New" button (placeholder for future implementation)
            CategoryChip(
              label: 'New',
              icon: Icons.add,
              color: context.colorScheme.onSurfaceVariant,
              isSelected: false,
              onTap: () {
                // TODO: Implement add new category
              },
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// A toggle widget for switching between Expense and Income transaction types.
///
/// Displays two options in a pill-shaped container with smooth transitions
/// and distinct styling for each type.
class TransactionTypeToggle extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;

  const TransactionTypeToggle({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(100),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Expense',
              isSelected: selectedType == 'expense',
              selectedColor: context.errorColor.withOpacity(0.1),
              selectedTextColor: context.errorColor,
              onTap: () => onTypeChanged('expense'),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _ToggleOption(
              label: 'Income',
              isSelected: selectedType == 'income',
              selectedColor: context.primaryColor.withOpacity(0.1),
              selectedTextColor: context.primaryColor,
              onTap: () => onTypeChanged('income'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color selectedColor;
  final Color selectedTextColor;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.selectedTextColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Center(
          child: Text(
            label,
            style: context.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? selectedTextColor
                  : context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/extensions/extensions.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

class CategoryFormPage extends StatefulWidget {
  final Category? category;

  const CategoryFormPage({super.key, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedIcon = 'category';
  int _selectedColor = 0xFF2196F3;
  String _selectedType = 'expense';

  bool get isEditMode => widget.category != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _nameController.text = widget.category!.name;
      _selectedIcon = widget.category!.icon;
      _selectedColor = widget.category!.color;
      _selectedType = widget.category!.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (_formKey.currentState!.validate()) {
      final category = Category(
        id: isEditMode ? widget.category!.id : const Uuid().v4(),
        name: _nameController.text.trim(),
        icon: _selectedIcon,
        color: _selectedColor,
        type: _selectedType,
      );

      if (isEditMode) {
        getIt.get<CategoryBloc>().add(UpdateCategoryEvent(category));
      } else {
        getIt.get<CategoryBloc>().add(CreateCategoryEvent(category));
      }

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isEditMode ? context.l10n.editCategory : context.l10n.newCategory,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: _saveCategory,
                child: Text(
                  isEditMode ? context.l10n.update : context.l10n.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNameField(),
                const Gap(24),
                _buildTypeSelector(),
                const Gap(24),
                _buildIconSelector(),
                const Gap(24),
                _buildColorSelector(),
                const Gap(32),
                _buildPreview(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.categoryName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: context.l10n.egGroceries,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.pleaseEnterCategoryName;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.type,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: _TypeChip(
                label: context.l10n.expense,
                icon: Icons.arrow_downward,
                isSelected: _selectedType == 'expense',
                onTap: () => setState(() => _selectedType = 'expense'),
                color: Colors.red,
              ),
            ),
            const Gap(12),
            Expanded(
              child: _TypeChip(
                label: context.l10n.income,
                icon: Icons.arrow_upward,
                isSelected: _selectedType == 'income',
                onTap: () => setState(() => _selectedType = 'income'),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    final icons = {
      'shopping_bag': Icons.shopping_bag,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'receipt': Icons.receipt,
      'favorite': Icons.favorite,
      'movie': Icons.movie,
      'work': Icons.work,
      'home': Icons.home,
      'school': Icons.school,
      'sports_soccer': Icons.sports_soccer,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
      'local_hospital': Icons.local_hospital,
      'fitness_center': Icons.fitness_center,
      'shopping_cart': Icons.shopping_cart,
      'phone': Icons.phone,
      'computer': Icons.computer,
      'pets': Icons.pets,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.icon,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: icons.entries.map((entry) {
            final isSelected = _selectedIcon == entry.key;
            return InkWell(
              onTap: () => setState(() => _selectedIcon = entry.key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Color(_selectedColor).withValues(alpha: 0.15)
                      : context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Color(_selectedColor)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Icon(
                  entry.value,
                  color: isSelected ? Color(_selectedColor) : Colors.grey[600],
                  size: 28,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final colors = [
      0xFFE91E63, // Pink
      0xFFF44336, // Red
      0xFFFF5722, // Deep Orange
      0xFFFF9800, // Orange
      0xFFFFC107, // Amber
      0xFFFFEB3B, // Yellow
      0xFFCDDC39, // Lime
      0xFF8BC34A, // Light Green
      0xFF4CAF50, // Green
      0xFF009688, // Teal
      0xFF00BCD4, // Cyan
      0xFF03A9F4, // Light Blue
      0xFF2196F3, // Blue
      0xFF3F51B5, // Indigo
      0xFF673AB7, // Deep Purple
      0xFF9C27B0, // Purple
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.color,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const Gap(12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((color) {
            final isSelected = _selectedColor == color;
            return InkWell(
              onTap: () => setState(() => _selectedColor = color),
              borderRadius: BorderRadius.circular(28),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Color(color),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 28)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.preview,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const Gap(12),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Color(_selectedColor).withValues(alpha: 0.15),
                child: Icon(
                  _getIconData(_selectedIcon),
                  color: Color(_selectedColor),
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameController.text.isEmpty
                          ? context.l10n.categoryName
                          : _nameController.text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      _selectedType == 'expense'
                          ? context.l10n.expense
                          : context.l10n.income,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'shopping_bag': Icons.shopping_bag,
      'restaurant': Icons.restaurant,
      'directions_car': Icons.directions_car,
      'receipt': Icons.receipt,
      'favorite': Icons.favorite,
      'movie': Icons.movie,
      'work': Icons.work,
      'home': Icons.home,
      'school': Icons.school,
      'sports_soccer': Icons.sports_soccer,
      'flight': Icons.flight,
      'hotel': Icons.hotel,
      'local_hospital': Icons.local_hospital,
      'fitness_center': Icons.fitness_center,
      'shopping_cart': Icons.shopping_cart,
      'phone': Icons.phone,
      'computer': Icons.computer,
      'pets': Icons.pets,
      'category': Icons.category,
    };
    return iconMap[iconName] ?? Icons.category;
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 20),
            const Gap(8),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

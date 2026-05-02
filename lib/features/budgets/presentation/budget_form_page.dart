import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/presentation/bloc/budget_bloc/budget_bloc.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:uuid/uuid.dart';

/// Modal bottom sheet for creating or editing a budget.
class BudgetFormPage extends StatefulWidget {
  /// Pass a [budget] to edit, null to create.
  final Budget? budget;

  /// All categories available for selection.
  final List<Category> categories;

  const BudgetFormPage({super.key, this.budget, required this.categories});

  bool get isEditMode => budget != null;

  @override
  State<BudgetFormPage> createState() => _BudgetFormPageState();
}

class _BudgetFormPageState extends State<BudgetFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();

  String? _selectedCategoryId;
  String _selectedPeriod = 'monthly';

  @override
  void initState() {
    super.initState();
    if (widget.isEditMode) {
      final raw = widget.budget!.amount.toStringAsFixed(0);
      final buf = StringBuffer();
      for (int i = 0; i < raw.length; i++) {
        if (i > 0 && (raw.length - i) % 3 == 0) buf.write('.');
        buf.write(raw[i]);
      }
      _amountController.text = buf.toString();
      _selectedCategoryId = widget.budget!.categoryId;
      _selectedPeriod = widget.budget!.period;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final budget = Budget(
      id: widget.isEditMode ? widget.budget!.id : const Uuid().v4(),
      categoryId: _selectedCategoryId!,
      amount: double.parse(_amountController.text.replaceAll('.', '').trim()),
      period: _selectedPeriod,
    );

    if (widget.isEditMode) {
      context.read<BudgetBloc>().add(UpdateBudgetEvent(budget));
    } else {
      context.read<BudgetBloc>().add(CreateBudgetEvent(budget));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(20),
            // Title
            Text(
              widget.isEditMode
                  ? context.l10n.editBudget
                  : context.l10n.newBudget,
              style: context.textTheme.headlineSmall,
            ),
            const Gap(24),
            // Category selector
            _buildCategoryDropdown(),
            const Gap(20),
            // Amount field
            _buildAmountField(),
            const Gap(20),
            // Period selector
            _buildPeriodSelector(),
            const Gap(32),
            // Submit button
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                widget.isEditMode ? context.l10n.update : context.l10n.save,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: context.l10n.category,
        hintText: context.l10n.selectACategory,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      isExpanded: true,
      items: widget.categories.map((cat) {
        return DropdownMenuItem<String>(
          value: cat.id,
          child: Text(cat.name, overflow: TextOverflow.ellipsis),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedCategoryId = value),
      validator: (value) {
        if (value == null) return context.l10n.pleaseSelectCategory;
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      inputFormatters: [MoneyInputFormatter()],
      decoration: InputDecoration(
        labelText: context.l10n.budgetAmount,
        hintText: context.l10n.enterAmount,
        prefixText: '\$ ',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return context.l10n.pleaseEnterAmount;
        }
        final parsed = double.tryParse(value.replaceAll('.', '').trim());
        if (parsed == null || parsed <= 0) {
          return context.l10n.pleaseEnterValidAmount;
        }
        return null;
      },
    );
  }

  Widget _buildPeriodSelector() {
    final periods = [
      ('monthly', context.l10n.monthly),
      ('weekly', context.l10n.weekly),
      ('yearly', context.l10n.yearly),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.period,
          style: context.textTheme.labelLarge!.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const Gap(10),
        Row(
          children: periods.map((p) {
            final isSelected = _selectedPeriod == p.$1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: p.$1 != 'yearly' ? 8 : 0),
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPeriod = p.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? context.colorScheme.primary
                          : context.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      p.$2,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : context.colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

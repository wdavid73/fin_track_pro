import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_cubit.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_state.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

/// Wraps [AddTransactionPage] with the required BLoC providers.
/// Call this from showModalBottomSheet so the modal has access to getIt.
class AddTransactionModal extends StatelessWidget {
  const AddTransactionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AddTransactionCubit>()),
        BlocProvider.value(value: getIt<TransactionBloc>()),
      ],
      child: const AddTransactionPage(),
    );
  }
}

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _amountController = TextEditingController(text: '0.00');
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddTransactionCubit, AddTransactionState>(
      listener: (context, state) {
        if (state.submitSuccess) {
          context.read<TransactionBloc>().add(const LoadTransactions());
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.l10n.transactionSaved),
              backgroundColor: context.colorScheme.tertiary,
            ),
          );
        }
        if (state.errorMessage != null && !state.isLoadingCategories) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.colorScheme.secondary,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddTransactionCubit>();
        final isExpense = state.transactionType == 'expense';
        final filteredCategories = state.categories
            .where((c) => c.type == state.transactionType)
            .toList();

        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHandle(),
              _buildHeader(context),
              _buildTypeToggle(isExpense, cubit),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Gap(24.0),
                      _buildAmountInput(cubit),
                      const Gap(32.0),
                      _buildLabel(context.l10n.category),
                      const Gap(16.0),
                      _buildCategoryChips(state, filteredCategories, cubit),
                      const Gap(32.0),
                      _buildLabel(context.l10n.note),
                      const Gap(16.0),
                      _buildNoteField(cubit),
                      const Gap(32.0),
                      _buildLabel(context.l10n.date),
                      const Gap(16.0),
                      _buildDateRow(context, state, cubit),
                      const Gap(4.00),
                      _buildSaveButton(context, state, cubit),
                      const Gap(24.0),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: context.colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
      child: Row(
        children: [
          Text(context.l10n.addTransaction, style: context.textTheme.headlineSmall!),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.close, color: context.colorScheme.onSurfaceVariant),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(bool isExpense, AddTransactionCubit cubit) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24.0,
        vertical: 16.0,
      ),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            _TypeOption(
              label: context.l10n.expense,
              isSelected: isExpense,
              color: context.colorScheme.secondary,
              onTap: () => cubit.updateTransactionType('expense'),
            ),
            _TypeOption(
              label: context.l10n.income,
              isSelected: !isExpense,
              color: context.colorScheme.tertiary,
              onTap: () => cubit.updateTransactionType('income'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput(AddTransactionCubit cubit) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 32.0,
        vertical: 24.0,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.amount, style: context.textTheme.labelLarge!),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '\$',
                style: context.textTheme.headlineMedium!.copyWith(color: context.colorScheme.primary),
              ),
              const Gap(8),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                    letterSpacing: -1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onChanged: (v) => cubit.updateAmount(double.tryParse(v)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text, style: context.textTheme.headlineSmall!);

  Widget _buildCategoryChips(
    AddTransactionState state,
    List<Category> categories,
    AddTransactionCubit cubit,
  ) {
    if (state.isLoadingCategories) {
      return const SizedBox(
        height: 40,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (categories.isEmpty) {
      return Text(context.l10n.noCategories, style: context.textTheme.bodyMedium!);
    }
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = state.selectedCategoryId == cat.id;
        final label = '${CategoryHelper.categoryEmoji(cat.icon)} ${cat.name}';
        return GestureDetector(
          onTap: () => cubit.updateCategory(cat.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.colorScheme.primary
                  : context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              label,
              style: context.textTheme.bodyMedium!.copyWith(
                color: isSelected ? Colors.white : context.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNoteField(AddTransactionCubit cubit) {
    return TextField(
      controller: _noteController,
      maxLines: 2,
      style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: context.l10n.addNote,
        hintStyle: context.textTheme.bodyMedium!,
        filled: true,
        fillColor: context.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(24.0),
      ),
      onChanged: cubit.updateDescription,
    );
  }

  Widget _buildDateRow(
    BuildContext context,
    AddTransactionState state,
    AddTransactionCubit cubit,
  ) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: state.selectedDate,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (picked != null) cubit.updateDate(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24.0,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: context.colorScheme.primary,
              size: 18,
            ),
            const Gap(10),
            Text(
              CategoryHelper.formatDateLong(state.selectedDate),
              style: context.textTheme.bodyMedium!.copyWith(color: context.colorScheme.onSurface),
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: context.colorScheme.outline, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(
    BuildContext context,
    AddTransactionState state,
    AddTransactionCubit cubit,
  ) {
    final enabled = state.isFormValid && !state.isSubmitting;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: enabled ? ThemeConstants.primaryGradient : null,
        color: enabled ? null : context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: enabled ? cubit.saveTransaction : null,
          child: Center(
            child: state.isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    context.l10n.saveTransaction,
                    style: TextStyle(
                      color: enabled
                          ? Colors.white
                          : context.colorScheme.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : context.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

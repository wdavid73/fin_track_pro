import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class TransactionFilterBottomSheet extends StatefulWidget {
  final String? selectedType;
  final String? selectedCategoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final List<Category> categories;
  final Function(
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  )
  onApplyFilters;
  final VoidCallback onClearFilters;

  const TransactionFilterBottomSheet({
    super.key,
    this.selectedType,
    this.selectedCategoryId,
    this.startDate,
    this.endDate,
    this.searchQuery,
    required this.categories,
    required this.onApplyFilters,
    required this.onClearFilters,
  });

  @override
  State<TransactionFilterBottomSheet> createState() =>
      _TransactionFilterBottomSheetState();
}

class _TransactionFilterBottomSheetState
    extends State<TransactionFilterBottomSheet> {
  late String? _selectedType;
  late String? _selectedCategoryId;
  late DateTime? _startDate;
  late DateTime? _endDate;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.selectedType;
    _selectedCategoryId = widget.selectedCategoryId;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Transactions',
                    style: context.textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Gap(24),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search by description',
                  hintText: 'Enter transaction description',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) => setState(() {}),
              ),
              const Gap(24),

              // Transaction Type
              Text('Transaction Type', style: context.textTheme.titleSmall),
              const Gap(8),
              SegmentedButton<String?>(
                segments: const [
                  ButtonSegment(value: null, label: Text('All')),
                  ButtonSegment(value: 'expense', label: Text('Expense')),
                  ButtonSegment(value: 'income', label: Text('Income')),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<String?> selection) {
                  setState(() {
                    _selectedType = selection.first;
                    // Reset category when type changes
                    _selectedCategoryId = null;
                  });
                },
              ),
              const Gap(24),

              // Category
              Text('Category', style: context.textTheme.titleSmall),
              const Gap(8),
              DropdownButtonFormField<String?>(
                value: _selectedCategoryId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                hint: const Text('All categories'),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...widget.categories
                      .where(
                        (c) => _selectedType == null || c.type == _selectedType,
                      )
                      .map(
                        (category) => DropdownMenuItem(
                          value: category.id,
                          child: Row(
                            children: [
                              Icon(
                                icons[category.icon] ?? Icons.category,
                                size: 20,
                              ),
                              const Gap(8),
                              Text(category.name),
                            ],
                          ),
                        ),
                      ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                  });
                },
              ),
              const Gap(24),

              // Date Range
              Text('Date Range', style: context.textTheme.titleSmall),
              const Gap(8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _startDate != null
                            ? DateFormat('MMM dd, yyyy').format(_startDate!)
                            : 'Start Date',
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        _endDate != null
                            ? DateFormat('MMM dd, yyyy').format(_endDate!)
                            : 'End Date',
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        widget.onClearFilters();
                        Navigator.of(context).pop();
                      },
                      child: const Text('Clear All'),
                    ),
                  ),
                  const Gap(16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onApplyFilters(
                          _selectedType,
                          _selectedCategoryId,
                          _startDate,
                          _endDate,
                          _searchController.text.isEmpty
                              ? null
                              : _searchController.text,
                        );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showTransactionFilterBottomSheet({
  required BuildContext context,
  String? selectedType,
  String? selectedCategoryId,
  DateTime? startDate,
  DateTime? endDate,
  String? searchQuery,
  required List<Category> categories,
  required Function(
    String? type,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  )
  onApplyFilters,
  required VoidCallback onClearFilters,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionFilterBottomSheet(
      selectedType: selectedType,
      selectedCategoryId: selectedCategoryId,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      categories: categories,
      onApplyFilters: onApplyFilters,
      onClearFilters: onClearFilters,
    ),
  );
}

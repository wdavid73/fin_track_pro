import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_details_modal.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_filter_bottom_sheet.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatelessWidget {
  const AllTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<TransactionBloc>()..add(const LoadPaginatedTransactions()),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text('All Transactions', style: context.textTheme.titleLarge),
          actions: [
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                return IconButton(
                  icon: Badge(
                    isLabelVisible: state.hasActiveFilters,
                    child: const Icon(Icons.filter_list),
                  ),
                  onPressed: () async {
                    final categories = await getIt<GetCategoriesUseCase>()();
                    if (context.mounted) {
                      showTransactionFilterBottomSheet(
                        context: context,
                        selectedType: state.typeFilter,
                        selectedCategoryId: state.categoryFilter,
                        startDate: state.startDateFilter,
                        endDate: state.endDateFilter,
                        searchQuery: state.searchQuery,
                        categories: categories,
                        onApplyFilters: (type, categoryId, startDate, endDate, searchQuery) {
                          context.read<TransactionBloc>().add(
                                FilterTransactions(
                                  type: type,
                                  categoryId: categoryId,
                                  startDate: startDate,
                                  endDate: endDate,
                                  searchQuery: searchQuery,
                                ),
                              );
                        },
                        onClearFilters: () {
                          context.read<TransactionBloc>().add(const ClearFilters());
                        },
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: const _TransactionsList(),
      ),
    );
  }
}

class _TransactionsList extends StatefulWidget {
  const _TransactionsList();

  @override
  State<_TransactionsList> createState() => _TransactionsListState();
}

class _TransactionsListState extends State<_TransactionsList> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isLoadingMore) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0; // Trigger load when 200px from bottom

    if (maxScroll - currentScroll <= delta) {
      final state = context.read<TransactionBloc>().state;
      if (state.hasMore && state.status == TransactionStatus.success) {
        setState(() => _isLoadingMore = true);
        context.read<TransactionBloc>().add(const LoadMoreTransactions());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TransactionBloc, TransactionState>(
      listener: (context, state) {
        if (state.status == TransactionStatus.success) {
          setState(() => _isLoadingMore = false);
        }
      },
      builder: (context, state) {
        if (state.status == TransactionStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == TransactionStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.errorColor),
                const Gap(16),
                Text(state.errorMessage ?? 'An error occurred'),
                const Gap(16),
                ElevatedButton(
                  onPressed: () {
                    context.read<TransactionBloc>().add(
                      const LoadPaginatedTransactions(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.status == TransactionStatus.success) {
          if (state.transactions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 48,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                  const Gap(16),
                  Text(
                    'No transactions yet',
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: context.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.transactions.length + (state.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              // Show loading indicator at the bottom
              if (index == state.transactions.length) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final transaction = state.transactions[index];
              final isIncome = transaction.type == 'income';

              // For now, we'll use default icons since we don't have category data
              // In a real implementation, you'd want to fetch categories too
              final categoryIcon = isIncome
                  ? Icons.arrow_downward
                  : Icons.arrow_upward;
              final categoryColor = isIncome
                  ? context.secondaryColor
                  : context.errorColor;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TransactionCard(
                  amount: transaction.amount,
                  icon: categoryIcon,
                  iconBackgroundColor: categoryColor.withValues(alpha: 0.1),
                  iconColor: categoryColor,
                  title: transaction.note ?? 'Transaction',
                  date: DateFormat('MMM dd, yyyy').format(transaction.date),
                  amountColor: categoryColor,
                  isIncome: isIncome,
                  onLongPress: () {
                    showTransactionDetailsModal(
                      context: context,
                      transaction: transaction,
                      icon: categoryIcon,
                      iconColor: categoryColor,
                      iconBackgroundColor: categoryColor.withValues(alpha: 0.1),
                    );
                  },
                ),
              );
            },
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

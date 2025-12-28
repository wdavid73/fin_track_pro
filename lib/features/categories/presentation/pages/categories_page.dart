import 'package:animate_do/animate_do.dart';
import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/extensions/extensions.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:fin_track_pro/features/categories/presentation/pages/category_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _WrapperCategoryProviders(child: _CategoryBody());
  }
}

class _CategoryBody extends StatefulWidget {
  const _CategoryBody();

  @override
  State<_CategoryBody> createState() => _CategoryBodyState();
}

class _CategoryBodyState extends State<_CategoryBody> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategoryStatsEvent());
  }

  void _showCategoryForm(BuildContext context, {Category? category}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CategoryFormPage(category: category),
    ).then((_) {
      // Reload categories after form is closed
      if (context.mounted) {
        context.read<CategoryBloc>().add(LoadCategoryStatsEvent());
      }
    });
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteCategory),
        content: Text(context.l10n.areYouSureDeleteCategory),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CategoryBloc>().add(
                DeleteCategoryEvent(category.id),
              );
              Future.delayed(const Duration(milliseconds: 500), () {
                if (context.mounted) {
                  context.read<CategoryBloc>().add(LoadCategoryStatsEvent());
                }
              });
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.categories), elevation: 0),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryForm(context),
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state.status == CategoryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == CategoryStatus.error) {
            return _errorWidget(state, context);
          }

          if (state.status == CategoryStatus.success) {
            if (state.categoryStats.isEmpty) {
              return _categoriesEmptyWidget();
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: RefreshIndicator(
                onRefresh: () async =>
                    context.read<CategoryBloc>().add(LoadCategoryStatsEvent()),
                child: ListView.separated(
                  itemCount: state.categoryStats.length,
                  separatorBuilder: (ctx, index) => const Gap(12),
                  itemBuilder: (ctx, index) {
                    final stats = state.categoryStats[index];
                    return _CategoryCard(
                      category: stats.category,
                      transactionCount: stats.transactionCount,
                      amount: stats.totalAmount.toCompactCurrency(
                        locale: context.locale.languageCode,
                      ),
                      onEdit: () =>
                          _showCategoryForm(context, category: stats.category),
                      onDelete: () =>
                          _showDeleteConfirmation(context, stats.category),
                    );
                  },
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Center _categoriesEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category_outlined, size: 64, color: Colors.grey[400]),
          const Gap(16),
          Text(
            'No categories yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const Gap(8),
          Text(
            'Create your first category to get started',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Center _errorWidget(CategoryState state, BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const Gap(16),
            Text(
              'Error loading categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            const Gap(8),
            Text(
              state.errorMessage ?? 'Unknown error',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const Gap(24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<CategoryBloc>().add(LoadCategoryStatsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final int transactionCount;
  final String amount;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryCard({
    required this.category,
    required this.transactionCount,
    required this.amount,
    required this.onEdit,
    required this.onDelete,
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
    return BounceInLeft(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Color(category.color).withValues(alpha: 0.15),
              child: Icon(
                _getIconData(category.icon),
                color: Color(category.color),
                size: 24,
              ),
            ),
            const Gap(16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Gap(4),
                Text(
                  '$transactionCount ${context.l10n.transactions}',
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            Text(
              amount,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit),
                      const Gap(12),
                      Text(context.l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const Gap(12),
                      Text(
                        context.l10n.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WrapperCategoryProviders extends StatelessWidget {
  final Widget child;
  const _WrapperCategoryProviders({required this.child});

  @override
  Widget build(BuildContext context) {
    final categoryBloc = getIt.get<CategoryBloc>();
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: categoryBloc)],
      child: child,
    );
  }
}

import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/features/home/presentation/shell_page.dart';
import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/home/presentation/widget/budget_bars_row.dart';
import 'package:fin_track_pro/features/home/presentation/widget/home_app_bar.dart';
import 'package:fin_track_pro/features/home/presentation/widget/home_empty_state.dart';
import 'package:fin_track_pro/features/home/presentation/widget/home_fab.dart';
import 'package:fin_track_pro/features/home/presentation/widget/home_transaction_tile.dart';
import 'package:fin_track_pro/features/home/presentation/widget/quick_stats_row.dart';
import 'package:fin_track_pro/features/home/presentation/widget/section_header.dart';
import 'package:fin_track_pro/features/home/presentation/widget/shimmers/home_content_shimmer.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/add_transaction_modal.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const LoadHomeData()),
        ),
        BlocProvider.value(value: getIt<TransactionBloc>()),
      ],
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  bool _isVisible = true;

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final balance = state is HomeLoaded ? state.totalBalance : 0.0;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const LoadHomeData());
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _buildCollapsibleHeader(context, balance),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _buildContent(context, state),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: HomeFab(onTap: () => _showAddTransaction(context)),
    );
  }

  SliverAppBar _buildCollapsibleHeader(BuildContext context, double balance) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 280,
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: HomeAppBar(
        balance: balance,
        isVisible: _isVisible,
        onToggle: () => setState(() => _isVisible = !_isVisible),
        onOpenDrawer: () => ShellPage.scaffoldKey.currentState?.openDrawer(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return const HomeContentShimmer();
    }
    if (state is HomeError) {
      return _buildError(context, state.message);
    }
    if (state is HomeLoaded) {
      return _buildLoaded(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoaded(BuildContext context, HomeLoaded state) {
    final income = state.recentTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (s, t) => s + t.amount);
    final expenses = state.recentTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16.0),
        QuickStatsRow(income: income, expenses: expenses),

        const Gap(16.0),
        SectionHeader(
          title: context.l10n.budgetOverview,
          actionLabel: context.l10n.viewAll,
          onAction: () => context.go(RouteConstants.budget),
        ),
        const Gap(16.0),
        if (state.budgetData != null && state.budgetData!.categories.isNotEmpty)
          BudgetBarsRow(budgetData: state.budgetData!)
        else
          const BudgetBarsRow.empty(),

        const Gap(16.00),
        SectionHeader(
          title: context.l10n.recentTransactions,
          actionLabel: context.l10n.viewAll,
          onAction: () => context.go(RouteConstants.transactions),
        ),
        const Gap(20.0),
        if (state.recentTransactions.isEmpty)
          HomeEmptyState(
            icon: Icons.receipt_long_outlined,
            label: context.l10n.noTransactions,
          )
        else
          ...state.recentTransactions.map((tx) {
            final category = state.categories[tx.categoryId];
            return HomeTransactionTile(
              emoji: CategoryHelper.categoryEmoji(category?.icon ?? ''),
              title: category?.name ?? (tx.note ?? 'Transacción'),
              category: category?.name ?? 'Sin categoría',
              amount: tx.type == 'income' ? tx.amount : -tx.amount,
              date: CategoryHelper.formatDate(tx.date),
            );
          }),
        const Gap(100),
      ],
    );
  }

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: context.colorScheme.secondary,
              size: 48,
            ),
            const Gap(16),
            Text(
              message,
              style: context.textTheme.bodyMedium!,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            TextButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(const LoadHomeData()),
              child: Text(
                'Reintentar',
                style: TextStyle(color: context.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


/**
 * 
 * Hemos avanzado significativamente en la migración, pero nos encontramos con un bloqueo técnico en la generación de imágenes que debo resolver. Aquí tienes el resumen de lo que falta:

✅ Lo que ya está hecho
Dependencias: alchemist instalado (actualizado a v0.14.0 para compatibilidad con Flutter 3.41).
Infraestructura: flutter_test_config.dart reescrito y helper golden_test_helpers.dart creado.
Configuración: .gitignore y dart_test.yaml actualizados.
Tests escritos: Ya están listos los archivos para TransactionCard, StatCard y BalanceHeroCard.
Limpieza: Las imágenes viejas de golden_toolkit ya fueron eliminadas.
🛠️ Lo que falta (El Bloqueo Actual)
Corregir errores de Layout: Al intentar generar las imágenes (--update-goldens), los tests fallan porque algunos widgets (como BalanceHeroCard) están intentando ocupar un tamaño infinito dentro del entorno de test.
Acción inmediata: Ajustar el helper buildWithFinTrackTheme para dar restricciones de tamaño explícitas o envolver los widgets en SizedBox/ConstrainedBox.
Generar Imágenes de Referencia: Una vez corregido el layout, ejecutar el comando para crear los nuevos archivos .png.
Tarea 4: CI y Documentación:
Agregar el job de golden_tests al workflow de GitHub Actions (ci.yml).
Redactar el ADR-010 en docs/ADR.md.
Actualizar docs/CURRENT_STATUS.md con los nuevos tests (pasamos de 4 a 12 escenarios).
Siguiente paso: Voy a corregir el problema de layout en los tests para poder generar las imágenes de referencia.
 */
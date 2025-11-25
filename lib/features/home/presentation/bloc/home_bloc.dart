import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_recent_transactions.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_total_balance.dart';

part 'home_event.dart';
part 'home_state.dart';

/// BLoC for managing home page state
@injectable
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetRecentTransactions _getRecentTransactions;
  final GetTotalBalance _getTotalBalance;
  final GetCategories _getCategories;
  final GetBudgetData _getBudgetData;

  HomeBloc(
    this._getRecentTransactions,
    this._getTotalBalance,
    this._getCategories,
    this._getBudgetData,
  ) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeData event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeData event,
    Emitter<HomeState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      // Load recent transactions, total balance, categories, and budget data
      final transactions = await _getRecentTransactions(limit: 5);
      final balance = await _getTotalBalance();
      final categoriesList = await _getCategories();
      final budgetData = await _getBudgetData();

      // Convert categories list to map for easy lookup
      final categoriesMap = <String, Category>{};
      for (final category in categoriesList) {
        categoriesMap[category.id] = category;
      }

      emit(
        HomeLoaded(
          recentTransactions: transactions,
          totalBalance: balance,
          categories: categoriesMap,
          budgetData: budgetData,
        ),
      );
    } catch (e) {
      emit(HomeError('An unexpected error occurred: $e'));
    }
  }
}

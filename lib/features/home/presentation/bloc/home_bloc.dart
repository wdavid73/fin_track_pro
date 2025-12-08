import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories_use_case.dart';
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
  final GetCategoriesUseCase _getCategories;
  final GetBudgetData _getBudgetData;
  final TransactionBloc _transactionBloc;
  StreamSubscription? _transactionSubscription;

  HomeBloc(
    this._getRecentTransactions,
    this._getTotalBalance,
    this._getCategories,
    this._getBudgetData,
    this._transactionBloc,
  ) : super(const HomeInitial()) {
    on<LoadHomeData>(_onLoadHomeData);
    on<RefreshHomeData>(_onRefreshHomeData);

    // Listen to TransactionBloc changes
    _transactionSubscription = _transactionBloc.stream.listen((state) {
      if (state is TransactionOperationSuccess) {
        add(const RefreshHomeData());
      }
    });
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
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
      if (FlavorConfig.instance.isDev) {
        await Future.delayed(const Duration(seconds: 2));
      }

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

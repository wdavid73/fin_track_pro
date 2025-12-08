// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:hive/hive.dart' as _i979;
import 'package:injectable/injectable.dart' as _i526;

import '../core/database/hive_service.dart' as _i82;
import '../core/database/seeders/budget_seeder.dart' as _i406;
import '../core/database/seeders/category_seeder.dart' as _i12;
import '../core/database/seeders/database_seeder.dart' as _i118;
import '../core/database/seeders/transaction_seeder.dart' as _i264;
import '../core/utils/logger_service.dart' as _i910;
import '../features/analytics/domain/usecases/get_analytics_data.dart' as _i86;
import '../features/analytics/presentation/bloc/analytics_bloc.dart' as _i260;
import '../features/budgets/data/datasources/budget_datasource.dart' as _i196;
import '../features/budgets/data/datasources/budget_local_datasource.dart'
    as _i285;
import '../features/budgets/data/models/budget_model.dart' as _i731;
import '../features/budgets/data/repositories/budget_repository_impl.dart'
    as _i310;
import '../features/budgets/domain/repositories/budget_repository.dart' as _i43;
import '../features/budgets/domain/usecases/get_budgets.dart' as _i299;
import '../features/budgets/domain/usecases/save_budget.dart' as _i1020;
import '../features/categories/data/datasources/category_local_datasource.dart'
    as _i409;
import '../features/categories/data/repositories/category_repository_impl.dart'
    as _i346;
import '../features/categories/domain/repositories/category_repository.dart'
    as _i745;
import '../features/categories/domain/usecases/create_category_use_case.dart'
    as _i946;
import '../features/categories/domain/usecases/delete_category_use_case.dart'
    as _i189;
import '../features/categories/domain/usecases/get_categories_use_case.dart'
    as _i374;
import '../features/categories/domain/usecases/get_category_stats_use_case.dart'
    as _i30;
import '../features/categories/domain/usecases/search_categories_use_case.dart'
    as _i867;
import '../features/categories/domain/usecases/update_category_use_case.dart'
    as _i331;
import '../features/categories/domain/usecases/usecases.dart' as _i931;
import '../features/categories/presentation/bloc/category_bloc/category_bloc.dart'
    as _i274;
import '../features/home/presentation/bloc/home_bloc.dart' as _i824;
import '../features/transactions/data/datasources/transaction_local_datasource.dart'
    as _i730;
import '../features/transactions/data/repositories/transaction_repository_impl.dart'
    as _i667;
import '../features/transactions/domain/repositories/transaction_repository.dart'
    as _i443;
import '../features/transactions/domain/usecases/create_transaction.dart'
    as _i333;
import '../features/transactions/domain/usecases/delete_transaction.dart'
    as _i424;
import '../features/transactions/domain/usecases/get_budget_data.dart' as _i230;
import '../features/transactions/domain/usecases/get_paginated_transactions.dart'
    as _i735;
import '../features/transactions/domain/usecases/get_recent_transactions.dart'
    as _i909;
import '../features/transactions/domain/usecases/get_total_balance.dart'
    as _i605;
import '../features/transactions/domain/usecases/get_transactions.dart'
    as _i1058;
import '../features/transactions/domain/usecases/update_transaction.dart'
    as _i974;
import '../features/transactions/domain/usecases/usecases.dart' as _i913;
import '../features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_cubit.dart'
    as _i70;
import '../features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart'
    as _i905;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final registerModule = _$RegisterModule();
    gh.singleton<_i82.HiveService>(() => _i82.HiveService());
    gh.singleton<_i910.LoggerService>(() => _i910.LoggerService());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.lazySingleton<_i979.Box<_i731.BudgetModel>>(
      () => registerModule.budgetBox,
      instanceName: 'budgetBox',
    );
    gh.singleton<_i406.BudgetSeeder>(() => _i406.BudgetSeeder(
          gh<_i82.HiveService>(),
          gh<_i910.LoggerService>(),
        ));
    gh.singleton<_i12.CategorySeeder>(() => _i12.CategorySeeder(
          gh<_i82.HiveService>(),
          gh<_i910.LoggerService>(),
        ));
    gh.singleton<_i264.TransactionSeeder>(() => _i264.TransactionSeeder(
          gh<_i82.HiveService>(),
          gh<_i910.LoggerService>(),
        ));
    gh.factory<_i730.TransactionLocalDataSource>(
        () => _i730.TransactionLocalDataSource(gh<_i82.HiveService>()));
    gh.factory<_i409.CategoryLocalDataSource>(
        () => _i409.CategoryLocalDataSource(gh<_i82.HiveService>()));
    gh.singleton<_i118.DatabaseSeeder>(() => _i118.DatabaseSeeder(
          gh<_i12.CategorySeeder>(),
          gh<_i406.BudgetSeeder>(),
          gh<_i264.TransactionSeeder>(),
          gh<_i910.LoggerService>(),
        ));
    gh.lazySingleton<_i196.BudgetDatasource>(() => _i285.BudgetLocalDatasource(
        gh<_i979.Box<_i731.BudgetModel>>(instanceName: 'budgetBox')));
    gh.lazySingleton<_i443.TransactionRepository>(() =>
        _i667.TransactionRepositoryImpl(
            gh<_i730.TransactionLocalDataSource>()));
    gh.lazySingleton<_i43.BudgetRepository>(
        () => _i310.BudgetRepositoryImpl(gh<_i196.BudgetDatasource>()));
    gh.factory<_i1058.GetTransactions>(
        () => _i1058.GetTransactions(gh<_i443.TransactionRepository>()));
    gh.factory<_i333.CreateTransaction>(
        () => _i333.CreateTransaction(gh<_i443.TransactionRepository>()));
    gh.factory<_i974.UpdateTransaction>(
        () => _i974.UpdateTransaction(gh<_i443.TransactionRepository>()));
    gh.factory<_i424.DeleteTransaction>(
        () => _i424.DeleteTransaction(gh<_i443.TransactionRepository>()));
    gh.factory<_i735.GetPaginatedTransactions>(() =>
        _i735.GetPaginatedTransactions(gh<_i443.TransactionRepository>()));
    gh.factory<_i1020.SaveBudget>(
        () => _i1020.SaveBudget(gh<_i43.BudgetRepository>()));
    gh.factory<_i299.GetBudgets>(
        () => _i299.GetBudgets(gh<_i43.BudgetRepository>()));
    gh.singleton<_i905.TransactionBloc>(() => _i905.TransactionBloc(
          gh<_i913.GetTransactions>(),
          gh<_i913.GetPaginatedTransactions>(),
          gh<_i913.CreateTransaction>(),
          gh<_i913.UpdateTransaction>(),
          gh<_i913.DeleteTransaction>(),
        ));
    gh.lazySingleton<_i745.CategoryRepository>(() =>
        _i346.CategoryRepositoryImpl(gh<_i409.CategoryLocalDataSource>()));
    gh.factory<_i909.GetRecentTransactions>(
        () => _i909.GetRecentTransactions(gh<_i443.TransactionRepository>()));
    gh.factory<_i605.GetTotalBalance>(
        () => _i605.GetTotalBalance(gh<_i443.TransactionRepository>()));
    gh.factory<_i230.GetBudgetData>(() => _i230.GetBudgetData(
          gh<_i443.TransactionRepository>(),
          gh<_i745.CategoryRepository>(),
          gh<_i299.GetBudgets>(),
        ));
    gh.factory<_i867.SearchCategoriesUseCase>(
        () => _i867.SearchCategoriesUseCase(gh<_i745.CategoryRepository>()));
    gh.factory<_i374.GetCategoriesUseCase>(
        () => _i374.GetCategoriesUseCase(gh<_i745.CategoryRepository>()));
    gh.factory<_i946.CreateCategoryUseCase>(
        () => _i946.CreateCategoryUseCase(gh<_i745.CategoryRepository>()));
    gh.factory<_i189.DeleteCategoryUseCase>(
        () => _i189.DeleteCategoryUseCase(gh<_i745.CategoryRepository>()));
    gh.factory<_i331.UpdateCategoryUseCase>(
        () => _i331.UpdateCategoryUseCase(gh<_i745.CategoryRepository>()));
    gh.factory<_i824.HomeBloc>(() => _i824.HomeBloc(
          gh<_i909.GetRecentTransactions>(),
          gh<_i605.GetTotalBalance>(),
          gh<_i374.GetCategoriesUseCase>(),
          gh<_i230.GetBudgetData>(),
          gh<_i905.TransactionBloc>(),
        ));
    gh.factory<_i86.GetAnalyticsData>(() => _i86.GetAnalyticsData(
          gh<_i443.TransactionRepository>(),
          gh<_i745.CategoryRepository>(),
        ));
    gh.factory<_i30.GetCategoryStatsUseCase>(() => _i30.GetCategoryStatsUseCase(
          gh<_i745.CategoryRepository>(),
          gh<_i443.TransactionRepository>(),
        ));
    gh.factory<_i70.AddTransactionCubit>(() => _i70.AddTransactionCubit(
          gh<_i374.GetCategoriesUseCase>(),
          gh<_i333.CreateTransaction>(),
        ));
    gh.factory<_i260.AnalyticsBloc>(() => _i260.AnalyticsBloc(
          gh<_i86.GetAnalyticsData>(),
          gh<_i905.TransactionBloc>(),
        ));
    gh.factory<_i274.CategoryBloc>(() => _i274.CategoryBloc(
          getCategories: gh<_i931.GetCategoriesUseCase>(),
          getCategoryStats: gh<_i931.GetCategoryStatsUseCase>(),
          createCategory: gh<_i931.CreateCategoryUseCase>(),
          updateCategory: gh<_i931.UpdateCategoryUseCase>(),
          deleteCategory: gh<_i931.DeleteCategoryUseCase>(),
          searchCategories: gh<_i931.SearchCategoriesUseCase>(),
        ));
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

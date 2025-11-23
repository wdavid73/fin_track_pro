// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../core/database/hive_service.dart' as _i82;
import '../features/categories/data/datasources/category_local_datasource.dart'
    as _i409;
import '../features/categories/data/repositories/category_repository_impl.dart'
    as _i346;
import '../features/categories/domain/repositories/category_repository.dart'
    as _i745;
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
import '../features/transactions/domain/usecases/get_transactions.dart'
    as _i1058;
import '../features/transactions/domain/usecases/update_transaction.dart'
    as _i974;
import '../features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart'
    as _i1071;
import 'register_module.dart' as _i291;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.singleton<_i82.HiveService>(() => _i82.HiveService());
    gh.lazySingleton<_i361.Dio>(() => registerModule.dio);
    gh.factory<_i730.TransactionLocalDataSource>(
      () => _i730.TransactionLocalDataSource(gh<_i82.HiveService>()),
    );
    gh.factory<_i409.CategoryLocalDataSource>(
      () => _i409.CategoryLocalDataSource(gh<_i82.HiveService>()),
    );
    gh.lazySingleton<_i443.TransactionRepository>(
      () => _i667.TransactionRepositoryImpl(
        gh<_i730.TransactionLocalDataSource>(),
      ),
    );
    gh.factory<_i1058.GetTransactions>(
      () => _i1058.GetTransactions(gh<_i443.TransactionRepository>()),
    );
    gh.factory<_i333.CreateTransaction>(
      () => _i333.CreateTransaction(gh<_i443.TransactionRepository>()),
    );
    gh.factory<_i974.UpdateTransaction>(
      () => _i974.UpdateTransaction(gh<_i443.TransactionRepository>()),
    );
    gh.factory<_i424.DeleteTransaction>(
      () => _i424.DeleteTransaction(gh<_i443.TransactionRepository>()),
    );
    gh.factory<_i1071.TransactionBloc>(
      () => _i1071.TransactionBloc(
        gh<_i1058.GetTransactions>(),
        gh<_i333.CreateTransaction>(),
        gh<_i974.UpdateTransaction>(),
        gh<_i424.DeleteTransaction>(),
      ),
    );
    gh.lazySingleton<_i745.CategoryRepository>(
      () => _i346.CategoryRepositoryImpl(gh<_i409.CategoryLocalDataSource>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i291.RegisterModule {}

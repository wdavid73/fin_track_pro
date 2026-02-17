import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';

/// Module for registering external dependencies
/// These are third-party packages or objects that need special configuration
@module
abstract class RegisterModule {
  /// Dio instance for HTTP requests
  /// @lazySingleton means it will be created once when first requested
  @lazySingleton
  Dio get dio {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors if needed
    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }

  // Example: You can add more external dependencies here
  // @lazySingleton
  // SharedPreferences get prefs => SharedPreferences.getInstance();

  /// Hive boxes for dependency injection
  @Named('budgetBox')
  @lazySingleton
  Box<BudgetModel> get budgetBox => Hive.box<BudgetModel>('budgets');
}

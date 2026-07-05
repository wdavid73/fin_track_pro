import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/services/sync_service.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

import '../../features/budgets/mocks/budget_mocks.dart';
import '../../features/categories/mocks/category_mocks.dart';
import '../../features/transactions/mocks/transactions_mocks.dart';

class MockBudgetDatasource extends Mock implements BudgetDatasource {}

class MockHiveService extends Mock implements HiveService {}

class MockBox extends Mock implements Box {}

void main() {
  late MockTransactionRepository transactionRepository;
  late MockCategoryRepository categoryRepository;
  late MockBudgetRepository budgetRepository;
  late MockTransactionLocalDataSource transactionLocal;
  late MockTransactionRemoteDataSource transactionRemote;
  late MockCategoryLocalDataSource categoryLocal;
  late MockCategoryRemoteDataSource categoryRemote;
  late MockBudgetDatasource budgetLocal;
  late MockBudgetRemoteDataSource budgetRemote;
  late MockHiveService hiveService;
  late SyncService sut;

  const userId = 'user1';

  setUpAll(() {
    registerFallbackValue(
      TransactionModel(
        id: 'fallback',
        amount: 0,
        categoryId: 'fallback',
        type: 'expense',
        date: DateTime(2026),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      ),
    );
    registerFallbackValue(<TransactionModel>[]);
  });

  setUp(() {
    transactionRepository = MockTransactionRepository();
    categoryRepository = MockCategoryRepository();
    budgetRepository = MockBudgetRepository();
    transactionLocal = MockTransactionLocalDataSource();
    transactionRemote = MockTransactionRemoteDataSource();
    categoryLocal = MockCategoryLocalDataSource();
    categoryRemote = MockCategoryRemoteDataSource();
    budgetLocal = MockBudgetDatasource();
    budgetRemote = MockBudgetRemoteDataSource();
    hiveService = MockHiveService();

    sut = SyncService(
      transactionRepository,
      categoryRepository,
      budgetRepository,
      transactionLocal,
      transactionRemote,
      categoryLocal,
      categoryRemote,
      budgetLocal,
      budgetRemote,
      hiveService,
    );

    when(() => transactionRepository.setUserId(any())).thenReturn(null);
    when(() => categoryRepository.setUserId(any())).thenReturn(null);
    when(() => budgetRepository.setUserId(any())).thenReturn(null);

    when(() => transactionLocal.getTransactions())
        .thenAnswer((_) async => []);
    when(() => transactionRemote.getTransactions(any()))
        .thenAnswer((_) async => []);
    when(() => categoryLocal.getCategories()).thenAnswer((_) async => []);
    when(() => categoryRemote.getCategories(any()))
        .thenAnswer((_) async => []);
    when(() => budgetLocal.getBudgets()).thenAnswer((_) async => []);
    when(() => budgetRemote.getBudgets(any())).thenAnswer((_) async => []);
  });

  group('onLogin', () {
    test('sets userId on the 3 repositories', () async {
      await sut.onLogin(userId);

      verify(() => transactionRepository.setUserId(userId)).called(1);
      verify(() => categoryRepository.setUserId(userId)).called(1);
      verify(() => budgetRepository.setUserId(userId)).called(1);
    });

    test('uploads local-only transactions and saves remote-only ones locally', () async {
      final localOnly = TransactionModel(
        id: 'local-only',
        amount: 10,
        categoryId: 'cat',
        type: 'expense',
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final remoteOnly = TransactionModel(
        id: 'remote-only',
        amount: 20,
        categoryId: 'cat',
        type: 'income',
        date: DateTime(2026, 1, 1),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      when(() => transactionLocal.getTransactions())
          .thenAnswer((_) async => [localOnly]);
      when(() => transactionRemote.getTransactions(userId))
          .thenAnswer((_) async => [remoteOnly]);
      when(() => transactionLocal.updateTransaction(any()))
          .thenAnswer((_) async {});
      when(() => transactionRemote.uploadAll(any(), any()))
          .thenAnswer((_) async {});

      await sut.onLogin(userId);

      verify(() => transactionLocal.updateTransaction(remoteOnly)).called(1);
      verify(() => transactionRemote.uploadAll(userId, [localOnly])).called(1);
    });

    test('merges categories and budgets the same way', () async {
      final localCategory = CategoryModel(
        id: 'cat-local',
        name: 'Local',
        icon: '🏠',
        color: 0,
        type: 'expense',
        updatedAt: DateTime(2026, 1, 1),
      );
      final localBudget = BudgetModel(
        id: 'budget-local',
        categoryId: 'cat',
        amount: 100,
        updatedAt: DateTime(2026, 1, 1),
      );
      when(() => categoryLocal.getCategories())
          .thenAnswer((_) async => [localCategory]);
      when(() => budgetLocal.getBudgets())
          .thenAnswer((_) async => [localBudget]);
      when(() => categoryRemote.uploadAll(any(), any()))
          .thenAnswer((_) async {});
      when(() => budgetRemote.uploadAll(any(), any()))
          .thenAnswer((_) async {});

      await sut.onLogin(userId);

      verify(() => categoryRemote.uploadAll(userId, [localCategory])).called(1);
      verify(() => budgetRemote.uploadAll(userId, [localBudget])).called(1);
    });

    test('never throws when remote sync fails', () async {
      when(() => transactionRemote.getTransactions(userId))
          .thenAnswer((_) async => throw Exception('offline'));

      await expectLater(sut.onLogin(userId), completes);
    });
  });

  group('onLogout', () {
    test('clears userId on the 3 repositories', () async {
      await sut.onLogout();

      verify(() => transactionRepository.setUserId(null)).called(1);
      verify(() => categoryRepository.setUserId(null)).called(1);
      verify(() => budgetRepository.setUserId(null)).called(1);
    });

    test('does not touch Hive boxes when clearLocalData is false', () async {
      await sut.onLogout();

      verifyNever(() => hiveService.getBox(any()));
    });

    test('clears only transactions and budgets boxes when clearLocalData is true', () async {
      final transactionsBox = MockBox();
      final budgetsBox = MockBox();
      when(() => hiveService.getBox(HiveService.transactionsBox))
          .thenReturn(transactionsBox);
      when(() => hiveService.getBox(HiveService.budgetsBox))
          .thenReturn(budgetsBox);
      when(() => transactionsBox.clear()).thenAnswer((_) async => 0);
      when(() => budgetsBox.clear()).thenAnswer((_) async => 0);

      await sut.onLogout(clearLocalData: true);

      verify(() => transactionsBox.clear()).called(1);
      verify(() => budgetsBox.clear()).called(1);
      verifyNever(() => hiveService.getBox(HiveService.categoriesBox));
      verifyNever(() => hiveService.getBox(HiveService.settingsBox));
    });
  });
}

import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/get_budgets.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_budget_data.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockGetBudgets extends Mock implements GetBudgets {}

void main() {
  late GetBudgetData usecase;
  late MockTransactionRepository mockTransactionRepository;
  late MockCategoryRepository mockCategoryRepository;
  late MockGetBudgets mockGetBudgets;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockCategoryRepository = MockCategoryRepository();
    mockGetBudgets = MockGetBudgets();
    usecase = GetBudgetData(
      mockTransactionRepository,
      mockCategoryRepository,
      mockGetBudgets,
    );
  });

  final tCategory = Category(
    id: 'cat1',
    name: 'Food',
    icon: 'food',
    color: 1,
    type: 'expense',
    updatedAt: DateTime.now(),
  );

  final tTransaction = Transaction(
    id: '1',
    amount: 100.0,
    categoryId: 'cat1',
    type: 'expense',
    date: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    note: 'Lunch',
  );

  final tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
    updatedAt: DateTime.now(),
  );

  test('should return correct BudgetData', () async {
    // arrange
    when(
      () => mockTransactionRepository.getTransactions(),
    ).thenAnswer((_) async => [tTransaction]);
    when(
      () => mockCategoryRepository.getCategories(),
    ).thenAnswer((_) async => [tCategory]);
    when(() => mockGetBudgets()).thenAnswer((_) async => [tBudget]);

    // act
    final result = await usecase();

    // assert
    expect(result, isA<BudgetData>());
    expect(result.totalSpent, 100.0);
    expect(result.totalBudget, 500.0);
    expect(result.categories.length, 1);
    expect(result.categories.first.category, tCategory);
    expect(result.categories.first.spent, 100.0);
    expect(result.categories.first.budget, 500.0);
  });
}

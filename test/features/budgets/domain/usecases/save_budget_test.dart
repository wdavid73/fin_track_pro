import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/save_budget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late SaveBudget usecase;
  late MockBudgetRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      const Budget(
        id: 'fallback',
        categoryId: 'fallback',
        amount: 0,
        period: 'monthly',
      ),
    );
  });

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = SaveBudget(mockRepository);
  });

  const tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
  );

  test('should save budget to repository', () async {
    // arrange
    when(() => mockRepository.saveBudget(any())).thenAnswer((_) async => {});

    // act
    await usecase(tBudget);

    // assert
    verify(() => mockRepository.saveBudget(tBudget)).called(1);
  });
}

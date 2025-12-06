import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/get_budgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

void main() {
  late GetBudgets usecase;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = GetBudgets(mockRepository);
  });

  const tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
  );

  test('should get budgets from repository', () async {
    // arrange
    when(() => mockRepository.getBudgets()).thenAnswer((_) async => [tBudget]);

    // act
    final result = await usecase();

    // assert
    expect(result, equals([tBudget]));
    verify(() => mockRepository.getBudgets()).called(1);
  });
}

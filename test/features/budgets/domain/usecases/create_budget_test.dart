import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/create_budget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/budget_mocks.dart';

void main() {
  late CreateBudget usecase;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = CreateBudget(mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(const Budget(
      id: 'fallback',
      categoryId: 'fallback',
      amount: 0,
      period: 'monthly',
    ));
  });

  const tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
  );

  test('should create budget using repository', () async {
    // arrange
    when(() => mockRepository.saveBudget(any())).thenAnswer((_) async {});

    // act
    await usecase(tBudget);

    // assert
    verify(() => mockRepository.saveBudget(tBudget)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

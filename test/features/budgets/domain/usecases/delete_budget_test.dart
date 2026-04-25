import 'package:fin_track_pro/features/budgets/domain/usecases/delete_budget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/budget_mocks.dart';

void main() {
  late DeleteBudget usecase;
  late MockBudgetRepository mockRepository;

  setUp(() {
    mockRepository = MockBudgetRepository();
    usecase = DeleteBudget(mockRepository);
  });

  const tId = '1';

  test('should delete budget using repository', () async {
    // arrange
    when(() => mockRepository.deleteBudget(any())).thenAnswer((_) async {});

    // act
    await usecase(tId);

    // assert
    verify(() => mockRepository.deleteBudget(tId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}

import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/update_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late UpdateTransaction useCase;
  late MockTransactionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      Transaction(
        id: '',
        amount: 0,
        categoryId: '',
        type: '',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = UpdateTransaction(mockRepository);
  });

  group('UpdateTransaction', () {
    final tTransaction = Transaction(
      id: '1',
      amount: 200.0,
      categoryId: 'cat1',
      type: 'expense',
      note: 'Updated transaction',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    );

    test('should update transaction in repository', () async {
      // arrange
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(tTransaction);

      // assert
      verify(() => mockRepository.updateTransaction(tTransaction)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.updateTransaction(any()),
      ).thenThrow(Exception('Failed to update'));

      // act & assert
      expect(() => useCase(tTransaction), throwsException);
      verify(() => mockRepository.updateTransaction(tTransaction)).called(1);
    });
  });
}

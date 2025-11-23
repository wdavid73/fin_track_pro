import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_transactions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late GetTransactions useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = GetTransactions(mockRepository);
  });

  group('GetTransactions', () {
    final tTransactions = [
      Transaction(
        id: '1',
        amount: 100.0,
        categoryId: 'cat1',
        type: 'expense',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      ),
      Transaction(
        id: '2',
        amount: 200.0,
        categoryId: 'cat2',
        type: 'income',
        date: DateTime(2024, 1, 2),
        createdAt: DateTime(2024, 1, 2),
      ),
    ];

    test('should get transactions from repository', () async {
      // arrange
      when(
        () => mockRepository.getTransactions(),
      ).thenAnswer((_) async => tTransactions);

      // act
      final result = await useCase();

      // assert
      expect(result, tTransactions);
      verify(() => mockRepository.getTransactions()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no transactions exist', () async {
      // arrange
      when(() => mockRepository.getTransactions()).thenAnswer((_) async => []);

      // act
      final result = await useCase();

      // assert
      expect(result, isEmpty);
      verify(() => mockRepository.getTransactions()).called(1);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.getTransactions(),
      ).thenThrow(Exception('Database error'));

      // act & assert
      expect(() => useCase(), throwsException);
      verify(() => mockRepository.getTransactions()).called(1);
    });
  });
}

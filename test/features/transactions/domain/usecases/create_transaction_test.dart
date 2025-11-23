import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/create_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late CreateTransaction useCase;
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
    useCase = CreateTransaction(mockRepository);
  });

  group('CreateTransaction', () {
    final tTransaction = Transaction(
      id: '1',
      amount: 150.0,
      categoryId: 'cat1',
      type: 'expense',
      note: 'Test transaction',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    );

    test('should create transaction in repository', () async {
      // arrange
      when(
        () => mockRepository.createTransaction(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(tTransaction);

      // assert
      verify(() => mockRepository.createTransaction(tTransaction)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.createTransaction(any()),
      ).thenThrow(Exception('Failed to create'));

      // act & assert
      expect(() => useCase(tTransaction), throwsException);
      verify(() => mockRepository.createTransaction(tTransaction)).called(1);
    });
  });
}

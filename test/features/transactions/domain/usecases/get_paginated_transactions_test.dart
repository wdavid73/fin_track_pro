import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_paginated_transactions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late GetPaginatedTransactions usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetPaginatedTransactions(mockRepository);
  });

  final tTransaction = Transaction(
    id: '1',
    amount: 100.0,
    categoryId: 'cat1',
    type: 'expense',
    date: DateTime.now(),
    createdAt: DateTime.now(),
    note: 'Test',
  );

  test('should get paginated transactions from repository', () async {
    // arrange
    when(
      () => mockRepository.getPaginatedTransactions(
        limit: any(named: 'limit'),
        offset: any(named: 'offset'),
      ),
    ).thenAnswer((_) async => [tTransaction]);

    // act
    final result = await usecase(limit: 10, offset: 0);

    // assert
    expect(result, equals([tTransaction]));
    verify(
      () => mockRepository.getPaginatedTransactions(limit: 10, offset: 0),
    ).called(1);
  });
}

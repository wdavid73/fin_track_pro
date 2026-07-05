import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_total_balance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late GetTotalBalance usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetTotalBalance(mockRepository);
  });

  final tTransactions = [
    Transaction(
      id: '1',
      amount: 100.0,
      categoryId: 'cat1',
      type: 'income',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      note: 'Income',
    ),
    Transaction(
      id: '2',
      amount: 50.0,
      categoryId: 'cat2',
      type: 'expense',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      note: 'Expense',
    ),
  ];

  test('should calculate total balance (income - expense)', () async {
    // arrange
    when(
      () => mockRepository.getTransactions(),
    ).thenAnswer((_) async => tTransactions);

    // act
    final result = await usecase();

    // assert
    expect(result, 50.0); // 100 - 50
    verify(() => mockRepository.getTransactions()).called(1);
  });
}

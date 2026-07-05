import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/get_recent_transactions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  late GetRecentTransactions usecase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    usecase = GetRecentTransactions(mockRepository);
  });

  final tTransactions = List.generate(
    10,
    (index) => Transaction(
      id: '$index',
      amount: 100.0,
      categoryId: 'cat1',
      type: 'expense',
      date: DateTime(2024, 1, 1).add(Duration(days: index)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      note: 'Test $index',
    ),
  );

  test('should return recent transactions sorted by date', () async {
    // arrange
    when(
      () => mockRepository.getTransactions(),
    ).thenAnswer((_) async => tTransactions);

    // act
    final result = await usecase(limit: 5);

    // assert
    expect(result.length, 5);
    // Should be sorted descending, so newest first (index 9)
    expect(result.first.id, '9');
    verify(() => mockRepository.getTransactions()).called(1);
  });
}

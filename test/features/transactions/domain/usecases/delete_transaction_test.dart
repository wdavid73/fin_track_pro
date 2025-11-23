import 'package:fin_track_pro/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late DeleteTransaction useCase;
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
    useCase = DeleteTransaction(mockRepository);
  });

  group('DeleteTransaction', () {
    const tTransactionId = '1';

    test('should delete transaction from repository', () async {
      // arrange
      when(
        () => mockRepository.deleteTransaction(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(tTransactionId);

      // assert
      verify(() => mockRepository.deleteTransaction(tTransactionId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.deleteTransaction(any()),
      ).thenThrow(Exception('Failed to delete'));

      // act & assert
      expect(() => useCase(tTransactionId), throwsException);
      verify(() => mockRepository.deleteTransaction(tTransactionId)).called(1);
    });
  });
}

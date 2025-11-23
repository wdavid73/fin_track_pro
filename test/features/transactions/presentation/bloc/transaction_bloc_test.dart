import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late TransactionBloc bloc;
  late MockGetTransactions mockGetTransactions;
  late MockCreateTransaction mockCreateTransaction;
  late MockUpdateTransaction mockUpdateTransaction;
  late MockDeleteTransaction mockDeleteTransaction;

  setUp(() {
    mockGetTransactions = MockGetTransactions();
    mockCreateTransaction = MockCreateTransaction();
    mockUpdateTransaction = MockUpdateTransaction();
    mockDeleteTransaction = MockDeleteTransaction();

    bloc = TransactionBloc(
      mockGetTransactions,
      mockCreateTransaction,
      mockUpdateTransaction,
      mockDeleteTransaction,
    );
  });

  tearDown(() {
    bloc.close();
  });

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

  group('TransactionBloc', () {
    test('initial state should be TransactionInitial', () {
      expect(bloc.state, const TransactionInitial());
    });

    group('LoadTransactions', () {
      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Loaded] when LoadTransactions succeeds',
        build: () {
          when(
            () => mockGetTransactions(),
          ).thenAnswer((_) async => tTransactions);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [
          const TransactionLoading(),
          TransactionLoaded(tTransactions),
        ],
        verify: (_) {
          verify(() => mockGetTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Error] when LoadTransactions fails',
        build: () {
          when(
            () => mockGetTransactions(),
          ).thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [
          const TransactionLoading(),
          const TransactionError(
            'Failed to load transactions: Exception: Database error',
          ),
        ],
        verify: (_) {
          verify(() => mockGetTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Loaded] with empty list when no transactions',
        build: () {
          when(() => mockGetTransactions()).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [const TransactionLoading(), const TransactionLoaded([])],
      );
    });

    group('CreateTransactionEvent', () {
      final tTransaction = Transaction(
        id: '3',
        amount: 150.0,
        categoryId: 'cat1',
        type: 'expense',
        date: DateTime(2024, 1, 3),
        createdAt: DateTime(2024, 1, 3),
      );

      setUpAll(() {
        registerFallbackValue(tTransaction);
      });

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Loaded, Success] when CreateTransaction succeeds',
        build: () {
          when(() => mockCreateTransaction(any())).thenAnswer((_) async => {});
          when(
            () => mockGetTransactions(),
          ).thenAnswer((_) async => [...tTransactions, tTransaction]);
          return bloc;
        },
        act: (bloc) => bloc.add(CreateTransactionEvent(tTransaction)),
        expect: () => [
          const TransactionLoading(),
          TransactionLoaded([...tTransactions, tTransaction]),
          const TransactionOperationSuccess('Transaction created successfully'),
        ],
        verify: (_) {
          verify(() => mockCreateTransaction(tTransaction)).called(1);
          verify(() => mockGetTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Error] when CreateTransaction fails',
        build: () {
          when(
            () => mockCreateTransaction(any()),
          ).thenThrow(Exception('Failed to create'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateTransactionEvent(tTransaction)),
        expect: () => [
          const TransactionLoading(),
          const TransactionError(
            'Failed to create transaction: Exception: Failed to create',
          ),
        ],
      );
    });

    group('UpdateTransactionEvent', () {
      final tUpdatedTransaction = Transaction(
        id: '1',
        amount: 250.0,
        categoryId: 'cat1',
        type: 'expense',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      setUpAll(() {
        registerFallbackValue(tUpdatedTransaction);
      });

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Loaded, Success] when UpdateTransaction succeeds',
        build: () {
          when(() => mockUpdateTransaction(any())).thenAnswer((_) async => {});
          when(
            () => mockGetTransactions(),
          ).thenAnswer((_) async => [tUpdatedTransaction, tTransactions[1]]);
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateTransactionEvent(tUpdatedTransaction)),
        expect: () => [
          const TransactionLoading(),
          TransactionLoaded([tUpdatedTransaction, tTransactions[1]]),
          const TransactionOperationSuccess('Transaction updated successfully'),
        ],
        verify: (_) {
          verify(() => mockUpdateTransaction(tUpdatedTransaction)).called(1);
          verify(() => mockGetTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Error] when UpdateTransaction fails',
        build: () {
          when(
            () => mockUpdateTransaction(any()),
          ).thenThrow(Exception('Failed to update'));
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateTransactionEvent(tUpdatedTransaction)),
        expect: () => [
          const TransactionLoading(),
          const TransactionError(
            'Failed to update transaction: Exception: Failed to update',
          ),
        ],
      );
    });

    group('DeleteTransactionEvent', () {
      const tId = '1';

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Loaded, Success] when DeleteTransaction succeeds',
        build: () {
          when(() => mockDeleteTransaction(any())).thenAnswer((_) async => {});
          when(
            () => mockGetTransactions(),
          ).thenAnswer((_) async => [tTransactions[1]]);
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteTransactionEvent(tId)),
        expect: () => [
          const TransactionLoading(),
          TransactionLoaded([tTransactions[1]]),
          const TransactionOperationSuccess('Transaction deleted successfully'),
        ],
        verify: (_) {
          verify(() => mockDeleteTransaction(tId)).called(1);
          verify(() => mockGetTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Error] when DeleteTransaction fails',
        build: () {
          when(
            () => mockDeleteTransaction(any()),
          ).thenThrow(Exception('Failed to delete'));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteTransactionEvent(tId)),
        expect: () => [
          const TransactionLoading(),
          const TransactionError(
            'Failed to delete transaction: Exception: Failed to delete',
          ),
        ],
      );
    });
  });
}

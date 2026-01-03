import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late TransactionBloc bloc;
  late MockGetTransactions mockGetTransactions;
  late MockGetPaginatedTransactions mockGetPaginatedTransactions;
  late MockCreateTransaction mockCreateTransaction;
  late MockUpdateTransaction mockUpdateTransaction;
  late MockDeleteTransaction mockDeleteTransaction;

  setUp(() {
    mockGetTransactions = MockGetTransactions();
    mockGetPaginatedTransactions = MockGetPaginatedTransactions();
    mockCreateTransaction = MockCreateTransaction();
    mockUpdateTransaction = MockUpdateTransaction();
    mockDeleteTransaction = MockDeleteTransaction();

    bloc = TransactionBloc(
      mockGetTransactions,
      mockGetPaginatedTransactions,
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
    test('initial state should have initial status', () {
      expect(bloc.state.status, TransactionStatus.initial);
      expect(bloc.state.transactions, const []);
      expect(bloc.state.hasMore, false);
      expect(bloc.state.currentOffset, 0);
    });

    group('LoadTransactions', () {
      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Success] when LoadTransactions succeeds',
        build: () {
          when(
            () => mockGetTransactions(),
          ).thenAnswer((_) async => tTransactions);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          TransactionState(
            status: TransactionStatus.success,
            transactions: tTransactions,
          ),
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
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.error,
            errorMessage:
                'Failed to load transactions: Exception: Database error',
          ),
        ],
        verify: (_) {
          verify(() => mockGetTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Success] with empty list when no transactions',
        build: () {
          when(() => mockGetTransactions()).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadTransactions()),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.success,
            transactions: [],
          ),
        ],
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
        'emits [Loading, Success, Loading, Success] when CreateTransaction succeeds',
        build: () {
          // Mock UseCase
          when(() => mockCreateTransaction(any())).thenAnswer((_) async => {});
          // Mock UseCase
          when(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).thenAnswer((_) async => [...tTransactions, tTransaction]);
          return bloc;
        },
        act: (bloc) => bloc.add(CreateTransactionEvent(tTransaction)),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.success,
            successMessage: 'Transaction created successfully',
          ),
          const TransactionState(
            status: TransactionStatus.loading,
            successMessage: 'Transaction created successfully',
          ),
          TransactionState(
            status: TransactionStatus.success,
            transactions: [...tTransactions, tTransaction],
            hasMore: false,
            currentOffset: 3,
            successMessage: 'Transaction created successfully',
            errorMessage: null,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateTransaction(tTransaction)).called(1);
          verify(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).called(1);
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
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.error,
            errorMessage:
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
        'emits [Loading, Success, Loading, Success] when UpdateTransaction succeeds',
        build: () {
          when(() => mockUpdateTransaction(any())).thenAnswer((_) async => {});
          when(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).thenAnswer((_) async => [tUpdatedTransaction, tTransactions[1]]);
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateTransactionEvent(tUpdatedTransaction)),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.success,
            successMessage: 'Transaction updated successfully',
          ),
          const TransactionState(
            status: TransactionStatus.loading,
            successMessage: 'Transaction updated successfully',
          ),
          TransactionState(
            status: TransactionStatus.success,
            transactions: [tUpdatedTransaction, tTransactions[1]],
            hasMore: false,
            currentOffset: 2,
            successMessage: 'Transaction updated successfully',
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateTransaction(tUpdatedTransaction)).called(1);
          verify(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).called(1);
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
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.error,
            errorMessage:
                'Failed to update transaction: Exception: Failed to update',
          ),
        ],
      );
    });

    group('DeleteTransactionEvent', () {
      const tId = '1';

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Success, Loading, Success] when DeleteTransaction succeeds',
        build: () {
          when(() => mockDeleteTransaction(any())).thenAnswer((_) async => {});
          when(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).thenAnswer((_) async => [tTransactions[1]]);
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteTransactionEvent(tId)),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.success,
            successMessage: 'Transaction deleted successfully',
          ),
          const TransactionState(
            status: TransactionStatus.loading,
            successMessage: 'Transaction deleted successfully',
          ),
          TransactionState(
            status: TransactionStatus.success,
            transactions: [tTransactions[1]],
            hasMore: false,
            currentOffset: 1,
            successMessage: 'Transaction deleted successfully',
          ),
        ],
        verify: (_) {
          verify(() => mockDeleteTransaction(tId)).called(1);
          verify(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).called(1);
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
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.error,
            errorMessage:
                'Failed to delete transaction: Exception: Failed to delete',
          ),
        ],
      );
    });

    group('LoadPaginatedTransactions', () {
      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Success] when LoadPaginatedTransactions succeeds',
        build: () {
          when(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).thenAnswer((_) async => tTransactions);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPaginatedTransactions()),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          TransactionState(
            status: TransactionStatus.success,
            transactions: tTransactions,
            hasMore: false, // 2 transactions < 15 limit
            currentOffset: 2,
          ),
        ],
        verify: (_) {
          verify(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Success] with hasMore=true when result equals limit',
        build: () {
          final fullPage = List.generate(
            15,
            (i) => Transaction(
              id: '$i',
              amount: 100.0,
              categoryId: 'cat1',
              type: 'expense',
              date: DateTime(2024, 1, i + 1),
              createdAt: DateTime(2024, 1, i + 1),
            ),
          );
          when(
            () => mockGetPaginatedTransactions(limit: 15, offset: 0),
          ).thenAnswer((_) async => fullPage);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPaginatedTransactions()),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          isA<TransactionState>()
              .having((s) => s.status, 'status', TransactionStatus.success)
              .having((s) => s.transactions.length, 'transactions length', 15)
              .having((s) => s.hasMore, 'hasMore', true)
              .having((s) => s.currentOffset, 'currentOffset', 15),
        ],
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [Loading, Error] when LoadPaginatedTransactions fails',
        build: () {
          when(
            () => mockGetPaginatedTransactions(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenThrow(Exception('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadPaginatedTransactions()),
        expect: () => [
          const TransactionState(status: TransactionStatus.loading),
          const TransactionState(
            status: TransactionStatus.error,
            errorMessage:
                'Failed to load transactions: Exception: Database error',
          ),
        ],
      );
    });

    group('LoadMoreTransactions', () {
      final initialTransactions = List.generate(
        15,
        (i) => Transaction(
          id: '$i',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          date: DateTime(2024, 1, i + 1),
          createdAt: DateTime(2024, 1, i + 1),
        ),
      );

      final moreTransactions = List.generate(
        10,
        (i) => Transaction(
          id: '${i + 15}',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          date: DateTime(2024, 1, i + 16),
          createdAt: DateTime(2024, 1, i + 16),
        ),
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits updated state with appended transactions',
        build: () {
          when(
            () => mockGetPaginatedTransactions(limit: 15, offset: 15),
          ).thenAnswer((_) async => moreTransactions);
          return bloc;
        },
        seed: () => TransactionState(
          status: TransactionStatus.success,
          transactions: initialTransactions,
          hasMore: true,
          currentOffset: 15,
        ),
        act: (bloc) => bloc.add(const LoadMoreTransactions()),
        expect: () => [
          isA<TransactionState>()
              .having((s) => s.status, 'status', TransactionStatus.success)
              .having((s) => s.transactions.length, 'transactions length', 25)
              .having((s) => s.hasMore, 'hasMore', false) // 10 < 15 limit
              .having((s) => s.currentOffset, 'currentOffset', 25),
        ],
        verify: (_) {
          verify(
            () => mockGetPaginatedTransactions(limit: 15, offset: 15),
          ).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'does not emit when hasMore is false',
        build: () => bloc,
        seed: () => TransactionState(
          status: TransactionStatus.success,
          transactions: initialTransactions,
          hasMore: false,
          currentOffset: 15,
        ),
        act: (bloc) => bloc.add(const LoadMoreTransactions()),
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockGetPaginatedTransactions(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          );
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'does not emit when hasMore is false in initial state',
        build: () => bloc,
        seed: () => const TransactionState(
          status: TransactionStatus.initial,
          hasMore: false,
        ),
        act: (bloc) => bloc.add(const LoadMoreTransactions()),
        expect: () => [],
        verify: (_) {
          verifyNever(
            () => mockGetPaginatedTransactions(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          );
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'keeps current state on error',
        build: () {
          when(
            () => mockGetPaginatedTransactions(
              limit: any(named: 'limit'),
              offset: any(named: 'offset'),
            ),
          ).thenThrow(Exception('Network error'));
          return bloc;
        },
        seed: () => TransactionState(
          status: TransactionStatus.success,
          transactions: initialTransactions,
          hasMore: true,
          currentOffset: 15,
        ),
        act: (bloc) => bloc.add(const LoadMoreTransactions()),
        expect: () => [],
      );
    });
  });
}

import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/update_transaction.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/edit_transaction_cubit/edit_transaction_cubit.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/edit_transaction_cubit/edit_transaction_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCategories extends Mock implements GetCategoriesUseCase {}

class MockUpdateTransaction extends Mock implements UpdateTransaction {}

void main() {
  late MockGetCategories mockGetCategories;
  late MockUpdateTransaction mockUpdateTransaction;

  final tCategory1 = Category(
    id: 'cat1',
    name: 'Food',
    icon: '🍔',
    color: 123,
    type: 'expense',
    updatedAt: DateTime(2024, 1, 1),
  );

  final tCategory2 = Category(
    id: 'cat2',
    name: 'Salary',
    icon: '💼',
    color: 456,
    type: 'income',
    updatedAt: DateTime(2024, 1, 1),
  );

  final tCategories = [tCategory1, tCategory2];
  final tDate = DateTime(2024, 1, 1);

  final tTransaction = Transaction(
    id: 'trans1',
    amount: 50.0,
    categoryId: 'cat1',
    type: 'expense',
    note: 'Test transaction',
    date: tDate,
    createdAt: tDate,
    updatedAt: tDate,
  );

  setUpAll(() {
    registerFallbackValue(
      Transaction(
        id: 'fallback',
        amount: 0,
        categoryId: 'fallback',
        type: 'expense',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockUpdateTransaction = MockUpdateTransaction();
    when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
  });

  group('EditTransactionCubit', () {
    group('initialization', () {
      test('should initialize with transaction data', () {
        final cubit = EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        );

        expect(cubit.state.transaction, tTransaction);
        expect(cubit.state.amount, tTransaction.amount);
        expect(cubit.state.selectedCategoryId, tTransaction.categoryId);
        expect(cubit.state.transactionType, tTransaction.type);
        expect(cubit.state.description, tTransaction.note);
        expect(cubit.state.selectedDate, tTransaction.date);
        expect(cubit.state.isFormValid, true);
      });

      blocTest<EditTransactionCubit, EditTransactionState>(
        'should emit categories when loadCategories succeeds',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          predicate<EditTransactionState>(
            (state) =>
                state.categories == tCategories &&
                state.isLoadingCategories == false &&
                state.errorMessage == null,
          ),
        ],
      );
    });

    group('updateTransactionType', () {
      blocTest<EditTransactionCubit, EditTransactionState>(
        'should update transaction type and clear category',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        seed: () => EditTransactionState.fromTransaction(
          tTransaction,
        ).copyWith(categories: tCategories, isLoadingCategories: false),
        act: (cubit) => cubit.updateTransactionType('income'),
        expect: () => [
          predicate<EditTransactionState>(
            (state) =>
                state.transactionType == 'income' &&
                state.selectedCategoryId == null,
          ),
        ],
      );
    });

    group('updateAmount', () {
      blocTest<EditTransactionCubit, EditTransactionState>(
        'should update amount and validate form',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        seed: () => EditTransactionState.fromTransaction(
          tTransaction,
        ).copyWith(categories: tCategories, isLoadingCategories: false),
        act: (cubit) => cubit.updateAmount(100.0),
        expect: () => [
          predicate<EditTransactionState>(
            (state) => state.amount == 100.0 && state.isFormValid == true,
          ),
        ],
      );

      blocTest<EditTransactionCubit, EditTransactionState>(
        'should invalidate form when amount is null',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        seed: () => EditTransactionState.fromTransaction(
          tTransaction,
        ).copyWith(categories: tCategories, isLoadingCategories: false),
        act: (cubit) => cubit.updateAmount(null),
        expect: () => [
          predicate<EditTransactionState>(
            (state) => state.amount == null && state.isFormValid == false,
          ),
        ],
      );
    });

    group('updateCategory', () {
      blocTest<EditTransactionCubit, EditTransactionState>(
        'should update category',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        seed: () => EditTransactionState.fromTransaction(
          tTransaction,
        ).copyWith(categories: tCategories, isLoadingCategories: false),
        act: (cubit) => cubit.updateCategory('cat2'),
        expect: () => [
          predicate<EditTransactionState>(
            (state) => state.selectedCategoryId == 'cat2',
          ),
        ],
      );
    });

    group('updateDescription', () {
      blocTest<EditTransactionCubit, EditTransactionState>(
        'should update description',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        seed: () => EditTransactionState.fromTransaction(
          tTransaction,
        ).copyWith(categories: tCategories, isLoadingCategories: false),
        act: (cubit) => cubit.updateDescription('Updated description'),
        expect: () => [
          predicate<EditTransactionState>(
            (state) => state.description == 'Updated description',
          ),
        ],
      );
    });

    group('updateDate', () {
      blocTest<EditTransactionCubit, EditTransactionState>(
        'should update date',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        seed: () => EditTransactionState.fromTransaction(
          tTransaction,
        ).copyWith(categories: tCategories, isLoadingCategories: false),
        act: (cubit) {
          final newDate = DateTime(2024, 2, 1);
          cubit.updateDate(newDate);
        },
        expect: () => [
          predicate<EditTransactionState>(
            (state) =>
                state.selectedDate.day == 1 && state.selectedDate.month == 2,
          ),
        ],
      );
    });

    group('saveTransaction', () {
      blocTest<EditTransactionCubit, EditTransactionState>(
        'should update transaction when form is valid',
        build: () => EditTransactionCubit(
          mockGetCategories,
          mockUpdateTransaction,
          tTransaction,
        ),
        setUp: () {
          when(() => mockUpdateTransaction(any())).thenAnswer((_) async {});
        },
        seed: () => EditTransactionState.fromTransaction(tTransaction).copyWith(
          categories: tCategories,
          isLoadingCategories: false,
          amount: 75.0,
          description: 'Updated note',
        ),
        act: (cubit) => cubit.saveTransaction(),
        expect: () => [
          predicate<EditTransactionState>(
            (state) => state.isSubmitting == true,
          ),
          predicate<EditTransactionState>(
            (state) =>
                state.isSubmitting == false && state.submitSuccess == true,
          ),
        ],
        verify: (_) {
          verify(() => mockUpdateTransaction(any())).called(1);
        },
      );
    });
  });
}

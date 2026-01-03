import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/create_transaction.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_cubit.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetCategories extends Mock implements GetCategoriesUseCase {}

class MockCreateTransaction extends Mock implements CreateTransaction {}

void main() {
  late MockGetCategories mockGetCategories;
  late MockCreateTransaction mockCreateTransaction;

  const tCategory1 = Category(
    id: 'cat1',
    name: 'Food',
    icon: '🍔',
    color: 123,
    type: 'expense',
  );

  const tCategory2 = Category(
    id: 'cat2',
    name: 'Salary',
    icon: '💼',
    color: 456,
    type: 'income',
  );

  final tCategories = [tCategory1, tCategory2];
  final tDate = DateTime(2024, 1, 1);

  setUpAll(() {
    registerFallbackValue(
      Transaction(
        id: 'fallback',
        amount: 0,
        categoryId: 'fallback',
        type: 'expense',
        date: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockCreateTransaction = MockCreateTransaction();
    when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
  });

  group('AddTransactionCubit', () {
    group('loadCategories', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should emit categories when loadCategories succeeds',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        wait: const Duration(milliseconds: 100),
        expect: () => [
          predicate<AddTransactionState>(
            (state) =>
                state.categories == tCategories &&
                state.isLoadingCategories == false &&
                state.errorMessage == null,
          ),
        ],
      );
    });

    group('updateTransactionType', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should update transaction type and clear category',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          selectedCategoryId: 'cat1',
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.updateTransactionType('income'),
        expect: () => [
          predicate<AddTransactionState>(
            (state) =>
                state.transactionType == 'income' &&
                state.selectedCategoryId == null,
          ),
        ],
      );
    });

    group('updateAmount', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should update amount and validate form',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          selectedCategoryId: 'cat1',
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.updateAmount(100.0),
        expect: () => [
          predicate<AddTransactionState>((state) => state.amount == 100.0),
          predicate<AddTransactionState>((state) => state.isFormValid == true),
        ],
      );

      blocTest<AddTransactionCubit, AddTransactionState>(
        'should invalidate form when amount is zero',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          selectedCategoryId: 'cat1',
          amount: 100.0,
          categories: tCategories,
          isLoadingCategories: false,
          isFormValid: true,
        ),
        act: (cubit) => cubit.updateAmount(0),
        expect: () => [
          predicate<AddTransactionState>((state) => state.amount == 0),
          predicate<AddTransactionState>((state) => !state.isFormValid),
        ],
      );

      blocTest<AddTransactionCubit, AddTransactionState>(
        'should invalidate form when amount is negative',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          selectedCategoryId: 'cat1',
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.updateAmount(-10),
        expect: () => [
          predicate<AddTransactionState>(
            (state) => state.amount == -10 && !state.isFormValid,
          ),
        ],
      );
    });

    group('updateCategory', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should update category and validate form',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          amount: 100.0,
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.updateCategory('cat1'),
        expect: () => [
          predicate<AddTransactionState>(
            (state) => state.selectedCategoryId == 'cat1',
          ),
          predicate<AddTransactionState>((state) => state.isFormValid == true),
        ],
      );

      blocTest<AddTransactionCubit, AddTransactionState>(
        'should clear category when null is passed',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          selectedCategoryId: 'cat1',
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.updateCategory(null),
        expect: () => [
          predicate<AddTransactionState>(
            (state) => state.selectedCategoryId == null && !state.isFormValid,
          ),
        ],
      );
    });

    group('updateDescription', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should update description',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.updateDescription('Test description'),
        expect: () => [
          predicate<AddTransactionState>(
            (state) => state.description == 'Test description',
          ),
        ],
      );
    });

    group('updateDate', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should update selected date',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) {
          final newDate = DateTime(2024, 1, 15);
          cubit.updateDate(newDate);
        },
        expect: () => [
          predicate<AddTransactionState>(
            (state) => state.selectedDate == DateTime(2024, 1, 15),
          ),
        ],
      );
    });

    group('saveTransaction', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should create transaction when form is valid',
        build: () {
          when(() => mockCreateTransaction(any())).thenAnswer((_) async => {});
          return AddTransactionCubit(mockGetCategories, mockCreateTransaction);
        },
        seed: () => AddTransactionState(
          selectedDate: tDate,
          amount: 100.0,
          selectedCategoryId: 'cat1',
          categories: tCategories,
          isLoadingCategories: false,
          isFormValid: true,
        ),
        act: (cubit) => cubit.saveTransaction(),
        expect: () => [
          predicate<AddTransactionState>(
            (state) => state.isSubmitting && state.errorMessage == null,
          ),
          predicate<AddTransactionState>(
            (state) => !state.isSubmitting && state.submitSuccess,
          ),
        ],
        verify: (_) {
          verify(() => mockCreateTransaction(any())).called(1);
        },
      );

      blocTest<AddTransactionCubit, AddTransactionState>(
        'should create transaction with description when provided',
        build: () {
          when(() => mockCreateTransaction(any())).thenAnswer((_) async => {});
          return AddTransactionCubit(mockGetCategories, mockCreateTransaction);
        },
        seed: () => AddTransactionState(
          selectedDate: tDate,
          amount: 100.0,
          selectedCategoryId: 'cat1',
          description: 'Test note',
          categories: tCategories,
          isLoadingCategories: false,
          isFormValid: true,
        ),
        act: (cubit) => cubit.saveTransaction(),
        verify: (_) {
          final captured =
              verify(() => mockCreateTransaction(captureAny())).captured.single
                  as Transaction;
          expect(captured.note, 'Test note');
          expect(captured.amount, 100.0);
          expect(captured.categoryId, 'cat1');
        },
      );

      blocTest<AddTransactionCubit, AddTransactionState>(
        'should create transaction with null note when description is empty',
        build: () {
          when(() => mockCreateTransaction(any())).thenAnswer((_) async => {});
          return AddTransactionCubit(mockGetCategories, mockCreateTransaction);
        },
        seed: () => AddTransactionState(
          selectedDate: tDate,
          amount: 100.0,
          selectedCategoryId: 'cat1',
          description: '',
          categories: tCategories,
          isLoadingCategories: false,
          isFormValid: true,
        ),
        act: (cubit) => cubit.saveTransaction(),
        verify: (_) {
          final captured =
              verify(() => mockCreateTransaction(captureAny())).captured.single
                  as Transaction;
          expect(captured.note, null);
        },
      );
    });

    group('resetForm', () {
      blocTest<AddTransactionCubit, AddTransactionState>(
        'should reset form to initial state but keep categories',
        build: () =>
            AddTransactionCubit(mockGetCategories, mockCreateTransaction),
        seed: () => AddTransactionState(
          selectedDate: tDate,
          amount: 100.0,
          selectedCategoryId: 'cat1',
          description: 'Test',
          transactionType: 'income',
          categories: tCategories,
          isLoadingCategories: false,
        ),
        act: (cubit) => cubit.resetForm(),
        expect: () => [
          predicate<AddTransactionState>(
            (state) =>
                state.amount == null &&
                state.selectedCategoryId == null &&
                state.description == '' &&
                state.transactionType == 'expense' &&
                state.categories == tCategories &&
                !state.isLoadingCategories,
          ),
        ],
      );
    });
  });
}

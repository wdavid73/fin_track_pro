import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/presentation/bloc/budget_bloc/budget_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/budget_mocks.dart';

void main() {
  late BudgetBloc bloc;
  late MockGetBudgets mockGetBudgets;
  late MockCreateBudget mockCreateBudget;
  late MockUpdateBudget mockUpdateBudget;
  late MockDeleteBudget mockDeleteBudget;

  setUp(() {
    mockGetBudgets = MockGetBudgets();
    mockCreateBudget = MockCreateBudget();
    mockUpdateBudget = MockUpdateBudget();
    mockDeleteBudget = MockDeleteBudget();

    bloc = BudgetBloc(
      mockGetBudgets,
      mockCreateBudget,
      mockUpdateBudget,
      mockDeleteBudget,
    );
  });

  final tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
    updatedAt: DateTime.now(),
  );

  final tBudgetList = [tBudget];

  setUpAll(() {
    registerFallbackValue(Budget(
      id: 'fallback_id',
      categoryId: 'fallback_cat',
      amount: 0.0,
      updatedAt: DateTime.now(),
    ));
  });

  test('initial state should be BudgetInitial', () {
    expect(bloc.state, const BudgetInitial());
  });

  group('LoadBudgets', () {
    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetLoading, BudgetLoaded] when successful',
      build: () {
        when(() => mockGetBudgets()).thenAnswer((_) async => tBudgetList);
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadBudgets()),
      expect: () => [
        const BudgetLoading(),
        BudgetLoaded(tBudgetList),
      ],
      verify: (_) {
        verify(() => mockGetBudgets()).called(1);
      },
    );

    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetLoading, BudgetError] when unsuccessful',
      build: () {
        when(() => mockGetBudgets()).thenThrow(Exception('Error loading'));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadBudgets()),
      expect: () => [
        const BudgetLoading(),
        const BudgetError('Exception: Error loading'),
      ],
    );
  });

  group('CreateBudgetEvent', () {
    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetActionSuccess] and fetch new list',
      build: () {
        when(() => mockCreateBudget(any())).thenAnswer((_) async {});
        when(() => mockGetBudgets()).thenAnswer((_) async => tBudgetList);
        return bloc;
      },
      act: (bloc) => bloc.add(CreateBudgetEvent(tBudget)),
      expect: () => [
        BudgetActionSuccess(tBudgetList),
      ],
      verify: (_) {
        verify(() => mockCreateBudget(tBudget)).called(1);
        verify(() => mockGetBudgets()).called(1);
      },
    );

    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetError] if creation fails',
      build: () {
        when(() => mockCreateBudget(any())).thenThrow(Exception('Error creating'));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateBudgetEvent(tBudget)),
      expect: () => [
        const BudgetError('Exception: Error creating'),
      ],
    );
  });

  group('UpdateBudgetEvent', () {
    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetActionSuccess] and fetch new list',
      build: () {
        when(() => mockUpdateBudget(any())).thenAnswer((_) async {});
        when(() => mockGetBudgets()).thenAnswer((_) async => tBudgetList);
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateBudgetEvent(tBudget)),
      expect: () => [
        BudgetActionSuccess(tBudgetList),
      ],
      verify: (_) {
        verify(() => mockUpdateBudget(tBudget)).called(1);
        verify(() => mockGetBudgets()).called(1);
      },
    );

    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetError] if update fails',
      build: () {
        when(() => mockUpdateBudget(any())).thenThrow(Exception('Error updating'));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateBudgetEvent(tBudget)),
      expect: () => [
        const BudgetError('Exception: Error updating'),
      ],
    );
  });

  group('DeleteBudgetEvent', () {
    const tId = '1';

    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetActionSuccess] and fetch new list',
      build: () {
        when(() => mockDeleteBudget(any())).thenAnswer((_) async {});
        // After deleting, the list might be empty, but let's just return empty list
        when(() => mockGetBudgets()).thenAnswer((_) async => []);
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteBudgetEvent(tId)),
      expect: () => [
        const BudgetActionSuccess([]),
      ],
      verify: (_) {
        verify(() => mockDeleteBudget(tId)).called(1);
        verify(() => mockGetBudgets()).called(1);
      },
    );

    blocTest<BudgetBloc, BudgetState>(
      'should emit [BudgetError] if deletion fails',
      build: () {
        when(() => mockDeleteBudget(any())).thenThrow(Exception('Error deleting'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteBudgetEvent(tId)),
      expect: () => [
        const BudgetError('Exception: Error deleting'),
      ],
    );
  });
}

import 'package:fin_track_pro/features/budgets/data/datasources/budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:fin_track_pro/features/budgets/data/repositories/budget_repository_impl.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/budget_mocks.dart';

class MockBudgetDatasource extends Mock implements BudgetDatasource {}

void main() {
  late BudgetRepositoryImpl repository;
  late MockBudgetDatasource mockDatasource;
  late MockBudgetRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(
      BudgetModel(
        id: 'fallback',
        categoryId: 'fallback',
        amount: 0,
        period: 'monthly',
        updatedAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockDatasource = MockBudgetDatasource();
    mockRemoteDataSource = MockBudgetRemoteDataSource();
    repository = BudgetRepositoryImpl(mockDatasource, mockRemoteDataSource);
  });

  final tUpdatedAt = DateTime(2026, 1, 1);

  final tBudgetModel = BudgetModel(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
    updatedAt: tUpdatedAt,
  );

  final tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
    updatedAt: tUpdatedAt,
  );

  group('BudgetRepositoryImpl', () {
    group('getBudgets', () {
      test('should return list of budgets from datasource', () async {
        // arrange
        when(
          () => mockDatasource.getBudgets(),
        ).thenAnswer((_) async => [tBudgetModel]);

        // act
        final result = await repository.getBudgets();

        // assert
        verify(() => mockDatasource.getBudgets()).called(1);
        expect(result, equals([tBudget]));
      });
    });

    group('getBudgetByCategoryId', () {
      test('should return budget when found', () async {
        // arrange
        when(
          () => mockDatasource.getBudgetByCategoryId('cat1'),
        ).thenAnswer((_) async => tBudgetModel);

        // act
        final result = await repository.getBudgetByCategoryId('cat1');

        // assert
        verify(() => mockDatasource.getBudgetByCategoryId('cat1')).called(1);
        expect(result, equals(tBudget));
      });

      test('should return null when datasource throws', () async {
        // arrange
        when(
          () => mockDatasource.getBudgetByCategoryId('cat1'),
        ).thenThrow(StateError('Budget not found'));

        // act
        final result = await repository.getBudgetByCategoryId('cat1');

        // assert
        verify(() => mockDatasource.getBudgetByCategoryId('cat1')).called(1);
        expect(result, isNull);
      });
    });

    group('saveBudget', () {
      test('should save budget to datasource', () async {
        // arrange
        when(
          () => mockDatasource.saveBudget(any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.saveBudget(tBudget);

        // assert
        verify(() => mockDatasource.saveBudget(any())).called(1);
      });
    });

    group('deleteBudget', () {
      test('should delete budget from datasource', () async {
        // arrange
        when(
          () => mockDatasource.deleteBudget(any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.deleteBudget('1');

        // assert
        verify(() => mockDatasource.deleteBudget('1')).called(1);
      });
    });

    group('setUserId / remote sync', () {
      test(
        'does not call remote data source when no user is set',
        () async {
          when(
            () => mockDatasource.saveBudget(any()),
          ).thenAnswer((_) async => {});

          await repository.saveBudget(tBudget);
          await Future<void>.delayed(Duration.zero);

          verifyNever(() => mockRemoteDataSource.saveBudget(any(), any()));
        },
      );

      test(
        'calls remote data source with the user id once it is set',
        () async {
          when(
            () => mockDatasource.saveBudget(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockRemoteDataSource.saveBudget(any(), any()),
          ).thenAnswer((_) async => {});

          repository.setUserId('user_123');
          await repository.saveBudget(tBudget);
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockRemoteDataSource.saveBudget('user_123', any()),
          ).called(1);
        },
      );

      test(
        'does not throw when the remote write fails (fire-and-forget)',
        () async {
          when(
            () => mockDatasource.saveBudget(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockRemoteDataSource.saveBudget(any(), any()),
          ).thenAnswer((_) async => throw Exception('network error'));

          repository.setUserId('user_123');

          await expectLater(repository.saveBudget(tBudget), completes);
        },
      );
    });
  });
}

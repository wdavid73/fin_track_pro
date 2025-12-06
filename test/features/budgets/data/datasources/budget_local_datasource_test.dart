import 'package:fin_track_pro/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetBox extends Mock implements Box<BudgetModel> {}

void main() {
  late BudgetLocalDatasource datasource;
  late MockBudgetBox mockBudgetBox;

  setUpAll(() {
    registerFallbackValue(
      const BudgetModel(
        id: 'fallback',
        categoryId: 'fallback',
        amount: 0,
        period: 'monthly',
      ),
    );
  });

  setUp(() {
    mockBudgetBox = MockBudgetBox();
    datasource = BudgetLocalDatasource(mockBudgetBox);
  });

  const tBudgetModel = BudgetModel(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
  );

  group('BudgetLocalDatasource', () {
    group('getBudgets', () {
      test('should return list of budgets from box', () async {
        // arrange
        when(() => mockBudgetBox.values).thenReturn([tBudgetModel]);

        // act
        final result = await datasource.getBudgets();

        // assert
        verify(() => mockBudgetBox.values).called(1);
        expect(result, equals([tBudgetModel]));
      });
    });

    group('getBudgetByCategoryId', () {
      test('should return budget when found', () async {
        // arrange
        when(() => mockBudgetBox.values).thenReturn([tBudgetModel]);

        // act
        final result = await datasource.getBudgetByCategoryId('cat1');

        // assert
        expect(result, equals(tBudgetModel));
      });

      test('should throw StateError when not found', () async {
        // arrange
        when(() => mockBudgetBox.values).thenReturn([]);

        // act
        final call = datasource.getBudgetByCategoryId;

        // assert
        expect(() => call('cat1'), throwsA(isA<StateError>()));
      });
    });

    group('saveBudget', () {
      test('should save budget to box', () async {
        // arrange
        when(() => mockBudgetBox.put(any(), any())).thenAnswer((_) async => {});

        // act
        await datasource.saveBudget(tBudgetModel);

        // assert
        verify(
          () => mockBudgetBox.put(tBudgetModel.id, tBudgetModel),
        ).called(1);
      });
    });

    group('deleteBudget', () {
      test('should delete budget from box', () async {
        // arrange
        when(() => mockBudgetBox.delete(any())).thenAnswer((_) async => {});

        // act
        await datasource.deleteBudget('1');

        // assert
        verify(() => mockBudgetBox.delete('1')).called(1);
      });
    });
  });
}

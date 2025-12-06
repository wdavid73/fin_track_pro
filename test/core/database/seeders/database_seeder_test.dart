import 'package:fin_track_pro/core/database/seeders/budget_seeder.dart';
import 'package:fin_track_pro/core/database/seeders/category_seeder.dart';
import 'package:fin_track_pro/core/database/seeders/database_seeder.dart';
import 'package:fin_track_pro/core/database/seeders/transaction_seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategorySeeder extends Mock implements CategorySeeder {}

class MockBudgetSeeder extends Mock implements BudgetSeeder {}

class MockTransactionSeeder extends Mock implements TransactionSeeder {}

class MockLoggerService extends Mock implements LoggerService {}

void main() {
  late DatabaseSeeder seeder;
  late MockCategorySeeder mockCategorySeeder;
  late MockBudgetSeeder mockBudgetSeeder;
  late MockTransactionSeeder mockTransactionSeeder;
  late MockLoggerService mockLoggerService;

  setUp(() {
    mockCategorySeeder = MockCategorySeeder();
    mockBudgetSeeder = MockBudgetSeeder();
    mockTransactionSeeder = MockTransactionSeeder();
    mockLoggerService = MockLoggerService();

    seeder = DatabaseSeeder(
      mockCategorySeeder,
      mockBudgetSeeder,
      mockTransactionSeeder,
      mockLoggerService,
    );

    when(() => mockCategorySeeder.name).thenReturn('CategorySeeder');
    when(() => mockBudgetSeeder.name).thenReturn('BudgetSeeder');
    when(() => mockTransactionSeeder.name).thenReturn('TransactionSeeder');
  });

  group('DatabaseSeeder', () {
    test('seedAll should run all seeders in order', () async {
      // arrange
      when(() => mockCategorySeeder.seed()).thenAnswer((_) async => {});
      when(() => mockBudgetSeeder.seed()).thenAnswer((_) async => {});
      when(() => mockTransactionSeeder.seed()).thenAnswer((_) async => {});

      // act
      await seeder.seedAll();

      // assert
      verify(() => mockCategorySeeder.seed()).called(1);
      verify(() => mockBudgetSeeder.seed()).called(1);
      verify(() => mockTransactionSeeder.seed()).called(1);
    });

    test('seedAll should log errors but continue', () async {
      // arrange
      when(() => mockCategorySeeder.seed()).thenThrow(Exception('Error'));
      when(() => mockBudgetSeeder.seed()).thenAnswer((_) async => {});
      when(() => mockTransactionSeeder.seed()).thenAnswer((_) async => {});

      // act
      await seeder.seedAll();

      // assert
      verify(() => mockCategorySeeder.seed()).called(1);
      verify(() => mockBudgetSeeder.seed()).called(1);
      verify(() => mockTransactionSeeder.seed()).called(1);
      verify(
        () => mockLoggerService.error(
          any(),
          tag: any(named: 'tag'),
          error: any(named: 'error'),
          stackTrace: any(named: 'stackTrace'),
        ),
      ).called(1);
    });

    test('seedOne should run specific seeder', () async {
      // arrange
      when(() => mockCategorySeeder.seed()).thenAnswer((_) async => {});

      // act
      await seeder.seedOne('CategorySeeder');

      // assert
      verify(() => mockCategorySeeder.seed()).called(1);
      verifyNever(() => mockBudgetSeeder.seed());
    });

    test('seedOne should log warning if seeder not found', () async {
      // act
      await seeder.seedOne('UnknownSeeder');

      // assert
      verify(
        () => mockLoggerService.warning(any(), tag: any(named: 'tag')),
      ).called(1);
    });
  });
}

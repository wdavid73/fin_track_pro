# Testing Patterns

## Unit Testing Riverpod Providers

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';

@GenerateMocks([PaymentRepository])
import 'payment_view_model_test.mocks.dart';

void main() {
  late MockPaymentRepository mockRepository;
  late ProviderContainer container;

  setUp(() {
    mockRepository = MockPaymentRepository();
    container = ProviderContainer(
      overrides: [
        paymentRepositoryProvider.overrideWithValue(mockRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PaymentViewModel', () {
    test('should emit loaded state when getPayments succeeds', () async {
      // Arrange
      final payments = [
        PaymentEntity(
          id: '1',
          amount: 100.0,
          currency: 'COP',
          status: PaymentStatus.completed,
          createdAt: DateTime(2024, 1, 1),
        ),
      ];

      when(mockRepository.getPayments())
          .thenAnswer((_) async => Right(payments));

      // Act
      final viewModel = container.read(paymentViewModelProvider.notifier);
      await viewModel.loadPayments();

      // Assert
      final state = container.read(paymentViewModelProvider);
      expect(state.isLoaded, isTrue);
      expect(state.payments, equals(payments));
    });

    test('should emit error state when getPayments fails', () async {
      // Arrange
      when(mockRepository.getPayments())
          .thenAnswer((_) async => const Left(ServerFailure('Network error')));

      // Act
      final viewModel = container.read(paymentViewModelProvider.notifier);
      await viewModel.loadPayments();

      // Assert
      final state = container.read(paymentViewModelProvider);
      expect(state.isError, isTrue);
      expect(state.errorMessage, equals('Network error'));
    });
  });
}
```

## Testing Either Results

```dart
test('repository should return Right on success', () async {
  when(mockDatasource.fetchData())
      .thenAnswer((_) async => [PaymentModel.fromJson(mockJson)]);

  final result = await repository.getPayments();

  expect(result.isRight(), isTrue);
  result.fold(
    (failure) => fail('Expected Right but got Left: $failure'),
    (payments) {
      expect(payments, hasLength(1));
      expect(payments.first.id, equals('1'));
    },
  );
});

test('repository should return Left on DioException', () async {
  when(mockDatasource.fetchData()).thenThrow(
    DioException(
      requestOptions: RequestOptions(path: '/payments'),
      response: Response(
        requestOptions: RequestOptions(path: '/payments'),
        statusCode: 500,
      ),
    ),
  );

  final result = await repository.getPayments();

  expect(result.isLeft(), isTrue);
  result.fold(
    (failure) {
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, equals(500));
    },
    (_) => fail('Expected Left but got Right'),
  );
});
```

## Model fromJson Tests

```dart
group('PaymentModel.fromJson', () {
  test('should parse valid JSON correctly', () {
    final json = {
      'id': 1,              // int — tests toString() handling
      'amount': 150.50,
      'currency': 'COP',
      'status': 'completed',
      'created_at': '2024-01-15T10:30:00.000Z',
    };

    final model = PaymentModel.fromJson(json);

    expect(model.id, equals('1'));          // string after toString()
    expect(model.amount, equals(150.50));
    expect(model.currency, equals('COP'));
    expect(model.status, equals('completed'));
    expect(model.createdAt, isA<DateTime>());
  });

  test('should handle string IDs', () {
    final json = {
      'id': 'abc-123',     // string ID
      'amount': 50,         // int instead of double — tests num cast
      'currency': 'COP',
      'status': 'pending',
      'created_at': '2024-01-15T10:30:00.000Z',
    };

    final model = PaymentModel.fromJson(json);

    expect(model.id, equals('abc-123'));
    expect(model.amount, equals(50.0));     // should be double
  });

  test('should convert to entity correctly', () {
    final model = PaymentModel(
      id: '1',
      amount: 100.0,
      currency: 'COP',
      status: 'completed',
      createdAt: DateTime(2024, 1, 1),
    );

    final entity = model.toEntity();

    expect(entity, isA<PaymentEntity>());
    expect(entity.status, equals(PaymentStatus.completed));
  });
});
```

## Widget Testing with Riverpod

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('PaymentScreen shows loading then data', (tester) async {
    // Arrange — override provider with mock
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentViewModelProvider.overrideWith(
            (ref) => PaymentViewModel.withState(
              PaymentState.loaded(payments: mockPayments),
            ),
          ),
        ],
        child: const MaterialApp(
          home: PaymentScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Assert
    expect(find.text('\$100.00'), findsOneWidget);
    expect(find.byType(PaymentCard), findsNWidgets(mockPayments.length));
  });

  testWidgets('PaymentScreen shows error state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          paymentViewModelProvider.overrideWith(
            (ref) => PaymentViewModel.withState(
              PaymentState.error(message: 'Network error'),
            ),
          ),
        ],
        child: const MaterialApp(
          home: PaymentScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Network error'), findsOneWidget);
    expect(find.byType(RetryButton), findsOneWidget);
  });
}
```

## Golden Tests

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('InfoBanner matches golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: InfoBanner(
            title: 'Important Notice',
            message: 'Your payment was processed successfully.',
            type: InfoBannerType.success,
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(InfoBanner),
      matchesGoldenFile('goldens/info_banner_success.png'),
    );
  });
}
```

Update goldens with: `flutter test --update-goldens`

## Test File Organization

```
test/
├── features/
│   └── payment/
│       ├── data/
│       │   ├── models/
│       │   │   └── payment_model_test.dart
│       │   └── repositories/
│       │       └── payment_repository_impl_test.dart
│       ├── domain/
│       │   └── usecases/
│       │       └── get_payments_usecase_test.dart
│       └── presentation/
│           ├── providers/
│           │   └── payment_view_model_test.dart
│           ├── screens/
│           │   └── payment_screen_test.dart
│           └── widgets/
│               └── payment_card_golden_test.dart
integration_test/
└── payment_flow_test.dart
```

## Test Naming Convention

Use descriptive names that explain the scenario:
- `should return Right with payments when datasource succeeds`
- `should return Left with ServerFailure when API returns 500`
- `should emit loaded state after successful fetch`
- `should show retry button on error state`

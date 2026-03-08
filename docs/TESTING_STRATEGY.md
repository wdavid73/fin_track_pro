# 🧪 Testing Strategy

> **Goal:** Mantener ≥75% de cobertura filtrada con tests de alta calidad y sostenibles

## 📊 Current Status

- **Coverage:** **79.2%** (filtrada, excl. generados) — Gate CI: ≥60%
- **Test Files:** 83 files
- **Tests:** 453 tests (0 fallas)
- **Test Types:** Unit, Widget, BLoC

## 🎯 Testing Pyramid

```
        /\
       /  \     E2E (5%) - Critical user flows
      /----\
     /      \   Widget (25%) - UI components
    /--------\
   /          \ Unit (70%) - Business logic
  /____________\
```

### Distribution Guidelines

| Type | Coverage | Purpose | Tools |
|------|----------|---------|-------|
| **Unit Tests** | 70% | Business logic, models, utilities | `flutter_test` |
| **Widget Tests** | 25% | UI components, user interactions | `flutter_test`, `mocktail` |
| **Integration Tests** | 5% | Critical user flows | `patrol`, `integration_test` |

## 🧩 Test Patterns by Layer

### 1. Models & Entities

**Pattern:** Test serialization, validation, equality

```dart
group('TransactionModel', () {
  test('should create from JSON', () {
    final json = {'id': '1', 'amount': 100.0};
    final model = TransactionModel.fromJson(json);
    expect(model.id, '1');
    expect(model.amount, 100.0);
  });

  test('should convert to JSON', () {
    final model = TransactionModel(id: '1', amount: 100.0);
    final json = model.toJson();
    expect(json['id'], '1');
    expect(json['amount'], 100.0);
  });

  test('should support equality', () {
    final model1 = TransactionModel(id: '1', amount: 100.0);
    final model2 = TransactionModel(id: '1', amount: 100.0);
    expect(model1, equals(model2));
  });
});
```

**Coverage Target:** 100%

### 2. Extensions

**Pattern:** Test all methods with edge cases

```dart
group('CurrencyExtensions', () {
  test('should format as currency', () {
    expect(1234.56.toCurrency(), contains('1,234.56'));
  });

  test('should handle zero', () {
    expect(0.0.toCurrency(), contains('0'));
  });

  test('should handle negative values', () {
    expect((-100.0).toCurrency(), contains('100'));
  });
});
```

**Coverage Target:** 100%

### 3. Data Sources

**Pattern:** Mock dependencies, test CRUD operations

```dart
class MockHiveService extends Mock implements HiveService {}

group('TransactionLocalDataSource', () {
  late MockHiveService mockHive;
  late TransactionLocalDataSource dataSource;

  setUp(() {
    mockHive = MockHiveService();
    dataSource = TransactionLocalDataSource(mockHive);
  });

  test('should get all transactions', () async {
    when(() => mockHive.getAll<TransactionModel>())
        .thenAnswer((_) async => [TransactionModel(id: '1')]);

    final result = await dataSource.getAll();

    expect(result, hasLength(1));
    verify(() => mockHive.getAll<TransactionModel>()).called(1);
  });
});
```

**Coverage Target:** 100%

### 4. Repositories

**Pattern:** Test data flow, error handling

```dart
group('TransactionRepository', () {
  test('should return data on success', () async {
    when(() => mockDataSource.getAll())
        .thenAnswer((_) async => [transaction]);

    final result = await repository.getAll();

    expect(result.isRight(), true);
  });

  test('should return failure on error', () async {
    when(() => mockDataSource.getAll())
        .thenThrow(Exception('Error'));

    final result = await repository.getAll();

    expect(result.isLeft(), true);
  });
});
```

**Coverage Target:** 100%

### 5. Use Cases

**Pattern:** Test single responsibility

```dart
group('GetAllTransactions', () {
  test('should get transactions from repository', () async {
    when(() => mockRepository.getAll())
        .thenAnswer((_) async => Right([transaction]));

    final result = await useCase(NoParams());

    expect(result.isRight(), true);
    verify(() => mockRepository.getAll()).called(1);
  });
});
```

**Coverage Target:** 100%

### 6. BLoCs

**Pattern:** Use `bloc_test` for state transitions

```dart
blocTest<TransactionBloc, TransactionState>(
  'emits [Loading, Loaded] when GetAllTransactions succeeds',
  build: () {
    when(() => mockGetAll(any()))
        .thenAnswer((_) async => Right([transaction]));
    return bloc;
  },
  act: (bloc) => bloc.add(GetAllTransactionsEvent()),
  expect: () => [
    TransactionLoading(),
    TransactionLoaded([transaction]),
  ],
  verify: (_) {
    verify(() => mockGetAll(any())).called(1);
  },
);
```

**Coverage Target:** 100%

### 7. Widgets

**Pattern:** Test rendering, interactions, edge cases

```dart
group('TransactionCard', () {
  testWidgets('should display transaction info', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TransactionCard(transaction: transaction),
      ),
    );

    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('\$100.00'), findsOneWidget);
  });

  testWidgets('should call onTap when tapped', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: TransactionCard(
          transaction: transaction,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(TransactionCard));
    expect(tapped, true);
  });
});
```

**Coverage Target:** 80%+

### 8. Formatters & Utils

**Pattern:** Test all input variations

```dart
group('MoneyInputFormatter', () {
  test('should format as currency', () {
    final formatter = MoneyInputFormatter();
    final result = formatter.format('1234.56');
    expect(result, '\$1,234.56');
  });

  test('should handle empty input', () {
    final formatter = MoneyInputFormatter();
    final result = formatter.format('');
    expect(result, '\$0.00');
  });
});
```

**Coverage Target:** 100%

## 🛠 Tools & Libraries

### Core Testing

- **flutter_test** - Flutter testing framework
- **mocktail** - Modern mocking library (preferred over mockito)
- **bloc_test** - Testing BLoC states and events
- **integration_test** - End-to-end testing

### Additional Tools

- **golden_toolkit** - Visual regression testing (Phase 1)
- **patrol 4.2.0** - Native integration testing ✅ Configurado (ver abajo)
- **very_good_analysis** - Linting and static analysis

---

## 🤖 Integration Tests con Patrol

### ¿Qué es Patrol?

[Patrol](https://patrol.leancode.co/) es un framework de integration testing para Flutter que extiende `integration_test` con:
- API ergonómica: `$.tap()`, `$.scrollUntilVisible()`, `$.pumpAndSettle()`
- Soporte nativo de flavors, devices y dart-defines desde CLI
- `PatrolJUnitRunner` + Android Test Orchestrator para aislar cada test
- Futura automatización nativa (permisos, teclado del sistema) con `native_automation: true`

### Smoke Tests actuales

Ubicación: `integration_test/smoke_test.dart`

| # | Test | Descripción |
|---|------|-------------|
| 1 | `puede navegar entre los 4 tabs del BottomNavigationBar` | Tab navigation completo |
| 2 | `el FAB abre la pantalla de Add Transaction` | OpenContainer + AddTransactionPage |
| 3 | `puede abrir el panel de filtros desde All Transactions` | Scroll + filtros `BottomSheet` |

### Comando de ejecución

```bash
# Android (emulador o dispositivo real)
patrol test --target integration_test/smoke_test.dart --flavor dev --device emulator-5554

# Con selección de device interactiva
patrol test --target integration_test/smoke_test.dart --flavor dev
```

### Versiones Fijadas

> ⚠️ Las versiones de `patrol` (pubspec.yaml) y `patrol_cli` (global) **deben mantenerse sincronizadas**.
> Consultar la [tabla de compatibilidad oficial](https://patrol.leancode.co/documentation/compatibility-table) antes de actualizar.

| Paquete | Versión | Dónde |
|---------|---------|-------|
| `patrol` | `>=4.2.0 <4.3.0` | `pubspec.yaml` (dev_dependencies) |
| `patrol_cli` | `4.2.0` | Global: `dart pub global activate patrol_cli 4.2.0` |
| Kotlin | `2.1.21` | `android/settings.gradle.kts` |
| AndroidX Orchestrator | `1.5.1` | `android/app/build.gradle.kts` |

### Configuración Android (archivos clave)

A diferencia de `integration_test` puro, Patrol requiere configuración adicional en Android:

```
android/app/
├── build.gradle.kts                          # +PatrolJUnitRunner, +orchestrator
└── src/androidTest/
    ├── AndroidManifest.xml                   # Registra PatrolJUnitRunner
    └── java/.../MainActivityTest.java        # @Parameterized runner
```

**`MainActivityTest.java`** (patrón oficial):
```java
@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner instrumentation =
            (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    private final String dartTestName;
    public MainActivityTest(String dartTestName) { this.dartTestName = dartTestName; }

    @Test
    public void runDartTest() {
        PatrolJUnitRunner instrumentation =
            (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}
```

### `patrol.yaml` (configuración del proyecto)

```yaml
app_id_android: com.example.fin_track_pro.dev
app_id_ios: com.example.finTrackPro.dev
wait_for_connection_timeout: "120"
native_automation: false

targets:
  - integration_test/smoke_test.dart
```

> `patrol.yaml` se usa como fallback de configuración. El `--target` debe pasarse explícitamente al CLI para evitar un bug en patrol_cli con paths de `pubspec.yaml`.

### `pubspec.yaml` — sección `patrol`

Esta sección es **obligatoria** para que patrol_cli resuelva el directorio de tests correctamente:

```yaml
patrol:
  test_directory: integration_test
```

Sin esta sección, `patrol_cli` usa el directorio por defecto `patrol_test/` y genera imports con rutas absolutas inválidas.

---

## 📝 Best Practices

### 1. Naming Conventions

```dart
// ✅ Good
test('should format currency with two decimals', () {});

// ❌ Bad
test('test1', () {});
test('currency', () {});
```

### 2. AAA Pattern

```dart
test('should return transaction when found', () {
  // Arrange
  final transaction = TransactionModel(id: '1');
  when(() => mockRepo.getById('1')).thenAnswer((_) async => transaction);

  // Act
  final result = await useCase(GetByIdParams(id: '1'));

  // Assert
  expect(result.isRight(), true);
});
```

### 3. Mock Only External Dependencies

```dart
// ✅ Good - Mock data source
class MockTransactionDataSource extends Mock
    implements TransactionLocalDataSource {}

// ❌ Bad - Don't mock what you're testing
class MockTransactionRepository extends Mock
    implements TransactionRepository {}
// Then test TransactionRepository
```

### 4. Test Edge Cases

```dart
group('CurrencyFormatter', () {
  test('handles zero', () {});
  test('handles negative', () {});
  test('handles very large numbers', () {});
  test('handles null', () {});
  test('handles empty string', () {});
});
```

### 5. Use Test Fixtures

```dart
// test/fixtures/transaction_fixtures.dart
class TransactionFixtures {
  static TransactionModel income() => TransactionModel(
    id: '1',
    type: TransactionType.income,
    amount: 1000.0,
  );

  static TransactionModel expense() => TransactionModel(
    id: '2',
    type: TransactionType.expense,
    amount: 50.0,
  );
}

// Usage
test('should process income', () {
  final transaction = TransactionFixtures.income();
  // ...
});
```

### 6. Test Descriptions

Use `group` to organize related tests:

```dart
group('TransactionBloc', () {
  group('GetAllTransactionsEvent', () {
    blocTest('emits loaded state when successful', ...);
    blocTest('emits error state when fails', ...);
  });

  group('AddTransactionEvent', () {
    blocTest('adds transaction and refreshes list', ...);
  });
});
```

### 7. Async Testing

```dart
// ✅ Good - Use async/await
test('should get transactions', () async {
  final result = await repository.getAll();
  expect(result, isNotEmpty);
});

// ❌ Bad - Don't forget async
test('should get transactions', () {
  repository.getAll().then((result) {
    expect(result, isNotEmpty);
  });
});
```

### 8. Widget Testing Best Practices

```dart
testWidgets('should render correctly', (tester) async {
  // Use MaterialApp for context
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MyWidget(),
      ),
    ),
  );

  // Wait for animations
  await tester.pumpAndSettle();

  // Find elements
  expect(find.text('Hello'), findsOneWidget);

  // Interact
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
});
```

## 🎯 Coverage Goals by Module

| Module | Current | Target | Status |
|--------|---------|--------|--------|
| Entities / Models | ~100% | 100% | ✅ Complete |
| Use Cases | ~100% | 100% | ✅ Complete |
| BLoCs / Cubits | ~85% | ≥85% | ✅ On target |
| Repositories | ~89% | ≥80% | ✅ On target |
| Data Sources | ~100% | ≥90% | ✅ Complete |
| Seeders | ~81% | ≥75% | ✅ On target |
| Widgets / Pages | ~65% | ≥65% | ✅ On target |
| Utils / Core | ~80% | ≥80% | ✅ On target |

### ¿Por qué no llegamos al 80%?

Existen categorías de código que son legítimamente difíciles (o imposibles) de cubrir
con unit/widget tests sin sacrificar la arquitectura:

| Categoría | Ejemplo | Razón |
|---|---|---|
| `part of` files | `transaction_event.dart`, `home_event.dart` | No importables en aislamiento |
| DI containers | `injection_container.dart`, `register_module.dart` | Excluidos del reporte |
| Wrappers con `getIt` | `wrapper.dart` | Requieren entorno DI completo |
| UI compleja con efectos | `all_transactions_page.dart` | Animaciones + estado global |
| Ramas aleatorias | `transaction_seeder.dart` | 30% null chance no determinística |

**Conclusión:** El ~79% representa la cobertura real practicamente alcanzable para esta
arquitectura. Empujar hacia el 80%+ requeriría tests de integración o refactrorizar
código productivo para mejorar la testabilidad — trade-off que no vale para este MVP.

### Gates CI/CD

```
CI Gate (falla PR):  ≥ 60%   ← protege regresiones
Target real:         ≥ 75%   ← calidad sostenible
Alcanzado:           79.2%   ← estado actual ✅
```

## 🚀 Quick Wins

Low-effort, high-impact tests to improve coverage quickly:

1. **Extensions** (0% → 100% in ~1.5h)
   - currency_extensions_test.dart
   - context_extensions_test.dart
   - locale_extensions_test.dart

2. **Simple Utils** (~1h)
   - date_utils_test.dart
   - validation_utils_test.dart

3. **Formatters** (~1h)
   - Additional edge cases for existing tests

## 📊 Running Coverage

### Generate Coverage Report

```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html
```

### Coverage Script

```bash
# Use convenience script
./coverage.sh

# With filtering
./coverage.sh --exclude="*.g.dart,*.freezed.dart"
```

### CI/CD Coverage

Coverage is automatically generated and reported in:
- GitHub Actions workflow
- Codecov dashboard
- PR comments

## 🔍 Coverage Exclusions

Exclude generated files and UI-only code:

```dart
// coverage:ignore-file - Entire file
// coverage:ignore-start
void generatedCode() {}
// coverage:ignore-end

// coverage:ignore-line - Single line
void debugOnly() {} // coverage:ignore-line
```

## 📈 Continuous Improvement

### Progreso de cobertura

```
Partida (Phase 0):   ~43%  (319 tests)
Sesión Feb 21 S1:    72.3% (+29 pp, 386 tests)
Sesión Feb 22 S3:    79.2% (+6.9 pp, 453 tests)
Objetivo sostenible: ≥75%  ✅
```

### Monitoring

- Daily coverage checks in CI
- Weekly coverage review
- Block PRs with coverage decrease >1%

### Review Checklist

- [ ] All new code has tests
- [ ] Tests follow naming conventions
- [ ] Edge cases covered
- [ ] Mocks used appropriately
- [ ] AAA pattern followed
- [ ] Coverage meets minimum threshold

## 🎓 Learning Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Very Good Testing Practices](https://verygood.ventures/blog/guide-to-flutter-testing)
- [bloc_test Documentation](https://pub.dev/packages/bloc_test)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)

## 🤝 Contributing

When adding tests:

1. Follow the patterns in this guide
2. Maintain or improve coverage
3. Add tests for bug fixes
4. Update this guide with new patterns

---

**Last Updated:** 2026-03-08
**Coverage Target:** ≥75% (filtrada) — CI Gate: ≥60%
**Cobertura Actual:** 79.2% / 453 tests ✅
**Integration Tests:** 3 smoke tests (Patrol) ✅ Android
**Status:** Objetivo alcanzado 🎉


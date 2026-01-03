# Testing Guide

Este documento describe cómo ejecutar y analizar los tests de la aplicación.

## 📋 Ejecutar Tests

### Todos los tests
```bash
fvm flutter test
```

### Tests con coverage
```bash
./coverage.sh
```

Este script:
- Ejecuta todos los tests con coverage
- Excluye archivos autogenerados (.g.dart, .freezed.dart, etc.)
- Genera un reporte HTML
- Muestra un resumen en la terminal

### Ver el reporte HTML
```bash
open coverage/html/index.html
```

### Tests específicos

#### Un solo archivo
```bash
fvm flutter test test/features/transactions/data/models/transaction_model_test.dart
```

#### Una feature específica
```bash
fvm flutter test test/features/transactions/
```

#### Con watch mode (re-ejecuta al guardar)
```bash
fvm flutter test --watch
```

## 📊 Coverage Actual

### Resumen General
- **Coverage Total**: 65.0% (1394/2145 líneas)
- **Archivos cubiertos**: 79

### Coverage por Capa

#### ✅ 100% Coverage
- **Models**:
  - TransactionModel
  - CategoryModel
  - BudgetModel
- **Datasources**:
  - TransactionLocalDataSource
  - CategoryLocalDataSource
  - BudgetLocalDataSource
- **Domain (Use Cases)**:
  - Todos los use cases de transactions
  - Todos los use cases de budgets
- **BLoCs**:
  - TransactionBloc
  - HomeBloc
  - AnalyticsBloc

#### 🟡 Coverage Parcial
- **Presentation Pages**: ~65-80%
- **Widgets**: Variable
- **Core Utils**: 75-80%

#### 🔴 Sin Coverage (0%)
- **add_transaction_cubit.dart**: Pendiente de tests
- **Archivos autogenerados**: Excluidos del coverage (*.g.dart, *.freezed.dart)

## 🎯 Estructura de Tests

```
test/
├── core/
│   ├── database/
│   │   ├── hive_service_test.dart
│   │   └── seeders/
│   ├── utils/
│   │   ├── icon_helper_test.dart
│   │   └── logger_service_test.dart
│   └── widgets/
│       └── formatters/
│           └── money_input_formatter_test.dart
│
├── features/
│   ├── analytics/
│   │   ├── domain/usecases/
│   │   └── presentation/
│   │
│   ├── budgets/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── budget_local_datasource_test.dart
│   │   │   ├── models/
│   │   │   │   └── budget_model_test.dart
│   │   │   └── repositories/
│   │   │       └── budget_repository_impl_test.dart
│   │   └── domain/usecases/
│   │
│   ├── categories/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── category_local_datasource_test.dart
│   │   │   ├── models/
│   │   │   │   └── category_model_test.dart
│   │   │   └── repositories/
│   │   │       └── category_repository_impl_test.dart
│   │   └── domain/
│   │
│   ├── transactions/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   │   └── transaction_local_datasource_test.dart
│   │   │   ├── models/
│   │   │   │   └── transaction_model_test.dart
│   │   │   └── repositories/
│   │   │       └── transaction_repository_test.dart
│   │   ├── domain/usecases/
│   │   └── presentation/
│   │
│   └── home/
│       └── presentation/
```

## 🧪 Mejores Prácticas

### 1. Naming Conventions
- Los archivos de test deben terminar en `_test.dart`
- Ubicar tests en la misma estructura que el código fuente

### 2. Estructura de Tests
```dart
void main() {
  // Setup común
  late MyClass sut; // System Under Test
  late MockDependency mockDependency;

  setUp(() {
    mockDependency = MockDependency();
    sut = MyClass(mockDependency);
  });

  group('MyClass', () {
    group('methodName', () {
      test('should do something when condition', () {
        // arrange
        when(() => mockDependency.method()).thenReturn(value);

        // act
        final result = sut.methodName();

        // assert
        expect(result, expected);
        verify(() => mockDependency.method()).called(1);
      });
    });
  });
}
```

### 3. Mocking
- Usar `mocktail` para crear mocks
- Registrar fallback values con `registerFallbackValue()` cuando sea necesario
- Verificar las llamadas a métodos con `verify()`

### 4. Coverage Goals
- **Crítico (100%)**: Models, Datasources, Repositories, Use Cases
- **Importante (80%+)**: BLoCs, Presenters
- **Deseable (60%+)**: Widgets, Pages
- **Opcional**: Archivos autogenerados, configuración

## 🔧 Archivos Excluidos del Coverage

Los siguientes archivos son excluidos automáticamente del coverage:

- `**/*.g.dart` - Generados por build_runner
- `**/*.freezed.dart` - Generados por freezed
- `**/*.config.dart` - Archivos de configuración generados
- `**/*.gr.dart` - Generados por auto_route
- `**/injection_container.config.dart` - Inyección de dependencias generada

## 📈 Próximos Pasos

Para mejorar el coverage:

1. **add_transaction_cubit.dart** (53 líneas sin cobertura)
2. **Core widgets** (donut_chart, budget_category_item)
3. **Presentation pages** (mejorar coverage existente)

## 🚀 CI/CD

El coverage se puede integrar en CI/CD:

```yaml
# .github/workflows/ci.yml
- name: Run tests with coverage
  run: ./coverage.sh

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage/lcov.info
```

## 📚 Recursos

- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Mocktail Package](https://pub.dev/packages/mocktail)
- [Bloc Testing](https://bloclibrary.dev/#/testing)

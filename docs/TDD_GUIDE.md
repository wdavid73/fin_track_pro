# Guía de Test-Driven Development (TDD)

Esta guía describe el proceso para implementar nuevas features en FinTrackPro usando la metodología TDD.

## ¿Qué es TDD?

Test-Driven Development (TDD) es una metodología de desarrollo que consiste en escribir las pruebas **antes** de escribir el código de producción. El ciclo de TDD sigue tres pasos fundamentales conocidos como **Red-Green-Refactor**:

1. **Red (Rojo)**: Escribir un test que falle
2. **Green (Verde)**: Escribir el código mínimo necesario para que el test pase
3. **Refactor**: Mejorar el código manteniendo los tests pasando

## Beneficios de TDD

- ✅ Código más testeable y modular por diseño
- ✅ Mayor confianza al hacer cambios
- ✅ Documentación viva a través de los tests
- ✅ Menos bugs en producción
- ✅ Diseño más claro y enfocado
- ✅ Facilita el refactoring

## Estructura de Carpetas

```
lib/
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   ├── entities/
        │   ├── repositories/
        │   └── usecases/
        └── presentation/
            ├── bloc/
            ├── pages/
            └── widgets/

test/
└── features/
    └── [feature_name]/
        ├── data/
        │   ├── datasources/
        │   ├── models/
        │   └── repositories/
        ├── domain/
        │   └── usecases/
        ├── presentation/
        │   ├── bloc/
        │   ├── pages/
        │   └── widgets/
        └── mocks/
```

## Proceso TDD Paso a Paso

### Paso 1: Definir Requisitos del Feature

Antes de escribir cualquier código, define claramente:

- ✏️ ¿Qué funcionalidades necesitas?
- ✏️ ¿Cuáles son los casos de uso?
- ✏️ ¿Qué datos necesitas manejar?
- ✏️ ¿Cómo interactuará el usuario?

**Ejemplo: Feature de Categorías**
```
Requisitos:
- Listar todas las categorías
- Crear nueva categoría
- Editar categoría existente
- Eliminar categoría
- Buscar categorías por nombre
```

### Paso 2: Crear Mocks

Crea los mocks necesarios para tus tests en `test/features/[feature]/mocks/`.

```dart
// test/features/categories/mocks/category_mocks.dart
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}
class MockCategoryLocalDataSource extends Mock implements CategoryLocalDataSource {}
```

### Paso 3: Escribir Tests de Use Cases (Domain Layer)

Comienza por la capa de dominio, ya que es independiente de frameworks y detalles de implementación.

#### 3.1 Test de Use Case

```dart
// test/features/categories/domain/usecases/create_category_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  late CreateCategory useCase;
  late MockCategoryRepository mockRepository;

  setUpAll(() {
    // Registrar fallback values si es necesario
    registerFallbackValue(const Category(/*...*/));
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = CreateCategory(mockRepository);
  });

  group('CreateCategory', () {
    const tCategory = Category(
      id: '1',
      name: 'Groceries',
      icon: '🛒',
      color: 0xFF4CAF50,
      type: 'expense',
    );

    test('should create category in repository', () async {
      // arrange
      when(() => mockRepository.createCategory(any()))
          .thenAnswer((_) async => {});

      // act
      await useCase(tCategory);

      // assert
      verify(() => mockRepository.createCategory(tCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(() => mockRepository.createCategory(any()))
          .thenThrow(Exception('Failed to create'));

      // act & assert
      expect(() => useCase(tCategory), throwsException);
    });
  });
}
```

#### 3.2 Implementar Use Case

Después de escribir el test, implementa el use case mínimo para que pase:

```dart
// lib/features/categories/domain/usecases/create_category.dart
import 'package:injectable/injectable.dart';

@injectable
class CreateCategory {
  final CategoryRepository repository;

  CreateCategory(this.repository);

  Future<void> call(Category category) async {
    return await repository.createCategory(category);
  }
}
```

#### 3.3 Actualizar Repository Interface

```dart
// lib/features/categories/domain/repositories/category_repository.dart
abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> searchCategories(String query);
}
```

### Paso 4: Escribir Tests de Repository (Data Layer)

```dart
// test/features/categories/data/repositories/category_repository_impl_test.dart
void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockCategoryLocalDataSource();
    repository = CategoryRepositoryImpl(mockDataSource);
  });

  group('createCategory', () {
    const tCategoryModel = CategoryModel(/*...*/);

    test('should call datasource to create category', () async {
      // arrange
      when(() => mockDataSource.createCategory(any()))
          .thenAnswer((_) async => {});

      // act
      await repository.createCategory(tCategoryModel);

      // assert
      verify(() => mockDataSource.createCategory(tCategoryModel)).called(1);
    });
  });
}
```

### Paso 5: Implementar Repository

```dart
// lib/features/categories/data/repositories/category_repository_impl.dart
@Injectable(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<void> createCategory(Category category) async {
    final model = CategoryModel.fromEntity(category);
    await localDataSource.createCategory(model);
  }
}
```

### Paso 6: Escribir Tests de DataSource

```dart
// test/features/categories/data/datasources/category_local_datasource_test.dart
void main() {
  late CategoryLocalDataSource dataSource;
  late MockHiveService mockHiveService;
  late MockBox mockBox;

  setUp(() {
    mockHiveService = MockHiveService();
    mockBox = MockBox();
    dataSource = CategoryLocalDataSource(mockHiveService);

    when(() => mockHiveService.getBox(any())).thenReturn(mockBox);
  });

  group('createCategory', () {
    const tCategory = CategoryModel(/*...*/);

    test('should add category to Hive box', () async {
      // arrange
      when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

      // act
      await dataSource.createCategory(tCategory);

      // assert
      verify(() => mockBox.put(tCategory.id, tCategory)).called(1);
    });
  });
}
```

### Paso 7: Implementar DataSource

```dart
// lib/features/categories/data/datasources/category_local_datasource.dart
@injectable
class CategoryLocalDataSource implements CategoryDataSource {
  final HiveService _hiveService;

  CategoryLocalDataSource(this._hiveService);

  @override
  Future<void> createCategory(CategoryModel category) async {
    final box = _hiveService.getBox(HiveService.categoriesBox);
    await box.put(category.id, category);
  }
}
```

### Paso 8: Escribir Tests de Bloc/Cubit (Presentation Layer)

```dart
// test/features/categories/presentation/bloc/category_bloc_test.dart
void main() {
  late CategoryBloc bloc;
  late MockGetCategories mockGetCategories;
  late MockCreateCategory mockCreateCategory;
  late MockUpdateCategory mockUpdateCategory;
  late MockDeleteCategory mockDeleteCategory;
  late MockSearchCategories mockSearchCategories;

  setUp(() {
    mockGetCategories = MockGetCategories();
    mockCreateCategory = MockCreateCategory();
    mockUpdateCategory = MockUpdateCategory();
    mockDeleteCategory = MockDeleteCategory();
    mockSearchCategories = MockSearchCategories();

    bloc = CategoryBloc(
      getCategories: mockGetCategories,
      createCategory: mockCreateCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
      searchCategories: mockSearchCategories,
    );
  });

  group('LoadCategories', () {
    const tCategories = [Category(/*...*/)];

    blocTest<CategoryBloc, CategoryState>(
      'should emit [Loading, Loaded] when data is gotten successfully',
      build: () {
        when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        CategoryLoading(),
        CategoryLoaded(categories: tCategories),
      ],
      verify: (_) {
        verify(() => mockGetCategories()).called(1);
      },
    );

    blocTest<CategoryBloc, CategoryState>(
      'should emit [Loading, Error] when getting data fails',
      build: () {
        when(() => mockGetCategories()).thenThrow(Exception('Error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadCategories()),
      expect: () => [
        CategoryLoading(),
        CategoryError(message: 'Exception: Error'),
      ],
    );
  });
}
```

### Paso 9: Implementar Bloc/Cubit

```dart
// lib/features/categories/presentation/bloc/category_bloc.dart
@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategories getCategories;
  final CreateCategory createCategory;
  final UpdateCategory updateCategory;
  final DeleteCategory deleteCategory;
  final SearchCategories searchCategories;

  CategoryBloc({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.searchCategories,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SearchCategoriesEvent>(_onSearchCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await getCategories();
      emit(CategoryLoaded(categories: categories));
    } catch (e) {
      emit(CategoryError(message: e.toString()));
    }
  }
}
```

### Paso 10: Escribir Tests de Widgets

```dart
// test/features/categories/presentation/pages/categories_page_test.dart
void main() {
  late MockCategoryBloc mockBloc;

  setUp(() {
    mockBloc = MockCategoryBloc();
  });

  Widget makeTestableWidget() {
    return MaterialApp(
      home: BlocProvider<CategoryBloc>.value(
        value: mockBloc,
        child: CategoriesPage(),
      ),
    );
  }

  testWidgets('should show loading indicator when state is loading',
      (tester) async {
    // arrange
    when(() => mockBloc.state).thenReturn(CategoryLoading());
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(CategoryLoading()));

    // act
    await tester.pumpWidget(makeTestableWidget());

    // assert
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('should show list of categories when state is loaded',
      (tester) async {
    // arrange
    const tCategories = [
      Category(id: '1', name: 'Groceries', /*...*/),
      Category(id: '2', name: 'Transport', /*...*/),
    ];
    when(() => mockBloc.state).thenReturn(CategoryLoaded(categories: tCategories));
    when(() => mockBloc.stream).thenAnswer(
      (_) => Stream.value(CategoryLoaded(categories: tCategories)),
    );

    // act
    await tester.pumpWidget(makeTestableWidget());

    // assert
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Transport'), findsOneWidget);
  });
}
```

### Paso 11: Implementar Widgets

```dart
// lib/features/categories/presentation/pages/categories_page.dart
class CategoriesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (state is CategoryLoaded) {
            return ListView.builder(
              itemCount: state.categories.length,
              itemBuilder: (context, index) {
                final category = state.categories[index];
                return ListTile(
                  title: Text(category.name),
                  leading: Text(category.icon),
                );
              },
            );
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
```

## Orden de Implementación Recomendado

1. **Entities** (Domain) - Define las entidades del dominio
2. **Repository Interface** (Domain) - Define el contrato del repositorio
3. **Use Cases Tests** (Domain) - Tests de casos de uso
4. **Use Cases** (Domain) - Implementación de casos de uso
5. **Models Tests** (Data) - Tests de modelos
6. **Models** (Data) - Implementación de modelos
7. **DataSource Tests** (Data) - Tests de fuentes de datos
8. **DataSource** (Data) - Implementación de fuentes de datos
9. **Repository Tests** (Data) - Tests de repositorio
10. **Repository Implementation** (Data) - Implementación del repositorio
11. **Bloc/Cubit Tests** (Presentation) - Tests de lógica de presentación
12. **Bloc/Cubit** (Presentation) - Implementación de lógica
13. **Widget Tests** (Presentation) - Tests de UI
14. **Widgets** (Presentation) - Implementación de UI

## Patrón AAA en Tests

Todos los tests deben seguir el patrón **Arrange-Act-Assert**:

```dart
test('description', () async {
  // Arrange (Preparar)
  // - Configurar mocks
  // - Preparar datos de prueba
  // - Definir comportamiento esperado
  when(() => mock.method()).thenAnswer((_) async => result);

  // Act (Actuar)
  // - Ejecutar la función/método que se está probando
  final result = await useCase();

  // Assert (Verificar)
  // - Verificar que el resultado es el esperado
  // - Verificar que se llamaron los métodos correctos
  expect(result, expectedResult);
  verify(() => mock.method()).called(1);
});
```

## Comandos Útiles

### Ejecutar todos los tests
```bash
flutter test
```

### Ejecutar tests con cobertura
```bash
flutter test --coverage
```

### Ejecutar tests de un archivo específico
```bash
flutter test test/features/categories/domain/usecases/create_category_test.dart
```

### Ejecutar tests en watch mode
```bash
flutter test --watch
```

### Ver reporte de cobertura (después de generar coverage)
```bash
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Checklist para Implementar un Feature con TDD

- [ ] Definir requisitos claros del feature
- [ ] Crear estructura de carpetas en `lib/` y `test/`
- [ ] Crear archivo de mocks
- [ ] Escribir tests de entities (si aplica)
- [ ] Crear entities
- [ ] Escribir tests de use cases
- [ ] Crear repository interface
- [ ] Implementar use cases
- [ ] Escribir tests de models
- [ ] Implementar models
- [ ] Escribir tests de datasource
- [ ] Implementar datasource
- [ ] Escribir tests de repository implementation
- [ ] Implementar repository
- [ ] Configurar inyección de dependencias
- [ ] Escribir tests de bloc/cubit
- [ ] Implementar bloc/cubit
- [ ] Escribir tests de widgets
- [ ] Implementar widgets
- [ ] Ejecutar todos los tests y verificar que pasen
- [ ] Verificar cobertura de tests
- [ ] Refactorizar código si es necesario
- [ ] Documentar el feature

## Mejores Prácticas

### 1. Tests Independientes
Cada test debe ser independiente y no depender de otros tests.

### 2. Nombres Descriptivos
```dart
// ❌ Mal
test('test1', () {});

// ✅ Bien
test('should return list of categories when repository call succeeds', () {});
```

### 3. Un Concepto por Test
Cada test debe probar un solo concepto o comportamiento.

### 4. Mock Solo lo Necesario
No mockees todo, solo las dependencias externas.

### 5. Tests Rápidos
Los tests deben ejecutarse rápidamente. Evita delays innecesarios.

### 6. Coverage Objetivo
Busca al menos 80% de cobertura en código crítico.

### 7. Evita Lógica en Tests
Los tests deben ser simples y fáciles de leer.

## Ejemplo Completo: Feature de Categorías

Puedes ver un ejemplo completo del feature de categorías en:

- Tests de use cases: `test/features/categories/domain/usecases/`
- Tests de repository: `test/features/categories/data/repositories/`
- Tests de datasource: `test/features/categories/data/datasources/`
- Mocks: `test/features/categories/mocks/`

## Recursos Adicionales

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Mocktail Documentation](https://pub.dev/packages/mocktail)
- [Bloc Testing](https://pub.dev/packages/bloc_test)
- [Test-Driven Development (Kent Beck)](https://www.amazon.com/Test-Driven-Development-Kent-Beck/dp/0321146530)

---

**Última actualización**: 2024-12-06

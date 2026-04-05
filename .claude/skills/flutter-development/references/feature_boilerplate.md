# Feature Boilerplate Generator

When generating a new feature, create all files in this order. Replace `<feature>`
with the actual feature name in snake_case (e.g., `payment`, `raffle`, `profile`).

## Directory Structure

```
lib/features/<feature>/
├── data/
│   ├── datasources/
│   │   └── <feature>_remote_datasource.dart
│   ├── models/
│   │   └── <feature>_model.dart
│   └── repositories/
│       └── <feature>_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── <feature>_entity.dart
│   ├── repositories/
│   │   └── <feature>_repository.dart
│   └── usecases/
│       └── get_<feature>_usecase.dart
└── presentation/
    ├── providers/
    │   ├── <feature>_provider.dart
    │   └── <feature>_view_model.dart
    ├── screens/
    │   └── <feature>_screen.dart
    └── widgets/
```

## File Templates

### 1. Entity (`domain/entities/<feature>_entity.dart`)

```dart
class <Feature>Entity {
  final String id;
  // Add fields based on requirements

  const <Feature>Entity({
    required this.id,
  });

  <Feature>Entity copyWith({
    String? id,
  }) {
    return <Feature>Entity(
      id: id ?? this.id,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is <Feature>Entity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => '<Feature>Entity(id: $id)';
}
```

### 2. Repository Contract (`domain/repositories/<feature>_repository.dart`)

```dart
import 'package:dartz/dartz.dart';

abstract class <Feature>Repository {
  Future<Either<Failure, List<<Feature>Entity>>> getAll();
  Future<Either<Failure, <Feature>Entity>> getById(String id);
}
```

### 3. Use Case (`domain/usecases/get_<feature>_usecase.dart`)

```dart
import 'package:dartz/dartz.dart';

class Get<Feature>UseCase {
  final <Feature>Repository _repository;

  const Get<Feature>UseCase(this._repository);

  Future<Either<Failure, List<<Feature>Entity>>> call() {
    return _repository.getAll();
  }
}
```

### 4. Model (`data/models/<feature>_model.dart`)

```dart
class <Feature>Model {
  final String id;

  const <Feature>Model({
    required this.id,
  });

  factory <Feature>Model.fromJson(Map<String, dynamic> json) {
    return <Feature>Model(
      id: json['id'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }

  <Feature>Entity toEntity() {
    return <Feature>Entity(
      id: id,
    );
  }

  factory <Feature>Model.fromEntity(<Feature>Entity entity) {
    return <Feature>Model(
      id: entity.id,
    );
  }

  <Feature>Model copyWith({String? id}) {
    return <Feature>Model(id: id ?? this.id);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is <Feature>Model && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
```

### 5. Remote Datasource (`data/datasources/<feature>_remote_datasource.dart`)

```dart
import 'package:dio/dio.dart';

abstract class <Feature>RemoteDatasource {
  Future<List<<Feature>Model>> getAll();
  Future<<Feature>Model> getById(String id);
}

class <Feature>RemoteDatasourceImpl implements <Feature>RemoteDatasource {
  final Dio _dio;

  const <Feature>RemoteDatasourceImpl(this._dio);

  @override
  Future<List<<Feature>Model>> getAll() async {
    final response = await _dio.get('/<feature>s');
    final data = response.data as List;
    return data
        .map((json) => <Feature>Model.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<<Feature>Model> getById(String id) async {
    final response = await _dio.get('/<feature>s/$id');
    return <Feature>Model.fromJson(response.data as Map<String, dynamic>);
  }
}
```

### 6. Repository Impl (`data/repositories/<feature>_repository_impl.dart`)

```dart
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class <Feature>RepositoryImpl implements <Feature>Repository {
  final <Feature>RemoteDatasource _datasource;

  const <Feature>RepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<<Feature>Entity>>> getAll() async {
    try {
      final models = await _datasource.getAll();
      return Right(models.map((m) => m.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.statusMessage ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, <Feature>Entity>> getById(String id) async {
    try {
      final model = await _datasource.getById(id);
      return Right(model.toEntity());
    } on DioException catch (e) {
      return Left(ServerFailure(
        e.response?.statusMessage ?? 'Server error',
        statusCode: e.response?.statusCode,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
```

### 7. Providers (`presentation/providers/<feature>_provider.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Datasource
final <feature>DatasourceProvider = Provider<<Feature>RemoteDatasource>((ref) {
  return <Feature>RemoteDatasourceImpl(ref.read(dioProvider));
});

/// Repository
final <feature>RepositoryProvider = Provider<<Feature>Repository>((ref) {
  return <Feature>RepositoryImpl(ref.read(<feature>DatasourceProvider));
});

/// Use Case
final get<Feature>UseCaseProvider = Provider<Get<Feature>UseCase>((ref) {
  return Get<Feature>UseCase(ref.read(<feature>RepositoryProvider));
});

/// ViewModel
final <feature>ViewModelProvider =
    StateNotifierProvider<<Feature>ViewModel, <Feature>State>((ref) {
  return <Feature>ViewModel(ref.read(get<Feature>UseCaseProvider));
});
```

### 8. ViewModel (`presentation/providers/<feature>_view_model.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class <Feature>State {
  final bool isLoading;
  final bool isLoaded;
  final bool isError;
  final String? errorMessage;
  final List<<Feature>Entity> items;

  const <Feature>State({
    this.isLoading = false,
    this.isLoaded = false,
    this.isError = false,
    this.errorMessage,
    this.items = const [],
  });

  <Feature>State copyWith({
    bool? isLoading,
    bool? isLoaded,
    bool? isError,
    String? errorMessage,
    List<<Feature>Entity>? items,
  }) {
    return <Feature>State(
      isLoading: isLoading ?? this.isLoading,
      isLoaded: isLoaded ?? this.isLoaded,
      isError: isError ?? this.isError,
      errorMessage: errorMessage,
      items: items ?? this.items,
    );
  }
}

class <Feature>ViewModel extends StateNotifier<<Feature>State> {
  final Get<Feature>UseCase _getUseCase;

  <Feature>ViewModel(this._getUseCase) : super(const <Feature>State());

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true, isError: false, errorMessage: null);

    final result = await _getUseCase();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isError: true,
        errorMessage: failure.message,
      ),
      (items) => state = state.copyWith(
        isLoading: false,
        isLoaded: true,
        items: items,
      ),
    );
  }
}
```

### 9. Screen (`presentation/screens/<feature>_screen.dart`)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class <Feature>Screen extends ConsumerStatefulWidget {
  const <Feature>Screen({super.key});

  @override
  ConsumerState<<Feature>Screen> createState() => _<Feature>ScreenState();
}

class _<Feature>ScreenState extends ConsumerState<<Feature>Screen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(<feature>ViewModelProvider.notifier).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(<feature>ViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('<Feature>')),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(<Feature>State state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'An error occurred'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(<feature>ViewModelProvider.notifier).loadItems();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return ListTile(
          title: Text(item.id),
          // Customize per feature
        );
      },
    );
  }
}
```

## GoRouter Registration

After creating the feature, add the route in `config/routes/`:

```dart
GoRoute(
  path: '/<feature>',
  name: '<feature>',
  builder: (context, state) => const <Feature>Screen(),
),
```

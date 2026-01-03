# Injectable Configuration

## Configuración de build.yaml

Para que Injectable funcione correctamente, crea un archivo `build.yaml` en la raíz del proyecto:

```yaml
targets:
  $default:
    builders:
      injectable_generator:injectable_builder:
        options:
          auto_register: true
          # Genera código para todos los archivos que usen @injectable
```

## Comandos útiles

### Generar código de inyección de dependencias
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Observar cambios y regenerar automáticamente
```bash
dart run build_runner watch --delete-conflicting-outputs
```

## Estructura recomendada

```
lib/
├── app/
│   ├── injection_container.dart       # Configuración de GetIt
│   └── injection_container.config.dart # Generado automáticamente
├── features/
│   └── transactions/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── transaction_local_datasource.dart  # @injectable
│       │   └── repositories/
│       │       └── transaction_repository_impl.dart   # @LazySingleton(as: TransactionRepository)
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── transaction_repository.dart        # Interface abstracta
│       │   └── usecases/
│       │       └── get_transactions.dart              # @injectable
│       └── presentation/
│           └── bloc/
│               └── transaction_bloc.dart              # @injectable
```

## Ejemplo de uso en un feature

### 1. Repository Interface (Domain Layer)
```dart
// No necesita anotación, es solo una interfaz
abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
}
```

### 2. Repository Implementation (Data Layer)
```dart
import 'package:injectable/injectable.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;
  
  TransactionRepositoryImpl(this.localDataSource);
  
  @override
  Future<List<Transaction>> getTransactions() async {
    return await localDataSource.getTransactions();
  }
}
```

### 3. Use Case (Domain Layer)
```dart
import 'package:injectable/injectable.dart';

@injectable
class GetTransactions {
  final TransactionRepository repository;
  
  GetTransactions(this.repository);
  
  Future<List<Transaction>> call() async {
    return await repository.getTransactions();
  }
}
```

### 4. BLoC (Presentation Layer)
```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  
  TransactionBloc(this.getTransactions) : super(TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
  }
  
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await getTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
```

### 5. Usar el BLoC en un Widget
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fin_track_pro/app/injection_container.dart';

class TransactionPage extends StatelessWidget {
  const TransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TransactionBloc>()..add(LoadTransactions()),
      child: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const CircularProgressIndicator();
          }
          if (state is TransactionLoaded) {
            return ListView.builder(
              itemCount: state.transactions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(state.transactions[index].description),
                );
              },
            );
          }
          return const Text('Error');
        },
      ),
    );
  }
}
```

## Anotaciones disponibles

- `@injectable` - Dependencia normal, se crea una nueva instancia cada vez
- `@singleton` - Se crea una instancia al inicio y se reutiliza
- `@lazySingleton` - Se crea la primera vez que se solicita y se reutiliza
- `@module` - Para registrar dependencias externas (Dio, SharedPreferences, etc.)

## Ventajas de este setup

1. **Testeable**: Fácil de mockear dependencias en tests
2. **Desacoplado**: Las clases no conocen cómo se crean sus dependencias
3. **Mantenible**: Cambiar implementaciones es simple
4. **Type-safe**: Errores en tiempo de compilación, no en runtime
5. **Clean Architecture**: Respeta la inversión de dependencias

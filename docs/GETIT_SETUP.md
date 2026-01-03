# GetIt + Injectable - Configuración Completa ✅

## ¿Qué se ha configurado?

1. **GetIt** - Service locator para inyección de dependencias
2. **Injectable** - Generador de código para automatizar el registro de dependencias
3. **Build Runner** - Herramienta para generar código automáticamente

## Archivos creados

### 1. `lib/app/injection_container.dart`
Archivo principal que configura GetIt:
```dart
final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async => getIt.init();
```

### 2. `lib/app/injection_container.config.dart`
Archivo generado automáticamente por Injectable (no editar manualmente).

### 3. `lib/app/register_module.dart`
Módulo de ejemplo para registrar dependencias externas como Dio.

### 4. `build.yaml`
Configuración para el generador de código.

### 5. `docs/INJECTABLE_GUIDE.md`
Guía completa con ejemplos de uso.

## Cómo usar

### Paso 1: Crear una clase con dependencias

```dart
import 'package:injectable/injectable.dart';

@injectable
class MyService {
  final Dio dio;
  
  MyService(this.dio);
  
  Future<void> fetchData() async {
    // usar dio...
  }
}
```

### Paso 2: Generar código

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Paso 3: Usar la dependencia

```dart
import 'package:fin_track_pro/app/injection_container.dart';

final myService = getIt<MyService>();
await myService.fetchData();
```

## Para BLoC (cuando lo uses)

### 1. Crear el BLoC

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

@injectable
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions getTransactions;
  
  TransactionBloc(this.getTransactions) : super(TransactionInitial());
}
```

### 2. Generar código

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### 3. Usar en un Widget

```dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fin_track_pro/app/injection_container.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<TransactionBloc>(),
      child: // tu widget...
    );
  }
}
```

## Anotaciones disponibles

- `@injectable` - Nueva instancia cada vez que se solicita
- `@singleton` - Una sola instancia creada al inicio
- `@lazySingleton` - Una sola instancia creada cuando se solicita por primera vez
- `@module` - Para registrar dependencias externas (Dio, SharedPreferences, etc.)

## Comandos útiles

### Generar código una vez
```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

### Observar cambios y regenerar automáticamente
```bash
fvm dart run build_runner watch --delete-conflicting-outputs
```

### Limpiar archivos generados
```bash
fvm dart run build_runner clean
```

## Estado actual

✅ GetIt configurado
✅ Injectable configurado
✅ Build runner funcionando
✅ Código generado correctamente
✅ Ejemplo de módulo creado (Dio)
✅ Documentación completa disponible

## Próximos pasos

Cuando empieces a crear features con BLoC:

1. Crea tu repositorio con `@LazySingleton(as: InterfaceRepository)`
2. Crea tu use case con `@injectable`
3. Crea tu BLoC con `@injectable`
4. Ejecuta `fvm dart run build_runner build --delete-conflicting-outputs`
5. Usa `getIt<TuBloc>()` en tus widgets

¡Todo listo para cuando empieces a usar BLoC! 🚀

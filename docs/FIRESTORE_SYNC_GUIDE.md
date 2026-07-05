# Cloud Sync con Firestore — Guía Técnica

> **Fase:** Phase 2 · **Estado:** ✅ Implementado (2026-07-05)

---

## Tabla de Contenidos

1. [Estrategia](#1-estrategia)
2. [Dependencias y DI](#2-dependencias-y-di)
3. [Schema de Firestore y namespacing por flavor](#3-schema-de-firestore-y-namespacing-por-flavor)
4. [Entidades y modelos: campo `updatedAt`](#4-entidades-y-modelos-campo-updatedat)
5. [Datasources remotos](#5-datasources-remotos)
6. [Repositorios duales](#6-repositorios-duales)
7. [SyncService y merge Last-Write-Wins](#7-syncservice-y-merge-last-write-wins)
8. [Integración con AuthBloc](#8-integración-con-authbloc)
9. [Reglas de Firestore y setup de Firebase CLI](#9-reglas-de-firestore-y-setup-de-firebase-cli)
10. [Testing](#10-testing)
11. [Recuperación de boxes Hive con schema incompatible](#11-recuperación-de-boxes-hive-con-schema-incompatible)
12. [Interacción con los seeders de dev](#12-interacción-con-los-seeders-de-dev)
13. [Próxima sesión: integration tests con Patrol](#13-próxima-sesión-integration-tests-con-patrol)

---

## 1. Estrategia

### Offline-first con write-through

```
LECTURA:    UI → BLoC → UseCase → Repository → Hive (siempre local, nunca espera Firestore)
ESCRITURA:  UI → BLoC → UseCase → Repository → Hive (primero) → Firestore async (fire-and-forget)
LOGIN:      AuthBloc → authenticated → SyncService.onLogin(uid) → merge LWW por feature
LOGOUT:     AuthBloc → unauthenticated → SyncService.onLogout() → limpia transactions/budgets locales
```

**Reglas fundamentales (implementadas tal cual):**
- La UI nunca espera a Firestore. Hive es la fuente de verdad para renderizar.
- Firestore es un espejo cloud namespaced por **flavor** y por usuario:
  `/environments/{dev|staging|prod}/users/{uid}/...`.
- Al login: se activa la escritura remota (`setUserId`) y se corre un merge Last-Write-Wins
  por `updatedAt` una sola vez.
- Al logout: se desactiva la escritura remota y (opcionalmente) se limpian los datos locales
  sensibles.
- Si un write a Firestore falla, se loguea (`LoggerService`) y nunca se propaga a la UI.

---

## 2. Dependencias y DI

```yaml
# pubspec.yaml
dependencies:
  cloud_firestore: ^6.6.0

dev_dependencies:
  fake_cloud_firestore: ^4.1.1
```

```dart
// lib/app/register_module.dart
@lazySingleton
FirebaseFirestore get firestore => FirebaseFirestore.instance;
```

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Schema de Firestore y namespacing por flavor

Los 3 flavors (`dev`, `staging`, `prod`) comparten **un solo proyecto Firebase**
(`mis-apps-c42cc` — ver `firebase.json`). Para que no mezclen datos entre sí, cada
documento se namespacea bajo `environments/{flavor}`:

```
/environments/{dev|staging|prod}/users/{uid}/
  transactions/{transactionId}/
    id, amount, categoryId, type, note, date, createdAt, updatedAt

  categories/{categoryId}/
    id, name, icon, color, type, updatedAt

  budgets/{budgetId}/
    id, categoryId, amount, period, updatedAt
```

Cada datasource Firestore construye la ruta leyendo `FlavorConfig.instance.name`
(ya inicializado antes de que se resuelva el DI en `main.dart`):

```dart
// lib/features/transactions/data/datasources/firestore_transaction_datasource.dart
CollectionReference<Map<String, dynamic>> _col(String userId) => _db
    .collection('environments')
    .doc(FlavorConfig.instance.name)
    .collection('users')
    .doc(userId)
    .collection('transactions');
```

El mismo patrón se repite en `firestore_category_datasource.dart` y
`firestore_budget_datasource.dart`.

---

## 4. Entidades y modelos: campo `updatedAt`

`Transaction` ya tenía `createdAt`; `Category` y `Budget` no tenían ni eso ni
`copyWith` — se agregó todo. Índices Hive usados (siguiente campo libre en cada
modelo):

| Entidad | Hive typeId | Campo `updatedAt` |
|---|---|---|
| `Transaction` | 1 | `@HiveField(7)` |
| `Category` | 0 | `@HiveField(5)` |
| `Budget` | 2 | `@HiveField(4)` |

El repositorio (no cada call site) normaliza `updatedAt` en cada `create*`/`update*`:

```dart
final model = TransactionModel.fromEntity(
  transaction.copyWith(updatedAt: DateTime.now()),
);
```

Los modelos exponen `toMap()`/`fromMap()` con fechas serializadas en ISO-8601
(los modelos no importan `cloud_firestore` — esa dependencia vive únicamente en
el datasource remoto):

```dart
Map<String, dynamic> toMap() => {
  'id': id,
  // ...
  'updatedAt': updatedAt.toIso8601String(),
};

factory TransactionModel.fromMap(Map<String, dynamic> map) => TransactionModel(
  // ...
  updatedAt: DateTime.parse(map['updatedAt'] as String),
);
```

---

## 5. Datasources remotos

Mismo patrón que `FirebaseAuthRemoteDataSource`: interfaz abstracta +
implementación concreta con `@LazySingleton(as: Interface)`.

```
lib/features/transactions/data/datasources/
  transaction_remote_datasource.dart     ← interfaz
  firestore_transaction_datasource.dart  ← implementación

lib/features/categories/data/datasources/
  category_remote_datasource.dart
  firestore_category_datasource.dart

lib/features/budgets/data/datasources/
  budget_remote_datasource.dart          ← un solo saveBudget(userId, model) upsert,
  firestore_budget_datasource.dart          sin split create/update (igual que el local)
```

Cada interfaz expone: lectura completa por usuario (`getTransactions(userId)`,
usada solo para el merge de sync — las lecturas filtradas de la UI siguen siendo
local-only), `create`/`update`/`delete` (o `save` en Budget), `uploadAll` (batch,
usado por el merge) y `deleteAll`.

`updateTransaction`/`updateCategory` usan `SetOptions(merge: true)`;
`saveBudget` también, ya que es upsert.

---

## 6. Repositorios duales

`setUserId(String? userId)` se agregó a las **interfaces de dominio**
(`TransactionRepository`, `CategoryRepository`, `BudgetRepository`), no a las
clases concretas — `@LazySingleton(as: Interface)` registra la instancia en
GetIt **solo bajo el tipo interfaz**, así que `getIt<TransactionRepositoryImpl>()`
fallaría en runtime.

```dart
@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  final TransactionRemoteDataSource _remoteDataSource;
  String? _userId;

  @override
  void setUserId(String? userId) => _userId = userId;

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(
      transaction.copyWith(updatedAt: DateTime.now()),
    );
    await _localDataSource.createTransaction(model);
    _syncWrite(() => _remoteDataSource.createTransaction(_userId!, model));
  }

  // Las lecturas siempre van a _localDataSource — nunca a Firestore.

  void _syncWrite(Future<void> Function() operation) {
    if (_userId == null) return;
    operation().catchError((Object e, StackTrace stackTrace) {
      LoggerService().warning(
        'Firestore write failed: $e',
        tag: 'TransactionRepository',
        error: e,
        stackTrace: stackTrace,
      );
    });
  }
}
```

Mismo patrón en `CategoryRepositoryImpl` y `BudgetRepositoryImpl` (este último
mantiene el nombre de campo público `datasource` para el local, ya existente).

---

## 7. SyncService y merge Last-Write-Wins

La lógica de merge vive separada (`lib/core/services/last_write_wins_merger.dart`),
pura y sin dependencias de Hive/Firestore — así se testea sin mocks:

```dart
class MergeResult<T> {
  final List<T> toSaveLocally;
  final List<T> toUploadRemote;
}

class LastWriteWinsMerger {
  static MergeResult<T> merge<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) idOf,
    required DateTime Function(T) updatedAtOf,
  }) { /* ver código para el detalle por-id */ }
}
```

Reglas: solo local → `toUploadRemote`; solo remoto → `toSaveLocally`; en ambos,
gana el `updatedAt` más reciente; empate → no-op. **No maneja borrados** (sin
tombstones) — un delete ya se propaga inmediato vía fire-and-forget cuando hay
conexión; no se implementó soft-delete por ahora.

`SyncService` (`lib/core/services/sync_service.dart`, `@lazySingleton`, 9
dependencias: 3 repos + 3 datasources locales + 3 remotos + `HiveService`):

```dart
Future<void> onLogin(String userId) async {
  _transactionRepository.setUserId(userId);
  _categoryRepository.setUserId(userId);
  _budgetRepository.setUserId(userId);

  try {
    await Future.wait([
      _syncTransactions(userId),
      _syncCategories(userId),
      _syncBudgets(userId),
    ]);
  } catch (e, stackTrace) {
    // Nunca lanza: un login sin conexión no debe bloquear al usuario.
    LoggerService().warning('Firestore sync on login failed: $e', ...);
  }
}

Future<void> onLogout({bool clearLocalData = false}) async {
  _transactionRepository.setUserId(null);
  _categoryRepository.setUserId(null);
  _budgetRepository.setUserId(null);

  if (clearLocalData) {
    await _hiveService.getBox(HiveService.transactionsBox).clear();
    await _hiveService.getBox(HiveService.budgetsBox).clear();
    // categories y settings NO se limpian — decisión de producto confirmada.
  }
}
```

---

## 8. Integración con AuthBloc

En `lib/main.dart`, **después** de `hiveService.init()` (no justo después de
`configureDependencies()`, para que el sync nunca toque boxes de Hive todavía
cerradas):

```dart
final syncService = getIt<SyncService>();
getIt<AuthBloc>().stream.listen((state) {
  if (state.status == AuthStatus.authenticated && state.user != null) {
    syncService.onLogin(state.user!.id);
  } else if (state.status == AuthStatus.unauthenticated) {
    syncService.onLogout(clearLocalData: true);
  }
});
```

---

## 9. Reglas de Firestore y setup de Firebase CLI

`firestore.rules` (raíz del repo):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /environments/{environment}/users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

Setup ya hecho (config generada por `firebase init firestore`, versionada):
`.firebaserc` (proyecto `mis-apps-c42cc`), `firestore.indexes.json` (vacío —
no hay queries compuestas todavía, el merge trae la colección completa por
usuario).

Deploy de reglas (requiere cuenta/permisos propios, no lo puede correr un
agente):

```bash
firebase login
firebase deploy --only firestore:rules
```

Habilitar Cloud Firestore (modo **Native**, no Datastore) en la consola es un
paso manual único por proyecto, ya hecho para `mis-apps-c42cc`.

---

## 10. Testing

- **Merge LWW** (`test/core/services/last_write_wins_merger_test.dart`): 6 casos
  puros (solo local, solo remoto, remoto más nuevo, local más nuevo, empate,
  colecciones mixtas).
- **`SyncService`** (`test/core/services/sync_service_test.dart`): mocktail sobre
  las 9 dependencias — verifica `setUserId` en login/logout, upload/download por
  feature, que un fallo de red en el login nunca lanza excepción, y que el logout
  solo limpia `transactions`/`budgets` (nunca `categories`/`settings`).
- **Datasources Firestore** (uno por feature, ej.
  `test/features/transactions/data/datasources/firestore_transaction_datasource_test.dart`):
  `fake_cloud_firestore`, con foco en 2 cosas: (1) roundtrip `toMap`/`fromMap`
  para cada operación CRUD, y (2) que el namespacing por flavor efectivamente
  aísla los datos — un test explícito confirma que dev y prod no se ven entre sí.
- **Repositorios duales**: se agregó un segundo mock (`MockXRemoteDataSource`)
  a cada suite existente, con casos para `setUserId(null)` suprimiendo la
  escritura remota y para que un fallo async del remoto no se propague.

---

## 11. Recuperación de boxes Hive con schema incompatible

No estaba en el diseño original — apareció en producción (crash reportado por
Crashlytics) al agregar `updatedAt`: los registros locales existentes no tienen
ese campo, y como `DateTime` no tiene constructor `const`, Hive no puede usar su
mecanismo nativo de `defaultValue` para rellenarlo. `HiveService.init()` ahora
abre cada box con un helper que, si falla, borra y recrea la box en vez de
crashear el arranque:

```dart
Future<void> _openBoxSafely<T>(String name) async {
  try {
    await Hive.openBox<T>(name);
  } catch (e, stackTrace) {
    LoggerService().warning('Failed to open Hive box "$name", recreating it: $e', ...);
    await Hive.deleteBoxFromDisk(name);
    await Hive.openBox<T>(name);
  }
}
```

---

## 12. Interacción con los seeders de dev

Los seeders (`CategorySeeder`, `BudgetSeeder`, `TransactionSeeder`) solo corren
si la box de Hive correspondiente está vacía, y solo en flavor `dev`. Como
`onLogout(clearLocalData: true)` limpia `transactions`/`budgets` al cerrar
sesión, el próximo **reinicio completo de la app** en dev las encuentra vacías
y las vuelve a poblar con datos random (IDs nuevos cada vez — no son idempotentes
entre corridas). Al loguearse de nuevo, el merge LWW sube ese nuevo lote como
"solo local", acumulando lotes de datos de prueba en el Firestore de dev en vez
de reemplazar los anteriores.

**No afecta staging/prod** (el seeder nunca corre ahí) y no rompe nada — solo
ensucia la colección de dev con datos de prueba duplicados si se repite el
ciclo logout→reinicio→login varias veces. No se implementó ninguna mitigación
todavía (decisión pendiente: no limpiar `transactions`/`budgets` en logout, o
saltar el reseed cuando hay sync activo).

---

## 13. Próxima sesión: integration tests con Patrol

Pendiente, no implementado en esta sesión. Alcance acordado: tests de
integración con Patrol para el sync con Firestore, **flavor dev únicamente**.

Contexto relevante para esa sesión:
- `integration_test/smoke_test.dart` ya bootstrapea la app completa vía
  `app.mainCommon(Flavor.dev, '.env.dev')` — el mismo mecanismo aplica para
  loguearse y ejercitar `SyncService.onLogin`.
- Correr con: `patrol test --target integration_test/<nuevo_archivo>.dart --flavor dev`.
- Firestore real (no `fake_cloud_firestore`) entra en juego acá — a diferencia
  de los tests unitarios de la sección 10, esto valida contra el proyecto
  `mis-apps-c42cc` de verdad, namespaced bajo `environments/dev/...`.
- Puntos a cubrir: login dispara `onLogin` y sube datos existentes; crear una
  transacción/categoría/presupuesto logueado la persiste en Firestore bajo la
  ruta esperada; logout detiene la escritura remota; un segundo login con el
  mismo usuario recupera los datos.
- Cuidado con el punto de la sección 12 (seeders + reseed): estos tests van a
  correr en un ambiente con seeders activos, así que conviene decidir cómo
  aislar o limpiar el estado de Firestore dev entre corridas de test para que
  no queden falsos positivos por datos de sesiones anteriores.

---

## Referencias

- [cloud_firestore pub.dev](https://pub.dev/packages/cloud_firestore)
- [fake_cloud_firestore pub.dev](https://pub.dev/packages/fake_cloud_firestore)
- Patrón de datasource remoto: `lib/features/auth/data/datasources/firebase_auth_remote_datasource.dart`
- Patrón de servicio Firebase: `lib/core/services/analytics_service.dart`
- Reglas de Firestore: [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Versión:** 2.0
**Creado:** 2026-06-08
**Última actualización:** 2026-07-05
**Estado:** ✅ Implementado — pendiente integration tests con Patrol (próxima sesión)

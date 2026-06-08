# Cloud Sync con Firestore — Guía de Implementación

> **Fase:** Phase 2 · **Prerrequisito:** Firebase Auth completo  
> **Estimado:** 2–3 sesiones de fin de semana

---

## Tabla de Contenidos

1. [Estrategia](#1-estrategia)
2. [Setup: Dependencia y DI](#2-setup-dependencia-y-di)
3. [Schema de Firestore](#3-schema-de-firestore)
4. [Fase 1 — Modelos: añadir toMap / fromMap](#4-fase-1--modelos-añadir-tomap--frommap)
5. [Fase 2 — Datasources remotos](#5-fase-2--datasources-remotos)
6. [Fase 3 — Repositorios duales](#6-fase-3--repositorios-duales)
7. [Fase 4 — SyncService](#7-fase-4--syncservice)
8. [Fase 5 — Integración con AuthBloc](#8-fase-5--integración-con-authbloc)
9. [Fase 6 — Registro DI completo](#9-fase-6--registro-di-completo)
10. [Testing](#10-testing)
11. [Resolución de conflictos](#11-resolución-de-conflictos)
12. [Migración de datos locales](#12-migración-de-datos-locales)
13. [Checklist de implementación](#13-checklist-de-implementación)

---

## 1. Estrategia

### Offline-First con Write-Through

```
LECTURA:    UI → BLoC → UseCase → Repository → Hive (siempre local, nunca esperar Firestore)
ESCRITURA:  UI → BLoC → UseCase → Repository → Hive (primero) → Firestore async (fire-and-forget)
SYNC DOWN:  Login → SyncService.downloadFromFirestore() → reemplazar Hive con datos del server
SYNC UP:    Logout (opcional) → ya está en Firestore por write-through
```

**Reglas fundamentales:**
- La UI nunca espera Firestore. Hive es la fuente de verdad para rendering.
- Firestore es el espejo cloud por usuario (subcollections bajo `/users/{uid}/`).
- Al login: descarga y merge (server wins en conflicto por `updatedAt`).
- Al logout: limpiar datos sensibles locales (configurable).
- Si Firestore falla en un write, se loguea pero no se lanza error al usuario.

---

## 2. Setup: Dependencia y DI

### 2.1 pubspec.yaml

```yaml
dependencies:
  cloud_firestore: ^5.6.0   # Añadir bajo firebase_crashlytics
```

```bash
fvm flutter pub get
```

### 2.2 register_module.dart

Añadir `FirebaseFirestore` junto a los otros singletons de Firebase:

```dart
// lib/app/register_module.dart
import 'package:cloud_firestore/cloud_firestore.dart';

@module
abstract class RegisterModule {
  // ... (Dio, budgetBox, FirebaseAuth, GoogleSignIn existentes)

  @lazySingleton
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
```

Después de editar, regenerar:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Schema de Firestore

### Estructura de colecciones

```
/users/{uid}/
  transactions/{transactionId}/
    id:          String
    amount:      Number
    categoryId:  String
    type:        String          # "income" | "expense"
    note:        String | null
    date:        Timestamp
    createdAt:   Timestamp
    updatedAt:   Timestamp       # Para resolución de conflictos

  categories/{categoryId}/
    id:          String
    name:        String
    icon:        String
    color:       Number
    type:        String          # "income" | "expense"
    updatedAt:   Timestamp

  budgets/{budgetId}/
    id:          String
    categoryId:  String
    amount:      Number
    period:      String          # "monthly" | "weekly" | "yearly"
    updatedAt:   Timestamp
```

### Reglas de Firestore (firestore.rules)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

> Desplegar con: `firebase deploy --only firestore:rules`

---

## 4. Fase 1 — Modelos: añadir toMap / fromMap

Los modelos actuales solo tienen adaptadores Hive. Necesitan serialización Map para Firestore.
**No requiere code generation** — es código manual limpio.

### Nota: campo `updatedAt`

Antes de añadir `toMap`/`fromMap`, los tres entities necesitan el campo `updatedAt`. Este campo
es crítico para la resolución de conflictos offline.

#### 4.1 Actualizar entidades del dominio

```dart
// lib/features/transactions/domain/entities/transaction.dart
class Transaction extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final String type;
  final String? note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;   // ← NUEVO

  const Transaction({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.type,
    this.note,
    required this.date,
    required this.createdAt,
    required this.updatedAt,  // ← NUEVO
  });

  @override
  List<Object?> get props => [id, amount, categoryId, type, note, date, createdAt, updatedAt];

  Transaction copyWith({
    // ... campos existentes
    DateTime? updatedAt,      // ← NUEVO
  }) {
    return Transaction(
      // ... campos existentes
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
```

Aplicar el mismo patrón a `Category` y `Budget`.

#### 4.2 Actualizar TransactionModel (Hive)

```dart
// lib/features/transactions/data/models/transaction_model.dart
@HiveType(typeId: 1)
class TransactionModel extends Transaction {
  // ... @HiveField(0..6) existentes

  @HiveField(7)              // ← NUEVO (siguiente índice disponible)
  @override
  DateTime get updatedAt => super.updatedAt;

  const TransactionModel({
    required super.id,
    required super.amount,
    required super.categoryId,
    required super.type,
    super.note,
    required super.date,
    required super.createdAt,
    required super.updatedAt,  // ← NUEVO
  });

  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.categoryId,
      type: transaction.type,
      note: transaction.note,
      date: transaction.date,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,  // ← NUEVO
    );
  }

  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      categoryId: categoryId,
      type: type,
      note: note,
      date: date,
      createdAt: createdAt,
      updatedAt: updatedAt,  // ← NUEVO
    );
  }

  // ── Firestore serialization ─────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'categoryId': categoryId,
      'type': type,
      'note': note,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      amount: (map['amount'] as num).toDouble(),
      categoryId: map['categoryId'] as String,
      type: map['type'] as String,
      note: map['note'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
```

> **Por qué ISO 8601 y no Timestamp?** Los modelos de datos no deben importar `cloud_firestore`.
> El datasource remoto es el único lugar donde vive la dependencia de Firebase.

#### 4.3 CategoryModel — toMap / fromMap

```dart
// lib/features/categories/data/models/category_model.dart

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'type': type,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

factory CategoryModel.fromMap(Map<String, dynamic> map) {
  return CategoryModel(
    id: map['id'] as String,
    name: map['name'] as String,
    icon: map['icon'] as String,
    color: map['color'] as int,
    type: map['type'] as String,
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
```

#### 4.4 BudgetModel — toMap / fromMap

```dart
// lib/features/budgets/data/models/budget_model.dart

Map<String, dynamic> toMap() {
  return {
    'id': id,
    'categoryId': categoryId,
    'amount': amount,
    'period': period,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

factory BudgetModel.fromMap(Map<String, dynamic> map) {
  return BudgetModel(
    id: map['id'] as String,
    categoryId: map['categoryId'] as String,
    amount: (map['amount'] as num).toDouble(),
    period: map['period'] as String,
    updatedAt: DateTime.parse(map['updatedAt'] as String),
  );
}
```

Después de añadir `@HiveField(7)` en los modelos, regenerar:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

---

## 5. Fase 2 — Datasources remotos

Seguir exactamente el mismo patrón que `FirebaseAuthRemoteDataSource`:  
`interfaz abstracta` + `implementación concreta con @LazySingleton(as: Interface)`.

### 5.1 Interfaz abstracta

```dart
// lib/features/transactions/data/datasources/transaction_remote_datasource.dart
abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<void> createTransaction(String userId, TransactionModel transaction);
  Future<void> updateTransaction(String userId, TransactionModel transaction);
  Future<void> deleteTransaction(String userId, String id);
  Future<void> uploadAll(String userId, List<TransactionModel> transactions);
  Future<void> deleteAll(String userId);
}
```

### 5.2 Implementación Firestore

```dart
// lib/features/transactions/data/datasources/firestore_transaction_datasource.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../models/transaction_model.dart';
import 'transaction_remote_datasource.dart';

@LazySingleton(as: TransactionRemoteDataSource)
class FirestoreTransactionDataSource implements TransactionRemoteDataSource {
  final FirebaseFirestore _db;

  FirestoreTransactionDataSource(this._db);

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _db.collection('users').doc(userId).collection('transactions');

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final snapshot = await _col(userId).get();
    return snapshot.docs
        .map((doc) => TransactionModel.fromMap(doc.data()))
        .toList();
  }

  @override
  Future<void> createTransaction(
    String userId,
    TransactionModel transaction,
  ) async {
    await _col(userId).doc(transaction.id).set(transaction.toMap());
  }

  @override
  Future<void> updateTransaction(
    String userId,
    TransactionModel transaction,
  ) async {
    await _col(userId).doc(transaction.id).set(
          transaction.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> deleteTransaction(String userId, String id) async {
    await _col(userId).doc(id).delete();
  }

  @override
  Future<void> uploadAll(
    String userId,
    List<TransactionModel> transactions,
  ) async {
    final batch = _db.batch();
    for (final t in transactions) {
      batch.set(_col(userId).doc(t.id), t.toMap());
    }
    await batch.commit();
  }

  @override
  Future<void> deleteAll(String userId) async {
    final snapshot = await _col(userId).get();
    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
```

### 5.3 Repetir para Categories y Budgets

Crear los mismos archivos para cada feature:

```
lib/features/categories/data/datasources/
  category_remote_datasource.dart        ← interfaz
  firestore_category_datasource.dart     ← implementación

lib/features/budgets/data/datasources/
  budget_remote_datasource.dart          ← interfaz
  firestore_budget_datasource.dart       ← implementación
```

El patrón es idéntico: `_db.collection('users').doc(userId).collection('categories')`, etc.

---

## 6. Fase 3 — Repositorios duales

El repositorio recibe ambos datasources. El datasource remoto es nullable/opcional
para soportar modo no autenticado.

### Patrón: write-local-then-remote

```dart
// lib/features/transactions/data/repositories/transaction_repository_impl.dart
import 'package:injectable/injectable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _local;
  final TransactionRemoteDataSource _remote;

  // userId se inyecta como String nullable; null = no autenticado
  String? _userId;

  TransactionRepositoryImpl(this._local, this._remote);

  /// Llamar desde SyncService al hacer login/logout
  void setUserId(String? userId) => _userId = userId;

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _local.createTransaction(model);
    _syncWrite(() => _remote.createTransaction(_userId!, model));
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(
      transaction.copyWith(updatedAt: DateTime.now()),
    );
    await _local.updateTransaction(model);
    _syncWrite(() => _remote.updateTransaction(_userId!, model));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _local.deleteTransaction(id);
    _syncWrite(() => _remote.deleteTransaction(_userId!, id));
  }

  // Las lecturas siempre van al local
  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await _local.getTransactions();
    return models.map((m) => m.toEntity()).toList();
  }

  // ... resto de métodos de lectura sin cambios (delegan a _local)

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Fire-and-forget hacia Firestore. Los errores se logean, nunca se lanzan.
  void _syncWrite(Future<void> Function() operation) {
    if (_userId == null) return;
    operation().catchError((e) {
      // TODO: reemplazar con LoggerService cuando esté disponible
      // ignore: avoid_print
      print('[Firestore] Write error: $e');
    });
  }
}
```

Aplicar el mismo patrón a `CategoryRepositoryImpl` y `BudgetRepositoryImpl`.

---

## 7. Fase 4 — SyncService

El `SyncService` coordina el sync masivo al hacer login (download) y el cleanup al logout.

```dart
// lib/core/services/sync_service.dart
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:fin_track_pro/features/categories/data/datasources/category_local_datasource.dart';
import 'package:fin_track_pro/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_local_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:fin_track_pro/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fin_track_pro/features/categories/data/repositories/category_repository_impl.dart';
import 'package:fin_track_pro/features/budgets/data/repositories/budget_repository_impl.dart';

@lazySingleton
class SyncService {
  final TransactionLocalDataSource _localTx;
  final TransactionRemoteDataSource _remoteTx;
  final CategoryLocalDataSource _localCat;
  final CategoryRemoteDataSource _remoteCat;
  final BudgetLocalDatasource _localBudget;
  final BudgetRemoteDataSource _remoteBudget;

  // Repositorios para actualizar el userId
  final TransactionRepositoryImpl _txRepo;
  final CategoryRepositoryImpl _catRepo;
  final BudgetRepositoryImpl _budgetRepo;

  SyncService(
    this._localTx,
    this._remoteTx,
    this._localCat,
    this._remoteCat,
    this._localBudget,
    this._remoteBudget,
    this._txRepo,
    this._catRepo,
    this._budgetRepo,
  );

  /// Llamar después de que AuthBloc emite estado autenticado.
  /// 1. Propaga userId a los repositorios (activa write-through)
  /// 2. Sube datos locales que el server no tiene
  /// 3. Descarga datos del server y hace merge (server wins en conflicto)
  Future<void> onLogin(String userId) async {
    _txRepo.setUserId(userId);
    _catRepo.setUserId(userId);
    _budgetRepo.setUserId(userId);

    await _syncTransactions(userId);
    await _syncCategories(userId);
    await _syncBudgets(userId);
  }

  /// Llamar antes de que AuthBloc emita estado no autenticado.
  /// Limpia el userId de los repositorios (desactiva write-through).
  /// Opcionalmente borra datos locales sensibles.
  Future<void> onLogout({bool clearLocalData = false}) async {
    _txRepo.setUserId(null);
    _catRepo.setUserId(null);
    _budgetRepo.setUserId(null);

    if (clearLocalData) {
      await _clearLocalData();
    }
  }

  // ── Private sync logic ─────────────────────────────────────────────────────

  Future<void> _syncTransactions(String userId) async {
    final localList = await _localTx.getTransactions();
    final remoteList = await _remoteTx.getTransactions(userId);

    final merged = _merge<TransactionModel>(
      local: localList,
      remote: remoteList,
      getId: (m) => m.id,
      getUpdatedAt: (m) => m.updatedAt,
    );

    // Escribir el merge en local y subir lo que faltaba en remote
    for (final model in merged) {
      await _localTx.updateTransaction(model);
    }
    await _remoteTx.uploadAll(userId, merged);
  }

  Future<void> _syncCategories(String userId) async {
    // Mismo patrón que _syncTransactions
  }

  Future<void> _syncBudgets(String userId) async {
    // Mismo patrón que _syncTransactions
  }

  Future<void> _clearLocalData() async {
    // Borrar cajas Hive de transacciones (mantener categorías por defecto)
    await _localTx.deleteAll();
    await _budgetRepo.deleteAll();
  }

  /// Merge: server wins si updatedAt de remote > local para el mismo id.
  /// Items solo en local se mantienen y se suben. Items solo en remote se descargan.
  List<T> _merge<T>({
    required List<T> local,
    required List<T> remote,
    required String Function(T) getId,
    required DateTime Function(T) getUpdatedAt,
  }) {
    final Map<String, T> map = {for (final item in local) getId(item): item};

    for (final remoteItem in remote) {
      final id = getId(remoteItem);
      final localItem = map[id];
      if (localItem == null) {
        // Solo en remote → descargar
        map[id] = remoteItem;
      } else if (getUpdatedAt(remoteItem).isAfter(getUpdatedAt(localItem))) {
        // Remote más reciente → server wins
        map[id] = remoteItem;
      }
      // Si local es más reciente o igual → mantener local (ya fue subido)
    }

    return map.values.toList();
  }
}
```

---

## 8. Fase 5 — Integración con AuthBloc

El `AuthBloc` ya maneja los cambios de estado. El `SyncService` debe reaccionar a ellos.
La integración se hace en `main.dart` tras inicializar DI.

```dart
// lib/main.dart — dentro de mainCommon(), después de configureDependencies()

final authBloc = getIt<AuthBloc>();
final syncService = getIt<SyncService>();

// Escuchar cambios de auth para triggear sync
authBloc.stream.listen((state) {
  if (state.status == AuthStatus.authenticated && state.user != null) {
    syncService.onLogin(state.user!.id);
  } else if (state.status == AuthStatus.unauthenticated) {
    syncService.onLogout();
  }
});

authBloc.add(AuthStarted());
```

> **¿Por qué en main.dart y no dentro del AuthBloc?**  
> El AuthBloc vive en la capa de presentación y no debe conocer el SyncService (core/services).
> La suscripción en main.dart es el punto de integración entre capas sin crear dependencias circulares.

---

## 9. Fase 6 — Registro DI completo

Después de crear los nuevos datasources y el SyncService, injectable los detectará
automáticamente gracias a las anotaciones `@LazySingleton`. Solo necesitas regenerar:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Verificar que `injection_container.config.dart` contiene los nuevos tipos:
- `FirestoreTransactionDataSource`
- `FirestoreCategpryDataSource`
- `FirestoreBudgetDataSource`
- `SyncService`

Los repositorios (`TransactionRepositoryImpl`, etc.) reciben ahora **dos** datasources.
Injectable los inyecta automáticamente por tipo — no requiere configuración adicional
siempre que las interfaces estén registradas con sus implementaciones concretas.

---

## 10. Testing

### 10.1 Mock de Firestore

Usar el paquete `fake_cloud_firestore` para tests de unidad:

```yaml
# pubspec.yaml — dev_dependencies
fake_cloud_firestore: ^3.1.0
```

```dart
// test/features/transactions/data/datasources/firestore_transaction_datasource_test.dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/firestore_transaction_datasource.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late FirestoreTransactionDataSource sut;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    sut = FirestoreTransactionDataSource(fakeFirestore);
  });

  test('createTransaction writes to correct path', () async {
    const userId = 'user_123';
    final model = TransactionModel(
      id: 'tx_1',
      amount: 50.0,
      categoryId: 'cat_1',
      type: 'expense',
      date: DateTime(2026, 1, 1),
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    await sut.createTransaction(userId, model);

    final doc = await fakeFirestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc('tx_1')
        .get();

    expect(doc.exists, isTrue);
    expect(doc.data()!['amount'], equals(50.0));
  });
}
```

### 10.2 Test del SyncService (merge logic)

La función `_merge` es pura — testear directamente sus escenarios:

| Escenario | Resultado esperado |
|-----------|-------------------|
| Item solo en local | Se mantiene en local, se sube a remote |
| Item solo en remote | Se descarga a local |
| Mismo id, remote más nuevo | Remote wins |
| Mismo id, local más nuevo | Local se mantiene |
| Mismo id, mismo updatedAt | Se mantiene local |

### 10.3 Test del repositorio dual

```dart
blocTest<TransactionBloc, TransactionState>(
  'createTransaction writes local first, then syncs to remote',
  build: () {
    // Mock _local que responde inmediato
    when(() => mockLocal.createTransaction(any())).thenAnswer((_) async {});
    // Mock _remote que tarda 500ms (simulando latencia)
    when(() => mockRemote.createTransaction(any(), any()))
        .thenAnswer((_) => Future.delayed(const Duration(milliseconds: 500)));
    return sut; // TransactionRepositoryImpl con ambos mocks
  },
  act: (repo) => repo.createTransaction(testTransaction),
  verify: (_) {
    verify(() => mockLocal.createTransaction(any())).called(1);
    // El remote se llama eventualmente (fire-and-forget)
    verify(() => mockRemote.createTransaction(any(), any())).called(1);
  },
);
```

---

## 11. Resolución de conflictos

### Estrategia: Last-Write-Wins con `updatedAt`

| Situación | Resultado |
|-----------|-----------|
| Edité offline → sync al conectar | Local se sube (updatedAt local > remote) |
| Edité en otro device mientras offline | Remote wins al hacer login (updatedAt remote > local) |
| Edité en dos devices al mismo tiempo | El que llegue primero a Firestore gana en el siguiente sync |
| Borré local, existe en remote | Conflicto no resuelto automáticamente — se puede añadir soft-delete con `deletedAt` |

### Soft-delete (para versión futura)

Para manejar borrados en sync, reemplazar borrados físicos por un campo `deletedAt`:

```dart
// En lugar de deleteTransaction(id):
await updateTransaction(transaction.copyWith(deletedAt: DateTime.now()));
```

El merge filtraría documentos con `deletedAt != null` después de sincronizar.
Esto es complejidad adicional — implementar solo si los conflictos de borrado son un problema real.

---

## 12. Migración de datos locales

### Escenario: usuario con datos locales que hace login por primera vez

El `SyncService.onLogin()` maneja esto automáticamente:
1. Descarga Firestore → vacío para usuario nuevo
2. `_merge()` retorna todos los items locales (solo en local)
3. `uploadAll()` sube todos los datos locales a Firestore

**No se necesita migración manual.** El primer login actúa como upload inicial.

### Escenario: usuario existente en Firestore que abre la app en nuevo device

1. Hive local empieza vacío
2. `onLogin()` → descarga todo de Firestore
3. `_merge()` retorna todos los items de Firestore (solo en remote)
4. Se escriben en Hive local
5. La app tiene todos los datos disponibles offline

### Consideración sobre seeders

Los seeders actuales (CategorySeeder, TransactionSeeder) corren en modo `dev`.
Con sync activo, los datos seeded se subirían a Firestore. Para evitar contaminar
la cuenta del developer con datos de prueba:

```dart
// lib/core/database/hive_service.dart — modificar condición de seeding
if (flavor == Flavor.dev && !await _isUserAuthenticated()) {
  await _runSeeders();
}
```

---

## 13. Checklist de implementación

### Sesión 1 — Fundamentos (~4h)
- [ ] Añadir `cloud_firestore` a pubspec.yaml
- [ ] Añadir `FirebaseFirestore` a `register_module.dart`
- [ ] Añadir `updatedAt` a los 3 entities (`Transaction`, `Category`, `Budget`)
- [ ] Añadir `@HiveField(7)` + `updatedAt` a los 3 modelos Hive
- [ ] Añadir `toMap()` y `fromMap()` a los 3 modelos
- [ ] Ejecutar `build_runner` y resolver errores de compilación
- [ ] Actualizar todos los lugares donde se construyen entities (seeders, use cases, tests)
- [ ] Correr `fvm flutter test` — todos los tests existentes deben pasar

### Sesión 2 — Datasources y Repositorios (~4h)
- [ ] Crear `TransactionRemoteDataSource` (interfaz) + `FirestoreTransactionDataSource`
- [ ] Crear `CategoryRemoteDataSource` + `FirestoreCategoryDataSource`
- [ ] Crear `BudgetRemoteDataSource` + `FirestoreBudgetDataSource`
- [ ] Actualizar `TransactionRepositoryImpl` para dual-source + `setUserId()`
- [ ] Actualizar `CategoryRepositoryImpl` para dual-source + `setUserId()`
- [ ] Actualizar `BudgetRepositoryImpl` para dual-source + `setUserId()`
- [ ] Regenerar DI y verificar `injection_container.config.dart`

### Sesión 3 — SyncService, Integración y Tests (~4h)
- [ ] Crear `SyncService` con lógica de merge
- [ ] Integrar `SyncService` en `main.dart` suscribiéndose al `AuthBloc.stream`
- [ ] Añadir `fake_cloud_firestore` como dev dependency
- [ ] Escribir tests para `FirestoreTransactionDataSource`
- [ ] Escribir tests para la lógica de merge en `SyncService`
- [ ] Test de integración manual: crear transacción → verificar en consola Firestore
- [ ] Verificar reglas de Firestore en Firebase Console
- [ ] Desplegar reglas: `firebase deploy --only firestore:rules`

---

## Referencias

- [cloud_firestore pub.dev](https://pub.dev/packages/cloud_firestore)
- [fake_cloud_firestore pub.dev](https://pub.dev/packages/fake_cloud_firestore) — para tests
- Patrón de datasource remoto existente: `lib/features/auth/data/datasources/firebase_auth_remote_datasource.dart`
- Patrón de servicio Firebase existente: `lib/core/services/analytics_service.dart`
- Reglas de Firestore: [Firebase Security Rules](https://firebase.google.com/docs/firestore/security/get-started)

---

**Versión:** 1.0  
**Creado:** 2026-06-08  
**Estado:** Listo para implementar — Phase 2 in progress

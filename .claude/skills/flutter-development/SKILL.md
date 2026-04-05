---
name: flutter-dev
description: >
  Skill for Flutter/Dart mobile development following Clean Architecture with Riverpod.
  Use this skill whenever the user asks to: create a new feature or module in a Flutter app,
  generate models/entities with fromJson/toJson/copyWith, write unit/widget/integration/golden tests,
  create or refactor Riverpod providers and ViewModels, build UI screens or reusable widgets,
  scaffold boilerplate for Clean Architecture layers (data/domain/presentation),
  refactor or optimize existing Flutter/Dart code, design system components,
  set up GoRouter routes, create repositories/datasources/usecases,
  or anything related to Flutter mobile app development. Trigger this skill even if the user
  just says "new feature", "create model", "write tests", "refactor this provider",
  "optimize this widget", or mentions Dart, Flutter, Riverpod, GoRouter, Dio, Formz,
  dartz, or Clean Architecture in any context.
---

# Flutter Mobile Development Skill

This skill encodes Wilson's Flutter development workflow: Clean Architecture (feature-first),
Riverpod state management, manual Dart classes (no Freezed), and a layered project structure.
Every piece of generated code should feel like it belongs in the existing codebase.

## Core Principles

1. **Clean Architecture, always.** Three layers per feature: `data/`, `domain/`, `presentation/`. No shortcuts, no mixing concerns.
2. **Manual Dart classes over codegen.** No Freezed. Write `==`, `hashCode`, `copyWith`, `toJson`, `fromJson` by hand. It's more explicit, easier to debug, and avoids build_runner overhead.
3. **Riverpod for everything stateful.** Use `StateNotifierProvider`, `FutureProvider`, `Provider`, etc. ViewModels extend `StateNotifier`.
4. **dartz for error handling.** `Either<Failure, T>` flows from datasource → repository → usecase → provider. Never throw exceptions across layer boundaries.
5. **Evidence-based decisions.** Don't over-engineer. If a simple solution works, prefer it.

## Project Structure

```
lib/
├── config/
│   ├── routes/          # GoRouter configuration
│   └── env/             # Environment config, Firebase Remote Config
├── core/
│   ├── theme/           # App theme, text styles (Display, Head, Body, Title)
│   ├── utils/           # Extensions, helpers, debounce logic
│   ├── constants/       # App-wide constants
│   └── networking/      # Dio client setup, interceptors, TLS config
├── features/
│   └── <feature_name>/
│       ├── data/
│       │   ├── datasources/    # Remote/local datasource implementations
│       │   ├── models/         # Data models with fromJson/toJson
│       │   └── repositories/   # Repository implementations
│       ├── domain/
│       │   ├── entities/       # Pure business entities
│       │   ├── repositories/   # Abstract repository contracts
│       │   └── usecases/       # Single-responsibility use cases
│       └── presentation/
│           ├── providers/      # Riverpod providers, ViewModels
│           ├── screens/        # Full page screens (*_screen.dart)
│           └── widgets/        # Feature-specific widgets
├── shared/
│   └── widgets/         # Cross-feature reusable widgets
└── l10n/                # Localization files
```

## File Naming Conventions

Use snake_case for all files. Suffix files by their role:

| Layer        | Suffix                  | Example                          |
|-------------|------------------------|----------------------------------|
| Model       | `_model.dart`          | `payment_model.dart`             |
| Entity      | `_entity.dart`         | `payment_entity.dart`            |
| Datasource  | `_datasource.dart`     | `payment_remote_datasource.dart` |
| Repository (abstract) | `_repository.dart` | `payment_repository.dart`    |
| Repository (impl) | `_repository_impl.dart` | `payment_repository_impl.dart` |
| Use case    | `_usecase.dart`        | `get_payments_usecase.dart`      |
| Provider    | `_provider.dart`       | `payment_provider.dart`          |
| ViewModel   | `_view_model.dart`     | `payment_view_model.dart`        |
| Screen      | `_screen.dart`         | `payment_screen.dart`            |
| Widget      | descriptive name       | `payment_card.dart`              |

## Tech Stack Quick Reference

Read `references/packages.md` for the full dependency list and usage patterns.

**State Management:** Riverpod (flutter_riverpod, riverpod_annotation)
**Navigation:** GoRouter (go_router)
**Networking:** Dio with interceptors
**Error Handling:** dartz (Either, Left, Right)
**Forms:** Formz (FormzInput subclasses)
**DI:** Riverpod providers (no get_it or injectable)
**Testing:** flutter_test, mockito, riverpod for provider overrides
**Assets:** flutter_gen, flutter_svg, cached_network_image, lottie
**Loading States:** Skeletonizer
**Storage:** flutter_secure_storage, shared_preferences
**Utilities:** url_launcher, permission_handler, package_info_plus
**CI/CD:** GitHub Actions, Fastlane (iOS), FVM for Flutter versions
**Linting:** flutter_lints (default rules)

---

## Task-Specific Instructions

Depending on what the user asks, follow the corresponding section below. For any task, read the relevant reference file first if one exists.

### Creating a New Feature (Boilerplate)

When the user asks to create a new feature, generate the full directory structure and all boilerplate files. Read `references/feature_boilerplate.md` for the complete template.

The generation order matters — build bottom-up:
1. **Domain layer first:** Entity → Repository contract → Use case
2. **Data layer second:** Model (extending/mapping to entity) → Datasource → Repository impl
3. **Presentation layer last:** Providers → ViewModel → Screen

Each file should compile independently. Never leave `// TODO` placeholders unless the user explicitly asks for stubs.

### Creating Models and Entities

Read `references/model_patterns.md` for the canonical patterns.

Key rules:
- **Entity** lives in `domain/entities/`. Pure Dart, no json logic, no framework imports.
- **Model** lives in `data/models/`. Contains `fromJson(Map<String, dynamic>)`, `toJson()`, and a way to convert to/from the entity.
- Always implement `==` and `hashCode` manually (use all fields).
- Always implement `copyWith` with nullable optional parameters.
- Use `DateTime.parse()` / `.toIso8601String()` for date fields in JSON.
- Numeric IDs from JSON: always handle both `int` and `String` with `toString()`.

### Writing Tests

Read `references/testing_patterns.md` for detailed patterns.

**Unit tests:** Test providers, ViewModels, use cases, repositories, and models in isolation.
- Use `ProviderContainer` with overrides for Riverpod testing.
- Mock dependencies with `mockito` (`@GenerateMocks`).
- Test `Either` results: verify `isLeft()` / `isRight()` and fold to check values.

**Widget tests:** Test screens and widgets with `WidgetTester`.
- Wrap widgets in `ProviderScope` with overrides.
- Use `pumpAndSettle()` after interactions.
- Test both success and error states.

**Golden tests:** For visual regression of design system components.
- Name files `*_golden_test.dart`.
- Use `matchesGoldenFile()`.

**Integration tests:** For critical user flows.
- Place in `integration_test/` directory.
- Test full feature flows end-to-end.

### Refactoring Code

When refactoring, follow these principles:
- **Decompose large files.** If a ViewModel exceeds ~300 lines, extract specialized services (e.g., `PaymentCalculatorService`, `PaymentValidatorService`).
- **Single Responsibility.** Each class/provider should do one thing well.
- **Extract magic values** into constants or Remote Config.
- **Eliminate duplication** by extracting shared logic into `core/utils/` or `shared/`.
- Preserve existing tests. If tests break, fix them — don't delete them.
- Run `dart analyze` and `dart format` after every refactor.

### Building UI / Design System Widgets

Read `references/design_system.md` for the component library patterns.

Key patterns:
- Use the app's custom text style hierarchy: Display, Head, Title, Body.
- Prefer composition over inheritance for widgets.
- Use `RepaintBoundary` for expensive widgets.
- Cache Lottie compositions with `AssetLottie`.
- Use `Skeletonizer` for loading states.
- For gradient borders, use the `CommodoGradientBorder` pattern (animated variant available).
- Always add `const` constructors where possible.

### Riverpod Provider Patterns

```dart
// Simple provider
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  return PaymentRepositoryImpl(ref.read(paymentDatasourceProvider));
});

// Use case provider
final getPaymentsUseCaseProvider = Provider<GetPaymentsUseCase>((ref) {
  return GetPaymentsUseCase(ref.read(paymentRepositoryProvider));
});

// ViewModel as StateNotifier
final paymentViewModelProvider =
    StateNotifierProvider<PaymentViewModel, PaymentState>((ref) {
  return PaymentViewModel(ref.read(getPaymentsUseCaseProvider));
});

// FutureProvider for simple async data
final userBalanceProvider = FutureProvider<double>((ref) async {
  final useCase = ref.read(getUserBalanceUseCaseProvider);
  final result = await useCase();
  return result.fold(
    (failure) => throw failure,
    (balance) => balance,
  );
});
```

### GoRouter Route Configuration

```dart
GoRoute(
  path: '/payment',
  name: 'payment',
  builder: (context, state) => const PaymentScreen(),
  routes: [
    GoRoute(
      path: 'confirmation',
      name: 'paymentConfirmation',
      builder: (context, state) {
        final extra = state.extra as PaymentConfirmationArgs;
        return PaymentConfirmationScreen(args: extra);
      },
    ),
  ],
),
```

### Formz Validation Pattern

```dart
class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return EmailValidationError.invalid;
    }
    return null;
  }
}

enum EmailValidationError { empty, invalid }
```

### Either/Failure Pattern (dartz)

```dart
// Domain failure
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure(super.message, {this.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

// Repository contract
abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentEntity>>> getPayments();
}

// Repository implementation
@override
Future<Either<Failure, List<PaymentEntity>>> getPayments() async {
  try {
    final models = await remoteDatasource.getPayments();
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
```

---

## Quality Checklist

Before presenting any generated code, verify:

- [ ] All imports are explicit (no `part` files unless for generated code)
- [ ] `const` constructors used wherever possible
- [ ] No `dynamic` types — everything is strongly typed
- [ ] `Either<Failure, T>` used for all fallible operations crossing layers
- [ ] Models have `fromJson`, `toJson`, `copyWith`, `==`, `hashCode`
- [ ] Providers follow the naming convention: `<name>Provider`
- [ ] ViewModels extend `StateNotifier<SomeState>`
- [ ] Screens are suffixed `_screen.dart`
- [ ] Tests mock dependencies, not implementations
- [ ] No Freezed annotations — everything is manual
- [ ] Dart formatting applied (`dart format`)

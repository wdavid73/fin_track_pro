# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Run Commands

This project uses FVM (Flutter Version Manager). Prefix commands with `fvm` when available.

```bash
# Setup (first time)
./setup.sh                    # Full project setup: deps, git hooks, code gen, analysis

# Run the app (three flavors: dev, staging, prod)
fvm flutter run --flavor dev -t lib/flavors/main_dev.dart
fvm flutter run --flavor staging -t lib/flavors/main_staging.dart
fvm flutter run --flavor prod -t lib/flavors/main_prod.dart

# Or use Makefile shortcuts
make run-dev
make run-staging
make run-prod
```

## Testing

```bash
# All unit tests
fvm flutter test

# Single test file
fvm flutter test test/features/transactions/data/models/transaction_model_test.dart

# Feature directory
fvm flutter test test/features/transactions/

# With coverage (generates HTML report)
./coverage.sh
open coverage/html/index.html

# Update golden test images
fvm flutter test --update-goldens test/goldens/

# Integration tests with Patrol
patrol test --target integration_test/smoke_test.dart --flavor dev
```

## Code Generation

Run after modifying models, adding `@injectable` annotations, or Hive type adapters:

```bash
fvm dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on changes)
fvm dart run build_runner watch --delete-conflicting-outputs
```

Generated files: `*.g.dart` (Hive adapters), `injection_container.config.dart` (DI)

## Architecture

**Clean Architecture with Feature-First structure:**

```
lib/
├── app/
│   ├── app.dart                    # MaterialApp root
│   └── injection_container.dart    # GetIt + Injectable setup
├── config/router/                  # go_router navigation
├── core/
│   ├── database/                   # HiveService + seeders
│   ├── error/                      # Failures + Exceptions
│   ├── extensions/                 # Context, currency, locale extensions
│   └── widgets/                    # Shared widgets
├── features/
│   └── <feature>/
│       ├── data/
│       │   ├── datasources/        # Local/Remote data sources
│       │   ├── models/             # Data models with Hive adapters
│       │   └── repositories/       # Repository implementations
│       ├── domain/
│       │   ├── entities/           # Business entities
│       │   ├── repositories/       # Repository interfaces
│       │   └── usecases/           # Business logic use cases
│       └── presentation/
│           ├── bloc/               # BLoC state management
│           ├── pages/              # Screen widgets
│           └── widgets/            # Feature-specific widgets
└── flavors/                        # Entry points: main_dev.dart, main_staging.dart, main_prod.dart
```

## Key Patterns

**Dependency Injection (get_it + injectable):**
- Use `@injectable` for transient dependencies
- Use `@lazySingleton` for singletons with interface binding: `@LazySingleton(as: TransactionRepository)`
- Use `@singleton` for eager singletons
- Access dependencies via `getIt<MyClass>()`

**State Management (BLoC):**
- Each feature has its own BLoC in `presentation/bloc/`
- Events define user actions, States define UI states
- Use `bloc_test` for testing BLoC logic

**Models vs Entities:**
- Models (`data/models/`): Include Hive annotations (`@HiveType`, `@HiveField`), `toEntity()` and `fromEntity()` methods
- Entities (`domain/entities/`): Pure Dart classes, no framework dependencies

**Testing conventions:**
- Mirror source structure in `test/` directory
- Use `mocktail` for mocking
- Name pattern: `<class_name>_test.dart`
- Use `sut` variable name for system under test

## Environment Configuration

Three flavors with corresponding `.env` files (not committed):
- `.env.dev` / `.env.staging` / `.env.prod`

Template available at `.env.template`. Environment loaded via `flutter_dotenv`.

## CI/CD

- CI runs on `develop` branch (push/PR)
- Coverage gate: minimum 60%
- Integration tests run on Firebase Test Lab after unit tests pass

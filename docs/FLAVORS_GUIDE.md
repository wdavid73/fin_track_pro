# Flutter Flavors Guide

## Overview

This project is configured with 3 flavors (environments):
- **dev** - Development environment
- **staging** - Staging/QA environment  
- **prod** - Production environment

Each flavor has its own:
- Application ID (bundle identifier)
- App name
- Environment variables (.env file)
- Configuration settings

## Running the App

### Using VS Code

Use the Run and Debug panel (Cmd/Ctrl + Shift + D) and select:
- "FinTrack Pro (Dev)"
- "FinTrack Pro (Staging)"
- "FinTrack Pro (Prod)"

### Using Command Line

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

## Building the App

### Android APK

```bash
# Development
flutter build apk --flavor dev -t lib/main_dev.dart

# Staging
flutter build apk --flavor staging -t lib/main_staging.dart

# Production
flutter build apk --flavor prod -t lib/main_prod.dart
```

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --flavor prod -t lib/main_prod.dart
```

### iOS (requires Mac)

```bash
# Development
flutter build ios --flavor dev -t lib/main_dev.dart

# Staging
flutter build ios --flavor staging -t lib/main_staging.dart

# Production
flutter build ios --flavor prod -t lib/main_prod.dart
```

## Flavor Configuration

### Application IDs

- **Dev**: `com.fintrackpro.dev`
- **Staging**: `com.fintrackpro.staging`
- **Prod**: `com.fintrackpro`

### App Names

- **Dev**: "FinTrack Pro DEV" (Green theme)
- **Staging**: "FinTrack Pro STG" (Orange theme)
- **Prod**: "FinTrack Pro" (Blue theme)

## Environment Variables

Each flavor loads its own `.env` file:

### `.env.dev`
```
APP_NAME=FinTrack Pro DEV
API_BASE_URL=https://dev-api.fintrackpro.com
ENABLE_LOGGING=true
ENABLE_DEBUG_BANNER=true
```

### `.env.staging`
```
APP_NAME=FinTrack Pro STG
API_BASE_URL=https://staging-api.fintrackpro.com
ENABLE_LOGGING=true
ENABLE_DEBUG_BANNER=false
```

### `.env.prod`
```
APP_NAME=FinTrack Pro
API_BASE_URL=https://api.fintrackpro.com
ENABLE_LOGGING=false
ENABLE_DEBUG_BANNER=false
```

## Accessing Configuration in Code

### Flavor Information

```dart
import 'package:fin_track_pro/core/config/flavor_config.dart';

final flavor = FlavorConfig.instance;

print(flavor.appName);        // "FinTrack Pro DEV"
print(flavor.isDev);          // true
print(flavor.isStaging);      // false
print(flavor.isProd);         // false
print(flavor.enableLogging);  // true
```

### Environment Variables

```dart
import 'package:fin_track_pro/core/config/env_config.dart';

print(EnvConfig.apiBaseUrl);      // "https://dev-api.fintrackpro.com"
print(EnvConfig.enableLogging);   // true
print(EnvConfig.environment);     // "development"
```

## iOS Configuration (Manual Steps Required)

For iOS, you need to create schemes in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner > Edit Scheme
3. Duplicate the Runner scheme 3 times
4. Rename them to: dev, staging, prod
5. For each scheme, set the Build Configuration accordingly

## Troubleshooting

### "Flavor not found" error

Make sure you're using both `--flavor` and `-t` flags:
```bash
flutter run --flavor dev -t lib/main_dev.dart
```

### Environment variables not loading

1. Check that .env files are in the root directory
2. Verify they're listed in `pubspec.yaml` under `assets`
3. Run `flutter clean` and `flutter pub get`

### Different app name not showing

For Android, the app name comes from the `resValue` in `build.gradle.kts`.
Make sure you've run the app with the correct flavor.

## Best Practices

1. **Never commit sensitive data** to .env files
2. **Use dev flavor** for daily development
3. **Use staging** for QA testing before production
4. **Use prod** only for production builds
5. **Test each flavor** before releasing

## Adding New Environment Variables

1. Add the variable to all three .env files
2. Add a getter in `lib/core/config/env_config.dart`
3. Use it via `EnvConfig.yourVariable`

Example:
```dart
// In env_config.dart
static String get newVariable => dotenv.get('NEW_VARIABLE', fallback: 'default');
```

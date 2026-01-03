# Configuración Rápida de iOS Flavors

## Opción 1: Configuración Manual (Recomendada)

Sigue la guía completa en: [`docs/IOS_FLAVORS_SETUP.md`](../docs/IOS_FLAVORS_SETUP.md)

## Opción 2: Verificar Configuración Actual

```bash
./ios/verify_flavors.sh
```

Este script te dirá si los schemes ya están configurados.

## Resumen de Pasos Manuales

1. **Abrir Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. **Crear Build Configurations** (en Project > Info):
   - Debug-dev, Debug-staging, Debug-prod
   - Release-dev, Release-staging, Release-prod

3. **Crear Schemes** (Product > Scheme > Manage Schemes):
   - dev (usando Debug-dev / Release-dev)
   - staging (usando Debug-staging / Release-staging)
   - prod (usando Debug-prod / Release-prod)

4. **Configurar Bundle IDs** (en Build Settings):
   - dev: `com.fintrackpro.dev`
   - staging: `com.fintrackpro.staging`
   - prod: `com.fintrackpro`

5. **Configurar Product Names** (en Build Settings):
   - dev: `FinTrack Pro DEV`
   - staging: `FinTrack Pro STG`
   - prod: `FinTrack Pro`

## ¿Ya está configurado?

Si ya configuraste los schemes, puedes ejecutar:

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

## Notas

- ✅ `Info.plist` ya está configurado para usar `$(PRODUCT_NAME)`
- ⚠️ Los schemes deben marcarse como "Shared" en Xcode
- 📱 Cada flavor puede instalarse simultáneamente (diferentes bundle IDs)

## Ayuda

Si tienes problemas, consulta la guía completa en `docs/IOS_FLAVORS_SETUP.md`

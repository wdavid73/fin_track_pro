# iOS Flavors Configuration Guide for Xcode

## Overview

Esta guía te ayudará a configurar los flavors (dev, staging, prod) en Xcode para iOS.

## Pasos para Configurar Schemes en Xcode

### 1. Abrir el Proyecto en Xcode

```bash
cd /Volumes/Mac-Mini-Apps/development/fin_track_pro
open ios/Runner.xcworkspace
```

⚠️ **IMPORTANTE**: Abre `Runner.xcworkspace`, NO `Runner.xcodeproj`

### 2. Crear Configuraciones de Build

1. En Xcode, selecciona el proyecto **Runner** en el navegador (panel izquierdo)
2. Selecciona el target **Runner**
3. Ve a la pestaña **Info**
4. En la sección **Configurations**, verás Debug y Release

#### Duplicar Configuraciones:

1. Haz clic en el **+** debajo de Configurations
2. Selecciona **Duplicate "Debug" Configuration**
3. Nómbrala: `Debug-dev`
4. Repite para crear:
   - `Debug-staging`
   - `Debug-prod`
   - `Release-dev`
   - `Release-staging`
   - `Release-prod`

Deberías tener 6 configuraciones en total:
- Debug-dev
- Debug-staging
- Debug-prod
- Release-dev
- Release-staging
- Release-prod

### 3. Crear Schemes

#### 3.1 Scheme para DEV

1. En la barra superior, haz clic en el scheme actual (probablemente "Runner")
2. Selecciona **Manage Schemes...**
3. Haz clic en **+** para crear un nuevo scheme
4. Nómbralo: `dev`
5. Asegúrate que el target sea **Runner**
6. Haz clic en **Close**

#### 3.2 Configurar el Scheme DEV

1. Selecciona el scheme `dev` y haz clic en **Edit...**
2. En **Build**:
   - Asegúrate que Runner esté marcado para todas las acciones
3. En **Run**:
   - Build Configuration: `Debug-dev`
   - Executable: Runner.app
4. En **Test**:
   - Build Configuration: `Debug-dev`
5. En **Profile**:
   - Build Configuration: `Release-dev`
6. En **Analyze**:
   - Build Configuration: `Debug-dev`
7. En **Archive**:
   - Build Configuration: `Release-dev`
8. Haz clic en **Close**

#### 3.3 Repetir para STAGING y PROD

Repite los pasos 3.1 y 3.2 para crear schemes:
- `staging` (usando configuraciones Debug-staging y Release-staging)
- `prod` (usando configuraciones Debug-prod y Release-prod)

### 4. Configurar Bundle Identifiers

1. Selecciona el proyecto **Runner**
2. Selecciona el target **Runner**
3. Ve a **Build Settings**
4. Busca "Product Bundle Identifier"
5. Expande la sección

Para cada configuración, establece:

```
Debug-dev:     com.fintrackpro.dev
Release-dev:   com.fintrackpro.dev

Debug-staging:     com.fintrackpro.staging
Release-staging:   com.fintrackpro.staging

Debug-prod:    com.fintrackpro
Release-prod:  com.fintrackpro
```

### 5. Configurar Display Names

1. En **Build Settings**, busca "Product Name"
2. Para cada configuración:

```
Debug-dev:     FinTrack Pro DEV
Release-dev:   FinTrack Pro DEV

Debug-staging:     FinTrack Pro STG
Release-staging:   FinTrack Pro STG

Debug-prod:    FinTrack Pro
Release-prod:  FinTrack Pro
```

### 6. Configurar Info.plist

1. Abre `ios/Runner/Info.plist`
2. Asegúrate que tenga:

```xml
<key>CFBundleDisplayName</key>
<string>$(PRODUCT_NAME)</string>
<key>CFBundleIdentifier</key>
<string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
```

### 7. Verificar Configuración

Cierra y vuelve a abrir Xcode para asegurarte que los cambios se guardaron.

## Ejecutar con Flavors desde Terminal

```bash
# Development
flutter run --flavor dev -t lib/main_dev.dart

# Staging
flutter run --flavor staging -t lib/main_staging.dart

# Production
flutter run --flavor prod -t lib/main_prod.dart
```

## Ejecutar desde Xcode

1. Selecciona el scheme deseado (dev, staging, o prod) en la barra superior
2. Selecciona el simulador o dispositivo
3. Presiona **Cmd + R** para ejecutar

## Build para Distribución

```bash
# Development
flutter build ios --flavor dev -t lib/main_dev.dart

# Staging
flutter build ios --flavor staging -t lib/main_staging.dart

# Production
flutter build ios --flavor prod -t lib/main_prod.dart
```

## Troubleshooting

### Error: "Scheme not found"

Asegúrate de haber creado los schemes correctamente y que estén compartidos:
1. Manage Schemes
2. Marca la casilla "Shared" para cada scheme

### Error: "Bundle identifier mismatch"

Verifica que los bundle identifiers en Build Settings coincidan con los configurados.

### Los cambios no se reflejan

1. Cierra Xcode completamente
2. Ejecuta: `flutter clean`
3. Ejecuta: `cd ios && pod install && cd ..`
4. Vuelve a abrir Xcode

## Verificación Final

Para verificar que todo funciona:

```bash
# Listar los schemes disponibles
xcodebuild -list -workspace ios/Runner.xcworkspace

# Deberías ver: dev, staging, prod
```

## Notas Importantes

- ⚠️ Los schemes deben estar marcados como "Shared" para que funcionen con Flutter CLI
- 📱 Cada flavor puede instalarse simultáneamente en el mismo dispositivo (diferentes bundle IDs)
- 🔐 Para distribución, necesitarás certificados y provisioning profiles separados para cada bundle ID

## Próximos Pasos

Una vez configurado:
1. Prueba ejecutar cada flavor
2. Verifica que el nombre de la app sea correcto
3. Confirma que los colores sean diferentes (Verde/Naranja/Azul)

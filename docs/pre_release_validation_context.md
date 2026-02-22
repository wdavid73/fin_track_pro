# Pre-Release Validation CI/CD — Contexto de Implementación

## Problema que Originó Esta Solución

En producción se detectó que el **flavor `prod` de iOS estaba apuntando a la configuración de build `Release`** en lugar de `Release-prod`. Esto causó que el nombre visual de la app se mostrara como **"Runner"** (el nombre por defecto de Xcode) en lugar del nombre correcto de la aplicación.

Este tipo de error es silencioso: compila sin errores, pero llega a producción con configuración incorrecta. El objetivo de este sistema es detectar este y otros errores similares **antes** de que el código llegue a la rama de compilación/publicación en tiendas.

---

## Objetivo

Implementar un sistema de validaciones automáticas en CI/CD que se ejecute **antes de subir cambios a la rama de producción**, garantizando que:

- Los nombres visuales de la app sean correctos en Android e iOS.
- Los flavors apunten a las configuraciones de build correctas en Xcode.
- Las variables de entorno estén completas y sin valores placeholder.
- No haya secrets ni API keys hardcodeadas.
- Los tests pasen y el código compile correctamente.

---

## Arquitectura del Sistema

```
Repositorio Flutter
├── .github/
│   └── workflows/
│       └── pre_release_validation.yml   ← CI/CD GitHub Actions
├── tools/
│   └── validate_release_config.dart     ← Script de validación principal
├── .git/
│   └── hooks/
│       └── pre-commit                   ← Validación local antes de commit
├── Makefile                             ← Comandos rápidos de validación
└── RELEASE_CHECKLIST.md                 ← Checklist manual pre-release
```

---

## Archivos a Implementar

### 1. `tools/validate_release_config.dart`

Script Dart que centraliza todas las validaciones de configuración. Se puede invocar localmente o desde CI/CD.

**Qué valida:**

| Área         | Validación                                                                                                                                                                                                                                    |
| ------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Android      | `applicationId`, `versionCode`, `versionName`, `android:label` en `AndroidManifest.xml`                                                                                                                                                       |
| iOS          | `APP_DISPLAY_NAME` en User-Defined Settings del `project.pbxproj` por cada Build Configuration, que `Info.plist` referencie `$(APP_DISPLAY_NAME)` y no tenga el nombre hardcodeado, existencia de `Release-{flavor}` como Build Configuration |
| Entorno      | Existencia de `.env.{flavor}`, variables requeridas presentes, sin valores placeholder                                                                                                                                                        |
| Assets       | Existencia de íconos principales                                                                                                                                                                                                              |
| Dependencias | Sin dependencias con `path:` local (no aptas para producción)                                                                                                                                                                                 |

**Uso:**

```bash
dart run tools/validate_release_config.dart prod
dart run tools/validate_release_config.dart dev
```

**Requisitos en `pubspec.yaml`:**

```yaml
dev_dependencies:
  yaml: ^3.1.2
  xml: ^6.5.0
```

**Configuración por flavor** (definida dentro del script):

```dart
final configs = {
  'prod': {
    'android': {
      'packageName': 'com.tuempresa.tuapp',
      'appName': 'TuApp',
      'versionCode': 1,
      'versionName': '1.0.0',
    },
    'ios': {
      'bundleId': 'com.tuempresa.tuapp',
      'appName': 'TuApp',
    },
    'env': {
      'required': ['API_URL', 'API_KEY', 'ENVIRONMENT'],
    },
  },
};
```

> ⚠️ Actualizar estos valores con los datos reales de cada proyecto antes de usar.

---

### 2. `.github/workflows/pre_release_validation.yml`

Workflow de GitHub Actions compuesto por tres jobs independientes:

#### Job 1: `validate-configuration`

- Runner: `ubuntu-latest`
- Ejecuta `validate_release_config.dart prod`
- Compila APK y build iOS (sin signing) para detectar errores de compilación

#### Job 2: `validate-app-names`

- Runner: `macos-latest`
- Lee `android:label` del `AndroidManifest.xml` con `grep`/`sed`
- Verifica que `Release-prod` existe como Build Configuration en `project.pbxproj`
- Verifica que `APP_DISPLAY_NAME` está definido por cada Build Configuration en `project.pbxproj`
- Verifica que `Info.plist` referencia `$(APP_DISPLAY_NAME)` en `CFBundleDisplayName` y no tiene el nombre hardcodeado

#### Job 3: `security-check`

- Runner: `ubuntu-latest`
- Busca patrones de API keys hardcodeadas con `grep` en `lib/`
- Verifica existencia de `.env.prod`
- Detecta valores placeholder (`YOUR_API_KEY`, `CHANGE_ME`, `TODO`)

**Triggers del workflow:**

```yaml
on:
  pull_request:
    branches:
      - main
      - release/*
  push:
    branches:
      - release/*
```

---

### 3. `.git/hooks/pre-commit`

Hook local que se ejecuta automáticamente antes de cada `git commit`.

**Qué hace:**

- Bloquea el commit si se intentan subir archivos sensibles (`.env.prod`, `google-services.json`, `GoogleService-Info.plist`)
- Ejecuta `flutter analyze`

**Instalación:**

```bash
chmod +x .git/hooks/pre-commit
```

> ⚠️ Los hooks de Git **no se sincronizan con el repositorio** por defecto. Para compartirlos con el equipo, se puede usar un script de setup o herramientas como `lefthook` o `husky` (vía un wrapper).

---

### 4. `Makefile`

Comandos de conveniencia para ejecutar validaciones localmente sin recordar flags de Flutter.

| Comando                  | Descripción                                                   |
| ------------------------ | ------------------------------------------------------------- |
| `make validate-prod`     | Ejecuta el script de validación para el flavor `prod`         |
| `make validate-dev`      | Ejecuta el script de validación para el flavor `dev`          |
| `make pre-release-check` | Validación completa: config + analyze + build APK + build iOS |

---

### 5. `RELEASE_CHECKLIST.md`

Checklist manual como última línea de defensa antes de publicar en tiendas. Cubre:

- Configuración de flavors e iOS
- Package name / Bundle ID
- Versiones
- Variables de entorno
- Assets e íconos
- Tests y quality gates
- Seguridad
- Documentación y changelogs

---

## Relación con el Error Original

El error fue: `flavor prod → apuntaba a → Release` (debía apuntar a `Release-prod`).

Este sistema lo hubiese detectado en dos niveles:

1. **`validate_release_config.dart`** → verifica que el string `Release-prod` exista como Build Configuration en `project.pbxproj`.
2. **Job `validate-app-names` en CI** → verifica que `APP_DISPLAY_NAME` esté definido correctamente para `Release-prod` en `project.pbxproj`, y que `Info.plist` lo referencie vía `$(APP_DISPLAY_NAME)`. Si el flavor apunta a `Release` en lugar de `Release-prod`, el User-Defined Setting incorrecto se usa y el nombre resulta en "Runner".

---

## Flujo de Trabajo Recomendado

```
Desarrollo local
      │
      ▼
git commit  ──►  pre-commit hook  ──►  (analyze + bloqueo de archivos sensibles)
      │
      ▼
git push  ──►  PR hacia main/release/*
      │
      ▼
GitHub Actions CI
      ├── validate-configuration   (Dart script + build checks)
      ├── validate-app-names       (nombres reales en Android/iOS)
      └── security-check           (secrets + env vars)
      │
      ▼ (solo si los 3 jobs pasan)
Merge permitido
      │
      ▼
Revisión manual RELEASE_CHECKLIST.md
      │
      ▼
Build y publicación en tiendas
```

---

## Consideraciones de Mantenimiento

- **Actualizar `configs` en `validate_release_config.dart`** cada vez que cambie el `versionCode`, `versionName`, o `packageName`.
- **Agregar nuevas variables requeridas** en la sección `env.required` cuando se integren nuevos servicios.
- **El job `validate-app-names` requiere `macos-latest`** para poder leer el `project.pbxproj` con herramientas nativas de macOS. Considerar el costo adicional de minutos en GitHub Actions si el plan es limitado.
- Los archivos `.env.*` deben estar en `.gitignore` y sus valores reales deben estar en los **Secrets de GitHub Actions**.

---

## Variables de Entorno en GitHub Actions

Para que el job `security-check` y el build funcionen correctamente, agregar en **Settings → Secrets and variables → Actions**:

| Secret              | Descripción                                  |
| ------------------- | -------------------------------------------- |
| `ENV_PROD`          | Contenido completo del archivo `.env.prod`   |
| `KEYSTORE_FILE`     | Keystore de Android en base64 (para signing) |
| `KEYSTORE_PASSWORD` | Contraseña del keystore                      |
| `KEY_ALIAS`         | Alias de la key de Android                   |
| `KEY_PASSWORD`      | Contraseña de la key                         |

Y en el workflow, escribir el archivo antes de compilar:

```yaml
- name: Create .env.prod
  run: echo "${{ secrets.ENV_PROD }}" > .env.prod
```

---

_Documento generado como contexto de implementación para el sistema de validaciones pre-release en proyectos Flutter con flavors._

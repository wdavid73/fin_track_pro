# GitHub Actions CI/CD

Este proyecto utiliza GitHub Actions para automatizar pruebas y builds.

## Workflows

### CI Workflow (`.github/workflows/ci.yml`)

Se ejecuta automáticamente en:
- **Pull Requests** a la rama `develop`
- **Push** a la rama `develop`

#### Jobs

**1. Test Job:**
- ✅ Checkout del código
- ✅ Setup de Flutter 3.10.0
- ✅ Instalación de dependencias
- ✅ Verificación de formato (`dart format`)
- ✅ Análisis estático (`flutter analyze`)
- ✅ Ejecución de tests con coverage (`flutter test --coverage`)
- ✅ Upload de coverage a Codecov (opcional)

**2. Build Job:**
- ✅ Build de APK dev en modo debug
- ✅ Upload del APK como artifact (7 días de retención)

## Configuración Local

Para ejecutar las mismas verificaciones localmente:

```bash
# Formato
dart format --set-exit-if-changed .

# Análisis
flutter analyze

# Tests con coverage
flutter test --coverage

# Build APK dev
flutter build apk --flavor dev -t lib/main_dev.dart --debug
```

## Codecov (Opcional)

Para habilitar el reporte de coverage en Codecov:

1. Crear cuenta en [codecov.io](https://codecov.io)
2. Agregar el repositorio
3. Copiar el token
4. Agregar secret `CODECOV_TOKEN` en GitHub:
   - Settings → Secrets and variables → Actions → New repository secret

## Artifacts

Los APKs generados están disponibles en:
- GitHub Actions → Workflow run → Artifacts
- Retención: 7 días

## Status Badge

Agregar al README.md:

```markdown
![CI](https://github.com/TU_USUARIO/fin_track_pro/workflows/Flutter%20CI/badge.svg)
```

## Troubleshooting

**Error: Flutter version mismatch**
- Actualizar `flutter-version` en el workflow

**Error: Tests failing**
- Ejecutar `flutter test` localmente
- Verificar que todos los tests pasen antes del PR

**Error: Format check failing**
- Ejecutar `dart format .` localmente
- Commitear los cambios

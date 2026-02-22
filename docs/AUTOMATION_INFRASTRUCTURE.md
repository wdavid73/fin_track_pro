# 🤖 Automation & Testing Infrastructure

Esta guía describe el ecosistema de automatización avanzada de **FinTrack Pro**, diseñado para garantizar la estabilidad visual, funcional y el despliegue continuo (CD) de alta fidelidad.

---

## 🏗️ Resumen de la Infraestructura

| Herramienta | Capa | Propósito |
|---|---|---|
| **Patrol** | Integración / E2E | Pruebas de UI avanzadas con interacción nativa. |
| **Golden Toolkit** | Visual Regression | Garantía de consistencia visual pixel-perfect. |
| **Fastlane** | DevOps | Automatización de compilaciones, certificados y despliegue. |
| **Firebase App Dist.** | Distribución | Entrega automatizada de versiones beta a testers. |

---

## 🧪 1. Patrol (Integration Testing)

Utilizamos [Patrol](https://patrol.leancode.co/) en lugar de `integration_test` estándar porque permite interactuar con elementos nativos del sistema (permisos, cámara, notificaciones) y ofrece un API más robusto (`PatrolTester`).

### Estructura
- **Ubicación:** `integration_test/`
- **Driver:** `test_driver/patrol_integration_test.dart`
- **Tests:** `integration_test/smoke_test.dart`

### Flujo de Ejecución
```bash
patrol test --target integration_test/smoke_test.dart
```

---

## 🖼️ 2. Golden Tests (Visual Testing)

Utilizamos [Golden Toolkit](https://pub.dev/packages/golden_toolkit) para validar que la UI no sufra regresiones visuales accidentales. Esto es crítico al manejar temas dinámicos (Dark/Light Mode) e i18n.

### Estrategia
1. **Atómicos:** Golden tests para widgets individuales (`TransactionCard`, `BalanceCard`).
2. **Multi-Dispositivo:** Generación automática de capturas para diferentes tamaños de pantalla y densidades de píxeles.

### Comandos Clave
```bash
# Generar/Actualizar capturas base
fvm flutter test --update-goldens test/core/widgets/

# Validar contra los goldens existentes
fvm flutter test test/core/widgets/
```

---

## 🚀 3. Fastlane (Mobile DevOps)

Fastlane actúa como el motor de orquestación en `/android` e `/ios`.

### Responsabilidades
- **Certificados:** Automatiza el code signing mediante `match` (iOS) o gestión de keystore (Android).
- **Versioning:** Sincroniza el número de build con los commits de Git.
- **Capturas de pantalla:** Genera automáticamente capturas para la tienda (Snapshot/Frameit).

### Lanes Principales
- `lane :beta`: Compila y sube a Firebase App Distribution.
- `lane :release`: Prepara el binario para revisión en App Store / Play Store.

---

## 📦 4. Firebase App Distribution

Nuestro canal principal de distribución interna para testers de confianza y control de calidad (QA).

### Automatización
El despliegue se activa automáticamente vía **GitHub Actions** bajo dos condiciones:
1. Merge exitoso a `main`.
2. Push a una rama de tipo `release/*`.

### Configuración de Seguridad
Las llaves de API y tokens de distribución residen en **GitHub Secrets** (`FIREBASE_APP_DIST_TOKEN`), asegurando que solo el CI pueda realizar despliegues automáticos.

---

## ☁️ 5. Integración en CI/CD

El pipeline de GitHub Actions (`.github/workflows/cd.yml`) orquestará estas herramientas en fases:

1. **Phasor 1: Quality Gate** (Lints + Unit/Widget Tests).
2. **Phase 2: Visual Validation** (Golden Tests).
3. **Phase 3: Integration** (Patrol Tests en CI o Cloud Devices).
4. **Phase 4: Distribute** (Fastlane → Firebase).

---

## 📖 Guía para Desarrolladores

Para trabajar con esta infraestructura localmente, asegúrate de tener instalado:
- **Patrol CLI:** `dart pub global activate patrol_cli`
- **Fastlane:** `gem install fastlane` o mediante Homebrew en macOS.
- **Bundler:** Para gestionar las dependencias de Ruby en las carpetas nativas.

> **Tip:** Antes de hacer un commit que modifique la UI, corre siempre los Golden Tests para evitar romper el CI de regresión visual.

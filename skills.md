---
name: fintrack-feature-dev
description: Desarrolla y valida una nueva feature en FinTrack Pro siguiendo Clean Architecture y BLoC.
---

## FinTrack Feature Execution: Clean Architecture & BLoC

**Objective:** Implementar un requerimiento asegurando la separación de capas (Domain, Data, Presentation), escribiendo pruebas y verificando el estado del proyecto.

**Instructions:**
1. **Scaffolding (Planificación):**
   * Analiza el requerimiento.
   * Crea las carpetas necesarias bajo `lib/features/<feature_name>/` con las subcarpetas `domain/`, `data/`, y `presentation/`.
   * Detente y genera un "Implementation Plan" breve detallando las Entidades, Repositorios (con Hive) y BLoCs que vas a crear.

2. **Domain Layer First:**
   * Escribe las Entidades y los contratos (Interfaces/Abstract classes) de los Repositorios.
   * Escribe los Casos de Uso (Use Cases).

3. **Data Layer (Hive Integration):**
   * Implementa los Repositorios y Data Sources usando `Hive`.
   * Genera o actualiza los `TypeAdapters` si el modelo de datos cambió.
   * Ejecuta `dart run build_runner build --delete-conflicting-outputs` si se requiere generación de código.

4. **Presentation Layer & State Management:**
   * Implementa el `BLoC` manejando estados complejos (Loading, Success, Error).
   * Escribe la UI utilizando Material Design 3.
   * Utiliza inyección de dependencias para conectar la UI con el BLoC.

5. **Verification & Cleanup:**
   * Ejecuta `flutter analyze` para verificar el linter.
   * Ejecuta `flutter test` en los BLoCs y Casos de Uso asociados. Repara cualquier fallo.
   * Revisa que no queden `print` o imports sin utilizar.
   * Informa al usuario: "Feature completada. Análisis limpio y pruebas pasando."
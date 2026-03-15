# Plan de Mejoras UI/UX — FinTrack Pro
> Basado en análisis de referencia visual (@imcharli.e) · Marzo 2026

---

## Resumen Ejecutivo

| Métrica | Valor |
|---|---|
| Mejoras totales | 8 componentes |
| Esfuerzo estimado | ~32 horas |
| Fases de entrega | 3 fases |
| Weekends requeridos | ~8 weekends |

**Stack necesario:** Todo el trabajo usa paquetes ya instalados (`animate_do`, `fl_chart`, `animations`). No se requieren dependencias nuevas para Fase 1 y Fase 2.

---

## Referencia Visual

La app analizada es de **@imcharli.e** en TikTok — fintech personal colombiana con pesos COP, nivel de polish muy alto. Las 3 features más impactantes:

1. **Contador animado del balance** → mayor impacto visual, menor esfuerzo
2. **Bar chart con tooltip flotante** → la pieza más impresionante para el portafolio
3. **Emojis en categorías** → calidez visual inmediata, reemplaza Material Icons outlined

---

## Fase 1 — Impacto Inmediato
> ~8 horas · 2 weekends

### 1.1 `AnimatedBalanceWidget` — Contador animado

**Descripción:** El balance principal anima los dígitos contando desde 0 hasta el número real cada vez que carga la pantalla. Tipografía 52px Bold. El efecto más llamativo del video con el menor esfuerzo de implementación.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐⭐⭐ Alto |
| Esfuerzo | ~2 horas |
| Paquetes | `animate_do`, `TweenAnimationBuilder` |
| Tipografía | Poppins 52px, Bold |

**Comportamiento esperado:**
- Al cargar `HomePage`, el balance inicia en `$0` y cuenta hasta el valor real en ~800ms
- Curva de animación: `Curves.easeOutExpo` para sensación de "peso"
- Los decimales aparecen al final con `FadeIn` separado
- Se re-ejecuta al hacer pull-to-refresh

---

### 1.2 Income / Expense Pills — Chips debajo del balance

**Descripción:** Dos pills con colores semánticos debajo del balance: verde para ingresos (`+$3.000.000`) y rojo para gastos (`-$706.521`). Aparecen con `FadeIn` después de que termina el contador. Reemplazan el texto plano actual.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐⭐ Alto |
| Esfuerzo | ~1 hora |
| Paquetes | `animate_do FadeIn` |
| Colores | `secondaryColor` (#34A853) · `errorColor` (#EA4335) |

**Comportamiento esperado:**
- Pill rojo: ícono `↓` + monto de gastos del periodo actual
- Pill verde: ícono `↑` + monto de ingresos del periodo actual
- Delay de 600ms después del contador para aparecer en secuencia
- Tipografía `bodySmall` · fondo con opacidad 15% del color semántico

---

### 1.3 `CategoryEmojiHelper` — Emojis en categorías

**Descripción:** El video usa emojis nativos del sistema (🍔 🚗 🛒 🐾) en lugar de iconos `outlined`. Dan calidez y personalidad visual inmediata. Migrar a `CategoryEmojiHelper` para complementar el `IconHelper` existente — no reemplazarlo, coexistir.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐ Medio-Alto |
| Esfuerzo | ~1 hora |
| Paquetes | Ninguno (emojis nativos vía `Text` widget) |
| Archivo | `lib/core/utils/category_emoji_helper.dart` |

**Mapping de emojis a implementar:**

| Categoría | Emoji | Icono actual |
|---|---|---|
| Alimentación | 🍔 | `restaurant_outlined` |
| Transporte | 🚗 | `directions_car_outlined` |
| Hogar | 🏠 | `home_outlined` |
| Compras | 🛍️ | `shopping_bag_outlined` |
| Entretenimiento | 🎬 | `movie_outlined` |
| Educación | 📚 | `school_outlined` |
| Salud | 💊 | `local_hospital_outlined` |
| Mascotas | 🐾 | — |
| Mercado | 🥑 | — |
| Ropa | 👔 | — |
| Salario | 💼 | `work_outlined` |
| Inversiones | 📈 | `trending_up` |

---

## Fase 2 — El Componente Estrella
> ~16 horas · 4 weekends

### 2.1 `CategoryBarChart` con tooltip flotante

**Descripción:** El componente más impactante del video y el más valioso para el portafolio. Gráfico de barras scrollable por categoría. Al tocar una barra aparece un tooltip tipo card con: emoji grande, monto del gasto, y porcentaje del presupuesto. Las barras no seleccionadas reducen su opacidad al 30%.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐⭐⭐ Máximo |
| Esfuerzo | ~6 horas |
| Paquetes | `fl_chart` (`BarChart`, `barTouchData`) |
| Archivo | `lib/features/analytics/presentation/widgets/category_bar_chart.dart` |

**Comportamiento esperado:**
- Barras scrollables horizontalmente (5-6 visibles a la vez)
- Cada barra tiene el emoji de la categoría debajo
- Altura de barra proporcional al gasto vs presupuesto
- Al tocar: tooltip flotante con `emoji (48px) + monto + porcentaje`
- Barras no seleccionadas: `AnimatedOpacity` → 30%
- Barra seleccionada: borde resaltado + tooltip
- Animación de entrada al cargar: barras crecen desde 0 (`BarChartRodData` con `toY` animado)

**Estructura del tooltip:**
```
┌─────────────────┐
│       🐾        │
│    $125.000     │
│      42%        │
└─────────────────┘
```

---

### 2.2 `BudgetModalSheet` — Stacked bottom sheets

**Descripción:** Pantalla de Presupuestos implementada como modal sheet (no navegación push). Al tocar una categoría de la lista, abre un segundo sheet encima del primero con el detalle de esa categoría y un selector de color circular. Patrón stacked/nested bottom sheets.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐⭐ Alto |
| Esfuerzo | ~5 horas |
| Paquetes | `showModalBottomSheet` (Flutter nativo) |
| Archivos | `budget_modal_sheet.dart` · `budget_category_detail_sheet.dart` |

**Estructura del primer sheet:**
- Título "Presupuestos" + botón X para cerrar
- Toggle switch: "Alertas de presupuesto"
- Sección "Recomendaciones": categorías de gastos frecuentes
- Sección "Otras": resto de categorías
- Cada item: `emoji + nombre + chevron >`

**Estructura del segundo sheet (detalle):**
- Emoji de categoría grande (64px) centrado
- Nombre de la categoría
- Selector de color: fila de círculos de colores (`ColorOption` widget)
- Campo de monto límite con `MoneyInputFormatter` ya existente
- Botón "Guardar" → `AppSnackbar().success()`

---

### 2.3 Hero animations en `TransactionCard`

**Descripción:** El emoji/ícono de categoría en la lista de transacciones hace Hero hasta la pantalla de detalle. Transición fluida que conecta ambas pantallas visualmente. Tu documentación ya menciona el patrón pero sin implementación completa de los tags.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐ Medio-Alto |
| Esfuerzo | ~3 horas |
| Paquetes | `Hero` widget (Flutter nativo) |
| Tag pattern | `'transaction-category-${transaction.id}'` |

**Comportamiento esperado:**
- En `TransactionCard` (lista): emoji envuelto en `Hero(tag: 'transaction-category-${id}')`
- En `TransactionDetailPage`: mismo emoji con el mismo tag en tamaño 64px
- La transición anima el tamaño y posición automáticamente
- Combinado con `SharedAxisTransition.horizontal` para el resto del contenido

---

## Fase 3 — Polish Final
> ~8 horas · 2 weekends

### 3.1 FAB con micrófono + morphing animation

**Descripción:** El FAB cambia a ícono de micrófono como preview visual del feature Speech-to-Text (ya en el roadmap Phase 4). Morphing animado entre `mic` y `add`. Color coral/salmon (`#E8593C`) para diferenciarlo del color primario. Botón `+` secundario outline en esquina inferior izquierda.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐ Medio |
| Esfuerzo | ~2 horas |
| Paquetes | `AnimatedSwitcher`, `ScaleTransition`, `OpenContainer` |
| Color FAB | `#E8593C` (coral) |

**Comportamiento esperado:**
- FAB principal: ícono `mic` con color coral
- Al tocar: morphing a `add` con `AnimatedSwitcher + ScaleTransition`
- `OpenContainer` con `fadeThrough` al abrir `AddTransactionPage`
- Botón secundario `+` en bottom-left: outline, sin fill, tamaño 40px
- Bottom bar: sin labels, solo íconos (style minimalista como el video)

---

### 3.2 Transiciones de página premium — Spring curves

**Descripción:** Reemplazar las curvas de animación estándar (`easeInOut`) con spring physics en todas las transiciones de la app. Mejorar `FadeIndexedStack` con `PageTransitionSwitcher` y `FadeThroughTransition` del package `animations`.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐⭐ Medio |
| Esfuerzo | ~2 horas |
| Paquetes | `animations` (ya instalado) |
| Archivos | `fade_indexed_stack.dart`, `app_router.dart` |

**Cambios específicos:**

| Ruta / Componente | Antes | Después |
|---|---|---|
| Tabs principales | `FadeIndexedStack` 300ms | `PageTransitionSwitcher` + `FadeThroughTransition` |
| `/home/transactions` | `SharedAxisTransition` default | `SharedAxisTransition` + spring curve 350ms |
| Modales (forms) | Bottom sheet default | `DraggableScrollableSheet` con spring physics |
| FAB → AddTransaction | `OpenContainer` 400ms | `OpenContainer` 350ms + `Curves.fastLinearToSlowEaseIn` |
| Animaciones generales | `Curves.easeInOut` | `Curves.easeOutExpo` / `SpringSimulation` |

---

### 3.3 Skeleton loaders específicos por componente

**Descripción:** Skeletons que replican exactamente la forma visual de cada componente nuevo. La experiencia de carga debe verse tan buena como la app en estado normal. Usa el `ShimmerWrapper` y `Skeleton` existentes en tu design system.

| Atributo | Detalle |
|---|---|
| Impacto visual | ⭐⭐ Medio-Bajo |
| Esfuerzo | ~2 horas |
| Paquetes | `Skeletonizer`, `shimmer_wrapper.dart` (ya existentes) |

**Nuevos skeletons a crear:**

| Widget | Descripción |
|---|---|
| `SkeletonBalanceHeader` | Número grande 52px + dos pills debajo |
| `SkeletonCategoryBarChart` | 5-6 barras de altura variable + círculos de emoji debajo |
| `SkeletonBudgetList` | 4-5 items con ícono + línea de texto + chevron |

---

## Matriz de Priorización

| # | Componente | Impacto | Esfuerzo | Fase | Prioridad |
|---|---|---|---|---|---|
| 1 | `AnimatedBalanceWidget` | ⭐⭐⭐⭐⭐ | 2h | 1 | 🔴 Inmediata |
| 2 | Income/Expense Pills | ⭐⭐⭐⭐ | 1h | 1 | 🔴 Inmediata |
| 3 | `CategoryEmojiHelper` | ⭐⭐⭐ | 1h | 1 | 🔴 Inmediata |
| 4 | `CategoryBarChart` + tooltip | ⭐⭐⭐⭐⭐ | 6h | 2 | 🟡 Alta |
| 5 | `BudgetModalSheet` | ⭐⭐⭐⭐ | 5h | 2 | 🟡 Alta |
| 6 | Hero animations | ⭐⭐⭐ | 3h | 2 | 🟡 Media-Alta |
| 7 | FAB mic + morphing | ⭐⭐⭐ | 2h | 3 | 🟢 Media |
| 8 | Spring curves | ⭐⭐⭐ | 2h | 3 | 🟢 Media |
| 9 | Skeleton loaders | ⭐⭐ | 2h | 3 | 🟢 Baja |

---

## Principios de Implementación

1. **Fase 1 primero, siempre.** El contador + pills + emojis dan el 60% del impacto visual en ~4 horas reales. No saltar a Fase 2 sin tener Fase 1 estable.

2. **No romper los tests existentes.** Cada componente nuevo necesita su golden test antes de considerarse completo. Target: 80%+ coverage mantenido.

3. **Coexistir, no reemplazar.** `CategoryEmojiHelper` convive con `IconHelper`. Las animaciones nuevas respetan `AnimatedContainer` existentes. Refactor incremental.

4. **Respetar el design system.** Todos los colores nuevos usan `ColorTheme.*`. Todos los espaciados usan `Sizes.*`. Ningún valor hardcoded.

5. **El `CategoryBarChart` es el item de portafolio.** Dedicarle el tiempo necesario — es el componente que más diferencia a FinTrack Pro de una app genérica de Flutter.

---

## Alineación con el Roadmap Existente

| Mejora | Fase del Roadmap | Notas |
|---|---|---|
| AnimatedBalanceWidget | Phase 1 (actual) | Se puede hacer ya, no bloquea CI/CD |
| Pills + Emojis | Phase 1 (actual) | Widgets puros, fáciles de testear con golden tests |
| CategoryBarChart | Phase 1-2 | Encaja en la feature Analytics ya existente |
| BudgetModalSheet | Phase 2 | Se beneficia de Firebase para persistir presupuestos |
| Hero animations | Phase 1-2 | Sin dependencias externas |
| FAB micrófono | Phase 4 | Preview visual del STT planeado — no bloquea |
| Spring curves | Phase 1 | Mejora global, bajo riesgo |
| Skeleton loaders | Phase 1 | Complementa la infraestructura de testing |

---

*Generado con base en análisis de video de referencia (@imcharli.e) y `UI_UX_DOCUMENTATION.md` de FinTrack Pro · Marzo 2026*

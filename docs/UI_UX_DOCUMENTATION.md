# Documentacion UI/UX - FinTrack Pro

Este documento describe en detalle todos los aspectos de UI/UX implementados en la aplicacion FinTrack Pro, incluyendo el sistema de diseno, componentes, patrones de navegacion y mejores practicas aplicadas.

## Tabla de Contenidos

1. [Sistema de Temas](#1-sistema-de-temas)
2. [Sistema de Colores](#2-sistema-de-colores)
3. [Sistema Tipografico](#3-sistema-tipográfico)
4. [Sistema de Espaciado y Dimensiones](#4-sistema-de-espaciado-y-dimensiones)
5. [Componentes Core Reutilizables](#5-componentes-core-reutilizables)
6. [Temas de Componentes Material](#6-temas-de-componentes-material)
7. [Sistema de Navegacion](#7-sistema-de-navegación)
8. [Animaciones y Transiciones](#8-animaciones-y-transiciones)
9. [Diseno Responsivo](#9-diseño-responsivo)
10. [Componentes por Feature](#10-componentes-por-feature)
11. [Patrones de Formularios](#11-patrones-de-formularios)
12. [Sistema de Iconos](#12-sistema-de-iconos)
13. [Accesibilidad](#13-accesibilidad)
14. [Mejores Practicas](#14-mejores-prácticas)

---

## 1. Sistema de Temas

### Arquitectura

El sistema de temas sigue el patron de Material Design 3 con soporte completo para modo claro y oscuro.

```
lib/theme/
├── app_theme.dart              # Punto de entrada principal
├── light_theme.dart            # Configuracion tema claro
├── dark_theme.dart             # Configuracion tema oscuro
├── theme_constants.dart        # Constantes globales
├── custom/                     # Temas de componentes individuales
│   ├── appbar_theme.dart
│   ├── bottom_navigation_bar_theme.dart
│   ├── bottom_sheet_theme.dart
│   ├── card_theme.dart
│   ├── checkbox_theme.dart
│   ├── chip_theme.dart
│   ├── elevated_button_theme.dart
│   ├── outlined_button_theme.dart
│   ├── snackbar_theme.dart
│   ├── text_button_theme.dart
│   ├── text_field_theme.dart
│   └── text_theme.dart
└── utils/
    ├── color_theme.dart        # Paleta de colores
    ├── sizes.dart              # Sistema de dimensiones
    └── resposive.dart          # Utilidades responsivas
```

### Uso del Tema

```dart
// Obtener tema claro/oscuro
AppTheme.getLightTheme(context)
AppTheme.getDarkTheme(context)

// En MaterialApp
MaterialApp(
  theme: AppTheme.getLightTheme(context),
  darkTheme: AppTheme.getDarkTheme(context),
  themeMode: ThemeMode.system, // o light/dark
)
```

### Cambio de Tema

El cambio de tema se gestiona a traves del `SettingsBloc` ubicado en:
- `lib/features/settings/presentation/bloc/settings_bloc.dart`
- `lib/features/settings/presentation/widgets/theme_option_bottom_sheet.dart`

---

## 2. Sistema de Colores

### Ubicacion
`lib/theme/utils/color_theme.dart`

### Paleta Principal

| Color | Hex | Uso |
|-------|-----|-----|
| Primary | `#4285F4` | Acciones principales, enlaces, elementos destacados |
| Secondary | `#34A853` | Ingresos, exito, confirmaciones |
| Tertiary | `#FBBC05` | Advertencias, elementos destacados secundarios |
| Error | `#EA4335` | Gastos, errores, acciones destructivas |

### Colores de Superficie

| Color | Hex | Uso |
|-------|-----|-----|
| Surface (Light) | `#F1F3F4` | Fondo de contenedores |
| Surface (Dark) | `#121212` | Fondo en modo oscuro |
| Light Background | `#F6F6F6` | Fondo de AppBar en modo claro |
| Dark Background | `#272727` | Fondo de cards en modo oscuro |

### Colores de Texto

| Color | Hex | Uso |
|-------|-----|-----|
| Text Primary | `#202124` | Texto principal en modo claro |
| Text Secondary | `#757575` | Texto secundario, placeholders |
| Text White | `#FFFFFF` | Texto sobre fondos oscuros |
| Light | `#F6F6F6` | Texto principal en modo oscuro |

### Colores On (para contenido sobre colores principales)

| Color | Hex | Uso |
|-------|-----|-----|
| On Primary | `#EAF1FC` | Contenido sobre Primary |
| On Secondary | `#E6F4EA` | Contenido sobre Secondary |
| On Tertiary | `#FEF3D9` | Contenido sobre Tertiary |
| On Error | `#FCE8E6` | Contenido sobre Error |

### Bordes

| Color | Hex | Uso |
|-------|-----|-----|
| Border Default | `#DADCE0` | Bordes de campos, cards |
| Border Primary | `#4285F4` | Bordes con estado focus/seleccion |

### Escala de Grises

| Color | Hex | Uso |
|-------|-----|-----|
| Grey | `#DADCE0` | Bordes, divisores |
| Dark Grey | `#939393` | Iconos deshabilitados |
| Darker Grey | `#4F4F4F` | Texto terciario |
| Button Disabled | `#C4C4C4` | Botones deshabilitados |

### Convencion Semantica de Colores

```dart
// En transacciones
Color incomeColor = ColorTheme.secondaryColor;  // Verde (#34A853)
Color expenseColor = ColorTheme.errorColor;      // Rojo (#EA4335)

// En balance
Color positiveBalance = ColorTheme.secondaryColor;  // Verde
Color negativeBalance = ColorTheme.errorColor;       // Rojo
```

---

## 3. Sistema Tipografico

### Ubicacion
`lib/theme/custom/text_theme.dart`

### Familia Tipografica
**Poppins** - Tipografia sans-serif moderna con excelente legibilidad.

### Escala Tipografica (Material Design 3)

| Estilo | Tamano | Peso | Uso |
|--------|--------|------|-----|
| `headlineLarge` | 32px | Bold (700) | Titulos de pantalla principales |
| `headlineMedium` | 24px | SemiBold (600) | Subtitulos importantes, montos grandes |
| `headlineSmall` | 18px | SemiBold (600) | Titulos de secciones |
| `titleLarge` | 16px | SemiBold (600) | Titulos de cards |
| `titleMedium` | 16px | Medium (500) | Titulos secundarios |
| `titleSmall` | 16px | Regular (400) | Titulos menores |
| `bodyLarge` | 14px | Medium (500) | Texto de cuerpo enfatizado |
| `bodyMedium` | 14px | Regular (400) | Texto de cuerpo principal |
| `bodySmall` | 14px | Medium (500) | Texto de cuerpo secundario (50% opacidad) |
| `labelLarge` | 12px | Regular (400) | Etiquetas, badges |
| `labelMedium` | 12px | Regular (400) | Etiquetas secundarias (50% opacidad) |

### Uso en Codigo

```dart
// Acceso via extension
Text(
  'Titulo',
  style: context.textTheme.headlineMedium,
)

// Con modificaciones
Text(
  'Balance',
  style: context.textTheme.headlineMedium?.copyWith(
    fontWeight: FontWeight.bold,
    color: context.colorScheme.onSurface,
  ),
)
```

### Adaptacion por Tema

Los estilos se adaptan automaticamente segun el tema:
- **Modo Claro**: Texto en `ColorTheme.dark` (#272727)
- **Modo Oscuro**: Texto en `ColorTheme.light` (#F6F6F6)

---

## 4. Sistema de Espaciado y Dimensiones

### Ubicacion
`lib/theme/utils/sizes.dart`

### Escala de Iconos

| Constante | Valor | Uso |
|-----------|-------|-----|
| `iconXs` | 12px | Iconos muy pequenos |
| `iconSm` | 16px | Iconos pequenos, badges |
| `iconMd` | 24px | Iconos estandar |
| `iconLg` | 32px | Iconos grandes |

### Escala de Espaciado

| Constante | Valor | Uso |
|-----------|-------|-----|
| `xs` | 4px | Micro espacios |
| `sm` | 8px | Espacios pequenos |
| `md` | 16px | Espacios estandar |
| `lg` | 24px | Espacios grandes |
| `xl` | 32px | Espacios extra grandes |

### Dimensiones de Botones

| Constante | Valor | Uso |
|-----------|-------|-----|
| `buttonHeight` | 18px | Padding vertical |
| `buttonRadius` | 12px | Border radius |
| `buttonWidth` | 120px | Ancho minimo |
| `buttonElevation` | 4px | Elevacion (no usado actualmente) |

### Dimensiones de Campos de Entrada

| Constante | Valor | Uso |
|-----------|-------|-----|
| `inputFieldRadius` | 12px | Border radius |
| `spaceBtwInputFields` | 16px | Espacio entre campos |

### Border Radius

| Constante | Valor | Uso |
|-----------|-------|-----|
| `borderRadiusSm` | 4px | Esquinas ligeramente redondeadas |
| `borderRadiusMd` | 8px | Esquinas moderadamente redondeadas |
| `borderRadiusLg` | 12px | Esquinas muy redondeadas |

### Tamanos de Fuente

| Constante | Valor | Uso |
|-----------|-------|-----|
| `fontSizeXs` | 12px | Texto muy pequeno |
| `fontSizeSm` | 14px | Texto pequeno |
| `fontSizeMd` | 16px | Texto estandar |
| `fontSizeLg` | 18px | Texto grande |

### Otras Dimensiones

| Constante | Valor | Uso |
|-----------|-------|-----|
| `appBarHeight` | 56px | Altura del AppBar |

---

## 5. Componentes Core Reutilizables

### Ubicacion
`lib/core/widgets/`

### 5.1 AppSnackbar

**Archivo**: `app_snack_bar.dart`

Sistema singleton para mostrar mensajes de feedback al usuario.

```dart
// Inicializacion (en MaterialApp)
final messengerKey = GlobalKey<ScaffoldMessengerState>();
AppSnackbar().init(messengerKey);

// Uso
AppSnackbar().show(context, 'Mensaje');
AppSnackbar().success(context, 'Operacion exitosa');
AppSnackbar().error(context, 'Ha ocurrido un error');
AppSnackbar().warning(context, 'Advertencia');
AppSnackbar().custom(
  context: context,
  message: 'Mensaje personalizado',
  background: Colors.purple,
  textColor: Colors.white,
);
```

**Caracteristicas**:
- Comportamiento floating
- Auto-limpieza de snackbars anteriores
- Duracion configurable (default: 3 segundos)
- Colores semanticos por tipo

### 5.2 Skeleton (Loading Placeholders)

**Archivo**: `skeleton.dart`

Componentes para estados de carga con efecto skeleton.

```dart
// Skeleton basico
Skeleton(width: 100, height: 20)

// Skeleton circular (avatares)
Skeleton.circle(size: 48)
SkeletonAvatar(size: 48)

// Skeleton cuadrado
Skeleton.square(size: 60, borderRadius: 12)

// Skeleton de texto multilinea
SkeletonText(width: 200, lines: 3)
```

**Caracteristicas**:
- Color adaptativo al tema (`surfaceContainerHighest`)
- Soporte para formas: rectangulo, circulo, cuadrado
- Texto multilinea con ultima linea al 70%
- Border radius configurable

### 5.3 DonutChart

**Archivo**: `donut_chart.dart`

Grafico de dona para visualizar presupuestos y gastos por categoria.

```dart
DonutChart(
  totalSpent: 1500.0,
  totalBudget: 3000.0,
  segments: [
    DonutSegment(value: 500, color: Colors.blue),
    DonutSegment(value: 300, color: Colors.red),
    DonutSegment(value: 700, color: Colors.green),
  ],
  size: 160, // Tamano en pixeles
)
```

**Caracteristicas**:
- Basado en `fl_chart`
- Centro con texto mostrando total gastado
- Espacio entre segmentos de 3px
- Formato de moneda localizado
- Tamano configurable

### 5.4 BudgetCategoryItem

**Archivo**: `budget_category_item.dart`

Widget para mostrar una categoria con su presupuesto.

```dart
BudgetCategoryItem(
  color: Colors.blue,
  name: 'Alimentacion',
  spent: 500.0,
  budget: 1000.0,
)
```

### 5.5 ShimmerWrapper

**Archivo**: `shimmer_wrapper.dart`

Efecto shimmer para estados de carga.

```dart
// Uso via extension
Skeleton(width: 100, height: 20).shimmer(isLoading: true)
```

### 5.6 MoneyInputFormatter

**Archivo**: `formatters/money_input_formatter.dart`

Formateador de entrada para campos de moneda.

```dart
TextField(
  inputFormatters: [MoneyInputFormatter()],
)
// "1000" -> "1.000"
// "1000000" -> "1.000.000"
```

**Caracteristicas**:
- Agrega separadores de miles (puntos)
- Mantiene posicion del cursor
- Solo permite digitos

---

## 6. Temas de Componentes Material

### 6.1 AppBar Theme

**Archivo**: `lib/theme/custom/appbar_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Elevation | 0 | 0 |
| Background | `#F6F6F6` | Transparent |
| Icon Color | Black | White |
| Icon Size | 24px | 24px |
| Center Title | false | false |

### 6.2 Bottom Navigation Bar Theme

**Archivo**: `lib/theme/custom/bottom_navigation_bar_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Type | Fixed | Fixed |
| Selected Color | Primary | Primary |
| Unselected Color | Dark Grey | Dark Grey |
| Background | White | Dark (#272727) |

### 6.3 Bottom Sheet Theme

**Archivo**: `lib/theme/custom/bottom_sheet_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Background | White | Dark (#272727) |
| Show Drag Handle | true | true |
| Shape | Rounded top 16px | Rounded top 16px |

### 6.4 Card Theme

**Archivo**: `lib/theme/custom/card_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Elevation | 0 | 0 |
| Background | White | Dark Surface (#202124) |
| Border | 1px `#DADCE0` | 1px white12 |
| Border Radius | 24px | 24px |

### 6.5 Elevated Button Theme

**Archivo**: `lib/theme/custom/elevated_button_theme.dart`

| Propiedad | Valor |
|-----------|-------|
| Background | Primary Color |
| Foreground | White |
| Elevation | 0 |
| Border Radius | 12px |
| Padding | 18px vertical |
| Disabled Background | Grey |
| Disabled Foreground | Dark Grey |

### 6.6 Outlined Button Theme

**Archivo**: `lib/theme/custom/outlined_button_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Border | 1px Primary | 1px Primary |
| Foreground | Dark | Light |
| Border Radius | 12px | 12px |
| Padding | 18px vertical | 18px vertical |

### 6.7 Text Button Theme

**Archivo**: `lib/theme/custom/text_button_theme.dart`

| Propiedad | Valor |
|-----------|-------|
| Foreground | Secondary Grey |
| Padding | 16px vertical |

### 6.8 TextField Theme

**Archivo**: `lib/theme/custom/text_field_theme.dart`

**Estados de borde (Modo Claro)**:
| Estado | Borde |
|--------|-------|
| Enabled | 1px Grey |
| Focused | 1px Dark |
| Error | 1px Red |
| Focused Error | 2px Red |

**Estados de borde (Modo Oscuro)**:
| Estado | Borde |
|--------|-------|
| Enabled | 1px Dark Grey |
| Focused | 1px White |
| Error | 1px Red |
| Focused Error | 2px Red |

**Propiedades comunes**:
- Border Radius: 12px
- Error Max Lines: 3 (light) / 2 (dark)

### 6.9 Checkbox Theme

**Archivo**: `lib/theme/custom/checkbox_theme.dart`

| Propiedad | Valor |
|-----------|-------|
| Border Radius | 4px |
| Check Color | White |
| Fill (selected) | Primary |
| Fill (unselected) | Transparent |

### 6.10 Chip Theme

**Archivo**: `lib/theme/custom/chip_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Padding | 12px | 12px |
| Disabled | Grey | Darker Grey |
| Selected | Primary | Primary |
| Checkmark | White | White |

### 6.11 Snackbar Theme

**Archivo**: `lib/theme/custom/snackbar_theme.dart`

| Propiedad | Modo Claro | Modo Oscuro |
|-----------|------------|-------------|
| Background | Surface (#F1F3F4) | Dark (#272727) |
| Behavior | Floating | Floating |
| Border Radius | 12px | 12px |
| Inset Padding | 8px | 8px |

---

## 7. Sistema de Navegacion

### Ubicacion
`lib/config/router/`

### Arquitectura

El sistema de navegacion utiliza **go_router** con las siguientes caracteristicas:

```
/splash                    -> SplashPage
/                          -> StatefulShellRoute (BottomNavigationBar)
  /home                    -> HomePage
    /home/transactions     -> AllTransactionsPage
  /analytics               -> AnalyticsPage
  /categories              -> CategoriesPage
  /settings                -> SettingsPage
```

### Componentes Principales

#### app_router.dart
- `createAppRouter()`: Crea la instancia de GoRouter
- `AppRoutes.getAppRoutes()`: Define todas las rutas
- `ScaffoldWithNavBar`: Shell con BottomNavigationBar

#### routes.dart
Constantes de rutas:
```dart
class RouteConstants {
  static const splash = '/splash';
  static const home = '/';
  static const analytics = '/analytics';
  static const categories = '/categories';
  static const settings = '/settings';
}
```

#### fade_indexed_stack.dart
Widget personalizado para transiciones suaves entre pestanas.

### Bottom Navigation Bar

```dart
BottomNavigationBar(
  type: BottomNavigationBarType.fixed,
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      activeIcon: Icon(Icons.home),
      label: 'Home',
    ),
    // ... analytics, categories, settings
  ],
)
```

**Patrones de iconos**:
- Estado inactivo: `Icons.*_outlined`
- Estado activo: `Icons.*` (filled)

### Transiciones de Pagina

| Ruta | Transicion | Duracion |
|------|------------|----------|
| Pestanas principales | Fade (FadeIndexedStack) | 300ms |
| /home/transactions | SharedAxisTransition horizontal | Default |
| Modales (forms) | Bottom sheet slide | Default |
| FAB -> AddTransaction | OpenContainer fadeThrough | 400ms |

---

## 8. Animaciones y Transiciones

### Librerias Utilizadas

1. **animate_do**: Animaciones predefinidas
2. **animations**: Transiciones de Material Design
3. **fl_chart**: Animaciones de graficos (built-in)

### Animaciones de Entrada

| Animacion | Uso | Ubicacion |
|-----------|-----|-----------|
| `FlipInX` | Logo wallet en Home | HomePage header |
| `ZoomIn` | Avatar de usuario | HomePage header |
| `BounceInLeft` | Cards de categoria | CategoriesPage |
| `fadeIn()` | Secciones del home | HomePage sections |

### Transiciones de Estado

```dart
// Toggle animado
AnimatedContainer(
  duration: Duration(milliseconds: 200),
  decoration: BoxDecoration(
    color: isSelected ? Colors.blue : Colors.grey,
  ),
)

// Texto con transicion
AnimatedDefaultTextStyle(
  duration: Duration(milliseconds: 200),
  style: isActive ? activeStyle : inactiveStyle,
  child: Text('Label'),
)

// Opacidad de pagina
AnimatedOpacity(
  duration: Duration(milliseconds: 300),
  opacity: isVisible ? 1.0 : 0.0,
  child: page,
)

// Indicador deslizante
AnimatedAlign(
  duration: Duration(milliseconds: 250),
  alignment: Alignment(alignmentX, 0),
  child: indicator,
)
```

### Transiciones de Navegacion

```dart
// FAB con expansion
OpenContainer(
  transitionType: ContainerTransitionType.fadeThrough,
  transitionDuration: Duration(milliseconds: 400),
  closedBuilder: (context, openContainer) => FloatingActionButton(...),
  openBuilder: (context, closeContainer) => AddTransactionPage(),
)

// Transicion de eje compartido
SharedAxisTransition(
  transitionType: SharedAxisTransitionType.horizontal,
  animation: animation,
  secondaryAnimation: secondaryAnimation,
  child: child,
)
```

### Hero Animations

```dart
// En lista de transacciones
Hero(
  tag: 'transaction-icon-${transaction.id}',
  child: CategoryIcon(...),
)

// En detalle
Hero(
  tag: 'transaction-icon-${transaction.id}',
  child: CategoryIconLarge(...),
)
```

---

## 9. Diseno Responsivo

### Ubicacion
`lib/theme/utils/resposive.dart`

### Extension Methods

```dart
extension ResponsiveExtension on BuildContext {
  // Dimensiones de pantalla
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  double get diagonal => sqrt(pow(width, 2) + pow(height, 2));

  // Deteccion de dispositivo
  bool get isTablet => MediaQuery.of(this).size.shortestSide >= 600;
  Orientation get orientation => MediaQuery.of(this).orientation;
  TextScaler get textScaler => MediaQuery.of(this).textScaler;

  // Porcentajes
  double wp(double percent) => width * (percent / 100);
  double hp(double percent) => height * (percent / 100);
  double dp(double percent) => diagonal * (percent / 100);
}
```

### Uso en Codigo

```dart
// Altura responsiva (40% de la pantalla)
SizedBox(height: context.hp(40))

// Ancho responsivo
Container(width: context.wp(80))

// Condicional por dispositivo
if (context.isTablet) {
  // Layout de tablet
} else {
  // Layout de telefono
}
```

### Patrones de Layout Responsivo

1. **SingleChildScrollView**: Para contenido que puede exceder la pantalla
2. **ListView.builder**: Para listas dinamicas con lazy loading
3. **Wrap**: Para grids flexibles con `spacing` y `runSpacing`
4. **Expanded/Flexible**: Para distribucion proporcional
5. **SafeArea**: Para evitar notches y barras del sistema

### Breakpoints

| Dispositivo | Condicion |
|-------------|-----------|
| Telefono | `shortestSide < 600` |
| Tablet | `shortestSide >= 600` |

---

## 10. Componentes por Feature

### 10.1 Home Feature

**Ubicacion**: `lib/features/home/presentation/`

#### Pagina Principal (HomePage)

**Secciones**:
1. **Header**: Logo animado (FlipInX) + Avatar (ZoomIn)
2. **Balance Summary**: Card con balance total
3. **Budget Overview**: DonutChart + lista de categorias
4. **Recent Transactions**: Lista de ultimas transacciones

#### Widgets Especificos

| Widget | Descripcion |
|--------|-------------|
| `BalanceSummary` | Card con balance total, color segun positivo/negativo |
| `BudgetOverview` | Donut chart + categorias con presupuesto |
| `Transactions` | Lista de transacciones recientes con skeleton loading |
| `TransactionCard` | Card individual de transaccion |

### 10.2 Transactions Feature

**Ubicacion**: `lib/features/transactions/presentation/`

#### Paginas

| Pagina | Ruta | Descripcion |
|--------|------|-------------|
| `AllTransactionsPage` | /home/transactions | Lista completa con filtros |
| `AddTransactionPage` | Modal | Formulario de creacion |
| `EditTransactionPage` | Modal | Formulario de edicion |

#### Widgets de Formulario

| Widget | Funcion |
|--------|---------|
| `TransactionTypeToggle` | Selector Income/Expense con animacion |
| `AmountInputWidget` | Campo de monto con formato moneda |
| `CategorySelector` | Grid de chips de categorias |
| `CategoryChip` | Chip individual con icono |
| `DescriptionInput` | Campo de descripcion |
| `DateSelector` | Selector de fecha con DatePicker |
| `TransactionDetailsModal` | Modal con detalles y acciones |
| `TransactionFilterBottomSheet` | Filtros avanzados |

#### TransactionTypeToggle

```dart
// Colores por tipo
Expense: Color(0xFFEA4335)  // Rojo
Income: Color(0xFF4285F4)   // Azul

// Animacion: 200ms
// Forma: Pill-shaped container
```

#### AmountInputWidget

```dart
// Tamano de fuente: 48px
// Prefijo: $
// Formateador: MoneyInputFormatter
// Color: segun tipo (rojo/azul)
```

### 10.3 Analytics Feature

**Ubicacion**: `lib/features/analytics/presentation/`

#### Widgets

| Widget | Descripcion |
|--------|-------------|
| `AnalyticsSummaryCards` | 3 cards: Income, Expenses, Net Savings |
| `SpendingByCategoryChart` | Donut chart por categoria |
| `IncomeVsExpenseChart` | Bar chart comparativo |
| `TimePeriodSelector` | Segmented control: Week/Month/Year |
| `TopSpendingCategories` | Lista ranking de categorias |

### 10.4 Categories Feature

**Ubicacion**: `lib/features/categories/presentation/`

#### Widgets

| Widget | Descripcion |
|--------|-------------|
| `CategoryCard` | Card con icono, nombre, conteo y monto |
| `CategoryFormPage` | Formulario crear/editar categoria |
| Empty State | Icono + mensaje + CTA |

### 10.5 Settings Feature

**Ubicacion**: `lib/features/settings/presentation/`

#### Estructura

```
Settings Page
├── Account Section
│   ├── Profile
│   └── Security
├── Preferences Section
│   ├── Notifications
│   ├── Currency
│   └── Theme Appearance
├── Data & Privacy Section
│   ├── Export Data
│   └── Privacy Policy
├── Support Section
│   ├── About
│   └── FAQ
└── Logout Button
```

#### Widgets

| Widget | Descripcion |
|--------|-------------|
| `SettingsItem` | ListTile con icono, titulo, subtitulo |
| `_SettingsCard` | Contenedor agrupado con divisores |
| `_SectionTitle` | Encabezado de seccion |
| `ThemeOptionBottomSheet` | Selector Light/Dark/System |

### 10.6 Splash Feature

**Ubicacion**: `lib/features/splash/presentation/`

- Background: Primary color
- Icono: Wallet 80px
- Titulo: App name
- Loading: CircularProgressIndicator
- Delay: 2 segundos

---

## 11. Patrones de Formularios

### Estructura de Formularios

```dart
// Formulario de transaccion
Form(
  child: Column(
    children: [
      TransactionTypeToggle(),      // Tipo (Income/Expense)
      AmountInputWidget(),          // Monto
      CategorySelector(),           // Categoria
      DescriptionInput(),           // Descripcion
      DateSelector(),               // Fecha
      ElevatedButton(               // Submit
        onPressed: state.isFormValid ? submit : null,
      ),
    ],
  ),
)
```

### Validacion Visual

| Estado | Visual |
|--------|--------|
| Valido | Border normal, boton habilitado |
| Invalido | Border rojo, mensaje de error |
| Loading | Boton con CircularProgressIndicator |
| Disabled | Boton gris, texto gris |
| Focus | Border primary/dark |

### Estados del Boton Submit

```dart
ElevatedButton(
  onPressed: state.isFormValid && !state.isSubmitting ? submit : null,
  child: state.isSubmitting
    ? CircularProgressIndicator(color: Colors.white)
    : Text('Guardar'),
)
```

### Feedback al Usuario

```dart
// Exito
AppSnackbar().success(context, 'Transaccion guardada');
Navigator.pop(context);

// Error
AppSnackbar().error(context, 'Error al guardar');
// Mantener formulario abierto para correccion
```

---

## 12. Sistema de Iconos

### Ubicacion
`lib/core/utils/icon_helper.dart`

### Iconos de Categoria

```dart
class IconHelper {
  static IconData getIcon(String iconName) {
    return switch (iconName) {
      // Ingresos
      'work' => Icons.work_outline,
      'laptop' => Icons.laptop_mac_outlined,
      'trending_up' => Icons.trending_up,
      'attach_money' => Icons.attach_money,

      // Gastos
      'restaurant' => Icons.restaurant_outlined,
      'directions_car' => Icons.directions_car_outlined,
      'home' => Icons.home_outlined,
      'shopping_bag' => Icons.shopping_bag_outlined,
      'movie' => Icons.movie_outlined,
      'school' => Icons.school_outlined,
      'local_hospital' => Icons.local_hospital_outlined,
      'theater' => Icons.theaters_outlined,

      _ => Icons.category_outlined,
    };
  }
}
```

### Iconos de Navegacion

| Seccion | Inactivo | Activo |
|---------|----------|--------|
| Home | `home_outlined` | `home` |
| Analytics | `bar_chart_outlined` | `bar_chart` |
| Categories | `category_outlined` | `category` |
| Settings | `settings_outlined` | `settings` |

### Iconos Comunes

| Accion | Icono |
|--------|-------|
| Agregar | `Icons.add` |
| Cerrar | `Icons.close` |
| Calendario | `Icons.calendar_today` |
| Buscar | `Icons.search` |
| Filtrar | `Icons.filter_list` |
| Editar | `Icons.edit` |
| Eliminar | `Icons.delete` |
| Mas opciones | `Icons.more_vert` |
| Atras | `Icons.arrow_back` |
| Error | `Icons.error_outline` |
| Refresh | `Icons.refresh` |
| Wallet | `Icons.account_balance_wallet_outlined` |

---

## 13. Accesibilidad

### Implementaciones Actuales

1. **Contraste de Colores**
   - Texto oscuro sobre fondos claros
   - Texto claro sobre fondos oscuros
   - Estados de error claramente indicados (rojo)
   - Estados de exito claramente indicados (verde)

2. **Tamanos de Touch Targets**
   - Bottom navigation items: 50+ px altura
   - Botones: 18-56px altura
   - Cards: 24px border radius (facil de tocar)

3. **Escalado de Texto**
   - Soporte para `textScaler` del sistema
   - Uso de unidades logicas (no hardcoded pixels)

4. **Localizacion**
   - Extension `context.l10n` para todos los textos
   - Soporte multi-idioma via `flutter_localizations`

### Recomendaciones de Mejora

1. **Semantics Widgets**
   ```dart
   Semantics(
     label: 'Boton agregar transaccion',
     button: true,
     child: FloatingActionButton(...),
   )
   ```

2. **Labels Descriptivos**
   ```dart
   TextField(
     decoration: InputDecoration(
       labelText: 'Monto',
       semanticCounterText: 'Ingrese el monto de la transaccion',
     ),
   )
   ```

3. **Anuncios de Estado**
   ```dart
   // Para lectores de pantalla
   SemanticsService.announce(
     'Transaccion guardada exitosamente',
     TextDirection.ltr,
   );
   ```

---

## 14. Mejores Practicas

### Organizacion de Codigo UI

1. **Separacion de Concerns**
   - Logica de negocio en BLoC
   - UI pura en widgets
   - Estilos en archivos de tema

2. **Widgets Pequenos y Reutilizables**
   - Extraer widgets cuando se repiten
   - Usar `const` constructors cuando sea posible
   - Evitar widgets monoliticos

3. **Nomenclatura**
   - Paginas: `*_page.dart`
   - Widgets: `*_widget.dart` o nombre descriptivo
   - BLoC: `*_bloc.dart`, `*_event.dart`, `*_state.dart`

### Patrones de Estado

```dart
// Skeleton loading
if (state is Loading) {
  return TransactionCardSkeleton();
}

// Estado de error
if (state is Error) {
  return ErrorWidget(message: state.message);
}

// Estado vacio
if (state.transactions.isEmpty) {
  return EmptyState();
}

// Estado con datos
return TransactionList(transactions: state.transactions);
```

### Performance

1. **Lazy Loading**
   - `ListView.builder` para listas largas
   - Paginacion en listas

2. **Keys Apropiados**
   - `ValueKey` para listas con items unicos
   - `GlobalKey` solo cuando sea necesario

3. **Const Constructors**
   ```dart
   const SizedBox(height: 16)
   const EdgeInsets.all(16)
   ```

4. **Evitar Rebuilds Innecesarios**
   - Usar `BlocSelector` para escuchar campos especificos
   - Extraer widgets que no cambian

---

## Recursos Adicionales

### Dependencias UI

```yaml
dependencies:
  fl_chart: ^latest          # Graficos
  animate_do: ^latest        # Animaciones
  animations: ^latest        # Transiciones Material
  go_router: ^latest         # Navegacion
  flutter_bloc: ^latest      # State management
```

### Herramientas de Desarrollo

- **Flutter Inspector**: Para debug de layouts
- **Device Preview**: Testing en multiples dispositivos
- **Golden Tests**: Testing visual de widgets

### Referencias

- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)
- [go_router Documentation](https://pub.dev/packages/go_router)
- [fl_chart Documentation](https://pub.dev/packages/fl_chart)

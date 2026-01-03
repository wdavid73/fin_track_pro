# Flutter Light/Dark Theme System - Implementation Guide

## PROJECT OVERVIEW
Sistema completo de temas claro/oscuro para Flutter usando Material 3. Provee configuración centralizada y modular de estilos para todos los widgets principales del proyecto FinTrack Pro.

## METADATA
- **Framework**: Flutter
- **Material Version**: Material 3
- **Font Family**: Poppins
- **Theme Mode**: Sistema (auto light/dark)
- **Architecture Pattern**: Modular Theme System
- **Namespace Prefix**: Custom* (ejemplo: CustomAppBarTheme, ColorTheme, AppSizes)

---

## ARCHITECTURE

### Entry Points
**Files**:
- [app_theme.dart](../lib/theme/app_theme.dart) - Main theme controller
- [light_theme.dart](../lib/theme/light_theme.dart) - Light theme configuration
- [dark_theme.dart](../lib/theme/dark_theme.dart) - Dark theme configuration

**Classes**:
- `AppTheme` - Main controller (abstract class)
- `LightTheme` - Light theme builder (abstract class)
- `DarkTheme` - Dark theme builder (abstract class)

**Exports**:
- `AppTheme.getLightTheme(context)` → ThemeData
- `AppTheme.getDarkTheme(context)` → ThemeData

### Project Structure
```
lib/theme/
├── app_theme.dart                    # Main entry point
├── light_theme.dart                  # Light theme assembly
├── dark_theme.dart                   # Dark theme assembly
├── theme_constants.dart              # Shared constants (ColorScheme, Dialog, etc.)
│
├── utils/
│   ├── color_theme.dart              # Color palette (ColorTheme)
│   └── sizes.dart                    # Size constants (AppSizes)
│
└── custom/                           # Modular widget themes
    ├── appbar_theme.dart             # AppBar styling
    ├── bottom_sheet_theme.dart       # Bottom sheet styling
    ├── card_theme.dart               # Card styling
    ├── checkbox_theme.dart           # Checkbox styling
    ├── chip_theme.dart               # Chip styling
    ├── elevated_button_theme.dart    # Primary button styling
    ├── outlined_button_theme.dart    # Secondary button styling
    ├── snackbar_theme.dart           # SnackBar styling
    ├── text_button_theme.dart        # Text button styling
    ├── text_field_theme.dart         # TextField/Input styling
    └── text_theme.dart               # Typography system
```

### Dependency Graph
```
app_theme.dart
├── light_theme.dart
│   ├── theme_constants.dart → ColorScheme, shared themes
│   ├── utils/color_theme.dart → ColorTheme
│   └── custom/*.dart → All modular themes
│
└── dark_theme.dart
    ├── theme_constants.dart → ColorScheme, shared themes
    ├── utils/color_theme.dart → ColorTheme
    └── custom/*.dart → All modular themes
```

---

## FILE STRUCTURE DETAILS

### 1. UTILS - Foundation Layer

#### **utils/color_theme.dart**
Defines all color constants used across the application.

```dart
class ColorTheme {
  ColorTheme._(); // Singleton pattern

  // Primary colors
  static const Color primaryColor = Color(0xFF4285F4);
  static const Color secondaryColor = Color(0xFF34A853);
  static const Color tertiaryColor = Color(0xFFFBBC05);

  // Text colors
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Surface & backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);
  static const Color darkBackgroundColor = Color(0xFF121212);

  // Grey scale
  static const Color grey = Color(0xFFDADCE0);
  static const Color darkGrey = Color(0xFF939393);
  static const Color darkerGrey = Color(0xFF4F4F4F);

  // State colors
  static const Color warning = Color(0xFFEA4335);
  static const Color borderPrimary = Color(0xFF4285F4);
  static const Color buttonDisabled = Color(0xFFC4C4C4);
}
```

#### **utils/sizes.dart**
Defines all size-related constants for consistent spacing and sizing.

```dart
class AppSizes {
  AppSizes._(); // Singleton pattern

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;

  // Spacing
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;

  // Button dimensions
  static const double buttonHeight = 18.0;
  static const double buttonRadius = 12.0;

  // Input fields
  static const double inputFieldRadius = 12.0;

  // Font sizes
  static const double fontSizeXs = 12.0;
  static const double fontSizeSm = 14.0;
  static const double fontSizeMd = 16.0;
  static const double fontSizeLg = 18.0;
}
```

---

### 2. CUSTOM - Modular Theme Components

All files in `custom/` follow the same pattern:
- Abstract class with private constructor
- Separate `light*` and `dark*` static properties
- Full documentation

#### **custom/text_theme.dart**
**Typography Scale**:

| Style | Size | Weight | Light Color | Dark Color | Usage |
|-------|------|--------|-------------|------------|-------|
| headlineLarge | 32px | bold | dark | light | Main headings |
| headlineMedium | 24px | w600 | dark | light | Section headers |
| headlineSmall | 18px | w600 | dark | light | Subsection headers |
| titleLarge | 16px | w600 | dark | light | Card titles |
| titleMedium | 16px | w500 | dark | light | Subtitles |
| titleSmall | 16px | w400 | dark | light | Minor titles |
| bodyLarge | 14px | w500 | dark | light | Emphasized body |
| bodyMedium | 14px | normal | dark | light | Regular body |
| bodySmall | 14px | w500 | dark (50%) | light (50%) | Secondary text |
| labelLarge | 12px | normal | dark | light | Labels |
| labelMedium | 12px | normal | dark (50%) | light (50%) | Secondary labels |

#### **custom/appbar_theme.dart**
**Properties**:
- `elevation: 0` (flat design)
- `centerTitle: false`
- `backgroundColor: Colors.transparent`
- **Light**: Icons and title in black
- **Dark**: Icons and title in white
- Icon size: `AppSizes.iconMd` (24px)
- Title: fontSize 18, fontWeight w600

#### **custom/elevated_button_theme.dart**
**Properties**:
- `elevation: 0`
- `backgroundColor: ColorTheme.primaryColor`
- `foregroundColor: ColorTheme.textWhite`
- `padding: vertical AppSizes.buttonHeight`
- `borderRadius: AppSizes.buttonRadius`
- **Disabled states**:
  - Light: `ColorTheme.buttonDisabled`
  - Dark: `ColorTheme.darkerGrey`

#### **custom/outlined_button_theme.dart**
**Properties**:
- `elevation: 0`
- `side: BorderSide(color: ColorTheme.borderPrimary)`
- `borderRadius: AppSizes.buttonRadius`
- `padding: vertical AppSizes.buttonHeight, horizontal 20`
- **Light**: foregroundColor `ColorTheme.dark`
- **Dark**: foregroundColor `ColorTheme.light`

#### **custom/text_field_theme.dart**
**Border Radius**: `AppSizes.inputFieldRadius`

**Border States (Light)**:
| State | Width | Color |
|-------|-------|-------|
| border | 1px | ColorTheme.grey |
| enabledBorder | 1px | ColorTheme.grey |
| focusedBorder | 1px | ColorTheme.dark |
| errorBorder | 1px | ColorTheme.warning |
| focusedErrorBorder | 2px | ColorTheme.warning |

**Border States (Dark)**:
| State | Width | Color |
|-------|-------|-------|
| border | 1px | ColorTheme.darkGrey |
| enabledBorder | 1px | ColorTheme.darkGrey |
| focusedBorder | 1px | ColorTheme.white |
| errorBorder | 1px | ColorTheme.warning |
| focusedErrorBorder | 2px | ColorTheme.warning |

#### **custom/checkbox_theme.dart**
**Properties**:
- `shape: RoundedRectangleBorder(radius: AppSizes.xs)`
- **Selected**: checkColor white, fillColor primary
- **Unselected**: checkColor black, fillColor transparent

#### **custom/chip_theme.dart**
**Properties**:
- `selectedColor: ColorTheme.primaryColor`
- `padding: horizontal 12, vertical 12`
- `checkmarkColor: ColorTheme.white`
- **Light**: labelStyle black, disabled grey (40% opacity)
- **Dark**: labelStyle white, disabled darkerGrey

#### **custom/bottom_sheet_theme.dart**
**Properties**:
- `showDragHandle: true`
- `constraints: BoxConstraints(minWidth: double.infinity)`
- `shape: RoundedRectangleBorder(radius: 16)`
- **Light**: backgroundColor white
- **Dark**: backgroundColor black

#### **custom/card_theme.dart**
**Properties**:
- `elevation: 0`
- `borderRadius: 24`
- `border: 1px`
- **Light**: white background, borderColor grey
- **Dark**: onSurfaceColor background, border white12

#### **custom/snackbar_theme.dart**
**Properties**:
- `behavior: SnackBarBehavior.floating`
- `insetPadding: 10`
- `borderRadius: topLeft 12, topRight 12`
- **Light**: backgroundColor onSurfaceColor, text 16px w600
- **Dark**: backgroundColor surfaceColor, text 14px w500

#### **custom/text_button_theme.dart**
**Properties**:
- `padding: vertical 16`
- `foregroundColor: ColorTheme.textSecondary`
- `textStyle: fontSize 16, fontWeight w600`
- Shared for both light and dark themes

---

### 3. THEME_CONSTANTS.DART - Shared Configuration

Contains theme configurations that don't have dedicated custom modules:

```dart
class ThemeConstants {
  ThemeConstants._(); // Singleton pattern

  // Color Schemes
  static const ColorScheme colorScheme = ColorScheme(...);
  static const ColorScheme darkColorScheme = ColorScheme(...);

  // Dialog themes
  static const baseDialogTheme = DialogTheme();
  static final baseDialogThemeDark = DialogTheme(...);

  // Tooltip, TabBar, BottomNavigationBar themes
  // (Only for widgets without custom modules)
}
```

**Modular themes defined in custom/ directory**:
- AppBarTheme → custom/appbar_theme.dart
- BottomSheetTheme → custom/bottom_sheet_theme.dart
- CardTheme → custom/card_theme.dart
- CheckboxTheme → custom/checkbox_theme.dart
- ChipTheme → custom/chip_theme.dart
- ElevatedButtonTheme → custom/elevated_button_theme.dart
- InputDecorationTheme → custom/text_field_theme.dart
- OutlinedButtonTheme → custom/outlined_button_theme.dart
- SnackBarTheme → custom/snackbar_theme.dart
- TextButtonTheme → custom/text_button_theme.dart
- TextTheme → custom/text_theme.dart

---

## INTEGRATION GUIDE

### Basic Setup

```dart
import 'package:flutter/material.dart';
import 'package:fin_track_pro/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.getLightTheme(context),
      darkTheme: AppTheme.getDarkTheme(context),
      themeMode: ThemeMode.system, // Auto switch based on system
      home: HomePage(),
    );
  }
}
```

### Manual Theme Control

```dart
// Force light theme
themeMode: ThemeMode.light

// Force dark theme
themeMode: ThemeMode.dark

// System default (auto switch)
themeMode: ThemeMode.system
```

### Accessing Theme Values

```dart
// Get current theme
final theme = Theme.of(context);

// Check if dark mode
final isDark = theme.brightness == Brightness.dark;

// Access colors
final primaryColor = theme.colorScheme.primary;
final surfaceColor = theme.colorScheme.surface;

// Access text styles
final headlineStyle = theme.textTheme.headlineLarge;
final bodyStyle = theme.textTheme.bodyMedium;
```

### Using Themed Widgets

```dart
// Auto-styled via theme
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)

TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)

Card(
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Text('Card Content'),
  ),
)
```

---

## DESIGN PATTERNS

### 1. Abstract Classes (Preferred over Singleton)
All theme classes use abstract classes instead of singleton pattern:

```dart
abstract class CustomAppBarTheme {
  static const lightAppBarTheme = AppBarTheme(...);
  static const darkAppBarTheme = AppBarTheme(...);
}
```

**Why abstract classes?**
- Cannot be instantiated (like singleton)
- More idiomatic in modern Dart
- Clearer intent - this is a namespace for static members
- No need for private constructor

### 2. Static Configuration
Everything is defined as `static const` or `static final` for:
- Zero runtime overhead
- Compile-time constants where possible
- Direct access without instantiation

### 3. Material State Handling
Dynamic widget states use `WidgetStateProperty.resolveWith()`:

```dart
fillColor: WidgetStateProperty.resolveWith((states) {
  if (states.contains(WidgetState.selected)) {
    return ColorTheme.primaryColor;
  }
  return Colors.transparent;
})
```

### 4. Modular Architecture
Each widget type has its own dedicated file for:
- Easy maintenance
- Clear separation of concerns
- Independent customization
- Better code organization

### 5. Naming Conventions
- **Classes**: `CustomXxxTheme` pattern (e.g., `CustomAppBarTheme`)
- **Properties**: `lightXxxTheme` and `darkXxxTheme` pattern
- **Constants**: `ColorTheme`, `AppSizes` (no prefix needed)
- **Files**: Snake_case (e.g., `appbar_theme.dart`)

---

## KEY FEATURES

1. ✅ **Material 3 Compliant**: Uses `useMaterial3: true`
2. ✅ **System Theme Aware**: Automatic light/dark switching
3. ✅ **Modular Structure**: Each widget theme in separate file
4. ✅ **Consistent Naming**: Clear conventions across all files
5. ✅ **Complete Typography**: Full text style scale
6. ✅ **State Management**: Proper handling of disabled, selected, focused, error states
7. ✅ **Zero Elevation**: Modern flat design (elevation: 0)
8. ✅ **Transparent AppBars**: For overlay effects
9. ✅ **DRY Principle**: No duplication, single source of truth
10. ✅ **Type Safety**: Full Dart type safety throughout

---

## CUSTOMIZATION GUIDE

### How to Modify Colors

Edit `lib/theme/utils/color_theme.dart`:

```dart
class ColorTheme {
  // Change primary brand color
  static const Color primaryColor = Color(0xFFYOURCOLOR);

  // Add new color
  static const Color customColor = Color(0xFFXXXXXX);
}
```

### How to Modify Sizes

Edit `lib/theme/utils/sizes.dart`:

```dart
class AppSizes {
  // Change button dimensions
  static const double buttonHeight = 20.0; // New value
  static const double buttonRadius = 16.0; // New value
}
```

### How to Modify Widget Themes

Edit the corresponding file in `lib/theme/custom/`:

```dart
// Example: custom/elevated_button_theme.dart
abstract class CustomElevatedButtonTheme {
  static final lightElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorTheme.primaryColor, // Use your colors
      padding: EdgeInsets.symmetric(vertical: AppSizes.buttonHeight),
      // ... customize as needed
    ),
  );
}
```

### How to Add New Widget Theme

1. Create new file in `custom/` directory
2. Follow the naming pattern: `xxx_theme.dart`
3. Use abstract class pattern
4. Define `lightXxxTheme` and `darkXxxTheme`
5. Import and use in `light_theme.dart` and `dark_theme.dart`

Example:

```dart
// lib/theme/custom/my_widget_theme.dart
import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

abstract class CustomMyWidgetTheme {
  static const lightMyWidgetTheme = MyWidgetThemeData(...);
  static const darkMyWidgetTheme = MyWidgetThemeData(...);
}
```

---

## COMPARISON WITH ORIGINAL GUIDE

### What's Different?

| Aspect | Original Guide | This Implementation |
|--------|----------------|---------------------|
| Naming | Prefix `T` (TAppTheme) | Prefix `Custom` for widgets |
| Pattern | Singleton `._()` | Abstract classes |
| Entry Point | Single `theme.dart` | `app_theme.dart` + separate light/dark files |
| Structure | Flat | Organized with `custom/` and `utils/` |
| Constants | TColors, TSizes | ColorTheme, AppSizes |
| Flexibility | Static properties | Methods with BuildContext |

### What's the Same?

✅ Material 3 compliance
✅ Modular widget themes
✅ Zero elevation design
✅ Complete typography system
✅ State management
✅ Light/Dark theme support

---

## BEST PRACTICES

### DO ✅
- Use `Theme.of(context)` to access theme values
- Define colors in `ColorTheme`
- Define sizes in `AppSizes`
- Keep widget themes in separate `custom/` files
- Use `const` where possible for performance
- Follow the naming conventions
- Document custom additions

### DON'T ❌
- Hardcode colors or sizes in widgets
- Mix theme logic with business logic
- Create theme instances (use static members)
- Duplicate theme definitions
- Skip documentation for custom themes

---

## COMPATIBILITY

- **Flutter SDK**: 3.0+ (Material 3 support required)
- **Dart**: 3.0+ (Modern Dart features)
- **Platform**: Cross-platform (iOS, Android, Web, Desktop)
- **IDE**: VS Code, Android Studio, IntelliJ IDEA

---

## VERSION INFO

- **Project**: FinTrack Pro
- **Implementation Date**: 2025
- **Based On**: Material Design 3 Guidelines
- **Theme Files**: 11 modular theme files
- **Total Components**: 11+ themed widgets

---

## QUICK REFERENCE

### Colors
```dart
ColorTheme.primaryColor      // Primary brand color
ColorTheme.textPrimary       // Main text color
ColorTheme.white             // White background
ColorTheme.darkBackgroundColor // Dark mode background
```

### Sizes
```dart
AppSizes.buttonHeight        // Button padding
AppSizes.buttonRadius        // Button border radius
AppSizes.inputFieldRadius    // Input field border radius
AppSizes.md                  // Standard spacing (16)
```

### Text Styles
```dart
Theme.of(context).textTheme.headlineLarge   // 32px bold
Theme.of(context).textTheme.bodyMedium      // 14px normal
Theme.of(context).textTheme.labelLarge      // 12px normal
```

### Common Patterns
```dart
// Get theme
final theme = Theme.of(context);

// Check dark mode
final isDark = theme.brightness == Brightness.dark;

// Access color
final color = theme.colorScheme.primary;

// Access text style
final style = theme.textTheme.titleLarge;
```

---

## SUPPORT & CONTRIBUTION

Para modificar o extender el sistema de temas:
1. Lee esta documentación completa
2. Sigue los patrones establecidos
3. Mantén la consistencia de nombres
4. Documenta tus cambios
5. Prueba en ambos temas (light/dark)

¿Preguntas? Revisa los archivos de ejemplo en `lib/theme/custom/`.

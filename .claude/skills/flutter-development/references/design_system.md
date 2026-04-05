# Design System Patterns

## Text Style Hierarchy

The app uses a custom text style hierarchy. Always use these instead of raw `TextStyle`:

| Style    | Usage                          |
|----------|--------------------------------|
| Display  | Hero text, large feature titles |
| Head     | Section headers, dialog titles  |
| Title    | Card titles, list item headers  |
| Body     | Paragraph text, descriptions    |

Access via the app's theme extension or constants. Never hardcode font sizes.

## Widget Performance Rules

1. **`const` constructors everywhere possible.** This prevents unnecessary rebuilds.
2. **`RepaintBoundary`** around expensive paint operations (gradients, shadows, animations).
3. **Lottie caching:** Always use `AssetLottie('path').load()` and cache the composition.
4. **Avoid `Opacity` widget** — use `AnimatedOpacity` or set opacity on `Color` directly.
5. **`ListView.builder`** for any list > 10 items. Never use `Column` with `SingleChildScrollView` for long lists.

## Skeletonizer Loading Pattern

```dart
class PaymentListSkeleton extends StatelessWidget {
  const PaymentListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: true,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return const PaymentCard(
            payment: PaymentEntity(
              id: 'skeleton',
              amount: 100.0,
              currency: 'COP',
              status: PaymentStatus.pending,
              createdAt: null, // use placeholder
            ),
          );
        },
      ),
    );
  }
}

// Usage in screen:
if (state.isLoading) {
  return const PaymentListSkeleton();
}
```

## Gradient Border Pattern

```dart
class CommodoGradientBorder extends StatelessWidget {
  final Widget child;
  final double borderWidth;
  final BorderRadius borderRadius;
  final Gradient gradient;

  const CommodoGradientBorder({
    super.key,
    required this.child,
    this.borderWidth = 2.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
      ),
      child: Padding(
        padding: EdgeInsets.all(borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: borderRadius,
          ),
          child: child,
        ),
      ),
    );
  }
}
```

## Reusable Widget Pattern (InfoBanner example)

```dart
enum InfoBannerType { info, success, warning, error }

class InfoBanner extends StatelessWidget {
  final String title;
  final String message;
  final InfoBannerType type;
  final VoidCallback? onClose;

  const InfoBanner({
    super.key,
    required this.title,
    required this.message,
    this.type = InfoBannerType.info,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: /* Title style */),
                const SizedBox(height: 4),
                Text(message, style: /* Body style */),
              ],
            ),
          ),
          if (onClose != null)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClose,
            ),
        ],
      ),
    );
  }

  // Private getters for type-based styling
  Color get _backgroundColor => switch (type) { ... };
  Color get _borderColor => switch (type) { ... };
  IconData get _icon => switch (type) { ... };
  Color get _iconColor => switch (type) { ... };
}
```

## Bottom Sheet Pattern

```dart
Future<void> showTermsBottomSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: const [
                    // Terms content
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
```

## SVG and Cached Image Usage

```dart
// SVG from assets (type-safe with flutter_gen)
SvgPicture.asset(
  Assets.icons.logo,  // flutter_gen generated
  width: 24,
  height: 24,
  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
)

// Cached network image with placeholder
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => const Skeletonizer(
    enabled: true,
    child: SizedBox(width: 48, height: 48),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  width: 48,
  height: 48,
  fit: BoxFit.cover,
)
```

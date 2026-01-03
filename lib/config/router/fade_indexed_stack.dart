import 'package:flutter/material.dart';

class FadeIndexedStack extends StatefulWidget {
  const FadeIndexedStack({
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  final int index;
  final List<Widget> children;
  final Duration duration;

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _controller.forward();
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: List.generate(widget.children.length, (index) {
        final isSelected = index == widget.index;

        // If not selected, we don't want it to be interactive or visible to screen readers
        // but we want it to fade out nicely if it was previously selected.
        // However, standard IndexedStack doesn't animate.
        // To strictly mimic "IndexedStack" but with fade, we can use FadeTransition
        // controlled by whether it is the 'active' one.

        // Simpler approach for "StatefulShellRoute" which gives us a list of Navigators:
        // We want the entering page to Fade IN. The exiting page changes immediately in many implementations,
        // effectively being covered / replaced.
        // But for a smoother look, we might want to keep the old one for a split second or just fade the new one in on top.
        //
        // A robust "FadeThrough" pattern often fades out the old and fades in the new.
        // But since we want to keep state, we shouldn't unmount them.

        return IgnorePointer(
          ignoring: !isSelected,
          child: AnimatedOpacity(
            duration: widget.duration,
            opacity: isSelected ? 1.0 : 0.0,
            curve: Curves.easeInOut,
            child: widget.children[index],
          ),
        );
      }),
    );
  }
}

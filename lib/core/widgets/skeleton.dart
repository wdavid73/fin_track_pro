import 'package:flutter/material.dart';

/// A skeleton widget that can be used as a placeholder during loading
/// Works great with ShimmerWrapper
class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final BoxShape shape;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8.0,
    this.shape = BoxShape.rectangle,
  });

  const Skeleton.circle({super.key, required double size})
    : width = size,
      height = size,
      borderRadius = 0,
      shape = BoxShape.circle;

  const Skeleton.square({
    super.key,
    required double size,
    this.borderRadius = 8.0,
  }) : width = size,
       height = size,
       shape = BoxShape.rectangle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: shape,
        borderRadius: shape == BoxShape.rectangle
            ? BorderRadius.circular(borderRadius)
            : null,
      ),
    );
  }
}

/// A skeleton text widget that mimics text dimensions
class SkeletonText extends StatelessWidget {
  final double width;
  final TextStyle? style;
  final int lines;

  const SkeletonText({
    super.key,
    required this.width,
    this.style,
    this.lines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? const TextStyle(fontSize: 14);
    final height = (textStyle.fontSize ?? 14) * (textStyle.height ?? 1.2);

    if (lines == 1) {
      return Skeleton(width: width, height: height, borderRadius: 4);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        lines,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: index < lines - 1 ? 8.0 : 0),
          child: Skeleton(
            width: index == lines - 1 ? width * 0.7 : width,
            height: height,
            borderRadius: 4,
          ),
        ),
      ),
    );
  }
}

/// A skeleton avatar widget
class SkeletonAvatar extends StatelessWidget {
  final double size;

  const SkeletonAvatar({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Skeleton.circle(size: size);
  }
}

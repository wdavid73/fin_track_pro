import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';

/// A text input field for transaction description.
///
/// Features a light background and placeholder text.
/// Supports both controller-based and callback-based patterns.
class DescriptionInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  const DescriptionInput({
    super.key,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.hintText,
  }) : assert(
         controller != null || onChanged != null,
         'Either controller or onChanged must be provided',
       );

  @override
  State<DescriptionInput> createState() => _DescriptionInputState();
}

class _DescriptionInputState extends State<DescriptionInput> {
  late TextEditingController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController(text: widget.initialValue ?? '');
      _isInternalController = true;
    }
  }

  @override
  void dispose() {
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: context.textTheme.titleSmall?.copyWith(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: context.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            maxLines: 1,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'e.g. Dinner with friends',
              hintStyle: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Generic outlined text field following the project's Material 3 design system.
///
/// Covers all standard use cases: plain text, email, password with toggle,
/// numeric input, and multiline. Pass [errorText] to show validation errors
/// reactively (e.g. from a Formz state).
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    required this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.maxLines = 1,
    this.autofillHints,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;

  /// When true the field hides its content (e.g. password).
  final bool obscureText;

  /// Shows an eye icon to toggle [obscureText]. Only meaningful when
  /// [obscureText] is also `true` initially.
  final bool showObscureToggle;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final int maxLines;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      autofillHints: widget.autofillHints,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon) : null,
        suffixIcon: widget.showObscureToggle
            ? IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
    );
  }
}

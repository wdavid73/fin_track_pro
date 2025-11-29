import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/core/widgets/formatters/money_input_formatter.dart';
import 'package:flutter/material.dart';

/// A large, prominent amount input widget with currency formatting.
///
/// Displays the amount in a large blue font with a dollar sign prefix.
/// Handles numeric input and real-time formatting.
class AmountInputWidget extends StatefulWidget {
  final double? initialAmount;
  final ValueChanged<double?> onAmountChanged;
  final String transactionType;

  const AmountInputWidget({
    super.key,
    this.initialAmount,
    required this.onAmountChanged,
    required this.transactionType,
  });

  @override
  State<AmountInputWidget> createState() => _AmountInputWidgetState();
}

class _AmountInputWidgetState extends State<AmountInputWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '0.00',
    );
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleAmountChange(String value) {
    if (value.isEmpty) {
      widget.onAmountChanged(null);
      return;
    }

    final cleanAmount = value.replaceAll('.', '');
    final amount = double.tryParse(cleanAmount);
    widget.onAmountChanged(amount);
  }

  Color _getAmountColor() {
    if (widget.transactionType == 'expense') {
      return context.errorColor; // Red for expense
    } else {
      return context.primaryColor; // Blue for income
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
        // Select all text when tapped
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '\$',
              style: context.textTheme.displayLarge?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: _getAmountColor(),
                height: 1.2,
              ),
            ),
            Flexible(
              child: IntrinsicWidth(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    // FilteringTextInputFormatter.digitsOnly,
                    MoneyInputFormatter(),
                  ],
                  style: context.textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: _getAmountColor(),
                    height: 1.2,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  textAlign: TextAlign.left,
                  onChanged: _handleAmountChange,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

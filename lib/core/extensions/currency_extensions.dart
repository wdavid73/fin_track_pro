import 'package:intl/intl.dart';

/// Extension for formatting double values as currency
extension CurrencyFormatter on double {
  /// Formats the double as currency with proper locale formatting
  ///
  /// Examples:
  /// - 1234.56 -> "$1,234.56" (en_US)
  /// - 1234.56 -> "$1.234,56" (es_ES)
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (e.g., 'en_US', 'es_ES').
  ///   If null, uses the system locale.
  /// - [symbol]: Currency symbol to use (default: '$')
  /// - [decimalDigits]: Number of decimal places (default: 2)
  String toCurrency({
    String? locale,
    String symbol = '\$',
    int decimalDigits = 2,
  }) {
    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
    return formatter.format(this);
  }

  /// Formats the double as compact currency (e.g., $1.2K, $3.4M)
  ///
  /// Examples:
  /// - 1234.56 -> "$1.2K"
  /// - 1234567.89 -> "$1.2M"
  ///
  /// Parameters:
  /// - [locale]: Optional locale string
  /// - [symbol]: Currency symbol to use (default: '$')
  String toCompactCurrency({String? locale, String symbol = '\$'}) {
    final formatter = NumberFormat.compactCurrency(
      locale: locale,
      symbol: symbol,
      decimalDigits: 1,
    );
    return formatter.format(this);
  }

  /// Formats the double as currency without decimal places
  ///
  /// Examples:
  /// - 1234.56 -> "$1,235"
  ///
  /// Parameters:
  /// - [locale]: Optional locale string
  /// - [symbol]: Currency symbol to use (default: '$')
  String toCurrencyInt({String? locale, String symbol = '\$'}) {
    return toCurrency(locale: locale, symbol: symbol, decimalDigits: 0);
  }
}

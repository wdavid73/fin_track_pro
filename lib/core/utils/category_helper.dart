/// Utilities for mapping category icons to emojis and formatting dates in Spanish.
class CategoryHelper {
  CategoryHelper._();

  /// Maps a Material icon name string (as stored in [Category.icon]) to an emoji.
  static String categoryEmoji(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return '🍽️';
      case 'shopping_cart':
      case 'shopping_bag':
        return '🛒';
      case 'directions_car':
        return '🚗';
      case 'home':
        return '🏠';
      case 'movie':
      case 'theaters':
        return '🎬';
      case 'local_hospital':
        return '💊';
      case 'school':
        return '📚';
      case 'work':
        return '💼';
      case 'laptop':
        return '💻';
      case 'trending_up':
        return '📈';
      case 'attach_money':
        return '💰';
      case 'settings':
        return '⚙️';
      case 'more_horiz':
        return '➕';
      default:
        return '💳';
    }
  }

  /// Returns a Spanish-localised, human-readable date string:
  /// "Hoy", "Ayer", "2 abr", or "2 abr 2025".
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final txDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(txDay).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';

    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];

    final day = date.day;
    final month = months[date.month - 1];
    if (date.year == now.year) return '$day $month';
    return '$day $month ${date.year}';
  }

  /// Returns a Spanish-localised full date string for the add transaction form,
  /// e.g. "2 de abril, 2026".
  static String formatDateLong(DateTime date) {
    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${date.day} de ${months[date.month - 1]}, ${date.year}';
  }
}

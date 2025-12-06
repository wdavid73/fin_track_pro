import 'package:flutter/material.dart';

/// context.locale.languageCode
extension LocaleExtension on BuildContext {
  Locale get locale => Localizations.localeOf(this);
}

import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension GetLocale on BuildContext {
  String currentLocale() {
    return Localizations.localeOf(this).toString();
  }
}

/* extension AppLocalizationsX on AppLocalizations {
  String? getByKey(String? key) {
    final map = <String, String>{
      'is_required': isRequired,
      'is_email': isEmail,
      'is_password_length': isPasswordLength,
      'is_invalid_password_pattern': isInvalidPasswordPattern,
      'is_not_equal_password': isNotEqualPassword,
      'is_empty': isEmpty,
      'is_empty_list': isEmptyList,
      'is_empty_select': isEmptySelect,
      'is_not_equal': isNotEqual,
      'connection_time_out': connectionTimeOut,
      'invalid-credential': invalidCredential,
      'email-already-in-use': emailAlreadyInUse,
      'wrong-password': wrongPassword,
      'invalid-email': invalidEmail,
      'weak-password': weakPassword,
    };
    return map[key] ?? key;
  }
} */

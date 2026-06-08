import 'package:fin_track_pro/core/l10n/app_localizations.dart';

String mapFirebaseAuthError(String? code, AppLocalizations l10n) {
  switch (code) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return l10n.authErrorInvalidCredential;
    case 'invalid-email':
      return l10n.authErrorInvalidEmail;
    case 'user-disabled':
      return l10n.authErrorUserDisabled;
    case 'too-many-requests':
      return l10n.authErrorTooManyRequests;
    case 'email-already-in-use':
      return l10n.authErrorEmailAlreadyInUse;
    case 'weak-password':
      return l10n.authErrorWeakPassword;
    case 'network-request-failed':
      return l10n.authErrorNetworkFailed;
    default:
      return l10n.authError;
  }
}

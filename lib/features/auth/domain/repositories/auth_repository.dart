import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  /// Stream of auth state changes. Emits [UserEntity] when signed in, null when signed out.
  Stream<UserEntity?> get authStateChanges;

  /// Returns the currently signed-in user, or null.
  Future<UserEntity?> getCurrentUser();

  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  });

  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<UserEntity> signInWithGoogle();

  Future<void> signOut();
}

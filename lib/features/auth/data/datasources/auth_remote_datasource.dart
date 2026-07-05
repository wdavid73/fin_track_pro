import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';

abstract class AuthRemoteDataSource {
  Stream<UserEntity?> get authStateChanges;
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmail({required String email, required String password});
  Future<UserEntity> signUpWithEmail({required String email, required String password, String? displayName});
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
}

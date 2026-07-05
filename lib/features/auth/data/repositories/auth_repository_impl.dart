import 'package:fin_track_pro/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  AuthRepositoryImpl(this._remote);

  @override
  Stream<UserEntity?> get authStateChanges => _remote.authStateChanges;

  @override
  Future<UserEntity?> getCurrentUser() => _remote.getCurrentUser();

  @override
  Future<UserEntity> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _remote.signInWithEmail(email: email, password: password);
  }

  @override
  Future<UserEntity> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => _remote.signUpWithEmail(
    email: email,
    password: password,
    displayName: displayName,
  );

  @override
  Future<UserEntity> signInWithGoogle() => _remote.signInWithGoogle();

  @override
  Future<void> signOut() => _remote.signOut();
}

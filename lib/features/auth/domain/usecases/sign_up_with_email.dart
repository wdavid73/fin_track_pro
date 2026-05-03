import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SignUpWithEmail {
  final AuthRepository _repository;

  SignUpWithEmail(this._repository);

  Future<UserEntity> call({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _repository.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
}

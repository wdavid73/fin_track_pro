import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SignInWithEmail {
  final AuthRepository _repository;

  SignInWithEmail(this._repository);

  Future<UserEntity> call({required String email, required String password}) =>
      _repository.signInWithEmail(email: email, password: password);
}

import 'package:fin_track_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class SignOut {
  final AuthRepository _repository;

  SignOut(this._repository);

  Future<void> call() => _repository.signOut();
}

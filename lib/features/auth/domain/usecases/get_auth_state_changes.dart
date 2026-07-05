import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetAuthStateChanges {
  final AuthRepository _repository;

  GetAuthStateChanges(this._repository);

  Stream<UserEntity?> call() => _repository.authStateChanges;
}

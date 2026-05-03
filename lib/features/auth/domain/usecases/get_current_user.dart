import 'package:fin_track_pro/features/auth/domain/entities/user_entity.dart';
import 'package:fin_track_pro/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetCurrentUser {
  final AuthRepository _repository;

  GetCurrentUser(this._repository);

  Future<UserEntity?> call() => _repository.getCurrentUser();
}

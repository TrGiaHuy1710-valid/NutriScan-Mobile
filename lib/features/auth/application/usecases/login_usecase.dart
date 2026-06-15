import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _repository.login(
      email: email,
      password: password,
      displayName: displayName,
    );
  }
}

import '../entities/auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser?> getCurrentUser();

  Future<AuthUser> login({
    required String email,
    required String password,
    required String displayName,
  });

  Future<AuthUser> createAccount({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> logout();
}

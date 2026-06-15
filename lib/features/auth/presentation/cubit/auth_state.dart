import '../../domain/entities/auth_user.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, failure }

class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  factory AuthState.initial() {
    return const AuthState(status: AuthStatus.initial);
  }

  final AuthStatus status;
  final AuthUser? user;
  final String? errorMessage;
  final String? successMessage;

  AuthState copyWith({
    AuthStatus? status,
    AuthUser? user,
    String? errorMessage,
    String? successMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

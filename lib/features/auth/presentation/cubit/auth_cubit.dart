import 'package:flutter/foundation.dart';

import '../../application/usecases/create_account_usecase.dart';
import '../../application/usecases/get_current_user_usecase.dart';
import '../../application/usecases/login_usecase.dart';
import '../../application/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends ChangeNotifier {
  AuthCubit({
    required CreateAccountUseCase createAccountUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _createAccountUseCase = createAccountUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase;

  final CreateAccountUseCase _createAccountUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;

  AuthState _state = AuthState.initial();

  AuthState get state => _state;

  Future<void> loadSession() async {
    _emit(_state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _getCurrentUserUseCase();
      _emit(
        AuthState(
          status: user == null
              ? AuthStatus.unauthenticated
              : AuthStatus.authenticated,
          user: user,
          successMessage: user == null ? null : 'Session restored',
        ),
      );
    } catch (error) {
      _emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: _debugMessage('Unable to load local session', error),
        ),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _emit(_state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _loginUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      _emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          successMessage: 'Login successful',
        ),
      );
    } catch (error) {
      _emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: _debugMessage('Unable to login locally', error),
        ),
      );
    }
  }

  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _emit(_state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _createAccountUseCase(
        email: email,
        password: password,
        displayName: displayName,
      );
      _emit(
        AuthState(
          status: AuthStatus.authenticated,
          user: user,
          successMessage: 'Account created successfully',
        ),
      );
    } catch (error) {
      _emit(
        AuthState(
          status: AuthStatus.failure,
          errorMessage: _debugMessage('Unable to create local account', error),
        ),
      );
    }
  }

  Future<void> logout() async {
    await _logoutUseCase();
    _emit(const AuthState(status: AuthStatus.unauthenticated));
  }

  void _emit(AuthState state) {
    _state = state;
    notifyListeners();
  }

  String _debugMessage(String message, Object error) {
    return '$message. Debug: $error';
  }
}

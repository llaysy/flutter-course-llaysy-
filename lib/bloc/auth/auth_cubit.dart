import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/auth_exception.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/app_user.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthState.unknown()) {
    _subscription = _repository.authStateChanges().listen(_onUserChanged);
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _subscription;

  void _onUserChanged(AppUser? user) {
    if (user == null) {
      emit(const AuthState(status: AuthStatus.unauthenticated));
    } else {
      emit(AuthState(status: AuthStatus.authenticated, user: user));
    }
  }

  Future<void> signIn(String email, String password) {
    return _submit(email, password, _repository.signIn);
  }

  Future<void> register(String email, String password) {
    return _submit(email, password, _repository.register);
  }

  Future<void> signOut() => _repository.signOut();

  Future<void> _submit(
    String email,
    String password,
    Future<void> Function(String email, String password) action,
  ) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Введите email и пароль',
        ),
      );
      return;
    }
    emit(const AuthState(status: AuthStatus.unauthenticated, isBusy: true));
    try {
      await action(trimmedEmail, password);
    } on AuthException catch (e) {
      emit(AuthState(status: AuthStatus.unauthenticated, error: e.message));
    } catch (_) {
      emit(
        const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Не удалось выполнить вход. Попробуйте ещё раз.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}

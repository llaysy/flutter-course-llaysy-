import '../../domain/entities/app_user.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AppUser? user;
  final bool isBusy;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.isBusy = false,
    this.error,
  });

  const AuthState.unknown() : this(status: AuthStatus.unknown);
}

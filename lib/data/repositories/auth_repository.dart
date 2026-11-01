import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/app_user.dart';
import 'auth_exception.dart';

class AuthRepository {
  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<AppUser?> authStateChanges() {
    return _auth.authStateChanges().map(_toUser);
  }

  AppUser? _toUser(User? user) {
    if (user == null) return null;
    return AppUser(uid: user.uid, email: user.email ?? '');
  }

  Future<void> signIn(String email, String password) {
    return _run(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<void> register(String email, String password) {
    return _run(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      throw AuthException(_message(e.code));
    }
  }

  String _message(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Некорректный email';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'email-already-in-use':
        return 'Этот email уже занят';
      case 'weak-password':
        return 'Слишком короткий пароль (минимум 6 символов)';
      case 'network-request-failed':
        return 'Нет подключения к интернету';
      case 'too-many-requests':
        return 'Слишком много попыток, попробуйте позже';
      case 'operation-not-allowed':
        return 'Вход по email отключён в консоли Firebase';
      default:
        return 'Ошибка входа ($code)';
    }
  }
}

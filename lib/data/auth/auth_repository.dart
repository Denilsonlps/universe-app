import '../models/app_user.dart';

/// Erro de autenticação com mensagem amigável (pt-BR) para a UI.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);
  @override
  String toString() => message;
}

abstract interface class AuthRepository {
  /// Emite o usuário atual (ou null quando deslogado). Emite o estado inicial ao ser ouvido.
  Stream<AppUser?> authState();

  AppUser? get currentUser;

  Future<AppUser> signIn({required String email, required String password});

  Future<AppUser> register({required String name, required String email, required String password});

  Future<void> signOut();
}

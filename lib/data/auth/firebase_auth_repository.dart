import 'package:firebase_auth/firebase_auth.dart';
import '../models/app_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);
  final FirebaseAuth _auth;

  AppUser? _map(User? u) => u == null
      ? null
      : AppUser(id: u.uid, name: u.displayName ?? (u.email?.split('@').first ?? 'Estudante'), email: u.email ?? '');

  @override
  Stream<AppUser?> authState() => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email.trim(), password: password);
      return _map(cred.user)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_msg(e.code));
    }
  }

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email.trim(), password: password);
      await cred.user!.updateDisplayName(name.trim());
      await cred.user!.reload();
      return _map(_auth.currentUser)!;
    } on FirebaseAuthException catch (e) {
      throw AuthException(_msg(e.code));
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _msg(String code) => switch (code) {
        'invalid-email' => 'E-mail inválido.',
        'user-not-found' => 'Conta não encontrada.',
        'wrong-password' || 'invalid-credential' => 'E-mail ou senha incorretos.',
        'email-already-in-use' => 'Já existe uma conta com este e-mail.',
        'weak-password' => 'Senha muito fraca.',
        'network-request-failed' => 'Sem conexão. Tente novamente.',
        _ => 'Não foi possível concluir. Tente novamente.',
      };
}

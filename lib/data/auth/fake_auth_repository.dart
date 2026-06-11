import 'dart:async';
import '../models/app_user.dart';
import 'auth_repository.dart';

/// Implementação em memória para desenvolvimento e testes (sem rede).
class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AppUser?>.broadcast();
  final Map<String, ({AppUser user, String password})> _accounts = {};
  AppUser? _current;
  var _seeded = false;

  @override
  Stream<AppUser?> authState() {
    // Retorna um stream que primeiro emite o estado corrente e depois
    // repassa todos os eventos do broadcast controller.
    final snapshot = _current;
    late StreamController<AppUser?> sc;
    sc = StreamController<AppUser?>(
      onListen: () {
        sc.add(snapshot);
        sc.addStream(_controller.stream).then((_) => sc.close());
      },
    );
    return sc.stream;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> register({required String name, required String email, required String password}) async {
    final key = email.toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthException('Já existe uma conta com este e-mail.');
    }
    final user = AppUser(id: 'u${_accounts.length + 1}', name: name, email: email);
    _accounts[key] = (user: user, password: password);
    _current = user;
    _controller.add(_current);
    return user;
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) async {
    final acc = _accounts[email.toLowerCase()];
    if (acc == null) throw const AuthException('Conta não encontrada.');
    if (acc.password != password) throw const AuthException('E-mail ou senha incorretos.');
    _current = acc.user;
    _controller.add(_current);
    return acc.user;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  /// Conta de demonstração pré-cadastrada (uso opcional em dev).
  void seedDemoUser() {
    if (_seeded) return;
    _seeded = true;
    _accounts['ana.silva@aluno.ifsp.edu.br'] =
        (user: const AppUser(id: 'demo', name: 'Ana Beatriz', email: 'ana.silva@aluno.ifsp.edu.br'), password: 'Universe@2026');
  }
}

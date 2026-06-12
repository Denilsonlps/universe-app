import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/auth/auth_repository.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

void main() {
  test('registro cria usuário, autentica e emite no stream', () async {
    final repo = FakeAuthRepository();
    final emissions = <String?>[];
    final sub = repo.authState().listen((u) => emissions.add(u?.email));

    final user = await repo.register(name: 'Ana Beatriz', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    expect(user.name, 'Ana Beatriz');
    expect(repo.currentUser?.email, 'ana@aluno.ifsp.edu.br');

    await repo.signOut();
    expect(repo.currentUser, isNull);

    final again = await repo.signIn(email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    expect(again.email, 'ana@aluno.ifsp.edu.br');

    await Future<void>.delayed(Duration.zero);
    expect(emissions, [null, 'ana@aluno.ifsp.edu.br', null, 'ana@aluno.ifsp.edu.br']);
    await sub.cancel();
  });

  test('signIn com senha errada lança AuthException', () async {
    final repo = FakeAuthRepository();
    await repo.register(name: 'X', email: 'x@aluno.ifsp.edu.br', password: 'Senha@123');
    await repo.signOut();
    expect(
      () => repo.signIn(email: 'x@aluno.ifsp.edu.br', password: 'errada'),
      throwsA(isA<AuthException>()),
    );
  });

  test('signIn de e-mail inexistente lança AuthException', () async {
    final repo = FakeAuthRepository();
    expect(
      () => repo.signIn(email: 'naoexiste@aluno.ifsp.edu.br', password: 'x'),
      throwsA(isA<AuthException>()),
    );
  });
}

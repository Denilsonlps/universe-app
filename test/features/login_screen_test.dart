import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';
import 'package:universe_app/features/auth/screens/login_screen.dart';

void main() {
  testWidgets('login com credenciais válidas autentica via repositório', (t) async {
    final fake = FakeAuthRepository()..seedDemoUser();
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => const LoginScreen())]);
    await t.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).at(0), 'ana.silva@aluno.ifsp.edu.br');
    await t.enterText(find.byType(TextField).at(1), 'Universe@2026');
    await t.tap(find.text('ENTRAR'));
    await t.pumpAndSettle();

    expect(fake.currentUser, isNotNull);
    expect(fake.currentUser!.email, 'ana.silva@aluno.ifsp.edu.br');
  });

  testWidgets('e-mail inválido mostra erro de campo', (t) async {
    final fake = FakeAuthRepository();
    final router = GoRouter(routes: [GoRoute(path: '/', builder: (c, s) => const LoginScreen())]);
    await t.pumpWidget(ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(fake)],
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).at(0), 'invalido');
    await t.enterText(find.byType(TextField).at(1), '123456');
    await t.tap(find.text('ENTRAR'));
    await t.pump();
    expect(find.text('Informe um e-mail válido'), findsOneWidget);
    expect(fake.currentUser, isNull);
  });
}

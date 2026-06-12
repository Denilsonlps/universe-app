import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

void main() {
  testWidgets('troca de aba pela bottom nav', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeAuthRepository();
    // Pré-autentica o usuário para iniciar na shell
    await fake.register(name: 'Ana', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');

    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();

    // Em /home, 'Cursos' aparece só no rótulo da bottom nav.
    expect(find.text('Cursos'), findsOneWidget);

    await t.tap(find.text('Cursos'));
    await t.pumpAndSettle();

    // Agora 'Cursos' aparece no título da tela E no rótulo da nav.
    expect(find.text('Cursos'), findsNWidgets(2));
  });

  testWidgets('abre o drawer pelo botão de menu', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeAuthRepository();
    // Pré-autentica o usuário para iniciar na shell
    await fake.register(name: 'Ana', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');

    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();

    expect(find.text('IFSP Pirituba'), findsNothing);
    await t.tap(find.byIcon(Icons.menu));
    await t.pumpAndSettle();
    expect(find.text('IFSP Pirituba'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';
import 'package:universe_app/shared/chrome/bottom_nav.dart';

Future<ProviderContainer> _loggedIn() async {
  final fake = FakeAuthRepository();
  await fake.register(name: 'Ana Beatriz', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
  return ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
}

void main() {
  testWidgets('troca de aba pela bottom nav (home -> cursos)', (t) async {
    SharedPreferences.setMockInitialValues({});
    final container = await _loggedIn();
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: container.read(routerProvider)),
    ));
    await t.pumpAndSettle();
    // Home real mostra a busca placeholder:
    expect(find.text('Buscar cursos, benefícios, dúvidas…'), findsOneWidget);
    // toca na aba Cursos (dentro da bottom nav, para evitar ambiguidade):
    await t.tap(find.descendant(of: find.byType(AppBottomNav), matching: find.text('Cursos')));
    await t.pumpAndSettle();
    // CoursesScreen tem o campo de busca com hint único:
    expect(find.text('Buscar curso…'), findsOneWidget);
  });

  testWidgets('abre o drawer pelo botão de menu', (t) async {
    SharedPreferences.setMockInitialValues({});
    final container = await _loggedIn();
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: container.read(routerProvider)),
    ));
    await t.pumpAndSettle();
    // 'Sair' só existe no drawer:
    expect(find.text('Sair'), findsNothing);
    await t.tap(find.byIcon(Icons.menu));
    await t.pumpAndSettle();
    expect(find.text('Sair'), findsOneWidget);
  });
}

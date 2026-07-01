import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

Future<void> _pump(WidgetTester t, FakeAuthRepository fake) async {
  final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
  addTearDown(container.dispose);
  final router = container.read(routerProvider);
  await t.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
  ));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('deslogado (onboarding não visto) cai no onboarding; após login vai para home', (t) async {
    SharedPreferences.setMockInitialValues({});
    final fake = FakeAuthRepository();
    await _pump(t, fake);
    expect(find.text('Próximo'), findsOneWidget);

    await fake.register(name: 'Ana', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    await t.pumpAndSettle();
    expect(find.text('Início'), findsWidgets);
  });

  testWidgets('deslogado mas já viu o onboarding vai para o LOGIN (não repete o onboarding)', (t) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final fake = FakeAuthRepository();
    await _pump(t, fake);
    expect(find.text('Próximo'), findsNothing); // não mostra o onboarding
    expect(find.text('Entrar'), findsOneWidget); // mostra a tela de login
  });

  testWidgets('sessão persistida abre direto na home (não passa pelo login)', (t) async {
    SharedPreferences.setMockInitialValues({'onboarding_seen': true});
    final fake = FakeAuthRepository();
    // Simula reabrir o app com sessão já salva: o usuário existe antes do router.
    await fake.register(name: 'Ana', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    await _pump(t, fake);
    expect(find.text('Entrar'), findsNothing);
    expect(find.text('Início'), findsWidgets);
  });
}

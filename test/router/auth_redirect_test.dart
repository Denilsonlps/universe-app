import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe_app/core/providers/auth_provider.dart';
import 'package:universe_app/core/router/app_router.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/auth/fake_auth_repository.dart';

void main() {
  testWidgets('deslogado cai no onboarding; após login vai para home', (t) async {
    final fake = FakeAuthRepository();
    final container = ProviderContainer(overrides: [authRepositoryProvider.overrideWithValue(fake)]);
    addTearDown(container.dispose);
    final router = container.read(routerProvider);

    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
    ));
    await t.pumpAndSettle();
    expect(find.text('Próximo'), findsOneWidget);

    await fake.register(name: 'Ana', email: 'ana@aluno.ifsp.edu.br', password: 'Senha@123');
    await t.pumpAndSettle();
    expect(find.text('Início'), findsWidgets);
  });
}

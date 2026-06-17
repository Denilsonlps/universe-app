import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe_app/core/providers/profile_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/chrome/menu_drawer.dart';

void main() {
  Widget host(bool admin) => ProviderScope(
    overrides: [isAdminProvider.overrideWithValue(admin)],
    child: MaterialApp(theme: AppTheme.light, home: Scaffold(
      drawer: Consumer(builder: (c, ref, _) => MenuDrawer(
        userName: 'Ana', userEmail: 'a@b.com', isAdmin: ref.watch(isAdminProvider),
        onNavigate: (_) {}, onLogout: () {},
      )),
      body: Builder(builder: (c) => TextButton(onPressed: () => Scaffold.of(c).openDrawer(), child: const Text('abrir'))),
    )),
  );

  testWidgets('aluno não vê o painel admin no drawer', (t) async {
    await t.pumpWidget(host(false));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('Painel do Setor de Estágios'), findsNothing);
  });

  testWidgets('admin vê o painel admin no drawer', (t) async {
    await t.pumpWidget(host(true));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
    expect(find.text('Painel do Setor de Estágios'), findsOneWidget);
  });
}

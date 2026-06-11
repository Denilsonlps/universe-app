import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universe_app/main.dart';

void main() {
  testWidgets('troca de aba pela bottom nav', (t) async {
    SharedPreferences.setMockInitialValues({});
    await t.pumpWidget(const ProviderScope(child: UniverseApp()));
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
    await t.pumpWidget(const ProviderScope(child: UniverseApp()));
    await t.pumpAndSettle();

    expect(find.text('IFSP Pirituba'), findsNothing);
    await t.tap(find.byIcon(Icons.menu));
    await t.pumpAndSettle();
    expect(find.text('IFSP Pirituba'), findsOneWidget);
  });
}

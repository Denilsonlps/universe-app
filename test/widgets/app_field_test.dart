import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/app_field.dart';

void main() {
  testWidgets('AppField emite onChanged e mostra erro', (t) async {
    String v = '';
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: AppField(label: 'E-mail', icon: 'mail', value: v, error: 'inválido', onChanged: (x) => v = x)),
    ));
    expect(find.text('E-mail'), findsOneWidget);
    expect(find.text('inválido'), findsOneWidget);
    await t.enterText(find.byType(TextField), 'a@b.com');
    expect(v, 'a@b.com');
  });

  testWidgets('PasswordField alterna visibilidade', (t) async {
    await t.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: PasswordField(label: 'Senha', value: 'x', onChanged: (_) {})),
    ));
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    await t.tap(find.byIcon(Icons.visibility_outlined));
    await t.pump();
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
  });
}

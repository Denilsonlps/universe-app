import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/app_button.dart';
import 'package:universe_app/shared/widgets/app_card.dart';
import 'package:universe_app/shared/widgets/list_row.dart';
import 'package:universe_app/shared/widgets/status_badge.dart';
import 'package:universe_app/shared/widgets/app_chip.dart';

Widget _host(ThemeData theme) => MaterialApp(
  theme: theme,
  home: Scaffold(
    body: ListView(children: const [
      AppButton('Entrar', full: true),
      AppCard(child: Text('card')),
      ListRow(icon: 'cap', title: 'Cursos', subtitle: 'sub'),
      StatusBadge(closed: false),
      StatusBadge(closed: true),
      AppChip('Todos', active: true),
    ]),
  ),
);

void main() {
  testWidgets('design system renderiza no tema claro', (t) async {
    await t.pumpWidget(_host(AppTheme.light));
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Cursos'), findsOneWidget);
    expect(find.text('Aberta'), findsOneWidget);
    expect(find.text('Encerrada'), findsOneWidget);
  });

  testWidgets('design system renderiza no tema escuro', (t) async {
    await t.pumpWidget(_host(AppTheme.dark));
    expect(find.text('Entrar'), findsOneWidget);
  });
}

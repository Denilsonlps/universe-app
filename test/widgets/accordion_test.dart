import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/widgets/accordion.dart';

void main() {
  testWidgets('Accordion alterna ao tocar', (t) async {
    var open = false;
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body: StatefulBuilder(
      builder: (c, setState) => Accordion(question: 'Pergunta?', answer: 'Resposta.', open: open, onToggle: () => setState(() => open = !open)),
    ))));
    expect(find.text('Pergunta?'), findsOneWidget);
    await t.tap(find.text('Pergunta?'));
    await t.pumpAndSettle();
    expect(open, isTrue);
    expect(find.text('Resposta.'), findsOneWidget);
  });
}

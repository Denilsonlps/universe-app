import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/shared/content/wiki_text.dart';

void main() {
  testWidgets('WikiText mostra display de [[chave|display]] e o texto plano', (t) async {
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(body:
      WikiText('Veja o [[Cadastro Único|CadÚnico]] e o [[PIBIC]]. Fim.', onOpenDoc: (_) {}, onOpenTerm: (_) {}),
    )));
    expect(find.textContaining('CadÚnico'), findsOneWidget);
    expect(find.textContaining('PIBIC'), findsOneWidget);
    expect(find.textContaining('Fim.'), findsOneWidget);
  });

  test('parseWikiTokens separa texto e chaves', () {
    final toks = parseWikiTokens('a [[X|b]] c [[Y]] d');
    expect(toks.length, 5);
    expect(toks[0].text, 'a ');
    expect(toks[1].linkKey, 'X');
    expect(toks[1].text, 'b');
    expect(toks[3].linkKey, 'Y');
    expect(toks[3].text, 'Y');
    expect(toks[4].text, ' d');
  });
}

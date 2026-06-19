import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/models/content_doc.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/features/content/screens/content_doc_screen.dart';

Widget _wrap(Widget child) => ProviderScope(
      overrides: [universeRepositoryProvider.overrideWithValue(FakeUniverseRepository())],
      child: MaterialApp(theme: AppTheme.light, home: child),
    );

ContentDoc _doc() => ContentDoc(
      id: 'inst-ic',
      kind: ContentKind.inst,
      icon: 'book',
      title: 'Iniciação Científica',
      tag: 'Pesquisa',
      summary: 's',
      updatedAt: DateTime(2026, 6, 8),
      sections: const [
        RichSection(heading: 'O que é', body: 'Pesquisa com [[PIBIC]] orientada.'),
        StepsSection(heading: 'Como participar', items: ['Procure um orientador']),
      ],
    );

void main() {
  testWidgets('ContentDocScreen mostra título, etapa e wikilink tocável', (t) async {
    await t.pumpWidget(_wrap(ContentDocScreen(doc: _doc())));
    await t.pumpAndSettle();

    // Título (no herói) e a etapa do passo a passo aparecem.
    expect(find.text('Iniciação Científica'), findsWidgets);
    expect(find.text('Procure um orientador'), findsOneWidget);
    expect(find.textContaining('Atualizado em 08/06/2026'), findsOneWidget);

    // O wikilink [[PIBIC]] vira um trecho tocável (GestureDetector com o texto).
    expect(find.text('PIBIC'), findsOneWidget);
    expect(
      find.ancestor(of: find.text('PIBIC'), matching: find.byType(GestureDetector)),
      findsOneWidget,
    );
  });

  testWidgets('ContentDocScreen com doc nulo mostra "não encontrado"', (t) async {
    await t.pumpWidget(_wrap(const ContentDocScreen(doc: null)));
    await t.pumpAndSettle();
    expect(find.textContaining('não encontrado'), findsOneWidget);
  });
}

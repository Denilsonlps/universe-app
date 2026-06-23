import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/features/admin/screens/admin_noticias_sugeridas_screen.dart';

void main() {
  testWidgets('lista sugestões e aprova (cria News, remove da lista)', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 1600));
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [universeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: AdminNoticiasSugeridasScreen())),
    ));
    await t.pumpAndSettle();

    expect(find.text('Sisu+: prazo de inscrição encerra nesta sexta'), findsOneWidget);
    final antes = (await repo.watchAllNews().first).length;
    await t.tap(find.text('Aprovar').first);
    await t.pumpAndSettle();
    expect((await repo.watchAllNews().first).length, antes + 1);
  });
}

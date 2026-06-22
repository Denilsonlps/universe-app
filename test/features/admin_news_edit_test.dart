import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/data/storage/storage_service.dart';
import 'package:universe_app/features/admin/screens/admin_news_edit_screen.dart';

void main() {
  testWidgets('publicar nova notícia chama upsertNews', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 1800));
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [
        universeRepositoryProvider.overrideWithValue(repo),
        storageServiceProvider.overrideWithValue(FakeStorageService()),
      ],
      child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: AdminNewsEditScreen(news: null))),
    ));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField).first, 'Notícia Teste');
    // o corpo é o 5º TextField (índice 5):
    // índice 0 = Título, 1 = Categoria-livre, 2 = Fonte, 3 = Tempo de leitura, 4 = Resumo, 5 = Corpo
    final fields = find.byType(TextField);
    await t.enterText(fields.at(5), 'Corpo de teste com mais de dez caracteres.');
    await t.tap(find.text('Salvar notícia'));
    await t.pumpAndSettle();

    final all = await repo.watchAllNews().first;
    expect(all.where((n) => n.title == 'Notícia Teste'), isNotEmpty);
  });
}

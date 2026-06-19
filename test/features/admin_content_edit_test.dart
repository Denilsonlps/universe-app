import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/data/storage/storage_service.dart';
import 'package:universe_app/features/admin/screens/admin_content_edit_screen.dart';

Widget _wrap(Widget child, FakeUniverseRepository repo) => ProviderScope(
  overrides: [
    universeRepositoryProvider.overrideWithValue(repo),
    storageServiceProvider.overrideWithValue(FakeStorageService()),
  ],
  child: MaterialApp(
    theme: AppTheme.light,
    // Scaffold gives ScaffoldMessenger a place to show SnackBars
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('adicionar seção aumenta a contagem do rascunho', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final repo = FakeUniverseRepository();
    await t.pumpWidget(_wrap(const AdminContentEditScreen(doc: null), repo));
    await t.pumpAndSettle();

    expect(find.text('Adicionar seção'), findsOneWidget);
    await t.tap(find.text('Adicionar seção'));
    await t.pumpAndSettle();

    // Choose "Texto" from the section type picker
    await t.tap(find.widgetWithText(GestureDetector, 'Texto').last);
    await t.pumpAndSettle();

    // The section card with label TEXTO now appears
    expect(find.text('TEXTO'), findsOneWidget);
  });

  testWidgets('publicar nova página chama upsert com updatedAt de hoje', (t) async {
    await t.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => t.binding.setSurfaceSize(null));

    final repo = FakeUniverseRepository();
    await t.pumpWidget(_wrap(const AdminContentEditScreen(doc: null), repo));
    await t.pumpAndSettle();

    // Fill in title (first TextField)
    await t.enterText(find.byType(TextField).first, 'Página Teste');
    await t.pumpAndSettle();

    // Tap "Adicionar seção"
    await t.tap(find.text('Adicionar seção'));
    await t.pumpAndSettle();

    // Choose "Texto"
    await t.tap(find.widgetWithText(GestureDetector, 'Texto').last);
    await t.pumpAndSettle();

    // Tap "Publicar"
    await t.tap(find.text('Publicar'));
    await t.pumpAndSettle();

    // Verify the repo effect (upsert happens before context.pop)
    final all = await repo.watchAllContentDocs().first;
    final created = all.where((d) => d.title == 'Página Teste');
    expect(created, isNotEmpty);
    expect(created.first.updatedAt.day, DateTime.now().day);
  });
}

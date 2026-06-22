import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/features/admin/screens/admin_sugestoes_screen.dart';

void main() {
  testWidgets('lista sugestões pendentes e aprova (remove da lista, cria vaga)', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 1600));
    final repo = FakeUniverseRepository();
    await t.pumpWidget(ProviderScope(
      overrides: [universeRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(theme: AppTheme.light, home: const Scaffold(body: AdminSugestoesScreen())),
    ));
    await t.pumpAndSettle();

    // As 2 sugestões de exemplo aparecem.
    expect(find.text('Estágio em Front-end'), findsOneWidget);
    expect(find.text('Estágio em Logística'), findsOneWidget);

    final antesVagas = (await repo.watchAllInternships().first).length;
    await t.tap(find.text('Aprovar').first);
    await t.pumpAndSettle();

    // virou Internship e saiu das sugestões
    expect((await repo.watchAllInternships().first).length, antesVagas + 1);
  });
}

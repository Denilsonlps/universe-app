import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:universe_app/core/providers/repository_provider.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';
import 'package:universe_app/features/courses/screens/courses_screen.dart';

void main() {
  // Exercita o caminho completo de stream: provider sobrescrito pelo Fake →
  // coursesProvider emite → AsyncListView renderiza os dados.
  testWidgets('CoursesScreen carrega cursos do repositório via stream', (t) async {
    await t.pumpWidget(ProviderScope(
      overrides: [universeRepositoryProvider.overrideWithValue(FakeUniverseRepository())],
      child: MaterialApp(theme: AppTheme.light, home: const CoursesScreen()),
    ));
    // primeiro frame: loading; após o stream emitir: dados
    await t.pumpAndSettle();
    expect(find.text('Análise e Desenvolvimento de Sistemas'), findsWidgets);
    expect(find.text('Gestão Pública'), findsWidgets);
  });
}

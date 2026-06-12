import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/core/theme/app_theme.dart';
import 'package:universe_app/data/models/course.dart';
import 'package:universe_app/features/courses/screens/course_detail_screen.dart';

void main() {
  // Regressão: telas de detalhe são rotas full-screen FORA do ShellRoute, ou seja,
  // sem Scaffold ancestral. O PageShell precisa prover Material por conta própria,
  // senão InkWell/AppCard lançam "No Material widget found".
  testWidgets('CourseDetailScreen renderiza sem Scaffold ancestral', (t) async {
    const course = Course(
      name: 'Análise e Desenvolvimento de Sistemas', category: 'Graduação',
      type: 'Tecnólogo', duration: '3 anos', period: 'Noturno', icon: 'doc',
    );
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: const CourseDetailScreen(course: course)));
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    expect(find.textContaining('Análise e Desenvolvimento'), findsWidgets);
  });

  testWidgets('CourseDetailScreen com curso nulo mostra "não encontrado"', (t) async {
    await t.pumpWidget(MaterialApp(theme: AppTheme.light, home: const CourseDetailScreen(course: null)));
    await t.pumpAndSettle();
    expect(find.text('Curso não encontrado'), findsOneWidget);
  });
}

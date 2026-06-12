import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';

Internship _vaga({bool open = true, DateTime? closedAt, String course = 'ADS'}) => Internship(
  id: 'x', role: 'Dev', companyName: 'Org', area: 'TI', duration: '12m',
  jobDescription: 'desc', requirements: const [], niceToHave: const [],
  companyDescription: 'sobre', benefits: const [], grant: 'R\$ 1.000',
  course: course, mode: 'Híbrido', open: open, closedAt: closedAt,
);

void main() {
  final now = DateTime(2026, 6, 11);

  test('vaga aberta é sempre visível', () {
    expect(_vaga(open: true).visibleAt(now), isTrue);
  });

  test('vaga encerrada há menos de 30 dias permanece visível (RF034)', () {
    expect(_vaga(open: false, closedAt: now.subtract(const Duration(days: 20))).visibleAt(now), isTrue);
  });

  test('vaga encerrada há mais de 30 dias some (RF034)', () {
    expect(_vaga(open: false, closedAt: now.subtract(const Duration(days: 40))).visibleAt(now), isFalse);
  });
}

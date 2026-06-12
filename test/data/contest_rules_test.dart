import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/contest.dart';

Contest _c(DateTime deadline) => Contest(
  id: 'c', role: 'Analista', org: 'IFSP', vagas: '10', salary: 'R\$ 4.000',
  level: 'Superior', about: 'x', deadline: deadline,
);

void main() {
  final now = DateTime(2026, 6, 11);
  test('edital dentro do prazo está aberto (RF036)', () {
    expect(_c(now.add(const Duration(days: 10))).isOpenAt(now), isTrue);
  });
  test('edital após o prazo não está mais aberto (RF036)', () {
    expect(_c(now.subtract(const Duration(days: 1))).isOpenAt(now), isFalse);
  });
  test('edital encerrado há menos de 30 dias ainda é visível (RF036)', () {
    expect(_c(now.subtract(const Duration(days: 20))).visibleAt(now), isTrue);
  });
  test('edital encerrado há mais de 30 dias some (RF036)', () {
    expect(_c(now.subtract(const Duration(days: 31))).visibleAt(now), isFalse);
  });
}

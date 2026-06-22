import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/models/vaga_sugerida.dart';

void main() {
  test('VagaSugerida round-trip (payload Internship + metadados)', () {
    const vaga = Internship(
      id: 'abc', role: 'Estágio Dev', companyName: 'ACME', area: 'TI',
      duration: '6h/dia', jobDescription: 'desc', requirements: ['req1'],
      niceToHave: ['nice1'], companyDescription: 'empresa', benefits: ['VT'],
      grant: 'R\$ 1.000', course: 'ADS', mode: 'Híbrido', link: 'https://x/y',
    );
    final s = VagaSugerida(id: 'abc', vaga: vaga, scrapedAt: DateTime(2026, 6, 22), source: 'gupy-auto');
    final back = VagaSugerida.fromMap('abc', s.toMap());
    expect(back.id, 'abc');
    expect(back.status, 'pendente');
    expect(back.source, 'gupy-auto');
    expect(back.scrapedAt, DateTime(2026, 6, 22));
    expect(back.vaga.role, 'Estágio Dev');
    expect(back.vaga.course, 'ADS');
    expect(back.vaga.requirements, ['req1']);
    expect(back.vaga.link, 'https://x/y');
  });
}

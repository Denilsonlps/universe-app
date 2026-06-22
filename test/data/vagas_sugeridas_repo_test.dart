import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/models/vaga_sugerida.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

Internship _v(String id) => Internship(
      id: id, role: 'R $id', companyName: 'C', area: 'A', duration: 'd',
      jobDescription: 'j', requirements: const [], niceToHave: const [],
      companyDescription: 'cd', benefits: const [], grant: 'g', course: 'ADS',
      mode: 'Híbrido', link: 'https://x/$id');

void main() {
  test('watchVagasSugeridas só pendentes, scrapedAt desc; rejeitar/remover', () async {
    final repo = FakeUniverseRepository();
    final base = (await repo.watchVagasSugeridas().first).length;
    await repo.upsertVagaSugerida(VagaSugerida(id: 's1', vaga: _v('s1'), scrapedAt: DateTime(2026, 1, 1), source: 'gupy-auto'));
    await repo.upsertVagaSugerida(VagaSugerida(id: 's2', vaga: _v('s2'), scrapedAt: DateTime(2026, 3, 1), source: 'gupy-auto'));
    var pend = await repo.watchVagasSugeridas().first;
    final mine = pend.where((s) => s.id == 's1' || s.id == 's2').toList();
    expect(mine.first.id, 's2'); // scrapedAt desc
    expect(pend.length, base + 2);

    await repo.rejeitarVagaSugerida('s2');
    pend = await repo.watchVagasSugeridas().first;
    expect(pend.where((s) => s.id == 's2'), isEmpty); // recusada sai dos pendentes

    await repo.deleteVagaSugerida('s1');
    pend = await repo.watchVagasSugeridas().first;
    expect(pend.where((s) => s.id == 's1'), isEmpty);
  });
}

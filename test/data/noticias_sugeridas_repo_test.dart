import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';
import 'package:universe_app/data/models/noticia_sugerida.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

News _n(String id, DateTime d) => News(
      id: id, category: 'Geral', source: 'G1', readTime: '1 min',
      title: 'T $id', summary: 's', body: 's', date: d, facts: const []);

void main() {
  test('watchNoticiasSugeridas só pendentes (scrapedAt desc); rejeitar/remover', () async {
    final repo = FakeUniverseRepository();
    final base = (await repo.watchNoticiasSugeridas().first).length;
    await repo.upsertNoticiaSugerida(NoticiaSugerida(id: 'x1', noticia: _n('x1', DateTime(2026, 1, 1)), scrapedAt: DateTime(2026, 1, 1)));
    await repo.upsertNoticiaSugerida(NoticiaSugerida(id: 'x2', noticia: _n('x2', DateTime(2026, 3, 1)), scrapedAt: DateTime(2026, 3, 1)));
    var pend = await repo.watchNoticiasSugeridas().first;
    final mine = pend.where((s) => s.id == 'x1' || s.id == 'x2').toList();
    expect(mine.first.id, 'x2'); // scrapedAt desc
    expect(pend.length, base + 2);

    await repo.rejeitarNoticiaSugerida('x2');
    pend = await repo.watchNoticiasSugeridas().first;
    expect(pend.where((s) => s.id == 'x2'), isEmpty);

    await repo.deleteNoticiaSugerida('x1');
    pend = await repo.watchNoticiasSugeridas().first;
    expect(pend.where((s) => s.id == 'x1'), isEmpty);
  });
}

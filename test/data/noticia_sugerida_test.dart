import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';
import 'package:universe_app/data/models/noticia_sugerida.dart';

void main() {
  test('NoticiaSugerida round-trip (payload News + metadados)', () {
    final n = News(
      id: 'abc', category: 'SiSU', source: 'G1', readTime: '1 min',
      title: 'T', summary: 's', body: 's', date: DateTime(2026, 6, 23),
      facts: const [], sourceUrl: 'https://g1/x', imageUrl: null,
      published: false, pinned: false,
    );
    final s = NoticiaSugerida(id: 'abc', noticia: n, scrapedAt: DateTime(2026, 6, 23), status: 'pendente');
    final back = NoticiaSugerida.fromMap('abc', s.toMap());
    expect(back.id, 'abc');
    expect(back.status, 'pendente');
    expect(back.scrapedAt, DateTime(2026, 6, 23));
    expect(back.noticia.title, 'T');
    expect(back.noticia.category, 'SiSU');
    expect(back.noticia.sourceUrl, 'https://g1/x');
  });
}

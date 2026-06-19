import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';

void main() {
  test('News round-trip com facts', () {
    final n = News(
      id: 'n1', category: 'SiSU', source: 'MEC', readTime: '2 min',
      title: 'T', summary: 's', body: 'corpo [[SiSU]]',
      date: DateTime(2026, 6, 8), published: true, pinned: true,
      facts: const [(label: 'Inscrições', value: '15 a 19/06')],
      sourceUrl: 'gov.br/mec', imageUrl: 'https://x/y.png',
    );
    final back = News.fromMap('n1', n.toMap());
    expect(back.title, 'T');
    expect(back.category, 'SiSU');
    expect(back.date, DateTime(2026, 6, 8));
    expect(back.published, true);
    expect(back.pinned, true);
    expect(back.facts.single.label, 'Inscrições');
    expect(back.facts.single.value, '15 a 19/06');
    expect(back.sourceUrl, 'gov.br/mec');
    expect(back.imageUrl, 'https://x/y.png');
  });

  test('fromMap tolera ausências', () {
    final back = News.fromMap('x', const {'title': 'T'});
    expect(back.published, false);
    expect(back.pinned, false);
    expect(back.facts, isEmpty);
    expect(back.sourceUrl, isNull);
  });
}

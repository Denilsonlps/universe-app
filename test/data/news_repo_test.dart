import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/news.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

void main() {
  test('publishedNews exclui rascunhos e ordena (pinned, data desc)', () async {
    final repo = FakeUniverseRepository();
    await repo.upsertNews(News(id: 'a', category: 'Geral', source: '', readTime: '', title: 'A', summary: '', body: '', date: DateTime(2026, 1, 1), published: true));
    await repo.upsertNews(News(id: 'b', category: 'Geral', source: '', readTime: '', title: 'B', summary: '', body: '', date: DateTime(2026, 3, 1), published: true));
    await repo.upsertNews(News(id: 'c', category: 'Geral', source: '', readTime: '', title: 'C', summary: '', body: '', date: DateTime(2026, 2, 1), published: true, pinned: true));
    await repo.upsertNews(News(id: 'd', category: 'Geral', source: '', readTime: '', title: 'D', summary: '', body: '', date: DateTime(2026, 5, 1), published: false));

    // Filtra aos ids deste teste (o Fake já vem com notícias do protótipo).
    final pub = (await repo.watchPublishedNews().first)
        .where((n) => const {'a', 'b', 'c', 'd'}.contains(n.id))
        .map((n) => n.id)
        .toList();
    expect(pub, ['c', 'b', 'a']); // pinned 1º, depois data desc; rascunho 'd' fora
  });

  test('upsert/delete e watchAll', () async {
    final repo = FakeUniverseRepository();
    final before = (await repo.watchAllNews().first).length;
    await repo.upsertNews(News(id: 'z', category: 'Geral', source: '', readTime: '', title: 'Z', summary: '', body: '', date: DateTime(2026, 1, 1)));
    expect((await repo.watchAllNews().first).length, before + 1);
    await repo.deleteNews('z');
    expect((await repo.watchAllNews().first).where((n) => n.id == 'z'), isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/content_doc.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

void main() {
  test('upsert insere e atualiza; delete remove; watchAll retorna todos', () async {
    final repo = FakeUniverseRepository();
    final before = (await repo.watchAllContentDocs().first).length;

    await repo.upsertContentDoc(ContentDoc(
      id: 'gov-novo', kind: ContentKind.gov, icon: 'doc', title: 'T', tag: 'x',
      summary: 's', updatedAt: DateTime(2026, 1, 1), sections: const [RichSection(body: 'b')]));
    var all = await repo.watchAllContentDocs().first;
    expect(all.length, before + 1);
    expect(all.firstWhere((d) => d.id == 'gov-novo').title, 'T');

    await repo.upsertContentDoc(ContentDoc(
      id: 'gov-novo', kind: ContentKind.gov, icon: 'doc', title: 'EDIT', tag: 'x',
      summary: 's', updatedAt: DateTime(2026, 1, 2), sections: const [RichSection(body: 'b')]));
    all = await repo.watchAllContentDocs().first;
    expect(all.where((d) => d.id == 'gov-novo').length, 1);
    expect(all.firstWhere((d) => d.id == 'gov-novo').title, 'EDIT');

    await repo.deleteContentDoc('gov-novo');
    all = await repo.watchAllContentDocs().first;
    expect(all.where((d) => d.id == 'gov-novo'), isEmpty);
  });
}

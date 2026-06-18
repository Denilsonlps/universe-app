import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/content_doc.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

void main() {
  final repo = FakeUniverseRepository();
  test('Fake expõe 8 content docs (4 gov + 4 inst), todos com seções', () async {
    final gov = await repo.watchContentDocs(ContentKind.gov).first;
    final inst = await repo.watchContentDocs(ContentKind.inst).first;
    expect(gov.length, 4);
    expect(inst.length, 4);
    expect(repo.allContentDocs.length, 8);
    for (final d in repo.allContentDocs) {
      expect(d.sections, isNotEmpty, reason: d.id);
    }
  });
  test('watchContentDoc resolve por id e retorna null p/ inexistente', () async {
    expect((await repo.watchContentDoc('gov-cadunico').first)?.title, isNotNull);
    expect(await repo.watchContentDoc('nope').first, isNull);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/content_doc.dart';

void main() {
  test('ContentDoc round-trip com várias seções', () {
    final doc = ContentDoc(
      id: 'gov-x', kind: ContentKind.gov, icon: 'card', title: 'X', tag: 'Federal',
      summary: 's', updatedAt: DateTime(2026, 6, 10),
      sections: [
        const RichSection(heading: 'O que é', body: 'Texto [[PIBIC]].'),
        const StepsSection(heading: 'Como', items: ['a', 'b']),
        const MediaSection(mediaType: 'video', caption: 'c', videoUrl: 'https://youtu.be/abc'),
        const CalloutSection(variant: 'warn', body: 'cuidado'),
        const FaqSection(items: [(q: 'q?', a: 'r')]),
        const SourcesSection(items: [(label: 'gov', url: 'gov.br')]),
        const DocsSection(items: ['doc1']),
      ],
    );
    final back = ContentDoc.fromMap('gov-x', doc.toMap());
    expect(back.title, 'X');
    expect(back.kind, ContentKind.gov);
    expect(back.updatedAt, DateTime(2026, 6, 10));
    expect(back.sections.length, 7);
    expect((back.sections[0] as RichSection).body, 'Texto [[PIBIC]].');
    expect((back.sections[1] as StepsSection).items, ['a', 'b']);
    expect((back.sections[4] as FaqSection).items.first.q, 'q?');
  });
}

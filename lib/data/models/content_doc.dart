enum ContentKind { gov, inst }

/// Seção tipada de um documento de conteúdo.
sealed class ContentSection {
  const ContentSection();
  Map<String, dynamic> toMap();

  static ContentSection? fromMap(Map<String, dynamic> m) {
    switch (m['type']) {
      case 'rich':
        return RichSection(heading: m['heading'], body: m['body'] ?? '');
      case 'steps':
        return StepsSection(heading: m['heading'], items: List<String>.from(m['items'] ?? const []));
      case 'docs':
        return DocsSection(heading: m['heading'], items: List<String>.from(m['items'] ?? const []));
      case 'media':
        return MediaSection(heading: m['heading'], caption: m['caption'], mediaType: m['mediaType'] ?? 'image', imageUrl: m['imageUrl'], videoUrl: m['videoUrl']);
      case 'callout':
        return CalloutSection(variant: m['variant'] ?? 'info', body: m['body'] ?? '');
      case 'faq':
        return FaqSection(heading: m['heading'], items: ((m['items'] ?? const []) as List).map((e) => (q: (e['q'] ?? '') as String, a: (e['a'] ?? '') as String)).toList());
      case 'sources':
        return SourcesSection(heading: m['heading'], items: ((m['items'] ?? const []) as List).map((e) => (label: (e['label'] ?? '') as String, url: (e['url'] ?? '') as String)).toList());
      default:
        return null;
    }
  }
}

class RichSection extends ContentSection {
  final String? heading;
  final String body;
  const RichSection({this.heading, required this.body});
  @override
  Map<String, dynamic> toMap() => {'type': 'rich', 'heading': heading, 'body': body};
}

class StepsSection extends ContentSection {
  final String? heading;
  final List<String> items;
  const StepsSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'steps', 'heading': heading, 'items': items};
}

class DocsSection extends ContentSection {
  final String? heading;
  final List<String> items;
  const DocsSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'docs', 'heading': heading, 'items': items};
}

class MediaSection extends ContentSection {
  final String? heading, caption, imageUrl, videoUrl;
  final String mediaType; // 'image' | 'video'
  const MediaSection({this.heading, this.caption, required this.mediaType, this.imageUrl, this.videoUrl});
  @override
  Map<String, dynamic> toMap() => {'type': 'media', 'heading': heading, 'caption': caption, 'mediaType': mediaType, 'imageUrl': imageUrl, 'videoUrl': videoUrl};
}

class CalloutSection extends ContentSection {
  final String variant; // 'info' | 'warn'
  final String body;
  const CalloutSection({required this.variant, required this.body});
  @override
  Map<String, dynamic> toMap() => {'type': 'callout', 'variant': variant, 'body': body};
}

class FaqSection extends ContentSection {
  final String? heading;
  final List<({String q, String a})> items;
  const FaqSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'faq', 'heading': heading, 'items': [for (final i in items) {'q': i.q, 'a': i.a}]};
}

class SourcesSection extends ContentSection {
  final String? heading;
  final List<({String label, String url})> items;
  const SourcesSection({this.heading, required this.items});
  @override
  Map<String, dynamic> toMap() => {'type': 'sources', 'heading': heading, 'items': [for (final i in items) {'label': i.label, 'url': i.url}]};
}

class ContentDoc {
  final String id;
  final ContentKind kind;
  final String icon, title, tag, summary;
  final DateTime updatedAt;
  final List<ContentSection> sections;
  const ContentDoc({required this.id, required this.kind, required this.icon, required this.title, required this.tag, required this.summary, required this.updatedAt, required this.sections});

  Map<String, dynamic> toMap() => {
        'kind': kind.name, 'icon': icon, 'title': title, 'tag': tag, 'summary': summary,
        'updatedAt': updatedAt.millisecondsSinceEpoch,
        'sections': [for (final s in sections) s.toMap()],
      };

  factory ContentDoc.fromMap(String id, Map<String, dynamic> m) => ContentDoc(
        id: id,
        kind: m['kind'] == 'inst' ? ContentKind.inst : ContentKind.gov,
        icon: m['icon'] ?? 'doc', title: m['title'] ?? '', tag: m['tag'] ?? '', summary: m['summary'] ?? '',
        updatedAt: DateTime.fromMillisecondsSinceEpoch((m['updatedAt'] as num? ?? 0).toInt()),
        sections: ((m['sections'] ?? const []) as List)
            .map((e) => ContentSection.fromMap(Map<String, dynamic>.from(e)))
            .whereType<ContentSection>()
            .toList(),
      );
}

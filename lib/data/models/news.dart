class News {
  final String id, category, source, readTime, title, summary, body;
  final DateTime date;
  final List<({String label, String value})> facts;
  final String? sourceUrl, imageUrl;
  final bool published, pinned;
  const News({
    required this.id, required this.category, required this.source, required this.readTime,
    required this.title, required this.summary, required this.body, required this.date,
    this.facts = const [], this.sourceUrl, this.imageUrl,
    this.published = false, this.pinned = false,
  });

  Map<String, dynamic> toMap() => {
        'category': category, 'source': source, 'readTime': readTime,
        'title': title, 'summary': summary, 'body': body,
        'date': date.millisecondsSinceEpoch,
        'facts': [for (final f in facts) {'label': f.label, 'value': f.value}],
        'sourceUrl': sourceUrl, 'imageUrl': imageUrl,
        'published': published, 'pinned': pinned,
      };

  News copyWith({bool? published, bool? pinned}) => News(
        id: id, category: category, source: source, readTime: readTime,
        title: title, summary: summary, body: body, date: date, facts: facts,
        sourceUrl: sourceUrl, imageUrl: imageUrl,
        published: published ?? this.published, pinned: pinned ?? this.pinned,
      );

  factory News.fromMap(String id, Map<String, dynamic> m) => News(
        id: id,
        category: m['category'] ?? 'Geral', source: m['source'] ?? '',
        readTime: m['readTime'] ?? '', title: m['title'] ?? '',
        summary: m['summary'] ?? '', body: m['body'] ?? '',
        date: DateTime.fromMillisecondsSinceEpoch((m['date'] as num? ?? 0).toInt()),
        facts: ((m['facts'] ?? const []) as List)
            .map((e) => (label: (e['label'] ?? '') as String, value: (e['value'] ?? '') as String))
            .toList(),
        sourceUrl: m['sourceUrl'], imageUrl: m['imageUrl'],
        published: m['published'] ?? false, pinned: m['pinned'] ?? false,
      );
}

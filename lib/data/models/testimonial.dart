class Testimonial {
  final String name, course, org, text;
  final int stars;
  final String? authorUid;
  final DateTime? createdAt;
  const Testimonial({
    required this.name, required this.course, required this.org,
    required this.text, required this.stars,
    this.authorUid, this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'name': name, 'course': course, 'org': org, 'text': text, 'stars': stars,
        'authorUid': authorUid,
        'createdAt': (createdAt ?? DateTime.now()).millisecondsSinceEpoch,
      };

  factory Testimonial.fromMap(String id, Map<String, dynamic> m) => Testimonial(
        name: m['name'] ?? '', course: m['course'] ?? '', org: m['org'] ?? '',
        text: m['text'] ?? '', stars: (m['stars'] ?? 5) as int,
        authorUid: m['authorUid'],
        createdAt: m['createdAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int));
}

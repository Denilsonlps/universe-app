enum BenefitKind { gov, inst }

class Benefit {
  final String icon, title, tag, description;
  final List<String> steps; // forma de obtenção (RF011)
  final String? url;         // portal oficial
  const Benefit({
    required this.icon, required this.title, required this.tag,
    required this.description, required this.steps, this.url,
  });

  Map<String, dynamic> toMap() => {
        'icon': icon, 'title': title, 'tag': tag,
        'description': description, 'steps': steps, 'url': url,
      };

  factory Benefit.fromMap(String id, Map<String, dynamic> m) => Benefit(
        icon: m['icon'] ?? 'doc', title: m['title'] ?? '', tag: m['tag'] ?? '',
        description: m['description'] ?? '',
        steps: List<String>.from(m['steps'] ?? const []),
        url: m['url']);
}

class Course {
  final String name, category, type, duration, period, icon;
  const Course({
    required this.name, required this.category, required this.type,
    required this.duration, required this.period, required this.icon,
  });

  Map<String, dynamic> toMap() => {
        'name': name, 'category': category, 'type': type,
        'duration': duration, 'period': period, 'icon': icon,
      };

  factory Course.fromMap(String id, Map<String, dynamic> m) => Course(
        name: m['name'] ?? '', category: m['category'] ?? '', type: m['type'] ?? '',
        duration: m['duration'] ?? '', period: m['period'] ?? '', icon: m['icon'] ?? 'doc');
}

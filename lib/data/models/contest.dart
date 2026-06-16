/// Concurso público / edital. RF035-RF036.
class Contest {
  final String id, role, org, vagas, salary, level, about;
  final String? link;
  final DateTime deadline; // fim do período de inscrição (RF036)

  const Contest({
    required this.id, required this.role, required this.org, required this.vagas,
    required this.salary, required this.level, required this.about,
    required this.deadline, this.link,
  });

  /// RF036: edital visível apenas durante o período de inscrição (+30d p/ consulta).
  bool visibleAt(DateTime now) => !now.isAfter(deadline.add(const Duration(days: 30)));
  bool isOpenAt(DateTime now) => !now.isAfter(deadline);

  Map<String, dynamic> toMap() => {
        'role': role, 'org': org, 'vagas': vagas, 'salary': salary, 'level': level,
        'about': about, 'link': link, 'deadline': deadline.millisecondsSinceEpoch,
      };

  factory Contest.fromMap(String id, Map<String, dynamic> m) => Contest(
        id: id, role: m['role'] ?? '', org: m['org'] ?? '', vagas: m['vagas'] ?? '',
        salary: m['salary'] ?? '', level: m['level'] ?? '', about: m['about'] ?? '', link: m['link'],
        deadline: DateTime.fromMillisecondsSinceEpoch((m['deadline'] ?? 0) as int),
      );
}

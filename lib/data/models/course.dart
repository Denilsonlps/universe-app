class Course {
  final String name, category, type, duration, period, icon;
  // Conteúdo rico opcional (do FlutterFlow / site do curso).
  final String? about;          // Sobre o curso (texto)
  final String? research;       // Pesquisas e Extensões (texto)
  final String? researchUrl;    // link de pesquisa (ex.: grupo no CNPq)
  final String? curriculumUrl;  // Grade curricular (documento)
  final String? ppcUrl;         // Projeto Pedagógico de Curso (documento)
  const Course({
    required this.name, required this.category, required this.type,
    required this.duration, required this.period, required this.icon,
    this.about, this.research, this.researchUrl, this.curriculumUrl, this.ppcUrl,
  });

  Map<String, dynamic> toMap() => {
        'name': name, 'category': category, 'type': type,
        'duration': duration, 'period': period, 'icon': icon,
        if (about != null) 'about': about,
        if (research != null) 'research': research,
        if (researchUrl != null) 'researchUrl': researchUrl,
        if (curriculumUrl != null) 'curriculumUrl': curriculumUrl,
        if (ppcUrl != null) 'ppcUrl': ppcUrl,
      };

  factory Course.fromMap(String id, Map<String, dynamic> m) => Course(
        name: m['name'] ?? '', category: m['category'] ?? '', type: m['type'] ?? '',
        duration: m['duration'] ?? '', period: m['period'] ?? '', icon: m['icon'] ?? 'doc',
        about: m['about'] as String?, research: m['research'] as String?,
        researchUrl: m['researchUrl'] as String?, curriculumUrl: m['curriculumUrl'] as String?,
        ppcUrl: m['ppcUrl'] as String?,
      );
}

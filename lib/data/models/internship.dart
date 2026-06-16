/// Vaga de estágio. Campos i–x conforme RF033 do TCC.
class Internship {
  final String id;
  final String role;             // iii cargo
  final String companyName;      // i empresa
  final String area;             // ii área de atuação
  final String duration;         // iv duração
  final String jobDescription;   // v descrição da vaga
  final List<String> requirements; // vi pré-requisitos
  final List<String> niceToHave;   // vii diferenciais
  final String companyDescription; // viii descrição da empresa
  final List<String> benefits;     // ix benefícios
  final String grant;              // x salário/bolsa
  // auxiliares
  final String course;   // RF031: organização por curso (rótulo curto)
  final String mode;     // presencial/híbrido
  final String? link;
  final String? tag;     // ex.: 'Novo'
  final bool open;       // RF034: disponível ou não
  final DateTime? closedAt; // quando foi encerrada (RF034)

  const Internship({
    required this.id, required this.role, required this.companyName, required this.area,
    required this.duration, required this.jobDescription, required this.requirements,
    required this.niceToHave, required this.companyDescription, required this.benefits,
    required this.grant, required this.course, required this.mode,
    this.link, this.tag, this.open = true, this.closedAt,
  });

  /// RF034: vaga encerrada permanece visível por até 30 dias após `closedAt`.
  bool visibleAt(DateTime now) {
    if (open) return true;
    final since = closedAt;
    if (since == null) return true; // sem data → mantém visível
    return now.difference(since).inDays <= 30;
  }

  Map<String, dynamic> toMap() => {
        'role': role, 'companyName': companyName, 'area': area, 'duration': duration,
        'jobDescription': jobDescription, 'requirements': requirements, 'niceToHave': niceToHave,
        'companyDescription': companyDescription, 'benefits': benefits, 'grant': grant,
        'course': course, 'mode': mode, 'link': link, 'tag': tag, 'open': open,
        'closedAt': closedAt?.millisecondsSinceEpoch,
      };

  factory Internship.fromMap(String id, Map<String, dynamic> m) => Internship(
        id: id, role: m['role'] ?? '', companyName: m['companyName'] ?? '', area: m['area'] ?? '',
        duration: m['duration'] ?? '', jobDescription: m['jobDescription'] ?? '',
        requirements: List<String>.from(m['requirements'] ?? const []),
        niceToHave: List<String>.from(m['niceToHave'] ?? const []),
        companyDescription: m['companyDescription'] ?? '',
        benefits: List<String>.from(m['benefits'] ?? const []),
        grant: m['grant'] ?? '', course: m['course'] ?? 'Todos', mode: m['mode'] ?? '',
        link: m['link'], tag: m['tag'], open: m['open'] ?? true,
        closedAt: m['closedAt'] == null ? null : DateTime.fromMillisecondsSinceEpoch(m['closedAt'] as int),
      );
}

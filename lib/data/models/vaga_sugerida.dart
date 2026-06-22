import 'internship.dart';

/// Vaga coletada pelo pipeline, aguardando curadoria do Setor de Estágios.
/// Envolve um [Internship] (payload) + metadados de procedência/estado.
class VagaSugerida {
  final String id; // = sha1(link), igual ao id da Internship ao aprovar
  final Internship vaga;
  final DateTime scrapedAt;
  final String source; // 'gupy-auto'
  final String status; // 'pendente' | 'recusada'
  const VagaSugerida({
    required this.id, required this.vaga, required this.scrapedAt,
    required this.source, this.status = 'pendente',
  });

  Map<String, dynamic> toMap() => {
        ...vaga.toMap(),
        'scrapedAt': scrapedAt.millisecondsSinceEpoch,
        'source': source,
        'status': status,
      };

  factory VagaSugerida.fromMap(String id, Map<String, dynamic> m) => VagaSugerida(
        id: id,
        vaga: Internship.fromMap(id, m),
        scrapedAt: DateTime.fromMillisecondsSinceEpoch((m['scrapedAt'] as num? ?? 0).toInt()),
        source: m['source'] ?? 'gupy-auto',
        status: m['status'] ?? 'pendente',
      );
}

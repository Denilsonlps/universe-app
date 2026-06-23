import 'news.dart';

/// Notícia coletada pelo pipeline, aguardando curadoria do Setor.
/// Envolve uma [News] (payload) + metadados de estado.
class NoticiaSugerida {
  final String id; // = sha1(link), igual ao id da News ao aprovar
  final News noticia;
  final DateTime scrapedAt;
  final String status; // 'pendente' | 'recusada'
  const NoticiaSugerida({required this.id, required this.noticia, required this.scrapedAt, this.status = 'pendente'});

  Map<String, dynamic> toMap() => {
        ...noticia.toMap(),
        'scrapedAt': scrapedAt.millisecondsSinceEpoch,
        'status': status,
      };

  factory NoticiaSugerida.fromMap(String id, Map<String, dynamic> m) => NoticiaSugerida(
        id: id,
        noticia: News.fromMap(id, m),
        scrapedAt: DateTime.fromMillisecondsSinceEpoch((m['scrapedAt'] as num? ?? 0).toInt()),
        status: m['status'] ?? 'pendente',
      );
}

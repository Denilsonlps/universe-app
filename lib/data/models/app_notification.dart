/// Aviso exibido na central de notificações do app.
/// Gerado quando o admin aprova uma vaga/notícia (RF037) ou manualmente.
class AppNotification {
  final String id;
  final String title, body;
  final String type; // 'vaga' | 'noticia' | 'sistema'
  final String? targetCourse; // rótulo curto do curso (null = para todos)
  final String? route; // destino ao tocar (ex.: '/estagio', '/noticias/<id>')
  final DateTime createdAt;

  const AppNotification({
    required this.id, required this.title, required this.body, required this.type,
    this.targetCourse, this.route, required this.createdAt,
  });

  /// Ícone padrão por tipo (chave de appIcon).
  String get icon => switch (type) { 'vaga' => 'briefcase', _ => 'bell' };

  /// Verdadeiro se este aviso interessa a quem cursa [meuCursoCurto].
  /// Avisos sem [targetCourse] valem para todos.
  bool matchesCourse(String? meuCursoCurto) =>
      targetCourse == null || targetCourse == meuCursoCurto;

  Map<String, dynamic> toMap() => {
        'title': title, 'body': body, 'type': type,
        'targetCourse': targetCourse, 'route': route,
        'createdAt': createdAt.millisecondsSinceEpoch,
      };

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
        id: id,
        title: m['title'] ?? '', body: m['body'] ?? '',
        type: m['type'] ?? 'sistema',
        targetCourse: m['targetCourse'] as String?,
        route: m['route'] as String?,
        createdAt: DateTime.fromMillisecondsSinceEpoch((m['createdAt'] as num? ?? 0).toInt()),
      );
}

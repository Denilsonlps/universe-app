/// Item da lista "Sobre o campus".
class IfspInfo {
  final String key, icon, title, subtitle;
  final IfspDetail? detail;
  const IfspInfo({
    required this.key, required this.icon, required this.title, required this.subtitle,
    this.detail,
  });

  Map<String, dynamic> toMap() => {
        'icon': icon, 'title': title, 'subtitle': subtitle, 'detail': detail?.toMap(),
      };

  factory IfspInfo.fromMap(String key, Map<String, dynamic> m) => IfspInfo(
        key: key, icon: m['icon'] ?? 'doc', title: m['title'] ?? '', subtitle: m['subtitle'] ?? '',
        detail: m['detail'] == null
            ? null
            : IfspDetail.fromMap(key, Map<String, dynamic>.from(m['detail'])));
}

/// Detalhe de um item do campus. `body` para texto livre; `rows` para pares chave/valor.
class IfspDetail {
  final String key, icon, title;
  final String? body;
  final List<(String, String)> rows; // ex.: horários, contatos
  const IfspDetail({required this.key, required this.icon, required this.title, this.body, this.rows = const []});

  Map<String, dynamic> toMap() => {
        'icon': icon, 'title': title, 'body': body,
        'rows': rows.map((r) => [r.$1, r.$2]).toList(),
      };

  factory IfspDetail.fromMap(String key, Map<String, dynamic> m) => IfspDetail(
        key: key, icon: m['icon'] ?? 'doc', title: m['title'] ?? '', body: m['body'],
        rows: ((m['rows'] ?? const []) as List)
            .map((r) => (r[0] as String, r[1] as String))
            .toList());
}

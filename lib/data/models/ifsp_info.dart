/// Item da lista "Sobre o campus".
class IfspInfo {
  final String key, icon, title, subtitle;
  const IfspInfo({required this.key, required this.icon, required this.title, required this.subtitle});
}

/// Detalhe de um item do campus. `body` para texto livre; `rows` para pares chave/valor.
class IfspDetail {
  final String key, icon, title;
  final String? body;
  final List<(String, String)> rows; // ex.: horários, contatos
  const IfspDetail({required this.key, required this.icon, required this.title, this.body, this.rows = const []});
}

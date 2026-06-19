import '../models/content_doc.dart';

const _accents = {
  'á':'a','à':'a','â':'a','ã':'a','ä':'a','é':'e','è':'e','ê':'e','ë':'e',
  'í':'i','ì':'i','î':'i','ï':'i','ó':'o','ò':'o','ô':'o','õ':'o','ö':'o',
  'ú':'u','ù':'u','û':'u','ü':'u','ç':'c','ñ':'n',
};

/// Converte um texto em slug ASCII minúsculo com hífens.
String slugify(String input) {
  var s = input.toLowerCase().trim();
  s = s.split('').map((ch) => _accents[ch] ?? ch).join();
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '-');
  s = s.replaceAll(RegExp(r'-+'), '-');
  s = s.replaceAll(RegExp(r'^-|-$'), '');
  return s;
}

/// Gera um id único `<kind>-<slug>` evitando os ids já existentes.
String generateDocId(ContentKind kind, String title, Set<String> existing) {
  final base = '${kind.name}-${slugify(title)}';
  if (!existing.contains(base)) return base;
  var n = 2;
  while (existing.contains('$base-$n')) {
    n++;
  }
  return '$base-$n';
}

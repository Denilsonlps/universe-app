import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/content/content_id.dart';
import 'package:universe_app/data/models/content_doc.dart';

void main() {
  test('slugify normaliza acentos, espaços e símbolos', () {
    expect(slugify('Cadastro Único'), 'cadastro-unico');
    expect(slugify('PAP — Auxílio Permanência'), 'pap-auxilio-permanencia');
    expect(slugify('  Olá!! Mundo  '), 'ola-mundo');
  });

  test('generateDocId prefixa por kind e evita colisão', () {
    expect(generateDocId(ContentKind.gov, 'ID Jovem', const {}), 'gov-id-jovem');
    expect(generateDocId(ContentKind.inst, 'Monitoria', const {'inst-monitoria'}), 'inst-monitoria-2');
    expect(generateDocId(ContentKind.gov, 'X', const {'gov-x', 'gov-x-2'}), 'gov-x-3');
  });
}

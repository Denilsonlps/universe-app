import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/models/contest.dart';
import 'package:universe_app/data/models/benefit.dart';
import 'package:universe_app/data/models/course.dart';
import 'package:universe_app/data/models/ifsp_info.dart';

void main() {
  test('IfspDetail.rows serializa como lista de mapas (Firestore não aceita array de array)', () {
    const d = IfspDetail(key: 'horario', icon: 'clock', title: 'Horário', rows: [('Seg a Sex', '08h às 22h'), ('Sábado', '08h às 12h')]);
    final map = d.toMap();
    // rows deve ser List<Map>, não List<List>
    expect(map['rows'], isA<List>());
    expect((map['rows'] as List).first, isA<Map>());
    final back = IfspDetail.fromMap('horario', map);
    expect(back.rows.length, 2);
    expect(back.rows.first.$1, 'Seg a Sex');
    expect(back.rows.first.$2, '08h às 22h');
  });

  test('Internship round-trip toMap/fromMap', () {
    final e = Internship(
      id: 'e1', role: 'Dev', companyName: 'Org', area: 'TI', duration: '12m',
      jobDescription: 'desc', requirements: const ['a'], niceToHave: const ['b'],
      companyDescription: 'sobre', benefits: const ['VT'], grant: 'R\$ 1.000',
      course: 'ADS', mode: 'Híbrido', open: false, closedAt: DateTime(2026, 6, 1),
    );
    final back = Internship.fromMap('e1', e.toMap());
    expect(back.role, 'Dev');
    expect(back.companyName, 'Org');
    expect(back.requirements, ['a']);
    expect(back.open, false);
    expect(back.closedAt, DateTime(2026, 6, 1));
  });

  test('Contest round-trip', () {
    final c = Contest(id: 'c1', role: 'Analista', org: 'IFSP', vagas: '10', salary: 'R\$ 4.000', level: 'Superior', about: 'x', deadline: DateTime(2026, 7, 30));
    final back = Contest.fromMap('c1', c.toMap());
    expect(back.deadline, DateTime(2026, 7, 30));
    expect(back.role, 'Analista');
  });

  test('Benefit e Course round-trip', () {
    const b = Benefit(icon: 'card', title: 'ID Jovem', tag: 'Federal', description: 'd', steps: ['s1'], url: 'https://x');
    final bb = Benefit.fromMap('id', b.toMap());
    expect(bb.title, 'ID Jovem');
    expect(bb.steps, ['s1']);
    expect(bb.url, 'https://x');
    const co = Course(name: 'ADS', category: 'Graduação', type: 'Tecnólogo', duration: '3 anos', period: 'Noturno', icon: 'doc');
    expect(Course.fromMap('id', co.toMap()).name, 'ADS');
  });
}

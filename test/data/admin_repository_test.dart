import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/profile/student_profile.dart';
import 'package:universe_app/data/models/internship.dart';
import 'package:universe_app/data/repositories/fake_universe_repository.dart';

void main() {
  test('StudentProfile lê role mas não o grava', () {
    final p = StudentProfile.fromMap('u1', {'course': 'ADS', 'role': 'admin'});
    expect(p.role, 'admin');
    expect(p.toMap().containsKey('role'), isFalse); // não sobrescreve role ao salvar
  });

  test('role default é student', () {
    expect(StudentProfile.fromMap('u1', {}).role, 'student');
  });

  test('upsert cria e atualiza; delete remove (Fake)', () async {
    final repo = FakeUniverseRepository();
    final id = repo.newId('internships');
    final v = Internship(id: id, role: 'Nova vaga', companyName: 'X', area: 'TI', duration: '6m',
      jobDescription: 'd', requirements: const [], niceToHave: const [], companyDescription: 's',
      benefits: const [], grant: 'R\$ 1.000', course: 'ADS', mode: 'Híbrido');
    await repo.upsertInternship(v);
    var all = await repo.watchAllInternships().first;
    expect(all.any((e) => e.id == id && e.role == 'Nova vaga'), isTrue);
    await repo.upsertInternship(Internship(id: id, role: 'Editada', companyName: 'X', area: 'TI', duration: '6m',
      jobDescription: 'd', requirements: const [], niceToHave: const [], companyDescription: 's',
      benefits: const [], grant: 'R\$ 1.000', course: 'ADS', mode: 'Híbrido'));
    all = await repo.watchAllInternships().first;
    expect(all.firstWhere((e) => e.id == id).role, 'Editada');
    await repo.deleteInternship(id);
    all = await repo.watchAllInternships().first;
    expect(all.any((e) => e.id == id), isFalse);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/profile/student_profile.dart';
import 'package:universe_app/data/profile/fake_profile_repository.dart';

void main() {
  test('save e get retornam o perfil', () async {
    final repo = FakeProfileRepository();
    expect(await repo.get('u1'), isNull);
    await repo.save(const StudentProfile(uid: 'u1', course: 'Análise e Desenvolvimento de Sistemas', enrollment: 'PT3024187'));
    final p = await repo.get('u1');
    expect(p?.course, 'Análise e Desenvolvimento de Sistemas');
    expect(p?.enrollment, 'PT3024187');
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:universe_app/data/models/app_notification.dart';

void main() {
  test('AppNotification round-trip (toMap/fromMap)', () {
    final n = AppNotification(
      id: 'n1', type: 'vaga', targetCourse: 'ADS',
      title: 'Nova vaga', body: 'TechCorp · R\$ 1.200',
      route: '/estagio', createdAt: DateTime(2026, 6, 24, 9),
    );
    final back = AppNotification.fromMap('n1', n.toMap());
    expect(back.id, 'n1');
    expect(back.type, 'vaga');
    expect(back.targetCourse, 'ADS');
    expect(back.title, 'Nova vaga');
    expect(back.route, '/estagio');
    expect(back.createdAt, DateTime(2026, 6, 24, 9));
    expect(back.icon, 'briefcase');
  });

  test('matchesCourse: alvo nulo vale para todos; senão casa pelo rótulo curto', () {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final geral = AppNotification(id: 'g', type: 'noticia', title: 't', body: 'b', createdAt: epoch);
    expect(geral.matchesCourse('ADS'), isTrue);
    expect(geral.matchesCourse(null), isTrue);

    final ads = AppNotification(id: 'a', type: 'vaga', targetCourse: 'ADS', title: 't', body: 'b', createdAt: epoch);
    expect(ads.matchesCourse('ADS'), isTrue);
    expect(ads.matchesCourse('Logística'), isFalse);
    expect(ads.matchesCourse(null), isFalse);
  });
}

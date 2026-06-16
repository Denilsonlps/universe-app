import 'package:cloud_firestore/cloud_firestore.dart';
import 'fake_universe_repository.dart';

/// Sobe o conteúdo do FakeUniverseRepository para o Firestore (idempotente).
/// Uso dev/admin apenas. IDs determinísticos via set(merge:true) onde houver id.
Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final fake = FakeUniverseRepository();
  final batch = db.batch();

  for (var i = 0; i < fake.allCourses.length; i++) {
    batch.set(db.collection('courses').doc('c$i'), fake.allCourses[i].toMap());
  }
  for (final b in fake.allBenGov) {
    batch.set(db.collection('benefits').doc('gov_${b.title.hashCode}'), {...b.toMap(), 'kind': 'gov'});
  }
  for (final b in fake.allBenInst) {
    batch.set(db.collection('benefits').doc('inst_${b.title.hashCode}'), {...b.toMap(), 'kind': 'inst'});
  }
  for (final e in fake.allInternships) {
    batch.set(db.collection('internships').doc(e.id), e.toMap());
  }
  for (final ct in fake.allContests) {
    batch.set(db.collection('contests').doc(ct.id), ct.toMap());
  }
  for (var i = 0; i < fake.allFaqs.length; i++) {
    batch.set(db.collection('faqs').doc('f$i'), fake.allFaqs[i].toMap());
  }
  for (final info in fake.allIfspInfo) {
    batch.set(db.collection('ifspInfo').doc(info.key), info.toMap());
  }
  await batch.commit();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'fake_universe_repository.dart';

/// Sobe o conteúdo do FakeUniverseRepository para o Firestore (idempotente).
/// Uso dev/admin apenas. IDs determinísticos via set(merge:true) onde houver id.
Future<void> seedFirestore() async {
  final db = FirebaseFirestore.instance;
  final fake = FakeUniverseRepository();
  final uid = FirebaseAuth.instance.currentUser?.uid;
  final batch = db.batch();

  for (var i = 0; i < fake.allCourses.length; i++) {
    batch.set(db.collection('courses').doc('c$i'), fake.allCourses[i].toMap());
  }
  for (final d in fake.allContentDocs) {
    batch.set(db.collection('contentDocs').doc(d.id), d.toMap());
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
  // Depoimentos de exemplo: authorUid = admin logado (satisfaz a regra de criação).
  for (var i = 0; i < fake.allTestimonials.length; i++) {
    batch.set(db.collection('testimonials').doc('t$i'), {...fake.allTestimonials[i].toMap(), 'authorUid': uid});
  }
  for (final n in fake.allNews) {
    batch.set(db.collection('news').doc(n.id), n.toMap());
  }
  for (final s in fake.allVagasSugeridas) {
    batch.set(db.collection('vagas_sugeridas').doc(s.id), s.toMap());
  }
  await batch.commit();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import '../models/content_doc.dart';
import '../models/news.dart';
import '../models/vaga_sugerida.dart';
import 'universe_repository.dart';

class FirestoreUniverseRepository implements UniverseRepository {
  FirestoreUniverseRepository(this._db);
  final FirebaseFirestore _db;

  List<T> _map<T>(QuerySnapshot s, T Function(String, Map<String, dynamic>) f) =>
      s.docs.map((d) => f(d.id, d.data() as Map<String, dynamic>)).toList();

  @override
  Stream<List<Course>> watchCourses() =>
      _db.collection('courses').snapshots().map((s) => _map(s, Course.fromMap));

  @override
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'}) =>
      _db.collection('internships').snapshots().map((s) {
        final now = DateTime.now();
        return _map(s, Internship.fromMap)
            .where((e) => e.visibleAt(now))
            .where((e) => courseFilter == 'Todos' || e.course == courseFilter)
            .toList();
      });

  @override
  Stream<List<Contest>> watchContests() => _db.collection('contests').snapshots().map((s) {
        final now = DateTime.now();
        return _map(s, Contest.fromMap).where((c) => c.visibleAt(now)).toList();
      });

  @override
  Stream<List<Testimonial>> watchTestimonials() =>
      _db.collection('testimonials').orderBy('createdAt', descending: true).snapshots().map((s) => _map(s, Testimonial.fromMap));

  @override
  Stream<List<Faq>> watchFaqs() => _db.collection('faqs').snapshots().map((s) => _map(s, Faq.fromMap));

  @override
  Stream<List<IfspInfo>> watchIfspInfo() => _db.collection('ifspInfo').snapshots().map((s) => _map(s, IfspInfo.fromMap));

  @override
  Stream<List<ContentDoc>> watchContentDocs(ContentKind kind) => _db.collection('contentDocs')
      .where('kind', isEqualTo: kind.name).snapshots().map((s) => _map(s, ContentDoc.fromMap));

  @override
  Stream<ContentDoc?> watchContentDoc(String id) =>
      _db.collection('contentDocs').doc(id).snapshots().map((d) => d.exists ? ContentDoc.fromMap(d.id, d.data()!) : null);

  @override
  Future<void> addTestimonial(Testimonial t) => _db.collection('testimonials').add(t.toMap());

  @override
  Stream<List<Internship>> watchAllInternships() =>
      _db.collection('internships').snapshots().map((s) => _map(s, Internship.fromMap));

  @override
  Stream<List<Contest>> watchAllContests() =>
      _db.collection('contests').snapshots().map((s) => _map(s, Contest.fromMap));

  @override
  Future<void> upsertInternship(Internship v) =>
      _db.collection('internships').doc(v.id).set(v.toMap());

  @override
  Future<void> deleteInternship(String id) => _db.collection('internships').doc(id).delete();

  @override
  Future<void> upsertContest(Contest c) => _db.collection('contests').doc(c.id).set(c.toMap());

  @override
  Future<void> deleteContest(String id) => _db.collection('contests').doc(id).delete();

  @override
  String newId(String collection) => _db.collection(collection).doc().id;

  @override
  Stream<List<ContentDoc>> watchAllContentDocs() =>
      _db.collection('contentDocs').snapshots().map((s) => _map(s, ContentDoc.fromMap));

  @override
  Future<void> upsertContentDoc(ContentDoc d) =>
      _db.collection('contentDocs').doc(d.id).set(d.toMap());

  @override
  Future<void> deleteContentDoc(String id) => _db.collection('contentDocs').doc(id).delete();

  @override
  Stream<List<News>> watchPublishedNews() => _db.collection('news')
      .where('published', isEqualTo: true).snapshots().map((s) {
        final list = _map(s, News.fromMap);
        list.sort((a, b) { if (a.pinned != b.pinned) return a.pinned ? -1 : 1; return b.date.compareTo(a.date); });
        return list;
      });
  @override
  Stream<List<News>> watchAllNews() => _db.collection('news').snapshots().map((s) {
        final list = _map(s, News.fromMap);
        list.sort((a, b) => b.date.compareTo(a.date));
        return list;
      });
  @override
  Future<void> upsertNews(News n) => _db.collection('news').doc(n.id).set(n.toMap());
  @override
  Future<void> deleteNews(String id) => _db.collection('news').doc(id).delete();

  @override
  Stream<List<VagaSugerida>> watchVagasSugeridas() =>
      _db.collection('vagas_sugeridas').snapshots().map((s) {
        final list = _map(s, VagaSugerida.fromMap).where((v) => v.status == 'pendente').toList();
        list.sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));
        return list;
      });
  @override
  Future<void> rejeitarVagaSugerida(String id) =>
      _db.collection('vagas_sugeridas').doc(id).set({'status': 'recusada'}, SetOptions(merge: true));
  @override
  Future<void> deleteVagaSugerida(String id) => _db.collection('vagas_sugeridas').doc(id).delete();
}

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
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
  Stream<List<Benefit>> watchBenefits(BenefitKind kind) => _db.collection('benefits')
      .where('kind', isEqualTo: kind == BenefitKind.gov ? 'gov' : 'inst')
      .snapshots().map((s) => _map(s, Benefit.fromMap));

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
  Future<void> addTestimonial(Testimonial t) => _db.collection('testimonials').add(t.toMap());
}

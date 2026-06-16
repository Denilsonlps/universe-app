import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';

/// Acesso ao conteúdo do app (camada de dados) — tempo real via streams.
abstract interface class UniverseRepository {
  Stream<List<Course>> watchCourses();
  Stream<List<Benefit>> watchBenefits(BenefitKind kind);
  /// Estágios visíveis (RF034) opcionalmente filtrados por curso (RF031).
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'});
  /// Concursos visíveis (RF036).
  Stream<List<Contest>> watchContests();
  Stream<List<Testimonial>> watchTestimonials();
  Stream<List<Faq>> watchFaqs();
  Stream<List<IfspInfo>> watchIfspInfo();

  Future<void> addTestimonial(Testimonial t);
}

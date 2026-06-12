import '../models/course.dart';
import '../models/benefit.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';

/// Acesso ao conteúdo do app (camada de dados). Mock agora; Firestore depois.
abstract interface class UniverseRepository {
  List<Course> courses();
  List<Benefit> benefits(BenefitKind kind);
  List<Testimonial> testimonials();
  List<Faq> faqs();
  List<IfspInfo> ifspInfo();
  IfspDetail? ifspDetail(String key);

  /// Estágios visíveis (aplica RF034) — opcionalmente filtrados por curso (RF031).
  List<Internship> internships({String courseFilter = 'Todos', DateTime? now});
  Internship? internship(String id);

  /// Concursos visíveis (aplica RF036).
  List<Contest> contests({DateTime? now});
  Contest? contest(String id);
}

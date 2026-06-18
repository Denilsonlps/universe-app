import '../models/course.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import '../models/content_doc.dart';

/// Acesso ao conteúdo do app (camada de dados) — tempo real via streams.
abstract interface class UniverseRepository {
  Stream<List<Course>> watchCourses();
  /// Estágios visíveis (RF034) opcionalmente filtrados por curso (RF031).
  Stream<List<Internship>> watchInternships({String courseFilter = 'Todos'});
  /// Concursos visíveis (RF036).
  Stream<List<Contest>> watchContests();
  Stream<List<Testimonial>> watchTestimonials();
  Stream<List<Faq>> watchFaqs();
  Stream<List<IfspInfo>> watchIfspInfo();

  /// Documentos de conteúdo rico por tipo (gov/inst).
  Stream<List<ContentDoc>> watchContentDocs(ContentKind kind);
  /// Um documento de conteúdo por id (null se não existir).
  Stream<ContentDoc?> watchContentDoc(String id);

  Future<void> addTestimonial(Testimonial t);

  // Leitura admin (sem filtro de visibilidade)
  Stream<List<Internship>> watchAllInternships();
  Stream<List<Contest>> watchAllContests();
  // Escrita (admin)
  Future<void> upsertInternship(Internship vaga);
  Future<void> deleteInternship(String id);
  Future<void> upsertContest(Contest c);
  Future<void> deleteContest(String id);
  /// Gera um novo id para uma coleção ('internships' | 'contests').
  String newId(String collection);
}

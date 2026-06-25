import '../models/course.dart';
import '../models/internship.dart';
import '../models/contest.dart';
import '../models/testimonial.dart';
import '../models/faq.dart';
import '../models/ifsp_info.dart';
import '../models/content_doc.dart';
import '../models/news.dart';
import '../models/vaga_sugerida.dart';
import '../models/noticia_sugerida.dart';
import '../models/app_notification.dart';

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
  /// Todos os documentos de conteúdo (sem filtro, para o admin).
  Stream<List<ContentDoc>> watchAllContentDocs();
  Future<void> upsertContentDoc(ContentDoc d);
  Future<void> deleteContentDoc(String id);

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

  Stream<List<News>> watchPublishedNews();
  Stream<List<News>> watchAllNews();
  Future<void> upsertNews(News n);
  Future<void> deleteNews(String id);

  Stream<List<VagaSugerida>> watchVagasSugeridas();
  Future<void> rejeitarVagaSugerida(String id);
  Future<void> deleteVagaSugerida(String id);

  Stream<List<NoticiaSugerida>> watchNoticiasSugeridas();
  Future<void> rejeitarNoticiaSugerida(String id);
  Future<void> deleteNoticiaSugerida(String id);

  /// Avisos da central de notificações (mais recentes primeiro).
  Stream<List<AppNotification>> watchNotifications();
  Future<void> addNotification(AppNotification n);
}

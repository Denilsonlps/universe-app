import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course.dart';
import '../../data/models/internship.dart';
import '../../data/models/contest.dart';
import '../../data/models/testimonial.dart';
import '../../data/models/faq.dart';
import '../../data/models/ifsp_info.dart';
import '../../data/models/content_doc.dart';
import '../../data/models/news.dart';
import '../../data/models/vaga_sugerida.dart';
import '../../data/models/noticia_sugerida.dart';
import '../../data/models/app_notification.dart';
import '../../data/repositories/universe_repository.dart';
import '../../data/repositories/firestore_universe_repository.dart';
import '../../data/storage/storage_service.dart';

final universeRepositoryProvider = Provider<UniverseRepository>((ref) =>
    FirestoreUniverseRepository(FirebaseFirestore.instance));

final storageServiceProvider = Provider<StorageService>((ref) => FirebaseStorageService(FirebaseStorage.instance));

final coursesProvider = StreamProvider<List<Course>>((ref) => ref.watch(universeRepositoryProvider).watchCourses());
final internshipsProvider = StreamProvider.family<List<Internship>, String>((ref, course) => ref.watch(universeRepositoryProvider).watchInternships(courseFilter: course));
final contestsProvider = StreamProvider<List<Contest>>((ref) => ref.watch(universeRepositoryProvider).watchContests());
final testimonialsProvider = StreamProvider<List<Testimonial>>((ref) => ref.watch(universeRepositoryProvider).watchTestimonials());
final faqsProvider = StreamProvider<List<Faq>>((ref) => ref.watch(universeRepositoryProvider).watchFaqs());
final ifspInfoProvider = StreamProvider<List<IfspInfo>>((ref) => ref.watch(universeRepositoryProvider).watchIfspInfo());
final allInternshipsProvider = StreamProvider<List<Internship>>((ref) => ref.watch(universeRepositoryProvider).watchAllInternships());
final allContestsProvider = StreamProvider<List<Contest>>((ref) => ref.watch(universeRepositoryProvider).watchAllContests());
final contentDocsProvider = StreamProvider.family<List<ContentDoc>, ContentKind>((ref, k) => ref.watch(universeRepositoryProvider).watchContentDocs(k));
final contentDocProvider = StreamProvider.family<ContentDoc?, String>((ref, id) => ref.watch(universeRepositoryProvider).watchContentDoc(id));
final allContentDocsProvider = StreamProvider<List<ContentDoc>>((ref) => ref.watch(universeRepositoryProvider).watchAllContentDocs());
final publishedNewsProvider = StreamProvider<List<News>>((ref) => ref.watch(universeRepositoryProvider).watchPublishedNews());
final allNewsProvider = StreamProvider<List<News>>((ref) => ref.watch(universeRepositoryProvider).watchAllNews());
final vagasSugeridasProvider = StreamProvider<List<VagaSugerida>>((ref) => ref.watch(universeRepositoryProvider).watchVagasSugeridas());
final noticiasSugeridasProvider = StreamProvider<List<NoticiaSugerida>>((ref) => ref.watch(universeRepositoryProvider).watchNoticiasSugeridas());
final notificationsProvider = StreamProvider<List<AppNotification>>((ref) => ref.watch(universeRepositoryProvider).watchNotifications());

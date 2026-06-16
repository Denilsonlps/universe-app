import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/course.dart';
import '../../data/models/benefit.dart';
import '../../data/models/internship.dart';
import '../../data/models/contest.dart';
import '../../data/models/testimonial.dart';
import '../../data/models/faq.dart';
import '../../data/models/ifsp_info.dart';
import '../../data/repositories/universe_repository.dart';
import '../../data/repositories/firestore_universe_repository.dart';

final universeRepositoryProvider = Provider<UniverseRepository>((ref) =>
    FirestoreUniverseRepository(FirebaseFirestore.instance));

final coursesProvider = StreamProvider<List<Course>>((ref) => ref.watch(universeRepositoryProvider).watchCourses());
final benefitsProvider = StreamProvider.family<List<Benefit>, BenefitKind>((ref, k) => ref.watch(universeRepositoryProvider).watchBenefits(k));
final internshipsProvider = StreamProvider.family<List<Internship>, String>((ref, course) => ref.watch(universeRepositoryProvider).watchInternships(courseFilter: course));
final contestsProvider = StreamProvider<List<Contest>>((ref) => ref.watch(universeRepositoryProvider).watchContests());
final testimonialsProvider = StreamProvider<List<Testimonial>>((ref) => ref.watch(universeRepositoryProvider).watchTestimonials());
final faqsProvider = StreamProvider<List<Faq>>((ref) => ref.watch(universeRepositoryProvider).watchFaqs());
final ifspInfoProvider = StreamProvider<List<IfspInfo>>((ref) => ref.watch(universeRepositoryProvider).watchIfspInfo());

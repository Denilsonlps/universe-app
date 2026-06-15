import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/testimonial.dart';

/// Depoimentos adicionados pelo aluno durante a sessão.
/// (Persistência definitiva virá com o Firestore.)
final userTestimonialsProvider = StateProvider<List<Testimonial>>((ref) => []);

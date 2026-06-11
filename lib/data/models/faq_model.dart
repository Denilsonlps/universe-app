import 'package:cloud_firestore/cloud_firestore.dart';

class FAQModel {
  final String id;
  final String question;
  final String answer;
  final String? category;
  final int order;

  const FAQModel({
    required this.id,
    required this.question,
    required this.answer,
    this.category,
    this.order = 0,
  });

  factory FAQModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FAQModel(
      id: doc.id,
      question: data['question'] as String,
      answer: data['answer'] as String,
      category: data['category'] as String?,
      order: data['order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'question': question,
        'answer': answer,
        'category': category,
        'order': order,
      };
}

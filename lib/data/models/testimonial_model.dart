import 'package:cloud_firestore/cloud_firestore.dart';

class TestimonialModel {
  final String id;
  final String authorName;
  final String? authorCourse;
  final String? authorPhotoUrl;
  final String content;
  final String? company;
  final String? role;
  final DateTime createdAt;

  const TestimonialModel({
    required this.id,
    required this.authorName,
    this.authorCourse,
    this.authorPhotoUrl,
    required this.content,
    this.company,
    this.role,
    required this.createdAt,
  });

  factory TestimonialModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TestimonialModel(
      id: doc.id,
      authorName: data['authorName'] as String,
      authorCourse: data['authorCourse'] as String?,
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      content: data['content'] as String,
      company: data['company'] as String?,
      role: data['role'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'authorName': authorName,
        'authorCourse': authorCourse,
        'authorPhotoUrl': authorPhotoUrl,
        'content': content,
        'company': company,
        'role': role,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}

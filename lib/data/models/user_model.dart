import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? ra;
  final String? courseId;
  final String? photoUrl;
  final bool isAdmin;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.ra,
    this.courseId,
    this.photoUrl,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      ra: data['ra'] as String?,
      courseId: data['courseId'] as String?,
      photoUrl: data['photoUrl'] as String?,
      isAdmin: data['isAdmin'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'ra': ra,
        'courseId': courseId,
        'photoUrl': photoUrl,
        'isAdmin': isAdmin,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? email,
    String? ra,
    String? courseId,
    String? photoUrl,
    bool? isAdmin,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email ?? this.email,
      ra: ra ?? this.ra,
      courseId: courseId ?? this.courseId,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt,
    );
  }
}

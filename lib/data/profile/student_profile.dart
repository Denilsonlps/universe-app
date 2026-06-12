class StudentProfile {
  final String uid;
  final String? course;     // nome completo do curso (campusCourses)
  final String? enrollment; // matrícula
  const StudentProfile({required this.uid, this.course, this.enrollment});

  StudentProfile copyWith({String? course, String? enrollment}) =>
      StudentProfile(uid: uid, course: course ?? this.course, enrollment: enrollment ?? this.enrollment);

  Map<String, dynamic> toMap() => {
        if (course != null) 'course': course,
        if (enrollment != null) 'enrollment': enrollment,
      };
  factory StudentProfile.fromMap(String uid, Map<String, dynamic> m) =>
      StudentProfile(uid: uid, course: m['course'] as String?, enrollment: m['enrollment'] as String?);
}

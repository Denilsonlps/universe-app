class StudentProfile {
  final String uid;
  final String? course;     // nome completo do curso (campusCourses)
  final String? enrollment; // matrícula
  final String role;        // 'student' | 'admin' (só-leitura no cliente)
  final bool onlyMyCourse;  // mostrar só vagas/avisos do meu curso (opt-in)
  final DateTime? lastSeenNotificationsAt; // última visita à central de notificações
  final List<String> dismissedNotifications; // ids descartados (deslizar p/ descartar)
  const StudentProfile({
    required this.uid, this.course, this.enrollment, this.role = 'student',
    this.onlyMyCourse = false, this.lastSeenNotificationsAt,
    this.dismissedNotifications = const [],
  });

  StudentProfile copyWith({String? course, String? enrollment, bool? onlyMyCourse,
          DateTime? lastSeenNotificationsAt, List<String>? dismissedNotifications}) =>
      StudentProfile(
        uid: uid, course: course ?? this.course, enrollment: enrollment ?? this.enrollment, role: role,
        onlyMyCourse: onlyMyCourse ?? this.onlyMyCourse,
        lastSeenNotificationsAt: lastSeenNotificationsAt ?? this.lastSeenNotificationsAt,
        dismissedNotifications: dismissedNotifications ?? this.dismissedNotifications,
      );

  // NÃO grava `role` (a regra do Firestore impede o cliente de alterá-lo).
  Map<String, dynamic> toMap() => {
        if (course != null) 'course': course,
        if (enrollment != null) 'enrollment': enrollment,
        'onlyMyCourse': onlyMyCourse,
        if (lastSeenNotificationsAt != null) 'lastSeenNotificationsAt': lastSeenNotificationsAt!.millisecondsSinceEpoch,
        'dismissedNotifications': dismissedNotifications,
      };
  factory StudentProfile.fromMap(String uid, Map<String, dynamic> m) => StudentProfile(
        uid: uid, course: m['course'] as String?, enrollment: m['enrollment'] as String?,
        role: (m['role'] as String?) ?? 'student',
        onlyMyCourse: m['onlyMyCourse'] as bool? ?? false,
        lastSeenNotificationsAt: m['lastSeenNotificationsAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch((m['lastSeenNotificationsAt'] as num).toInt()),
        dismissedNotifications: List<String>.from(m['dismissedNotifications'] ?? const []),
      );
}

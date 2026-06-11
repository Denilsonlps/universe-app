import 'package:cloud_firestore/cloud_firestore.dart';

enum CourseLevel { tecnologo, bacharelado, licenciatura, tecnicoIntegrado, tecnicoConcomitante, tecnicoSubsequente, proeja, especializacao }

enum CourseShift { matutino, vespertino, noturno, integral }

extension CourseLevelLabel on CourseLevel {
  String get label {
    switch (this) {
      case CourseLevel.tecnologo: return 'Tecnólogo';
      case CourseLevel.bacharelado: return 'Bacharelado';
      case CourseLevel.licenciatura: return 'Licenciatura';
      case CourseLevel.tecnicoIntegrado: return 'Técnico Integrado';
      case CourseLevel.tecnicoConcomitante: return 'Técnico Concomitante';
      case CourseLevel.tecnicoSubsequente: return 'Técnico Subsequente';
      case CourseLevel.proeja: return 'PROEJA';
      case CourseLevel.especializacao: return 'Especialização';
    }
  }
}

extension CourseShiftLabel on CourseShift {
  String get label {
    switch (this) {
      case CourseShift.matutino: return 'Matutino';
      case CourseShift.vespertino: return 'Vespertino';
      case CourseShift.noturno: return 'Noturno';
      case CourseShift.integral: return 'Integral';
    }
  }
}

class CourseModel {
  final String id;
  final String name;
  final CourseLevel level;
  final String duration;
  final CourseShift shift;
  final String? description;
  final List<String> tags;

  const CourseModel({
    required this.id,
    required this.name,
    required this.level,
    required this.duration,
    required this.shift,
    this.description,
    this.tags = const [],
  });

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CourseModel(
      id: doc.id,
      name: data['name'] as String,
      level: CourseLevel.values.firstWhere(
        (e) => e.name == data['level'],
        orElse: () => CourseLevel.tecnologo,
      ),
      duration: data['duration'] as String,
      shift: CourseShift.values.firstWhere(
        (e) => e.name == data['shift'],
        orElse: () => CourseShift.noturno,
      ),
      description: data['description'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'level': level.name,
        'duration': duration,
        'shift': shift.name,
        'description': description,
        'tags': tags,
      };
}

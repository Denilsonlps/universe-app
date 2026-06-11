import 'package:cloud_firestore/cloud_firestore.dart';

enum InternshipModality { presencial, hibrido, remoto }

enum InternshipStatus { aberta, encerrada }

extension InternshipModalityLabel on InternshipModality {
  String get label {
    switch (this) {
      case InternshipModality.presencial: return 'Presencial';
      case InternshipModality.hibrido: return 'Híbrido';
      case InternshipModality.remoto: return 'Remoto';
    }
  }
}

class InternshipModel {
  final String id;
  final String role;
  final String company;
  final String targetCourse;
  final int stipendCents;
  final InternshipModality modality;
  final InternshipStatus status;
  final String? description;
  final String? requirements;
  final DateTime? deadline;

  const InternshipModel({
    required this.id,
    required this.role,
    required this.company,
    required this.targetCourse,
    required this.stipendCents,
    required this.modality,
    required this.status,
    this.description,
    this.requirements,
    this.deadline,
  });

  String get stipendFormatted {
    final value = stipendCents / 100;
    return 'R\$${value.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  bool get isOpen => status == InternshipStatus.aberta;

  factory InternshipModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return InternshipModel(
      id: doc.id,
      role: data['role'] as String,
      company: data['company'] as String,
      targetCourse: data['targetCourse'] as String,
      stipendCents: data['stipendCents'] as int,
      modality: InternshipModality.values.firstWhere(
        (e) => e.name == data['modality'],
        orElse: () => InternshipModality.presencial,
      ),
      status: InternshipStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => InternshipStatus.aberta,
      ),
      description: data['description'] as String?,
      requirements: data['requirements'] as String?,
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role,
        'company': company,
        'targetCourse': targetCourse,
        'stipendCents': stipendCents,
        'modality': modality.name,
        'status': status.name,
        'description': description,
        'requirements': requirements,
        'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      };
}

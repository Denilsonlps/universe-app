import 'package:cloud_firestore/cloud_firestore.dart';

enum ContestStatus { aberta, encerrada }

class ContestModel {
  final String id;
  final String role;
  final String organization;
  final int vacancies;
  final int salaryCents;
  final ContestStatus status;
  final DateTime? deadline;
  final String? description;
  final String? editalUrl;

  const ContestModel({
    required this.id,
    required this.role,
    required this.organization,
    required this.vacancies,
    required this.salaryCents,
    required this.status,
    this.deadline,
    this.description,
    this.editalUrl,
  });

  String get salaryFormatted {
    final value = salaryCents / 100;
    return 'R\$${value.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  bool get isOpen => status == ContestStatus.aberta;

  factory ContestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContestModel(
      id: doc.id,
      role: data['role'] as String,
      organization: data['organization'] as String,
      vacancies: data['vacancies'] as int,
      salaryCents: data['salaryCents'] as int,
      status: ContestStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ContestStatus.aberta,
      ),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      description: data['description'] as String?,
      editalUrl: data['editalUrl'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'role': role,
        'organization': organization,
        'vacancies': vacancies,
        'salaryCents': salaryCents,
        'status': status.name,
        'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
        'description': description,
        'editalUrl': editalUrl,
      };
}

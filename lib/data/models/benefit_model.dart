import 'package:cloud_firestore/cloud_firestore.dart';

enum BenefitKind { gov, inst }

class BenefitModel {
  final String id;
  final String name;
  final BenefitKind kind;
  final String description;
  final String? howToAccess;
  final String? linkUrl;
  final String? iconName;

  const BenefitModel({
    required this.id,
    required this.name,
    required this.kind,
    required this.description,
    this.howToAccess,
    this.linkUrl,
    this.iconName,
  });

  factory BenefitModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BenefitModel(
      id: doc.id,
      name: data['name'] as String,
      kind: BenefitKind.values.firstWhere(
        (e) => e.name == data['kind'],
        orElse: () => BenefitKind.gov,
      ),
      description: data['description'] as String,
      howToAccess: data['howToAccess'] as String?,
      linkUrl: data['linkUrl'] as String?,
      iconName: data['iconName'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'kind': kind.name,
        'description': description,
        'howToAccess': howToAccess,
        'linkUrl': linkUrl,
        'iconName': iconName,
      };
}

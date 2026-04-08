import '../../core/enums/perk_type.dart';

class HospitalPerkModel {
  final PerkType type;
  final String description;
  final String? conditionNote;

  const HospitalPerkModel({
    required this.type,
    required this.description,
    this.conditionNote,
  });

  factory HospitalPerkModel.fromJson(Map<String, dynamic> json) =>
      HospitalPerkModel(
        type: PerkType.values.byName(json['type']),
        description: json['description'],
        conditionNote: json['conditionNote'],
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'description': description,
        'conditionNote': conditionNote,
      };

  HospitalPerkModel copyWith({
    PerkType? type,
    String? description,
    String? conditionNote,
  }) =>
      HospitalPerkModel(
        type: type ?? this.type,
        description: description ?? this.description,
        conditionNote: conditionNote ?? this.conditionNote,
      );
}

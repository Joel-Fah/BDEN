import '../../core/enums/blood_type.dart';
import '../../core/enums/campaign_status.dart';
import '../../core/enums/campaign_urgency.dart';
import 'hospital_perk_model.dart';

class CampaignModel {
  final String id;
  final String title;
  final String description;
  final String organizerId;
  final String organizerName;
  final String? organizerLogoUrl;
  final String? imageUrl;
  final List<BloodType> bloodTypesNeeded;
  final int unitsNeeded;
  final int unitsPledged;
  final int unitsConfirmed;
  final String address;
  final String city;
  final String region;
  final CampaignStatus status;
  final CampaignUrgency urgency;
  final DateTime deadline;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<HospitalPerkModel> perks;
  final int minimumVolumeMl;

  const CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.organizerId,
    required this.organizerName,
    this.organizerLogoUrl,
    this.imageUrl,
    required this.bloodTypesNeeded,
    required this.unitsNeeded,
    this.unitsPledged = 0,
    this.unitsConfirmed = 0,
    required this.address,
    required this.city,
    required this.region,
    required this.status,
    required this.urgency,
    required this.deadline,
    required this.createdAt,
    required this.updatedAt,
    this.perks = const [],
    this.minimumVolumeMl = 350,
  });

  double get progressPercent =>
      unitsNeeded == 0 ? 0 : (unitsPledged / unitsNeeded).clamp(0.0, 1.0);
  bool get isExpired => deadline.isBefore(DateTime.now());
  bool get isFull => unitsPledged >= unitsNeeded;
  bool get isActive => status == CampaignStatus.active && !isExpired;
  bool get hasPerks => perks.isNotEmpty;

  factory CampaignModel.fromJson(Map<String, dynamic> json) => CampaignModel(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        organizerId: json['organizerId'],
        organizerName: json['organizerName'],
        organizerLogoUrl: json['organizerLogoUrl'],
        imageUrl: json['imageUrl'],
        bloodTypesNeeded: (json['bloodTypesNeeded'] as List)
            .map((e) => BloodType.fromString(e))
            .toList(),
        unitsNeeded: json['unitsNeeded'],
        unitsPledged: json['unitsPledged'] ?? 0,
        unitsConfirmed: json['unitsConfirmed'] ?? 0,
        address: json['address'],
        city: json['city'],
        region: json['region'],
        status: CampaignStatus.values.byName(json['status']),
        urgency: CampaignUrgency.values.byName(json['urgency']),
        deadline: DateTime.parse(json['deadline']),
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        perks: (json['perks'] as List? ?? [])
            .map((e) => HospitalPerkModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        minimumVolumeMl: json['minimumVolumeMl'] ?? 350,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'organizerId': organizerId,
        'organizerName': organizerName,
        'organizerLogoUrl': organizerLogoUrl,
        'imageUrl': imageUrl,
        'bloodTypesNeeded': bloodTypesNeeded.map((e) => e.label).toList(),
        'unitsNeeded': unitsNeeded,
        'unitsPledged': unitsPledged,
        'unitsConfirmed': unitsConfirmed,
        'address': address,
        'city': city,
        'region': region,
        'status': status.name,
        'urgency': urgency.name,
        'deadline': deadline.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'perks': perks.map((e) => e.toJson()).toList(),
        'minimumVolumeMl': minimumVolumeMl,
      };

  CampaignModel copyWith({
    String? title,
    String? description,
    String? imageUrl,
    List<BloodType>? bloodTypesNeeded,
    int? unitsNeeded,
    int? unitsPledged,
    int? unitsConfirmed,
    CampaignStatus? status,
    CampaignUrgency? urgency,
    DateTime? deadline,
    DateTime? updatedAt,
    List<HospitalPerkModel>? perks,
    int? minimumVolumeMl,
  }) =>
      CampaignModel(
        id: id,
        organizerId: organizerId,
        organizerName: organizerName,
        organizerLogoUrl: organizerLogoUrl,
        address: address,
        city: city,
        region: region,
        createdAt: createdAt,
        title: title ?? this.title,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        bloodTypesNeeded: bloodTypesNeeded ?? this.bloodTypesNeeded,
        unitsNeeded: unitsNeeded ?? this.unitsNeeded,
        unitsPledged: unitsPledged ?? this.unitsPledged,
        unitsConfirmed: unitsConfirmed ?? this.unitsConfirmed,
        status: status ?? this.status,
        urgency: urgency ?? this.urgency,
        deadline: deadline ?? this.deadline,
        updatedAt: updatedAt ?? DateTime.now(),
        perks: perks ?? this.perks,
        minimumVolumeMl: minimumVolumeMl ?? this.minimumVolumeMl,
      );
}

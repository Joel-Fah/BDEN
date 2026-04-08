import '../../core/enums/donor_card_status.dart';

class DonorCardModel {
  final String id;
  final String donorId;
  final String hospitalId;
  final String hospitalName;
  final String? hospitalLogoUrl;
  final DonorCardStatus status;
  final int qualifyingDonationCount;
  final DateTime? lastDonationAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DonorCardModel({
    required this.id,
    required this.donorId,
    required this.hospitalId,
    required this.hospitalName,
    this.hospitalLogoUrl,
    required this.status,
    required this.qualifyingDonationCount,
    this.lastDonationAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed
  int get donationsUntilElite => (5 - qualifyingDonationCount).clamp(0, 5);
  bool get isElite => status == DonorCardStatus.elite;
  bool get isActive => status == DonorCardStatus.active || isElite;

  /// Checks whether this donor is currently eligible to donate again
  /// (at least 90 days since last donation)
  bool get canDonateAgain {
    if (lastDonationAt == null) return true;
    return DateTime.now().difference(lastDonationAt!).inDays >= 90;
  }

  int get daysSinceLastDonation {
    if (lastDonationAt == null) return 999;
    return DateTime.now().difference(lastDonationAt!).inDays;
  }

  int get daysUntilEligible {
    if (canDonateAgain) return 0;
    return 90 - daysSinceLastDonation;
  }

  factory DonorCardModel.fromJson(Map<String, dynamic> json) => DonorCardModel(
        id: json['id'],
        donorId: json['donorId'],
        hospitalId: json['hospitalId'],
        hospitalName: json['hospitalName'],
        hospitalLogoUrl: json['hospitalLogoUrl'],
        status: DonorCardStatus.values.byName(json['status']),
        qualifyingDonationCount: json['qualifyingDonationCount'] ?? 0,
        lastDonationAt: json['lastDonationAt'] != null
            ? DateTime.parse(json['lastDonationAt'])
            : null,
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'donorId': donorId,
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'hospitalLogoUrl': hospitalLogoUrl,
        'status': status.name,
        'qualifyingDonationCount': qualifyingDonationCount,
        'lastDonationAt': lastDonationAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  DonorCardModel copyWith({
    DonorCardStatus? status,
    int? qualifyingDonationCount,
    DateTime? lastDonationAt,
    DateTime? updatedAt,
  }) =>
      DonorCardModel(
        id: id,
        donorId: donorId,
        hospitalId: hospitalId,
        hospitalName: hospitalName,
        hospitalLogoUrl: hospitalLogoUrl,
        createdAt: createdAt,
        status: status ?? this.status,
        qualifyingDonationCount:
            qualifyingDonationCount ?? this.qualifyingDonationCount,
        lastDonationAt: lastDonationAt ?? this.lastDonationAt,
        updatedAt: updatedAt ?? DateTime.now(),
      );
}

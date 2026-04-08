class DonationRecordModel {
  final String id;
  final String donorId;
  final String campaignId;
  final String pledgeId;
  final String hospitalId; // organizerId of the campaign
  final String hospitalName;
  final int volumeMl; // how many ml were donated (default 350 for MVP)
  final DateTime donatedAt;
  final bool isQualifying; // volumeMl >= 350

  const DonationRecordModel({
    required this.id,
    required this.donorId,
    required this.campaignId,
    required this.pledgeId,
    required this.hospitalId,
    required this.hospitalName,
    required this.volumeMl,
    required this.donatedAt,
    required this.isQualifying,
  });

  factory DonationRecordModel.fromJson(Map<String, dynamic> json) =>
      DonationRecordModel(
        id: json['id'],
        donorId: json['donorId'],
        campaignId: json['campaignId'],
        pledgeId: json['pledgeId'],
        hospitalId: json['hospitalId'],
        hospitalName: json['hospitalName'],
        volumeMl: json['volumeMl'] ?? 350,
        donatedAt: DateTime.parse(json['donatedAt']),
        isQualifying: json['isQualifying'] ?? true,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'donorId': donorId,
        'campaignId': campaignId,
        'pledgeId': pledgeId,
        'hospitalId': hospitalId,
        'hospitalName': hospitalName,
        'volumeMl': volumeMl,
        'donatedAt': donatedAt.toIso8601String(),
        'isQualifying': isQualifying,
      };
}

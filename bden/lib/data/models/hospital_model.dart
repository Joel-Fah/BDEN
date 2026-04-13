import '../../core/enums/verification_status.dart';

class HospitalModel {
  final String id;
  final String ownerUid;
  final String name;
  final String email;
  final String phone;
  final String licenseNumber;
  final String address;
  final String city;
  final String region;
  final VerificationStatus verificationStatus;
  final String? documentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const HospitalModel({
    required this.id,
    required this.ownerUid,
    required this.name,
    required this.email,
    required this.phone,
    required this.licenseNumber,
    required this.address,
    required this.city,
    required this.region,
    this.verificationStatus = VerificationStatus.pending,
    this.documentUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HospitalModel.fromJson(Map<String, dynamic> json) => HospitalModel(
        id: json['id'],
        ownerUid: json['ownerUid'],
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        licenseNumber: json['licenseNumber'],
        address: json['address'],
        city: json['city'],
        region: json['region'],
        verificationStatus: VerificationStatus.values.byName(json['verificationStatus'] ?? 'pending'),
        documentUrl: json['documentUrl'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'ownerUid': ownerUid,
        'name': name,
        'email': email,
        'phone': phone,
        'licenseNumber': licenseNumber,
        'address': address,
        'city': city,
        'region': region,
        'verificationStatus': verificationStatus.name,
        'documentUrl': documentUrl,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

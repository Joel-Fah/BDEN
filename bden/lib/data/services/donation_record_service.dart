import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/donation_record_model.dart';
import '../repositories/donation_record_repository.dart';

class DonationRecordService extends GetxService
    implements DonationRecordRepository {
  final _firestore = FirebaseFirestore.instance;

  CollectionReference get _col => _firestore.collection('donation_records');

  @override
  Future<void> createRecord(DonationRecordModel record) async {
    await _col.doc(record.id).set(record.toJson());
  }

  @override
  Stream<List<DonationRecordModel>> getDonorRecords(String donorId) {
    return _col
        .where('donorId', isEqualTo: donorId)
        .orderBy('donatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                DonationRecordModel.fromJson(d.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Stream<List<DonationRecordModel>> getHospitalRecords(String hospitalId) {
    return _col
        .where('hospitalId', isEqualTo: hospitalId)
        .orderBy('donatedAt', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                DonationRecordModel.fromJson(d.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<DonationRecordModel?> getLastDonationForDonor(String donorId) async {
    final snap = await _col
        .where('donorId', isEqualTo: donorId)
        .orderBy('donatedAt', descending: true)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return DonationRecordModel.fromJson(
        snap.docs.first.data() as Map<String, dynamic>);
  }
}

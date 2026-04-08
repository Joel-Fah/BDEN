import '../models/donation_record_model.dart';

abstract class DonationRecordRepository {
  Future<void> createRecord(DonationRecordModel record);
  Stream<List<DonationRecordModel>> getDonorRecords(String donorId);
  Stream<List<DonationRecordModel>> getHospitalRecords(String hospitalId);
  Future<DonationRecordModel?> getLastDonationForDonor(String donorId);
}

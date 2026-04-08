import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../models/donor_card_model.dart';
import '../repositories/donor_card_repository.dart';
import '../../core/enums/donor_card_status.dart';

class DonorCardService extends GetxService implements DonorCardRepository {
  final _firestore = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  CollectionReference get _col => _firestore.collection('donor_cards');

  @override
  Stream<List<DonorCardModel>> getDonorCards(String donorId) {
    return _col
        .where('donorId', isEqualTo: donorId)
        .orderBy('qualifyingDonationCount', descending: true)
        .snapshots()
        .map((s) => s.docs
            .map((d) =>
                DonorCardModel.fromJson(d.data() as Map<String, dynamic>))
            .toList());
  }

  @override
  Future<DonorCardModel?> getCard(String donorId, String hospitalId) async {
    final snap = await _col
        .where('donorId', isEqualTo: donorId)
        .where('hospitalId', isEqualTo: hospitalId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return DonorCardModel.fromJson(
        snap.docs.first.data() as Map<String, dynamic>);
  }

  @override
  Future<void> createCard(DonorCardModel card) async {
    await _col.doc(card.id).set(card.toJson());
  }

  @override
  Future<void> recordQualifyingDonation(
      String donorId, String hospitalId, DateTime donatedAt) async {
    final existing = await getCard(donorId, hospitalId);

    if (existing == null) {
      // First qualifying donation at this hospital — create card
      final now = DateTime.now();
      final card = DonorCardModel(
        id: _uuid.v4(),
        donorId: donorId,
        hospitalId: hospitalId,
        hospitalName: '', // filled by caller
        status: DonorCardStatus.active,
        qualifyingDonationCount: 1,
        lastDonationAt: donatedAt,
        createdAt: now,
        updatedAt: now,
      );
      await createCard(card);
    } else {
      // Increment count, recompute status
      final newCount = existing.qualifyingDonationCount + 1;
      final newStatus = DonorCardStatus.fromDonationCount(newCount);
      await _col.doc(existing.id).update({
        'qualifyingDonationCount': newCount,
        'status': newStatus.name,
        'lastDonationAt': donatedAt.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
  }
}

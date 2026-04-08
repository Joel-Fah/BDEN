import '../models/donor_card_model.dart';

abstract class DonorCardRepository {
  /// Returns all donor cards for a given donor (one per hospital)
  Stream<List<DonorCardModel>> getDonorCards(String donorId);

  /// Returns the card for a specific (donor, hospital) pair, or null
  Future<DonorCardModel?> getCard(String donorId, String hospitalId);

  /// Creates a new card (first qualifying donation at a hospital)
  Future<void> createCard(DonorCardModel card);

  /// Increments qualifying count, updates status and lastDonationAt
  Future<void> recordQualifyingDonation(
      String donorId, String hospitalId, DateTime donatedAt);
}

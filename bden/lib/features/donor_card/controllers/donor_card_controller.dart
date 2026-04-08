import 'package:get/get.dart';
import '../../../data/models/donor_card_model.dart';
import '../../../data/models/donation_record_model.dart';
import '../../../data/repositories/donor_card_repository.dart';
import '../../../data/repositories/donation_record_repository.dart';

class DonorCardController extends GetxController {
  final DonorCardRepository _cardService;
  final DonationRecordRepository _recordService;
  final String donorId;

  DonorCardController(this._cardService, this._recordService, this.donorId);

  final cards = <DonorCardModel>[].obs;
  final records = <DonationRecordModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _cardService.getDonorCards(donorId).listen((data) {
      cards.value = data;
      isLoading.value = false;
    });
    _recordService.getDonorRecords(donorId).listen((data) {
      records.value = data;
    });
  }

  int get totalQualifyingDonations =>
    records.where((r) => r.isQualifying).length;

  bool get hasAnyCard => cards.isNotEmpty;

  DonorCardModel? get primaryCard =>
    cards.isEmpty ? null : cards.first; // highest count first

  /// Whether the donor can donate again globally
  /// (based on most recent donation across all hospitals)
  bool get isGloballyEligible {
    if (records.isEmpty) return true;
    final latest = records.first; // ordered by donatedAt desc
    return DateTime.now().difference(latest.donatedAt).inDays >= 90;
  }

  int get daysUntilNextDonation {
    if (isGloballyEligible) return 0;
    final latest = records.first;
    return 90 - DateTime.now().difference(latest.donatedAt).inDays;
  }
}

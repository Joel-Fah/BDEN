import 'package:get/get.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/pledge_model.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../data/repositories/pledge_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/donation_record_repository.dart';
import '../../../data/repositories/donor_card_repository.dart';
import '../../../data/models/donation_record_model.dart';
import '../../../core/enums/campaign_status.dart';
import '../../../core/enums/pledge_status.dart';
import '../../../core/enums/notification_type.dart';
import 'package:uuid/uuid.dart';

class OrganizerDashboardController extends GetxController {
  final CampaignRepository _campaignService;
  final PledgeRepository _pledgeService;
  final NotificationRepository _notifService;
  final DonationRecordRepository _donationRecordService;
  final DonorCardRepository _donorCardService;
  final String organizerId;

  OrganizerDashboardController(
    this._campaignService,
    this._pledgeService,
    this._notifService,
    this._donationRecordService,
    this._donorCardService,
    this.organizerId,
  );

  final campaigns = <CampaignModel>[].obs;
  final pledgesMap = <String, List<PledgeModel>>{}.obs;
  final isLoading = true.obs;

  int get totalPledges =>
    pledgesMap.values.fold(0, (sum, list) => sum + list.length);
  int get totalConfirmed =>
    campaigns.fold(0, (sum, c) => sum + c.unitsConfirmed);

  @override
  void onInit() {
    super.onInit();
    _loadDashboard();
  }

  void _loadDashboard() {
    _campaignService.getOrganizerCampaigns(organizerId).listen((list) {
      campaigns.value = list;
      isLoading.value = false;
      for (final c in list) {
        _pledgeService.getCampaignPledges(c.id).listen((pledges) {
          pledgesMap[c.id] = pledges;
          pledgesMap.refresh();
        });
      }
    });
  }

  Future<void> confirmPledge(PledgeModel pledge, CampaignModel campaign) async {
    // 1. Update pledge status to confirmed
    await _pledgeService.updatePledgeStatus(pledge.id, PledgeStatus.confirmed);

    // 2. Create a DonationRecord
    final record = DonationRecordModel(
      id: const Uuid().v4(),
      donorId: pledge.donorId,
      campaignId: pledge.campaignId,
      pledgeId: pledge.id,
      hospitalId: campaign.organizerId,
      hospitalName: campaign.organizerName,
      volumeMl: campaign.minimumVolumeMl,
      donatedAt: DateTime.now(),
      isQualifying: campaign.minimumVolumeMl >= 350,
    );
    await _donationRecordService.createRecord(record);

    // 3. If qualifying, update or create DonorCard
    if (record.isQualifying) {
      await _donorCardService.recordQualifyingDonation(
        pledge.donorId,
        campaign.organizerId,
        record.donatedAt,
      );
    }

    // 4. Notify donor
    await _notifService.createNotification(NotificationModel(
      id: const Uuid().v4(),
      userId: pledge.donorId,
      title: 'Donation confirmed ??',
      body: 'Your donation at \ has been confirmed. Thank you!',
      type: NotificationType.pledgeUpdate,
      relatedId: pledge.campaignId,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> closeCampaign(String campaignId) async {
    final campaign = campaigns.firstWhere((c) => c.id == campaignId);
    await _campaignService.updateCampaign(
      campaign.copyWith(status: CampaignStatus.completed),
    );
  }

  List<PledgeModel> pledgesFor(String campaignId) =>
    pledgesMap[campaignId] ?? [];
}

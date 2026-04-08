import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/campaign_model.dart';
import '../../../data/models/hospital_perk_model.dart';
import '../../../data/repositories/campaign_repository.dart';
import '../../../core/enums/blood_type.dart';
import '../../../core/enums/campaign_status.dart';
import '../../../core/enums/campaign_urgency.dart';
import '../../../core/enums/perk_type.dart';
import 'package:uuid/uuid.dart';

class CreateCampaignController extends GetxController {
  final CampaignRepository _campaignService;
  final String organizerId;
  final String organizerName;

  CreateCampaignController(
    this._campaignService,
    this.organizerId,
    this.organizerName,
  );

  final title = ''.obs;
  final description = ''.obs;
  final address = ''.obs;
  final city = ''.obs;
  final region = ''.obs;
  final selectedBloodTypes = <BloodType>[].obs;
  final selectedPerks = <HospitalPerkModel>[].obs;
  final unitsNeeded = 1.obs;
  final urgency = CampaignUrgency.routine.obs;
  final deadline = Rxn<DateTime>();
  final coverImage = Rxn<File>();
  final isLoading = false.obs;

  bool get isFormValid =>
    title.value.isNotEmpty &&
    description.value.isNotEmpty &&
    city.value.isNotEmpty &&
    selectedBloodTypes.isNotEmpty &&
    deadline.value != null &&
    unitsNeeded.value > 0;

  void toggleBloodType(BloodType bt) {
    if (selectedBloodTypes.contains(bt)) {
      selectedBloodTypes.remove(bt);
    } else {
      selectedBloodTypes.add(bt);
    }
  }

  void addPerk(PerkType type, String description, String? condition) {
    selectedPerks.add(HospitalPerkModel(
      type: type, description: description, conditionNote: condition,
    ));
  }

  void removePerk(PerkType type) {
    selectedPerks.removeWhere((p) => p.type == type);
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) coverImage.value = File(picked.path);
  }

  Future<void> submitCampaign() async {
    if (!isFormValid) return;
    isLoading.value = true;
    try {
      String? imageUrl;
      if (coverImage.value != null) {
        imageUrl = await _campaignService.uploadCoverImage(coverImage.value!);
      }
      final now = DateTime.now();
      final campaign = CampaignModel(
        id: const Uuid().v4(),
        title: title.value,
        description: description.value,
        organizerId: organizerId,
        organizerName: organizerName,
        imageUrl: imageUrl,
        bloodTypesNeeded: selectedBloodTypes.toList(),
        unitsNeeded: unitsNeeded.value,
        address: address.value,
        city: city.value,
        region: region.value,
        status: CampaignStatus.active,
        urgency: urgency.value,
        deadline: deadline.value!,
        createdAt: now,
        updatedAt: now,
        perks: selectedPerks.toList(),
        minimumVolumeMl: 350,
      );
      await _campaignService.createCampaign(campaign);
      Get.back(result: true);
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/pledge_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/pledge_repository.dart';
import '../../../core/enums/blood_type.dart';

class ProfileController extends GetxController {
  final AuthRepository _authService;
  final PledgeRepository _pledgeService;
  final AuthController _authController = Get.find<AuthController>();

  ProfileController(this._authService, this._pledgeService);

  final user = Rxn<UserModel>();
  final myPledges = <PledgeModel>[].obs;
  final isLoading = true.obs;

  final isEditMode = false.obs;
  final nameController = TextEditingController();
  final cityController = TextEditingController();
  final regionController = TextEditingController();
  final selectedBloodType = Rxn<BloodType>();

  @override
  void onInit() {
    super.onInit();
    _authController.currentUser.listen((currentUser) {
      if (currentUser != null) {
        user.value = currentUser;
        _initEditControllers(currentUser);
        _pledgeService.getDonorPledges(currentUser.uid).listen((pledges) {
          myPledges.value = pledges;
          isLoading.value = false;
        });
      }
    });

    if (_authController.currentUser.value != null) {
      user.value = _authController.currentUser.value!;
      _initEditControllers(user.value!);
      _pledgeService.getDonorPledges(user.value!.uid).listen((pledges) {
        myPledges.value = pledges;
        isLoading.value = false;
      });
    }
  }

  void _initEditControllers(UserModel currentUser) {
    nameController.text = currentUser.displayName;
    cityController.text = currentUser.city ?? '';
    regionController.text = currentUser.region ?? '';
    selectedBloodType.value = currentUser.bloodType;
  }

  void toggleEditMode() {
    if (isEditMode.value) {
      // Revert changes
      if (user.value != null) _initEditControllers(user.value!);
    }
    isEditMode.value = !isEditMode.value;
  }

  Future<void> saveProfile() async {
    if (user.value == null) return;
    isLoading.value = true;
    final updated = user.value!.copyWith(
      displayName: nameController.text.trim(),
      city: cityController.text.trim(),
      region: regionController.text.trim(),
      bloodType: selectedBloodType.value,
    );
    await updateFullProfile(updated);
    isEditMode.value = false;
    isLoading.value = false;
  }

  void loadProfile(UserModel currentUser) {
    // No-op or deprecated if handled by onInit
  }

  Future<void> updateBloodType(BloodType bt) async {
    if (user.value == null) return;
    final updated = user.value!.copyWith(bloodType: bt);
    await _authService.updateUserProfile(updated);
    user.value = updated;
  }

  Future<void> updateLocation(String city, String region) async {
    if (user.value == null) return;
    final updated = user.value!.copyWith(city: city, region: region);
    await _authService.updateUserProfile(updated);
    user.value = updated;
  }

  Future<void> updateLastDonationDate(DateTime date) async {
    if (user.value == null) return;
    final updated = user.value!.copyWith(lastDonationDate: date);
    await _authService.updateUserProfile(updated);
    user.value = updated;
  }

  Future<void> updateFullProfile(UserModel updatedUser) async {
    if (user.value == null) return;
    await _authService.updateUserProfile(updatedUser);
    user.value = updatedUser;
  }
}

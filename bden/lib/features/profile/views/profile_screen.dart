import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/enums/blood_type.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../donor_card/controllers/donor_card_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  void _showLogoutDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const HugeIcon(
                icon: HugeIcons.strokeRoundedLogout01,
                color: AppColors.error,
                size: 48),
            const Gap(16),
            Text('Sign Out', style: AppTextStyles.headlineMedium),
            const Gap(8),
            Text('Are you sure you want to sign out?',
                style: AppTextStyles.bodyMedium),
            const Gap(24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      Get.find<AuthController>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Sign Out',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title:
            Text(AppStrings.profileTitle, style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedLogout01,
                color: AppColors.error),
            onPressed: _showLogoutDialog,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: AppColors.primary, size: 40));
        }

        final user = controller.user.value;
        if (user == null) return const Center(child: Text('Not logged in'));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Header
              UserAvatar(
                  photoUrl: user.photoUrl,
                  displayName: user.displayName,
                  radius: 50),
              const Gap(16),

              if (controller.isEditMode.value) ...[
                TextField(
                  controller: controller.nameController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'Display Name',
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  style: AppTextStyles.titleLarge,
                ),
                const Gap(8),
              ] else ...[
                Text(user.displayName, style: AppTextStyles.titleLarge),
              ],
              Text(user.email, style: AppTextStyles.bodyMedium),

              const Gap(8),
              if (controller.isEditMode.value) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => controller.saveProfile(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Save Profile',
                          style: TextStyle(color: Colors.white)),
                    ),
                    const Gap(12),
                    OutlinedButton(
                      onPressed: () => controller.toggleEditMode(),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
                const Gap(24),
              ] else ...[
                TextButton.icon(
                  onPressed: () => controller.toggleEditMode(),
                  icon: const Icon(HugeIcons.strokeRoundedEdit02, size: 18),
                  label: const Text('Edit Profile'),
                ),
                const Gap(24),
              ],

              // Info Tiles
              if (user.isDonor) ...[
                if (controller.isEditMode.value) ...[
                  _EditTile(
                    icon: HugeIcons.strokeRoundedDroplet,
                    label: 'Blood Type',
                    child: DropdownButtonFormField<String>(
                      initialValue: controller.selectedBloodType.value?.label,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero),
                      items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                          .map((bt) =>
                              DropdownMenuItem(value: bt, child: Text(bt)))
                          .toList(),
                      onChanged: (val) {
                        try {
                          controller.selectedBloodType.value = [
                            'A+',
                            'A-',
                            'B+',
                            'B-',
                            'AB+',
                            'AB-',
                            'O+',
                            'O-'
                          ].contains(val)
                              ? (val == 'A+'
                                  ? BloodType.aPositive
                                  : val == 'A-'
                                      ? BloodType.aNegative
                                      : val == 'B+'
                                          ? BloodType.bPositive
                                          : val == 'B-'
                                              ? BloodType.bNegative
                                              : val == 'AB+'
                                                  ? BloodType.abPositive
                                                  : val == 'AB-'
                                                      ? BloodType.abNegative
                                                      : val == 'O+'
                                                          ? BloodType.oPositive
                                                          : BloodType.oNegative)
                              : null;
                        } catch (_) {}
                      },
                    ),
                  ),
                  _EditTile(
                    icon: HugeIcons.strokeRoundedLocation01,
                    label: 'City',
                    child: TextField(
                      controller: controller.cityController,
                      decoration: const InputDecoration(
                          hintText: 'City',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                  _EditTile(
                    icon: HugeIcons.strokeRoundedLocation01,
                    label: 'Region',
                    child: TextField(
                      controller: controller.regionController,
                      decoration: const InputDecoration(
                          hintText: 'Region',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero),
                    ),
                  ),
                ] else ...[
                  _InfoTile(
                    icon: HugeIcons.strokeRoundedDroplet,
                    label: 'Blood Type',
                    value: user.bloodType?.label ?? 'Unknown',
                  ),
                  _InfoTile(
                    icon: HugeIcons.strokeRoundedLocation01,
                    label: 'Location',
                    value: '${user.city ?? '-'}, ${user.region ?? '-'}',
                  ),
                ],
                _InfoTile(
                  icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                  label: 'Status',
                  value: user.isEligible
                      ? AppStrings.eligibleLabel
                      : AppStrings.notEligible,
                  valueColor:
                      user.isEligible ? AppColors.success : AppColors.error,
                ),
                _InfoTile(
                  icon: HugeIcons.strokeRoundedCalendar01,
                  label: 'Last Donation',
                  value: user.lastDonationDate?.relative ?? 'Never',
                ),
                const Gap(16),

                // NEW: My Donor Cards and Myth Busters
                GetBuilder<DonorCardController>(
                    init: DonorCardController(Get.find(), Get.find(), user.uid),
                    builder: (cardController) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          leading: const HugeIcon(
                              icon: HugeIcons.strokeRoundedCreditCard,
                              color: AppColors.primary),
                          title: Text('My Donor Cards',
                              style: AppTextStyles.titleMedium),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Obx(() => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      '${cardController.cards.length}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )),
                              const Gap(8),
                              const Icon(HugeIcons.strokeRoundedArrowRight01,
                                  color: AppColors.textSecondary),
                            ],
                          ),
                          onTap: () => context.push(AppRoutes.donorCards),
                        ),
                      );
                    }),
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    leading: const HugeIcon(
                        icon: HugeIcons.strokeRoundedHelpCircle,
                        color: AppColors.primary),
                    title:
                        Text('Myth Busters', style: AppTextStyles.titleMedium),
                    subtitle: Text('Learn the facts',
                        style: AppTextStyles.labelSmall),
                    trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                        color: AppColors.textSecondary),
                    onTap: () => context.push(AppRoutes.myths),
                  ),
                ),
                const Gap(16),

                // Pledge History
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(AppStrings.pledgeHistory,
                        style: AppTextStyles.titleMedium)),
                const Gap(16),
                if (controller.myPledges.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(AppStrings.noPledges,
                        style: AppTextStyles.bodyMedium),
                  )
                else
                  ...controller.myPledges.take(3).map((p) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          leading: const Icon(HugeIcons.strokeRoundedTime01,
                              color: AppColors.textSecondary),
                          title: Text(p.status.name.toUpperCase()),
                          trailing: Text(p.createdAt.relative,
                              style: AppTextStyles.labelSmall),
                        ),
                      )),
              ],

              if (user.isOrganizer) ...[
                _InfoTile(
                  icon: HugeIcons.strokeRoundedHospital01,
                  label: 'Organization',
                  value: user.displayName,
                ),
                _InfoTile(
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: 'Location',
                  value: '${user.city ?? '-'}, ${user.region ?? '-'}',
                ),
              ],

              const Gap(32),
              OutlinedButton(
                onPressed: _showLogoutDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(label, style: AppTextStyles.bodyMedium),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value,
                style: AppTextStyles.titleMedium.copyWith(color: valueColor)),
          ],
        ),
      ),
    );
  }
}

class _EditTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget child;

  const _EditTile({
    required this.icon,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.labelSmall),
                child,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

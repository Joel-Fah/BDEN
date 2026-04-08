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
import '../../../../routes/app_routes.dart';
import '../controllers/profile_controller.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../shared/widgets/user_avatar.dart';
import '../../donor_card/controllers/donor_card_controller.dart';

class ProfileScreen extends GetView<ProfileController> {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(AppStrings.profileTitle, style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedLogout01,
                color: AppColors.error),
            onPressed: () => Get.find<AuthController>().logout(),
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
              Text(user.displayName, style: AppTextStyles.titleLarge),
              Text(user.email, style: AppTextStyles.bodyMedium),
              const Gap(32),

              // Info Tiles
              if (user.isDonor) ...[
                _InfoTile(
                  icon: HugeIcons.strokeRoundedDroplet,
                  label: 'Blood Type',
                  value: user.bloodType?.label ?? 'Unknown',
                  onTap: () {}, // Edit
                ),
                _InfoTile(
                  icon: HugeIcons.strokeRoundedLocation01,
                  label: 'Location',
                  value: '${user.city ?? '-'}, ${user.region ?? '-'}',
                  onTap: () {}, // Edit
                ),
                _InfoTile(
                  icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                  label: 'Status',
                  value: user.isEligible
                      ? AppStrings.eligibleLabel
                      : AppStrings.notEligible,
                  valueColor:
                      user.isEligible ? AppColors.success : AppColors.error,
                  onTap: () {}, // Edit
                ),
                _InfoTile(
                  icon: HugeIcons.strokeRoundedCalendar01,
                  label: 'Last Donation',
                  value: user.lastDonationDate?.relative ?? 'Never',
                  onTap: () {}, // Edit
                ),
                const Gap(16),

                // NEW: My Donor Cards and Myth Busters
                GetBuilder<DonorCardController>(
                    init: DonorCardController(Get.find(), Get.find(), user.uid),
                    builder: (cardController) {
                      return ListTile(
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
                      );
                    }),
                const Divider(),
                ListTile(
                  leading: const HugeIcon(
                      icon: HugeIcons.strokeRoundedHelpCircle,
                      color: AppColors.primary),
                  title: Text('Myth Busters', style: AppTextStyles.titleMedium),
                  subtitle:
                      Text('Learn the facts', style: AppTextStyles.labelSmall),
                  trailing: const Icon(HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.textSecondary),
                  onTap: () => context.push(AppRoutes.myths),
                ),
                const Divider(),
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
                  ...controller.myPledges.take(3).map((p) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(HugeIcons.strokeRoundedTime01,
                            color: AppColors.textSecondary),
                        title: Text(p.status.name.toUpperCase()),
                        trailing: Text(p.createdAt.relative,
                            style: AppTextStyles.labelSmall),
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
                onPressed: () => Get.find<AuthController>().logout(),
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
  final VoidCallback? onTap;

  const _InfoTile(
      {required this.icon,
      required this.label,
      required this.value,
      this.valueColor,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
          if (onTap != null) ...[
            const Gap(8),
            const Icon(HugeIcons.strokeRoundedEdit02,
                size: 16, color: AppColors.textSecondary),
          ],
        ],
      ),
      onTap: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import '../../../routes/app_routes.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:gap/gap.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/blood_type.dart';
import '../controllers/campaign_feed_controller.dart';
import '../../myths/controllers/myth_controller.dart';
import '../widgets/campaign_card.dart';
import '../../../shared/widgets/empty_state.dart';

class CampaignFeedScreen extends GetView<CampaignFeedController> {
  const CampaignFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MythController>()) {
      // Lazy inject if needed, or already injected in bindings.
      // Usually would be in bindings, but we can Get.find and if not present, safe checking.
      // We will assume it's injected, but let's just use GetBuilder or GetX safely.
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.feedTitle, style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Badge(
                child: HugeIcon(
                    icon: HugeIcons.strokeRoundedNotification01,
                    color: AppColors.textPrimary)),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search campaigns...',
                prefixIcon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: AppColors.textSecondary),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Obx(() => Row(
                  children: [
                    ...BloodType.values.map((bt) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(bt.label),
                            selected:
                                controller.selectedBloodTypes.contains(bt),
                            onSelected: (_) =>
                                controller.toggleBloodTypeFilter(bt),
                            selectedColor: AppColors.primaryLight,
                            labelStyle: TextStyle(
                                color:
                                    controller.selectedBloodTypes.contains(bt)
                                        ? AppColors.primary
                                        : AppColors.textSecondary),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: controller.selectedBloodTypes
                                            .contains(bt)
                                        ? AppColors.primary
                                        : AppColors.border)),
                            showCheckmark: false,
                          ),
                        )),
                  ],
                )),
          ),
          const Gap(16),

          // NEW: Myths Teaser
          GetX<MythController>(
            init: MythController(Get.find()),
            builder: (mythController) {
              if (mythController.myths.isEmpty) {
                return const SizedBox.shrink();
              }
              final displayMyths = mythController.myths.take(3).toList();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Did you know? ??', style: AppTextStyles.titleMedium),
                        TextButton(
                          onPressed: () => context.push(AppRoutes.myths),
                          child: Text('See all', style: AppTextStyles.labelLarge.copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: displayMyths.length,
                      separatorBuilder: (_, __) => const Gap(12),
                      itemBuilder: (context, index) {
                        final myth = displayMyths[index];
                        return GestureDetector(
                          onTap: () => context.push(AppRoutes.myths),
                          child: Container(
                            width: 260,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              border: Border.all(color: AppColors.primary),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Text(
                                        'MYTH',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Text('Tap to bust ?', style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                                  ],
                                ),
                                const Gap(8),
                                Expanded(
                                  child: Text(
                                    myth.myth,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.primaryDark, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Gap(16),
                ],
              );
            },
          ),

          // Campaign List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: LoadingAnimationWidget.inkDrop(
                      color: AppColors.primary, size: 40),
                );
              }

              final campaigns = controller.filteredCampaigns;
              if (campaigns.isEmpty) {
                return EmptyState(
                  icon: HugeIcons.strokeRoundedHospital01,
                  title: 'No campaigns found',
                  subtitle: AppStrings.feedEmpty,
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // The controller stream already handles updates.
                  await Future.delayed(const Duration(seconds: 1));
                },
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: campaigns.length,
                  separatorBuilder: (_, __) => const Gap(16),
                  itemBuilder: (context, index) {
                    final campaign = campaigns[index];
                    return CampaignCard(campaign: campaign);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

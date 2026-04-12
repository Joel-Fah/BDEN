import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/datetime_extensions.dart';
import '../../../../core/enums/blood_type.dart';
import '../../../../core/enums/pledge_status.dart';
import '../controllers/campaign_detail_controller.dart';
import '../../../shared/widgets/bden_button.dart';
import '../widgets/campaign_progress_bar.dart';
import '../widgets/blood_type_chip.dart';
import '../widgets/urgency_badge.dart';
import '../../../../data/models/pledge_model.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CampaignDetailScreen extends GetView<CampaignDetailController> {
  final String campaignId;

  const CampaignDetailScreen({super.key, required this.campaignId});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.campaign.value?.id != campaignId) {
        controller.loadCampaign(campaignId);
      }
    });

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: AppColors.primary, size: 40));
        }

        final campaign = controller.campaign.value;
        if (campaign == null) {
          return const Center(child: Text('Campaign not found'));
        }

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Hero(
                      tag: 'campaign-image-${campaign.id}',
                      child: campaign.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: campaign.imageUrl!, fit: BoxFit.cover)
                          : Container(
                              color: AppColors.primaryLight,
                              child: const Center(
                                child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedDroplet,
                                    size: 60,
                                    color: AppColors.primary),
                              ),
                            ),
                    ),
                  ),
                  leading: IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.surface),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const HugeIcon(
                          icon: HugeIcons.strokeRoundedShare01,
                          color: AppColors.surface),
                      onPressed: () {
                        // Share logic
                      },
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                                child: Text(campaign.title,
                                    style: AppTextStyles.headlineMedium)),
                            const Gap(8),
                            UrgencyBadge(urgency: campaign.urgency),
                          ],
                        ),
                        const Gap(16),
                        Row(
                          children: [
                            const CircleAvatar(
                                backgroundColor: AppColors.primaryLight,
                                child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedHospital01,
                                    color: AppColors.primary,
                                    size: 20)),
                            const Gap(12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(campaign.organizerName,
                                    style: AppTextStyles.titleMedium),
                                Text(campaign.city,
                                    style: AppTextStyles.bodyMedium),
                              ],
                            ),
                          ],
                        ),
                        const Gap(24),
                        Text(
                            '${campaign.unitsPledged} ${AppStrings.unitsPledged} / ${campaign.unitsNeeded} ${AppStrings.unitsNeeded}',
                            style: AppTextStyles.labelLarge),
                        const Gap(8),
                        CampaignProgressBar(
                            progress: campaign.progressPercent, height: 12),
                        const Gap(24),
                        Text('Blood Types Needed',
                            style: AppTextStyles.titleMedium),
                        const Gap(8),
                        Wrap(
                          spacing: 8,
                          children: campaign.bloodTypesNeeded
                              .map((bt) => BloodTypeChip(type: bt))
                              .toList(),
                        ),
                        const Gap(24),
                        Text('About this campaign',
                            style: AppTextStyles.titleMedium),
                        const Gap(8),
                        Text(campaign.description,
                            style: AppTextStyles.bodyLarge),
                        const Gap(24),
                        Text('What you get in return ðŸŽ',
                            style: AppTextStyles.titleMedium),
                        const Gap(8),
                        if (campaign.hasPerks)
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: campaign.perks.length,
                            itemBuilder: (context, index) {
                              final perk = campaign.perks[index];
                              IconData getIcon(String iconName) {
                                switch (iconName) {
                                  case 'stethoscope':
                                    return HugeIcons.strokeRoundedStethoscope;
                                  case 'medicine_02':
                                    return HugeIcons
                                        .strokeRoundedMedicineBottle01;
                                  case 'star':
                                    return HugeIcons.strokeRoundedStar;
                                  case 'doctor_01':
                                    return HugeIcons.strokeRoundedDoctor01;
                                  case 'test_tube':
                                    return HugeIcons.strokeRoundedTestTube01;
                                  default:
                                    return HugeIcons.strokeRoundedGift;
                                }
                              }

                              return ListTile(
                                leading: HugeIcon(
                                  icon: getIcon(perk.type.icon),
                                  color: AppColors.primary,
                                ),
                                title: Text(perk.type.label,
                                    style: AppTextStyles.labelLarge),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(perk.description,
                                        style: AppTextStyles.bodyMedium),
                                    if (perk.conditionNote != null)
                                      Text(
                                        perk.conditionNote!,
                                        style:
                                            AppTextStyles.labelSmall.copyWith(
                                          color: AppColors.textHint,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                  ],
                                ),
                                contentPadding: EdgeInsets.zero,
                              )
                                  .animate(delay: index.ms * 80)
                                  .fadeIn()
                                  .slideX(begin: 0.1);
                            },
                          )
                        else
                          Text(
                            "This campaign hasn't listed any perks yet.",
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.textHint,
                            ),
                          ),
                        const Gap(24),
                        Row(
                          children: [
                            const HugeIcon(
                                icon: HugeIcons.strokeRoundedTime01,
                                color: AppColors.textSecondary),
                            const Gap(8),
                            Text('Ends ${campaign.deadline.relative}',
                                style: AppTextStyles.bodyMedium),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -5))
                  ],
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SafeArea(
                  child: controller.hasPledged
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            BdenButton(
                              label: AppStrings.pledgedBtn,
                              onPressed: () {},
                              isOutlined: true,
                              backgroundColor:
                                  AppColors.success.withValues(alpha: 0.1),
                              textColor: AppColors.success,
                            ),
                            const Gap(8),
                            TextButton(
                              onPressed: controller.isActing.value
                                  ? null
                                  : controller.cancelPledge,
                              child: const Text(AppStrings.cancelPledge,
                                  style: TextStyle(
                                      color: AppColors.textSecondary)),
                            ),
                          ],
                        )
                      : BdenButton(
                          label: AppStrings.pledgeBtn,
                          onPressed: campaign.isFull || campaign.isExpired
                              ? null
                              : () {
                                  final pledge = PledgeModel(
                                    id: const Uuid().v4(),
                                    campaignId: campaign.id,
                                    donorId: controller.currentUserId,
                                    donorName: controller.currentUserName,
                                    donorBloodType: BloodType
                                        .oPositive, // TODO: fetch from user
                                    status: PledgeStatus.pledged,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  );
                                  controller.pledgeToDonate(pledge);
                                },
                          isLoading: controller.isActing.value,
                          backgroundColor:
                              (campaign.isFull || campaign.isExpired)
                                  ? AppColors.textSecondary
                                  : AppColors.primary,
                        ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}


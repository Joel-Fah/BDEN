import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:go_router/go_router.dart';
// For timeago
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/extensions/datetime_extensions.dart'; // Ensure extensions are imported
import '../../../data/models/campaign_model.dart';
import 'campaign_progress_bar.dart';
import 'urgency_badge.dart';
import 'blood_type_chip.dart';

class CampaignCard extends StatelessWidget {
  final CampaignModel campaign;

  const CampaignCard({super.key, required this.campaign});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/home/feed/${campaign.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + Badge
              Stack(
                children: [
                  Hero(
                    tag: 'campaign-image-${campaign.id}',
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      color: AppColors.background,
                      child: campaign.imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: campaign.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  Container(color: Colors.grey.shade200),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.primaryLight.withValues(alpha: 0.3),
                                child: Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedDroplet,
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    size: 48,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primaryLight,
                                    Colors.white
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: const Center(
                                  child: HugeIcon(
                                      icon: HugeIcons.strokeRoundedDroplet,
                                      color: AppColors.primary,
                                      size: 48)),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: UrgencyBadge(urgency: campaign.urgency),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.title,
                        style: AppTextStyles.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const Gap(4),
                    Row(
                      children: [
                        const HugeIcon(
                            icon: HugeIcons.strokeRoundedHospital01,
                            size: 16,
                            color: AppColors.textSecondary),
                        const Gap(4),
                        Expanded(
                          child: Text(
                            '${campaign.organizerName} â€¢ ${campaign.city}',
                            style: AppTextStyles.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Gap(12),
                    CampaignProgressBar(progress: campaign.progressPercent),
                    const Gap(12),
                    Row(
                      children: [
                        ...campaign.bloodTypesNeeded
                            .take(3)
                            .map((bt) => BloodTypeChip(type: bt)),
                        if (campaign.bloodTypesNeeded.length > 3)
                          Text('+${campaign.bloodTypesNeeded.length - 3}',
                              style: AppTextStyles.labelSmall),
                        const Spacer(),
                        Text(
                          campaign.deadline.relative, // Using extension
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


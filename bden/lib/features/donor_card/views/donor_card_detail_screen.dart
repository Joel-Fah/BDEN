import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../controllers/donor_card_controller.dart';
import 'donor_cards_screen.dart';

class DonorCardDetailScreen extends StatelessWidget {
  final String hospitalId;
  const DonorCardDetailScreen({super.key, required this.hospitalId});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<DonorCardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Details'),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final card =
            c.cards.firstWhereOrNull((card) => card.hospitalId == hospitalId);
        if (card == null) {
          return const Center(child: Text('Card not found'));
        }

        final history =
            c.records.where((r) => r.hospitalId == hospitalId).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'card_${card.id}',
                child: Material(
                  type: MaterialType.transparency,
                  child: DonorCardWidget(card: card),
                ),
              ),
              const Gap(24),
              if (!c.isGloballyEligible) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const HugeIcon(
                          icon: HugeIcons.strokeRoundedClock01,
                          color: AppColors.warning),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          "You'll be eligible to donate here again in \ days.",
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(24),
              ],
              Text('Donation history', style: AppTextStyles.titleMedium),
              const Gap(12),
              if (history.isEmpty)
                Text('No recorded donations yet.',
                    style: AppTextStyles.bodyMedium)
              else
                ...history.map((record) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                            ),
                            child: const HugeIcon(
                              icon: HugeIcons.strokeRoundedDroplet,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const Gap(12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  DateFormat.yMMMd().format(record.donatedAt),
                                  style: AppTextStyles.labelLarge,
                                ),
                                Text(
                                  '\ ml',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          if (record.isQualifying)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const HugeIcon(
                                      icon: HugeIcons
                                          .strokeRoundedCheckmarkBadge01,
                                      color: AppColors.success,
                                      size: 14),
                                  const Gap(4),
                                  Text('Qualifying',
                                      style: AppTextStyles.labelSmall
                                          .copyWith(color: AppColors.success)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    )),
            ],
          ),
        );
      }),
    );
  }
}


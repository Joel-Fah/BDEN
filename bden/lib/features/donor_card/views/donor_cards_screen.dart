import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../routes/app_routes.dart';
import '../controllers/donor_card_controller.dart';
import '../../../data/models/donor_card_model.dart';

class DonorCardsScreen extends StatelessWidget {
  const DonorCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controller should be initialized usually on route navigation, but we just find it.
    final c = Get.find<DonorCardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donor Cards'),
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!c.hasAnyCard) {
          return Center(
            child: EmptyState(
              icon: HugeIcons.strokeRoundedCreditCard,
              title: "No cards yet",
              subtitle: "Donate at a hospital to earn your first donor card",
            ),
          );
        }

        return Column(
          children: [
            _buildEligibilityBanner(c),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: c.cards.length,
                separatorBuilder: (_, __) => const Gap(16),
                itemBuilder: (_, index) {
                  final card = c.cards[index];
                  return GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.donorCardDetail
                          .replaceFirst(':hospitalId', card.hospitalId));
                    },
                    child: DonorCardWidget(card: card),
                  );
                },
              ),
            ),
            _buildStatsRow(c),
          ],
        );
      }),
    );
  }

  Widget _buildEligibilityBanner(DonorCardController c) {
    final isEligible = c.isGloballyEligible;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: isEligible
          ? AppColors.success.withValues(alpha: 0.1)
          : AppColors.warning.withValues(alpha: 0.1),
      child: Row(
        children: [
          HugeIcon(
            icon: isEligible
                ? HugeIcons.strokeRoundedCheckmarkBadge01
                : HugeIcons.strokeRoundedClock01,
            color: isEligible ? AppColors.success : AppColors.warning,
            size: 20,
          ),
          const Gap(8),
          Expanded(
            child: Text(
              isEligible
                  ? "You're eligible to donate! ðŸ©¸"
                  : "Next donation available in ${c.daysUntilNextDonation} days",
              style: AppTextStyles.labelLarge.copyWith(
                color: isEligible ? AppColors.success : AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DonorCardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Stat(label: 'Total Pledges', value: '${controller.records.length}'),
          _Stat(
              label: 'Qualifying',
              value: '${controller.totalQualifyingDonations}'),
          _Stat(label: 'Hospitals', value: '${controller.cards.length}'),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: AppTextStyles.titleLarge),
        const Gap(4),
        Text(label, style: AppTextStyles.bodyMedium),
      ],
    );
  }
}

class DonorCardWidget extends StatelessWidget {
  final DonorCardModel card;
  const DonorCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final isActive = card.isActive;
    final isElite = card.isElite;

    Widget cardWidget = Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: isActive
              ? [AppColors.primaryDark, AppColors.primary]
              : [Colors.grey.shade700, Colors.grey.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white,
                backgroundImage: card.hospitalLogoUrl != null
                    ? CachedNetworkImageProvider(card.hospitalLogoUrl!)
                    : null,
                child: card.hospitalLogoUrl == null
                    ? HugeIcon(
                        icon: HugeIcons.strokeRoundedHospital01,
                        color: AppColors.primaryDark)
                    : null,
              ),
              const Gap(12),
              Expanded(
                child: Text(
                  card.hospitalName.isNotEmpty
                      ? card.hospitalName
                      : 'Health Center',
                  style: AppTextStyles.titleLarge.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  card.status.label,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isActive ? AppColors.primary : Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            '${card.qualifyingDonationCount} donations',
            style: AppTextStyles.displayLarge.copyWith(color: Colors.white),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Member since ${card.createdAt.year}',
                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
              ),
              Row(
                children: List.generate(5, (i) {
                  final activeDot = i < card.qualifyingDonationCount;
                  return Container(
                    margin: const EdgeInsets.only(left: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeDot ? Colors.white : Colors.white24,
                    ),
                  );
                }),
              )
            ],
          ),
        ],
      ),
    );

    if (isElite) {
      cardWidget = cardWidget
          .animate(onPlay: (controller) => controller.repeat())
          .shimmer(
            duration: const Duration(seconds: 3),
            color: Colors.white30,
          );
    }

    return cardWidget;
  }
}


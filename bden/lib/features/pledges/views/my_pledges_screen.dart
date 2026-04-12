import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/pledge_status.dart';
import '../controllers/pledge_controller.dart';
import '../../../shared/widgets/empty_state.dart';

class MyPledgesScreen extends GetView<PledgeController> {
  const MyPledgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text('My Pledges', style: AppTextStyles.headlineMedium),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: AppColors.primary, size: 40));
        }

        if (controller.pledges.isEmpty) {
          return const EmptyState(
            icon: HugeIcons.strokeRoundedDroplet,
            title: 'No pledges yet',
            subtitle: 'Find a campaign and start donating!',
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: controller.pledges.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final pledge = controller.pledges[index];
            final isConfirmed = pledge.status == PledgeStatus.confirmed;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      color: isConfirmed
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isConfirmed
                          ? HugeIcons.strokeRoundedCheckmarkBadge01
                          : HugeIcons.strokeRoundedTime01,
                      color:
                          isConfirmed ? AppColors.success : AppColors.primary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Donation Pledge',
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isConfirmed
                                    ? AppColors.success.withValues(alpha: 0.1)
                                    : AppColors.warning.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                pledge.status.name.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: isConfirmed
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              timeago.format(pledge.createdAt),
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (pledge.status == PledgeStatus.pledged)
                    IconButton(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedCancel01,
                        color: AppColors.error,
                      ),
                      onPressed: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Cancel Pledge'),
                            content: const Text(
                                'Are you sure you want to cancel this pledge?'),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  controller.cancelPledge(pledge.id);
                                  Get.back();
                                },
                                child: const Text('Yes, Cancel',
                                    style: TextStyle(color: AppColors.error)),
                              ),
                            ],
                          ),
                        );
                      },
                    )
                  else
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight01,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}


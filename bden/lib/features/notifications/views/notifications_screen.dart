import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/notification_type.dart';
import '../controllers/notification_controller.dart';
import '../../../shared/widgets/empty_state.dart';

class NotificationsScreen extends GetView<NotificationController> {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.notifTitle, style: AppTextStyles.headlineMedium),
        actions: [
          TextButton(
            onPressed: controller.markAllAsRead,
            child: const Text(AppStrings.markAllRead,
                style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: AppColors.primary, size: 40));
        }

        if (controller.notifications.isEmpty) {
          return const EmptyState(
            icon: HugeIcons.strokeRoundedNotification01,
            title: AppStrings.notifEmpty,
            subtitle: 'We\'ll let you know when something important happens.',
          );
        }

        return ListView.builder(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final n = controller.notifications[index];
            return Container(
              color: n.isRead
                  ? Colors.transparent
                  : AppColors.primaryLight.withValues(alpha: 0.3),
              child: ListTile(
                leading: _buildIcon(n.type),
                title: Text(n.title, style: AppTextStyles.titleMedium),
                subtitle: Text(n.body, style: AppTextStyles.bodyMedium),
                trailing: Text(timeago.format(n.createdAt),
                    style: AppTextStyles.labelSmall),
                onTap: () {
                  controller.markAsRead(n.id);
                  if (n.relatedId != null) {
                    // Navigate to related
                    // context.push ...
                  }
                },
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildIcon(NotificationType type) {
    IconData icon;
    Color color;
    switch (type) {
      case NotificationType.newCampaign:
        icon = HugeIcons.strokeRoundedMegaphone01;
        color = Colors.blue;
        break;
      case NotificationType.pledgeUpdate:
        icon = HugeIcons.strokeRoundedDroplet;
        color = AppColors.primary;
        break;
      case NotificationType.campaignDeadline:
        icon = HugeIcons.strokeRoundedTime01;
        color = Colors.orange;
        break;
    }
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: 0.1),
      child: Icon(icon, color: color),
    );
  }
}


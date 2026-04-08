import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:gap/gap.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../routes/app_routes.dart';
import '../../../../data/models/campaign_model.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/enums/pledge_status.dart';
import '../controllers/organizer_dashboard_controller.dart';
import '../../../shared/widgets/empty_state.dart';

class OrganizerDashboardScreen extends GetView<OrganizerDashboardController> {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.dashTitle, style: AppTextStyles.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(HugeIcons.strokeRoundedNotification01),
            onPressed: () => context.push(AppRoutes.organizerNotif),
          ),
          const Gap(8),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.createCampaign),
        backgroundColor: AppColors.primary,
        child: const Icon(HugeIcons.strokeRoundedAdd01, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
              child: LoadingAnimationWidget.inkDrop(
                  color: AppColors.primary, size: 40));
        }

        if (controller.campaigns.isEmpty) {
          return const Center(
            child: EmptyState(
              icon: HugeIcons.strokeRoundedFolder01,
              title: 'No campaigns yet',
              subtitle: 'Start your first blood drive today!',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => controller.onInit(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                Row(
                  children: [
                    Expanded(
                        child: _StatCard(
                      label: 'Campaigns',
                      value: '${controller.campaigns.length}',
                      icon: HugeIcons.strokeRoundedMegaphone01,
                      color: Colors.blue,
                    )),
                    const Gap(8),
                    Expanded(
                        child: _StatCard(
                      label: 'Pledges',
                      value: '${controller.totalPledges}',
                      icon: HugeIcons.strokeRoundedUserGroup,
                      color: Colors.orange,
                    )),
                    const Gap(8),
                    Expanded(
                        child: _StatCard(
                      label: 'Confirmed',
                      value: '${controller.totalConfirmed}',
                      icon: HugeIcons.strokeRoundedCheckmarkBadge01,
                      color: AppColors.success,
                    )),
                  ],
                ),
                const Gap(24),

                // Chart
                Text('Performance', style: AppTextStyles.titleMedium),
                const Gap(16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: FlTitlesData(
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (val, meta) {
                              final index = val.toInt();
                              if (index >= controller.campaigns.length) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  controller.campaigns[index].title
                                      .substring(0, 3)
                                      .toUpperCase(),
                                  style: AppTextStyles.labelSmall,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: controller.campaigns
                          .take(5)
                          .toList()
                          .asMap()
                          .entries
                          .map((e) {
                        final idx = e.key;
                        final c = e.value;
                        return BarChartGroupData(x: idx, barRods: [
                          BarChartRodData(
                              toY: c.unitsPledged.toDouble(),
                              color: AppColors.primaryLight,
                              width: 12),
                          BarChartRodData(
                              toY: c.unitsConfirmed.toDouble(),
                              color: AppColors.success,
                              width: 12),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                const Gap(24),

                // Campaigns List
                Text(AppStrings.myCampaigns, style: AppTextStyles.titleMedium),
                const Gap(16),
                ...controller.campaigns.map((c) => _CampaignRow(
                      campaign: c,
                      controller: controller,
                    )),
                const Gap(80), // FAB spacing
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Gap(8),
          Text(value,
              style: AppTextStyles.headlineMedium.copyWith(fontSize: 20)),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}

class _CampaignRow extends StatelessWidget {
  final CampaignModel campaign;
  final OrganizerDashboardController controller;

  const _CampaignRow({required this.campaign, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text(campaign.title, style: AppTextStyles.titleMedium),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: campaign.isActive
                    ? AppColors.success.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                campaign.isActive ? 'Active' : 'Closed',
                style: AppTextStyles.labelSmall.copyWith(
                  color: campaign.isActive ? AppColors.success : Colors.grey,
                ),
              ),
            ),
            const Gap(8),
            Text('${campaign.unitsPledged} pledges',
                style: AppTextStyles.bodyMedium),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (campaign.isActive)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(AppStrings.closeCampaign),
                    onPressed: () => controller.closeCampaign(campaign.id),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error),
                  ),
                const Gap(12),
                const Text('Pledges',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Gap(8),
                Obx(() {
                  final pledges = controller.pledgesFor(campaign.id);
                  if (pledges.isEmpty) {
                    return const Text('No pledges yet.',
                        style: TextStyle(color: Colors.grey));
                  }

                  return Column(
                    children: pledges
                        .map((p) => ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryLight,
                                child: Text(p.donorBloodType.label,
                                    style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                              title: Text(p.donorName),
                              subtitle: Text(p.status.name),
                              trailing: p.status == PledgeStatus.pledged
                                  ? IconButton(
                                      icon: const Icon(
                                          Icons.check_circle_outline,
                                          color: AppColors.success),
                                      onPressed: () =>
                                          controller.confirmPledge(p, campaign),
                                    )
                                  : const Icon(Icons.check_circle,
                                      color: AppColors.success, size: 16),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

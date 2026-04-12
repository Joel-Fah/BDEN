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
import '../../../core/enums/campaign_urgency.dart';
import '../controllers/campaign_feed_controller.dart';
import '../../myths/controllers/myth_controller.dart';
import '../widgets/campaign_card.dart';
import '../../../shared/widgets/empty_state.dart';

class CampaignFeedScreen extends StatefulWidget {
  const CampaignFeedScreen({super.key});

  @override
  State<CampaignFeedScreen> createState() => _CampaignFeedScreenState();
}

class _CampaignFeedScreenState extends State<CampaignFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showSearchIcon = false;
  late CampaignFeedController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<CampaignFeedController>();
    if (!Get.isRegistered<MythController>()) {
      Get.put(MythController(Get.find()));
    }

    _scrollController.addListener(() {
      if (_scrollController.offset > 60 && !_showSearchIcon) {
        setState(() => _showSearchIcon = true);
      } else if (_scrollController.offset <= 60 && _showSearchIcon) {
        setState(() => _showSearchIcon = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            scrolledUnderElevation: 0,
            title:
                Text(AppStrings.feedTitle, style: AppTextStyles.headlineMedium),
            actions: [
              AnimatedOpacity(
                opacity: _showSearchIcon ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedSearch01,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () {
                    _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                  },
                ),
              ),
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

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
          ),

          // Filters pinned when scrolling
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverFilterDelegate(
              child: Container(
                color: AppColors.background,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Obx(() => Row(
                        children: [
                          ...BloodType.values.map((bt) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(bt.label),
                                  selected: controller.selectedBloodTypes
                                      .contains(bt),
                                  onSelected: (_) =>
                                      controller.toggleBloodTypeFilter(bt),
                                  selectedColor: AppColors.primaryLight,
                                  labelStyle: TextStyle(
                                      color: controller.selectedBloodTypes
                                              .contains(bt)
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
              ),
            ),
          ),

          // Main body content (Myths, Interactive Segments, All Campaigns)
          SliverToBoxAdapter(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Container(
                  height: 300,
                  alignment: Alignment.center,
                  child: LoadingAnimationWidget.inkDrop(
                      color: AppColors.primary, size: 40),
                );
              }

              final campaigns = controller.filteredCampaigns;
              if (campaigns.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: EmptyState(
                    icon: HugeIcons.strokeRoundedHospital01,
                    title: 'No campaigns found',
                    subtitle: AppStrings.feedEmpty,
                  ),
                );
              }

              final urgentCampaigns = campaigns
                  .where((c) =>
                      c.urgency == CampaignUrgency.critical ||
                      c.urgency == CampaignUrgency.urgent)
                  .toList();
              final recentCampaigns = campaigns
                  .where((c) =>
                      c.urgency != CampaignUrgency.critical &&
                      c.urgency != CampaignUrgency.urgent)
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

              final uniqueHospitals =
                  campaigns.map((c) => c.organizerName).toSet().toList();
              final uniquePlaces =
                  campaigns.map((c) => c.city).toSet().toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),
                  // NEW: Myths Teaser
                  GetX<MythController>(
                    builder: (mythController) {
                      if (mythController.myths.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      final displayMyths =
                          mythController.myths.take(3).toList();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Did you know? ðŸ¤”',
                                    style: AppTextStyles.titleMedium),
                                TextButton(
                                  onPressed: () =>
                                      context.push(AppRoutes.myths),
                                  child: Text('See all',
                                      style: AppTextStyles.labelLarge
                                          .copyWith(color: AppColors.primary)),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 130,
                            child: ListView.separated(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
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
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.3)),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: const Text(
                                                'MYTH',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            Text('Tap to bust ðŸ”¥',
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                        color:
                                                            AppColors.primary)),
                                          ],
                                        ),
                                        const Gap(8),
                                        Expanded(
                                          child: Text(
                                            myth.myth,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTextStyles.bodyMedium
                                                .copyWith(
                                                    color:
                                                        AppColors.primaryDark,
                                                    fontWeight:
                                                        FontWeight.w600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const Gap(24),
                        ],
                      );
                    },
                  ),

                  // Urgent Requests Section
                  if (urgentCampaigns.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const HugeIcon(
                              icon: HugeIcons.strokeRoundedAlert02,
                              color: AppColors.error),
                          const Gap(8),
                          Text('Urgent Requests',
                              style: AppTextStyles.titleMedium),
                        ],
                      ),
                    ),
                    const Gap(12),
                    SizedBox(
                      height: 400,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: urgentCampaigns.length,
                        separatorBuilder: (_, __) => const Gap(16),
                        itemBuilder: (context, index) {
                          return SizedBox(
                            width: 280,
                            child:
                                CampaignCard(campaign: urgentCampaigns[index]),
                          );
                        },
                      ),
                    ),
                    const Gap(24),
                  ],

                  // Recently Added Section
                  if (recentCampaigns.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          Text('Newly Added', style: AppTextStyles.titleMedium),
                    ),
                    const Gap(12),
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics:
                          const NeverScrollableScrollPhysics(), // Scroll handled by CustomScrollView
                      shrinkWrap: true,
                      itemCount: recentCampaigns.length < 3
                          ? recentCampaigns.length
                          : 3,
                      separatorBuilder: (_, __) => const Gap(16),
                      itemBuilder: (context, index) {
                        return CampaignCard(campaign: recentCampaigns[index]);
                      },
                    ),
                    const Gap(24),
                  ],

                  // Featured Hospitals
                  if (uniqueHospitals.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Featured Hospitals',
                          style: AppTextStyles.titleMedium),
                    ),
                    const Gap(12),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: uniqueHospitals.length,
                        separatorBuilder: (_, __) => const Gap(16),
                        itemBuilder: (context, index) {
                          final hospitalName = uniqueHospitals[index];
                          return Container(
                            width: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.5)),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primaryLight.withValues(alpha: 0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedHospital01,
                                    color: AppColors.primary,
                                    size: 32,
                                  ),
                                ),
                                const Gap(12),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text(
                                    hospitalName,
                                    style: AppTextStyles.bodyMedium
                                        .copyWith(fontWeight: FontWeight.w600),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(24),
                  ],

                  // Featured Towns/Places
                  if (uniquePlaces.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Featured Places',
                          style: AppTextStyles.titleMedium),
                    ),
                    const Gap(12),
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: uniquePlaces.length,
                        separatorBuilder: (_, __) => const Gap(16),
                        itemBuilder: (context, index) {
                          final placeName = uniquePlaces[index];
                          final campaignsInPlace = campaigns
                              .where((c) => c.city == placeName)
                              .length;
                          return Container(
                            width: 200,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primaryLight, Colors.white],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: AppColors.border.withValues(alpha: 0.5)),
                              boxShadow: const [
                                BoxShadow(
                                    color: Color(0x0F000000),
                                    blurRadius: 10,
                                    offset: Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const HugeIcon(
                                    icon: HugeIcons.strokeRoundedLocation01,
                                    color: AppColors.primary,
                                    size: 24,
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        placeName,
                                        style: AppTextStyles.bodyLarge.copyWith(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Gap(4),
                                      Text(
                                        '$campaignsInPlace Drive${campaignsInPlace > 1 ? 's' : ''}',
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                                color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Gap(24),
                  ],

                  // Remaining Campaigns Section (if more than 3)
                  if (recentCampaigns.length > 3) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('More Campaigns',
                          style: AppTextStyles.titleMedium),
                    ),
                    const Gap(12),
                    ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics:
                          const NeverScrollableScrollPhysics(), // Scroll handled by CustomScrollView
                      shrinkWrap: true,
                      itemCount: recentCampaigns.length - 3,
                      separatorBuilder: (_, __) => const Gap(16),
                      itemBuilder: (context, index) {
                        return CampaignCard(
                            campaign: recentCampaigns[index + 3]);
                      },
                    ),
                    const Gap(24),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SliverFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _SliverFilterDelegate({
    required this.child,
  });

  @override
  double get minExtent => 60.0;
  @override
  double get maxExtent => 60.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_SliverFilterDelegate oldDelegate) {
    return true; // We want it to rebuild when filters change though Obx inside handles it
  }
}


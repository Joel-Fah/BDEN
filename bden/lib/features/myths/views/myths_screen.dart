import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/myth_category.dart';
import '../controllers/myth_controller.dart';
import '../../../data/models/myth_model.dart';
import '../../../data/repositories/myth_repository.dart';

class MythsScreen extends StatefulWidget {
  const MythsScreen({super.key});

  @override
  State<MythsScreen> createState() => _MythsScreenState();
}

class _MythsScreenState extends State<MythsScreen> {
  late MythController c;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<MythController>()) {
      Get.put(MythController(Get.find<MythRepository>()));
    }
    c = Get.find<MythController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Myth Busters ??'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.myths.isEmpty) {
                return const Center(child: Text('No myths found.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: c.myths.length,
                separatorBuilder: (_, __) => const Gap(12),
                itemBuilder: (_, index) {
                  final myth = c.myths[index];
                  return MythCard(myth: myth, controller: c);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SizedBox(
      height: 60,
      child: Obx(() => ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              _FilterChip(
                label: 'All',
                isSelected: c.selectedCategory.value == null,
                onTap: () => c.setCategory(null),
              ),
              ...MythCategory.values.map((cat) => Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _FilterChip(
                      label: cat.label,
                      isSelected: c.selectedCategory.value == cat,
                      onTap: () => c.setCategory(cat),
                    ),
                  )),
            ],
          )),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTextStyles.labelLarge.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class MythCard extends StatelessWidget {
  final MythModel myth;
  final MythController controller;

  const MythCard({super.key, required this.myth, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedMythId.value == myth.id;

      return GestureDetector(
        onTap: () => controller.toggleMyth(myth.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 4,
                  offset: Offset(0, 2))
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('MYTH',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold)),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      myth.myth,
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isExpanded
                            ? AppColors.textSecondary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const Gap(8),
                  HugeIcon(
                    icon: isExpanded
                        ? HugeIcons.strokeRoundedArrowUp01
                        : HugeIcons.strokeRoundedArrowDown01,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
              if (isExpanded)
                ...[
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('TRUTH',
                        style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold)),
                  ),
                  const Gap(8),
                  Text(myth.truth, style: AppTextStyles.bodyLarge),
                  if (myth.sourceName != null) ...[
                    const Gap(12),
                    GestureDetector(
                      onTap: myth.sourceUrl != null
                          ? () => launchUrl(Uri.parse(myth.sourceUrl!))
                          : null,
                      child: Row(
                        children: [
                          const HugeIcon(
                              icon: HugeIcons.strokeRoundedLink01,
                              color: AppColors.textHint,
                              size: 14),
                          const Gap(4),
                          Text(
                            'Source: ${myth.sourceName}',
                            style: AppTextStyles.labelSmall.copyWith(
                              decoration: myth.sourceUrl != null
                                  ? TextDecoration.underline
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ].animate().fadeIn(duration: 200.ms).slideY(begin: -0.1),
            ],
          ),
        ),
      );
    });
  }
}


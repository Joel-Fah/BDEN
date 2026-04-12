import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:dotted_border/dotted_border.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/enums/blood_type.dart';
import '../../../core/enums/campaign_urgency.dart';
import '../../../core/enums/perk_type.dart';
import '../../../shared/widgets/bden_button.dart';
import '../../../shared/widgets/bden_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/create_campaign_controller.dart';
import '../widgets/blood_type_chip.dart';

class CreateCampaignScreen extends GetView<CreateCampaignController> {
  const CreateCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text('New Campaign'),
            actions: [
              Obx(() => TextButton(
                    onPressed: controller.isFormValid
                        ? () => controller.submitCampaign()
                        : null,
                    child: Text(
                      'Publish',
                      style: AppTextStyles.labelLarge.copyWith(
                        color: controller.isFormValid
                            ? AppColors.primary
                            : AppColors.textHint,
                      ),
                    ),
                  )),
              const Gap(8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Upload
                GestureDetector(
                  onTap: controller.pickImage,
                  child: DottedBorder(
                    color: AppColors.border,
                    strokeWidth: 2,
                    dashPattern: const [8, 4],
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(16),
                    child: Container(
                      width: double.infinity,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Obx(() {
                        if (controller.coverImage.value != null) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(
                              controller.coverImage.value!,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(HugeIcons.strokeRoundedImage01,
                                size: 40, color: AppColors.textHint),
                            const Gap(8),
                            Text('Tap to upload cover image',
                                style: AppTextStyles.bodyMedium),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
                const Gap(24),

                BdenTextField(
                  label: 'Title',
                  hint: 'e.g., Urgent O- Blood Required',
                  onChanged: (v) => controller.title.value = v,
                ),
                const Gap(16),

                Text('Urgency Level', style: AppTextStyles.labelLarge),
                const Gap(8),
                Obx(() => Row(
                      children: CampaignUrgency.values.map((u) {
                        final isSelected = controller.urgency.value == u;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: GestureDetector(
                              onTap: () => controller.urgency.value = u,
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? u.color.withValues(alpha: 0.1)
                                      : AppColors.surface,
                                  border: Border.all(
                                    color:
                                        isSelected ? u.color : AppColors.border,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  u.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: isSelected
                                        ? u.color
                                        : AppColors.textSecondary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                const Gap(16),

                BdenTextField(
                  label: 'Description',
                  hint: 'Tell donors why this is important...',
                  maxLines: 4,
                  onChanged: (v) => controller.description.value = v,
                ),
                const Gap(16),

                Row(
                  children: [
                    Expanded(
                      child: BdenTextField(
                        label: 'City',
                        onChanged: (v) => controller.city.value = v,
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      child: BdenTextField(
                        label: 'Region',
                        onChanged: (v) => controller.region.value = v,
                      ),
                    ),
                  ],
                ),
                const Gap(16),
                BdenTextField(
                  label: 'Address',
                  onChanged: (v) => controller.address.value = v,
                ),
                const Gap(24),

                Text('Units Needed', style: AppTextStyles.labelLarge),
                const Gap(8),
                Obx(() => Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => controller.unitsNeeded.value > 1
                              ? controller.unitsNeeded.value--
                              : null,
                        ),
                        Text('${controller.unitsNeeded.value}',
                            style: AppTextStyles.headlineMedium),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () => controller.unitsNeeded.value++,
                        ),
                      ],
                    )),
                const Gap(24),

                Text('Blood Types Needed', style: AppTextStyles.labelLarge),
                const Gap(8),
                Obx(() => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: BloodType.values
                          .map((bt) => BloodTypeChip(
                                type: bt,
                                isSelected:
                                    controller.selectedBloodTypes.contains(bt),
                                onTap: () => controller.toggleBloodType(bt),
                              ))
                          .toList(),
                    )),
                const Gap(24),

                GestureDetector(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) controller.deadline.value = date;
                  },
                  child: AbsorbPointer(
                    child: Obx(() => BdenTextField(
                          label: 'Deadline',
                          hint: 'Select date',
                          controller: TextEditingController(
                              text: controller.deadline.value
                                      ?.toString()
                                      .split(' ')[0] ??
                                  ''),
                          suffixIcon:
                              const Icon(HugeIcons.strokeRoundedCalendar01),
                        )),
                  ),
                ),
                const Gap(24),

                // NEW: Perks Section
                Text('What will you offer donors? (optional)',
                    style: AppTextStyles.labelLarge),
                const Gap(8),
                Obx(() => Column(
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PerkType.values.map((pt) {
                            final isSelected = controller.selectedPerks
                                .any((p) => p.type == pt);
                            return FilterChip(
                              label: Text(pt.label,
                                  style: const TextStyle(fontSize: 12)),
                              selected: isSelected,
                              onSelected: (selected) {
                                if (selected) {
                                  _showAddPerkDialog(context, pt);
                                } else {
                                  controller.removePerk(pt);
                                }
                              },
                              backgroundColor: AppColors.surface,
                              selectedColor: AppColors.primaryLight,
                              checkmarkColor: AppColors.primary,
                            );
                          }).toList(),
                        ),
                        const Gap(16),
                        if (controller.selectedPerks.isNotEmpty)
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.selectedPerks.length,
                            separatorBuilder: (_, __) => const Gap(8),
                            itemBuilder: (context, index) {
                              final perk = controller.selectedPerks[index];
                              return ListTile(
                                title: Text(perk.type.label,
                                    style: AppTextStyles.titleMedium),
                                subtitle: Text(
                                  "${perk.description}\n${perk.conditionNote ?? ''}"
                                      .trim(),
                                  style: AppTextStyles.bodyMedium,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.close,
                                      color: AppColors.error),
                                  onPressed: () =>
                                      controller.removePerk(perk.type),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side:
                                      const BorderSide(color: AppColors.border),
                                ),
                              );
                            },
                          )
                      ],
                    )),

                const Gap(48),
              ],
            ),
          ),
        ),
        Obx(() {
          if (controller.isLoading.value) {
            return const LoadingOverlay();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  void _showAddPerkDialog(BuildContext context, PerkType type) {
    final descCtrl = TextEditingController();
    final condCtrl = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add ${type.label}', style: AppTextStyles.titleLarge),
              const Gap(16),
              BdenTextField(
                label: 'Description',
                hint: 'e.g. Free full blood count',
                controller: descCtrl,
              ),
              const Gap(16),
              BdenTextField(
                label: 'Condition (optional)',
                hint: 'e.g. After 2 donations',
                controller: condCtrl,
              ),
              const Gap(24),
              SizedBox(
                width: double.infinity,
                child: BdenButton(
                  label: 'Add',
                  onPressed: () {
                    if (descCtrl.text.isNotEmpty) {
                      controller.addPerk(
                        type,
                        descCtrl.text,
                        condCtrl.text.isEmpty ? null : condCtrl.text,
                      );
                      Get.back();
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


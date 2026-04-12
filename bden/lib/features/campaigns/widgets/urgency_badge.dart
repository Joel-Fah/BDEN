import 'package:flutter/material.dart';
import '../../../../core/enums/campaign_urgency.dart';
import '../../../../core/constants/app_text_styles.dart';

class UrgencyBadge extends StatelessWidget {
  final CampaignUrgency urgency;

  const UrgencyBadge({super.key, required this.urgency});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: urgency.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: urgency.color),
      ),
      child: Text(
        urgency.label.toUpperCase(),
        style: AppTextStyles.labelSmall
            .copyWith(color: urgency.color, fontWeight: FontWeight.bold),
      ),
    );
  }
}


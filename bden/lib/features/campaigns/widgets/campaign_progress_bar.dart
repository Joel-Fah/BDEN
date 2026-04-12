import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CampaignProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final bool showLabel;

  const CampaignProgressBar(
      {super.key,
      required this.progress,
      this.height = 8,
      this.showLabel = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Text('${(progress * 100).toInt()}% gathered',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 4),
        ],
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.border,
          color: AppColors.primary,
          minHeight: height,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      ],
    );
  }
}

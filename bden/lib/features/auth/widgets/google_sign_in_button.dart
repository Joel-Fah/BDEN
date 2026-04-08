import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class GoogleSignInButton extends StatelessWidget {
  final Future<void> Function() onPressed;
  final bool isLoading;

  const GoogleSignInButton(
      {super.key, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: const BorderSide(color: AppColors.border),
          backgroundColor: AppColors.surface,
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: LoadingAnimationWidget.inkDrop(
                  color: AppColors.primary,
                  size: 24,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(' Continue with Google',
                      style: AppTextStyles.labelLarge),
                ],
              ),
      ),
    );
  }
}

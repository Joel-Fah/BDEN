import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/bden_button.dart';
import '../../../../shared/widgets/bden_text_field.dart';
import '../controllers/auth_controller.dart';

class OrganizerLoginScreen extends GetView<AuthController> {
  const OrganizerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo and Header
              Center(
                child: Column(
                  children: [
                    const HugeIcon(
                      icon: HugeIcons.strokeRoundedHospital01,
                      color: AppColors.primary,
                      size: 72,
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                    const Gap(16),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.displayLarge.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const Gap(8),
                    Text(
                      'Health Center Portal',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(48),

              // Welcome Text
              Text('Welcome Back', style: AppTextStyles.headlineMedium),
              const Gap(8),
              Text('Sign in to manage campaigns and pledges.',
                  style: AppTextStyles.bodyMedium),
              const Gap(32),

              // Inputs
              BdenTextField(
                label: 'Center Email',
                controller: emailCtrl,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedMail01,
                  color: AppColors.textSecondary,
                ),
              ),
              const Gap(20),
              BdenTextField(
                label: 'Password',
                controller: passCtrl,
                validator: Validators.password,
                obscureText: true,
                prefixIcon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedLockKey,
                  color: AppColors.textSecondary,
                ),
              ),
              const Gap(32),

              // Actions
              Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (controller.errorMessage.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: AppColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const HugeIcon(
                                icon: HugeIcons.strokeRoundedAlert02,
                                color: AppColors.error,
                                size: 20,
                              ),
                              const Gap(8),
                              Expanded(
                                child: Text(
                                  controller.errorMessage.value,
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                      BdenButton(
                        label: 'Sign In as Center',
                        isLoading: controller.isLoading.value,
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.loginWithEmail(
                                emailCtrl.text.trim(), passCtrl.text.trim());
                          }
                        },
                      ),
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}


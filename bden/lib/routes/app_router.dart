import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'app_routes.dart';
import '../features/auth/controllers/auth_controller.dart';
import '../features/auth/views/login_screen.dart';
import '../features/auth/views/organizer_login_screen.dart';
import '../features/auth/views/role_selection_screen.dart';
import '../features/onboarding/views/onboarding_screen.dart';
import '../features/onboarding/views/donor_setup_screen.dart';
import '../features/campaigns/views/campaign_feed_screen.dart';
import '../features/campaigns/views/campaign_detail_screen.dart';
import '../features/campaigns/views/create_campaign_screen.dart';
import '../features/pledges/views/my_pledges_screen.dart';
import '../features/dashboard/views/organizer_dashboard_screen.dart';
import '../features/notifications/views/notifications_screen.dart';
import '../features/profile/views/profile_screen.dart';
import '../features/donor_card/views/donor_cards_screen.dart';
import '../features/donor_card/views/donor_card_detail_screen.dart';
import '../features/myths/views/myths_screen.dart';
import '../shared/layouts/donor_shell.dart';
import '../shared/layouts/organizer_shell.dart';

// Splash Screen
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class AuthListenable extends ChangeNotifier {
  final AuthController auth;
  AuthListenable(this.auth) {
    auth.currentUser.listen((_) => notifyListeners());
    auth.isOnboarded.listen((_) => notifyListeners());
    auth.isAuthReady.listen((_) => notifyListeners());
  }
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.splash,
  refreshListenable: AuthListenable(Get.find<AuthController>()),
  redirect: (context, state) {
    final auth = Get.find<AuthController>();

    if (!auth.isAuthReady.value) {
      return null;
    }

    final isLoggedIn = auth.currentUser.value != null;
    final isOnboarded = auth.isOnboarded.value;
    final isOrganizer = auth.currentUser.value?.isOrganizer ?? false;

    final isOnLogin = state.matchedLocation.startsWith('/login') ||
        state.matchedLocation == AppRoutes.splash;
    final isOnOnboarding = state.matchedLocation.startsWith('/onboarding') ||
        state.matchedLocation == AppRoutes.roleSelect;

    if (!isLoggedIn) {
      if (isOnLogin && state.matchedLocation != AppRoutes.splash) {
        return null;
      }
      return AppRoutes.login;
    }

    // Logged in
    if (!isOnboarded) {
      if (state.matchedLocation == AppRoutes.roleSelect ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.donorSetup) {
        return null; // Allow staying on onboarding flow
      }
      return AppRoutes.roleSelect;
    }

    // Logged in and Onboarded
    if (isOnLogin || isOnOnboarding) {
      return isOrganizer ? AppRoutes.organizerDashboard : AppRoutes.feed;
    }

    if (state.matchedLocation == AppRoutes.splash) {
      return isOrganizer ? AppRoutes.organizerDashboard : AppRoutes.feed;
    }

    return null;
  },
  routes: [
    GoRoute(path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
    GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
    GoRoute(
        path: AppRoutes.organizerLogin,
        builder: (_, __) => const OrganizerLoginScreen()),
    GoRoute(
        path: AppRoutes.roleSelect,
        builder: (_, __) => const RoleSelectionScreen()),
    GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen()),
    GoRoute(
        path: AppRoutes.donorSetup,
        builder: (_, __) => const DonorSetupScreen()),

    // Donor shell
    ShellRoute(
      builder: (_, __, child) => DonorShell(child: child),
      routes: [
        GoRoute(
            path: AppRoutes.feed,
            builder: (_, __) => const CampaignFeedScreen()),
        GoRoute(
          path: '/home/feed/:id', // Matching AppRoutes.campaignDetail pattern
          builder: (_, state) =>
              CampaignDetailScreen(campaignId: state.pathParameters['id']!),
        ),
        GoRoute(
            path: AppRoutes.pledges,
            builder: (_, __) => const MyPledgesScreen()),
        GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => const NotificationsScreen()),
        GoRoute(
            path: AppRoutes.profile, builder: (_, __) => const ProfileScreen()),
        
        // NEW Routes
        GoRoute(
          path: '/home/cards', // AppRoutes.donorCards
          builder: (_, __) => const DonorCardsScreen(),
        ),
        GoRoute(
          path: '/home/cards/:hospitalId', // AppRoutes.donorCardDetail
          builder: (_, state) =>
            DonorCardDetailScreen(hospitalId: state.pathParameters['hospitalId']!),
        ),
        GoRoute(
          path: '/home/myths', // AppRoutes.myths
          builder: (_, __) => const MythsScreen(),
        ),
      ],
    ),

    // Organizer shell
    ShellRoute(
      builder: (_, __, child) => OrganizerShell(child: child),
      routes: [
        GoRoute(
            path: AppRoutes.organizerDashboard,
            builder: (_, __) => const OrganizerDashboardScreen()),
        GoRoute(
            path: AppRoutes.createCampaign,
            builder: (_, __) => const CreateCampaignScreen()),
        GoRoute(
            path: AppRoutes.organizerNotif,
            builder: (_, __) => const NotificationsScreen()),
        GoRoute(
            path: AppRoutes.organizerProfile,
            builder: (_, __) => const ProfileScreen()),
      ],
    ),
  ],
);

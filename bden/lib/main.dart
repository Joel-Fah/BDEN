import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'data/services/firebase_auth_service.dart';
import 'data/services/campaign_service.dart';
import 'data/services/pledge_service.dart';
import 'data/services/notification_service.dart';
import 'data/services/donation_record_service.dart';
import 'data/services/donor_card_service.dart';
import 'data/services/myth_service.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/campaign_repository.dart';
import 'data/repositories/pledge_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/donation_record_repository.dart';
import 'data/repositories/donor_card_repository.dart';
import 'data/repositories/myth_repository.dart';

import 'features/auth/controllers/auth_controller.dart';
import 'features/campaigns/controllers/campaign_feed_controller.dart';
import 'features/campaigns/controllers/campaign_detail_controller.dart';
import 'features/campaigns/controllers/create_campaign_controller.dart';
import 'features/dashboard/controllers/organizer_dashboard_controller.dart';
import 'features/notifications/controllers/notification_controller.dart';
import 'features/pledges/controllers/pledge_controller.dart';
import 'features/profile/controllers/profile_controller.dart';

import 'routes/app_router.dart';
import 'core/constants/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await GetStorage.init();

  // Register services
  Get.put<AuthRepository>(FirebaseAuthService());
  Get.put<CampaignRepository>(CampaignService());
  Get.put<PledgeRepository>(PledgeService());
  Get.put<NotificationRepository>(NotificationService());
  Get.put<DonationRecordRepository>(DonationRecordService());
  Get.put<DonorCardRepository>(DonorCardService());
  Get.put<MythRepository>(MythService());

  // Register AuthController permanently
  final authController =
      Get.put(AuthController(Get.find<AuthRepository>()), permanent: true);

  // LazyPut other controllers
  Get.lazyPut(() => CampaignFeedController(Get.find<CampaignRepository>()));

  // Actually, those requiring currentUser IDs can be fetched safely dynamically.
  // Using fenix: true so they can be recreated if auth changes

  Get.lazyPut(
      () => CampaignDetailController(
            Get.find<CampaignRepository>(),
            Get.find<PledgeRepository>(),
            Get.find<NotificationRepository>(),
          ),
      fenix: true);

  Get.lazyPut(
      () => CreateCampaignController(
            Get.find<CampaignRepository>(),
            authController.currentUser.value!.uid,
            authController.currentUser.value!.displayName,
          ),
      fenix: true);

  Get.lazyPut(
      () => OrganizerDashboardController(
            Get.find<CampaignRepository>(),
            Get.find<PledgeRepository>(),
            Get.find<NotificationRepository>(),
            Get.find<DonationRecordRepository>(),
            Get.find<DonorCardRepository>(),
            authController.currentUser.value!.uid,
          ),
      fenix: true);

  Get.lazyPut(() => ProfileController(
        Get.find<AuthRepository>(),
        Get.find<PledgeRepository>(),
      ));

  Get.lazyPut(() => PledgeController(Get.find<PledgeRepository>()));

  Get.lazyPut(
      () => NotificationController(
            Get.find<NotificationRepository>(),
          ),
      fenix: true);

  // locked orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const BdenApp());
}

class BdenApp extends StatelessWidget {
  const BdenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BDEN',
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: GoogleFonts.plusJakartaSansTextTheme(),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          foregroundColor: AppColors.textPrimary,
          surfaceTintColor: Colors.transparent,
        ),
      ),
    );
  }
}

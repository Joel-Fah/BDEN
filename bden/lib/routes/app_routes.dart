class AppRoutes {
  AppRoutes._();
  static const splash            = '/';
  static const login             = '/login';
  static const organizerLogin    = '/login/organizer';
  static const roleSelect        = '/role-select';
  static const onboarding        = '/onboarding';
  static const donorSetup        = '/onboarding/setup';
  static const feed              = '/home/feed';
  static const campaignDetail    = '/home/feed/:id';
  static const pledges           = '/home/pledges';
  static const notifications     = '/home/notifications';
  static const profile           = '/home/profile';
  static const organizerDashboard = '/organizer/dashboard';
  static const organizerCampaigns = '/organizer/campaigns';
  static const createCampaign    = '/organizer/campaigns/create';
  static const organizerNotif    = '/organizer/notifications';
  static const organizerProfile  = '/organizer/profile';
  
  // NEW
  static const donorCards       = '/home/cards';
  static const donorCardDetail  = '/home/cards/:hospitalId';
  static const myths            = '/home/myths';
}

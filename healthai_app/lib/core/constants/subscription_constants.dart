/// Subscription Plans and Features - PRD v1.3 Section 4.4
class SubscriptionPlans {
  // Plan IDs (RevenueCat Entitlement IDs)
  static const String free = 'free';
  static const String basic = 'basic';
  static const String premium = 'premium';
  static const String family = 'family';

  // RevenueCat Product IDs (App Store Connect / Play Console)
  static const String basicMonthly = 'basic_monthly_3900';
  static const String premiumMonthly = 'premium_monthly_5900';
  static const String familyMonthly = 'family_monthly_9900';

  // Features by Plan
  static const Map<String, PlanFeatures> features = {
    free: PlanFeatures(
      familyProfiles: 2,
      aiConversations: 10,
      dataRetentionDays: 30,
      advancedAnalytics: false,
      prioritySupport: false,
    ),
    basic: PlanFeatures(
      familyProfiles: 5,
      aiConversations: 100,
      dataRetentionDays: 90,
      advancedAnalytics: false,
      prioritySupport: false,
    ),
    premium: PlanFeatures(
      familyProfiles: -1, // unlimited
      aiConversations: -1, // unlimited
      dataRetentionDays: 365,
      advancedAnalytics: true,
      prioritySupport: true,
    ),
    family: PlanFeatures(
      familyProfiles: -1, // unlimited
      aiConversations: -1, // unlimited
      dataRetentionDays: 365,
      advancedAnalytics: true,
      prioritySupport: true,
    ),
  };

  // Plan Names (Korean)
  static const Map<String, String> planNames = {
    free: '무료',
    basic: '베이직',
    premium: '프리미엄',
    family: '패밀리',
  };

  // Plan Prices (원/월)
  static const Map<String, int> prices = {
    basicMonthly: 3900,
    premiumMonthly: 5900,
    familyMonthly: 9900,
  };
}

class PlanFeatures {
  final int familyProfiles; // -1 = unlimited
  final int aiConversations; // -1 = unlimited
  final int dataRetentionDays;
  final bool advancedAnalytics;
  final bool prioritySupport;

  const PlanFeatures({
    required this.familyProfiles,
    required this.aiConversations,
    required this.dataRetentionDays,
    required this.advancedAnalytics,
    required this.prioritySupport,
  });

  bool get hasUnlimitedProfiles => familyProfiles == -1;
  bool get hasUnlimitedConversations => aiConversations == -1;

  String get profilesLimit =>
      hasUnlimitedProfiles ? '무제한' : '$familyProfiles개';
  String get conversationsLimit =>
      hasUnlimitedConversations ? '무제한' : '월 $aiConversations회';
}

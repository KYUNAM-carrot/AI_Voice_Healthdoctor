# Day 43-52: RevenueCat 구독 & Flutter UI 완전 가이드

## 📋 개요

이 섹션은 Claude Code 개발 프롬프트 v1.3의 **Day 43-52: RevenueCat 구독 시스템 & Flutter UI/UX 구현** 부분입니다.

**참조 문서:**
- 개발_체크리스트_v1.3.md: Day 43-52 (Lines 365-416)
- TRD v1.3: 섹션 4.6 (Subscriptions 테이블)
- PRD v1.3: 섹션 4.4 (구독 기능)
- UI_UX_가이드_v1.2.md: 전체 디자인 시스템

---

## Day 43-45: RevenueCat 구독 시스템

### 목표
Flutter 앱에서 RevenueCat을 통한 인앱 구매 및 구독 관리를 구현합니다.

### Claude Code 프롬프트

```markdown
# Day 43-45: RevenueCat 구독 시스템

## 목표
RevenueCat SDK를 통한 인앱 구매 및 구독 상태 관리를 구현합니다.

## 1. pubspec.yaml 의존성 추가

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.5
  
  # Navigation
  go_router: ^14.0.0
  
  # RevenueCat
  purchases_flutter: ^6.29.1
  
  # Network
  dio: ^5.4.0
  pretty_dio_logger: ^1.3.1
  
  # Storage
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  
  # UI
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  lottie: ^3.0.0
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  riverpod_generator: ^2.3.11
  build_runner: ^2.4.8
  flutter_lints: ^3.0.0
```

## 2. lib/core/constants/subscription_constants.dart 작성

PRD v1.3 섹션 4.4 참조:

```dart
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
}
```

## 3. lib/features/subscription/models/subscription_model.dart 작성

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required String userId,
    required String plan, // 'free', 'basic', 'premium', 'family'
    required String status, // 'active', 'cancelled', 'expired', 'trial'
    String? revenuecatCustomerId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    @Default(true) bool autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SubscriptionModel;
  
  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

@freezed
class PackageModel with _$PackageModel {
  const factory PackageModel({
    required String identifier,
    required String packageType,
    required ProductModel product,
    required String offeringIdentifier,
  }) = _PackageModel;
  
  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);
}

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String identifier,
    required String description,
    required String title,
    required double price,
    required String priceString,
    required String currencyCode,
  }) = _ProductModel;
  
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}
```

## 4. lib/features/subscription/services/revenuecat_service.dart 작성

```dart
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RevenueCatService {
  static const String _apiKeyApple = 'appl_YOUR_API_KEY';
  static const String _apiKeyGoogle = 'goog_YOUR_API_KEY';
  
  Future<void> initialize(String userId) async {
    // RevenueCat 설정
    PurchasesConfiguration configuration;
    
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      configuration = PurchasesConfiguration(_apiKeyApple);
    } else {
      configuration = PurchasesConfiguration(_apiKeyGoogle);
    }
    
    await Purchases.configure(configuration);
    
    // User ID 설정
    await Purchases.logIn(userId);
    
    // Debug 모드 활성화 (개발 중)
    await Purchases.setLogLevel(LogLevel.debug);
  }
  
  Future<Offerings> getOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      return offerings;
    } catch (e) {
      throw Exception('Failed to fetch offerings: $e');
    }
  }
  
  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      return purchaserInfo;
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        throw Exception('User cancelled purchase');
      } else if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
        throw Exception('Purchase not allowed');
      } else {
        throw Exception('Purchase failed: ${e.message}');
      }
    }
  }
  
  Future<CustomerInfo> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo;
    } catch (e) {
      throw Exception('Failed to restore purchases: $e');
    }
  }
  
  Future<CustomerInfo> getCustomerInfo() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo;
    } catch (e) {
      throw Exception('Failed to get customer info: $e');
    }
  }
  
  Future<void> logout() async {
    try {
      await Purchases.logOut();
    } catch (e) {
      throw Exception('Failed to logout: $e');
    }
  }
  
  String getCurrentPlan(CustomerInfo customerInfo) {
    // Entitlement 확인
    if (customerInfo.entitlements.all['family']?.isActive == true) {
      return 'family';
    } else if (customerInfo.entitlements.all['premium']?.isActive == true) {
      return 'premium';
    } else if (customerInfo.entitlements.all['basic']?.isActive == true) {
      return 'basic';
    } else {
      return 'free';
    }
  }
  
  bool isSubscriptionActive(CustomerInfo customerInfo) {
    return customerInfo.entitlements.active.isNotEmpty;
  }
}

// Provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});
```

## 5. lib/features/subscription/providers/subscription_provider.dart 작성

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../models/subscription_model.dart';

// Current Subscription State
final currentSubscriptionProvider = StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionModel>>((ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return SubscriptionNotifier(revenueCatService);
});

class SubscriptionNotifier extends StateNotifier<AsyncValue<SubscriptionModel>> {
  final RevenueCatService _revenueCatService;
  
  SubscriptionNotifier(this._revenueCatService) : super(const AsyncValue.loading()) {
    fetchCurrentSubscription();
  }
  
  Future<void> fetchCurrentSubscription() async {
    state = const AsyncValue.loading();
    
    try {
      final customerInfo = await _revenueCatService.getCustomerInfo();
      final currentPlan = _revenueCatService.getCurrentPlan(customerInfo);
      
      // Backend API에서 상세 정보 가져오기
      final subscription = await _fetchFromBackend();
      
      state = AsyncValue.data(subscription);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
  
  Future<void> purchasePackage(Package package) async {
    try {
      final customerInfo = await _revenueCatService.purchasePackage(package);
      
      // Backend에 구독 정보 동기화
      await _syncToBackend(customerInfo);
      
      // 상태 업데이트
      await fetchCurrentSubscription();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> restorePurchases() async {
    try {
      final customerInfo = await _revenueCatService.restorePurchases();
      
      // Backend에 동기화
      await _syncToBackend(customerInfo);
      
      // 상태 업데이트
      await fetchCurrentSubscription();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<SubscriptionModel> _fetchFromBackend() async {
    // TODO: Backend API 호출
    // GET /api/v1/subscriptions/me
    throw UnimplementedError();
  }
  
  Future<void> _syncToBackend(CustomerInfo customerInfo) async {
    // TODO: Backend API 호출
    // POST /api/v1/subscriptions/sync
    throw UnimplementedError();
  }
}

// Offerings Provider
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return await revenueCatService.getOfferings();
});
```

## 6. lib/features/subscription/screens/subscription_screen.dart 작성

UI/UX 가이드 v1.2 참조:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/subscription_provider.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final currentSubscription = ref.watch(currentSubscriptionProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        elevation: 0,
      ),
      body: offeringsAsync.when(
        data: (offerings) {
          if (offerings.current == null) {
            return const Center(child: Text('이용 가능한 구독 플랜이 없습니다'));
          }
          
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 현재 플랜
              currentSubscription.when(
                data: (subscription) => _buildCurrentPlanCard(subscription),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('오류: $e'),
              ),
              
              const SizedBox(height: 24),
              
              // 플랜 목록
              ...offerings.current!.availablePackages.map((package) {
                return _buildPlanCard(context, ref, package);
              }),
              
              const SizedBox(height: 24),
              
              // 구매 복원 버튼
              OutlinedButton(
                onPressed: () => _restorePurchases(ref),
                child: const Text('구매 복원'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('오류: $e')),
      ),
    );
  }
  
  Widget _buildCurrentPlanCard(SubscriptionModel subscription) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '현재 플랜',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getPlanName(subscription.plan),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subscription.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                '다음 결제일: ${_formatDate(subscription.endDate!)}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlanCard(BuildContext context, WidgetRef ref, Package package) {
    final product = package.storeProduct;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _purchasePackage(context, ref, package),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    product.priceString,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _purchasePackage(context, ref, package),
                child: const Text('구독하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _purchasePackage(BuildContext context, WidgetRef ref, Package package) async {
    try {
      await ref.read(currentSubscriptionProvider.notifier).purchasePackage(package);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('구독이 완료되었습니다')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('구독 실패: $e')),
        );
      }
    }
  }
  
  Future<void> _restorePurchases(WidgetRef ref) async {
    try {
      await ref.read(currentSubscriptionProvider.notifier).restorePurchases();
    } catch (e) {
      // Error handling
    }
  }
  
  String _getPlanName(String plan) {
    switch (plan) {
      case 'basic':
        return '베이직';
      case 'premium':
        return '프리미엄';
      case 'family':
        return '패밀리';
      default:
        return '무료';
    }
  }
  
  String _formatDate(DateTime date) {
    return '${date.year}.${date.month}.${date.day}';
  }
}
```

## 완료 기준
- [ ] pubspec.yaml 의존성 추가
- [ ] lib/core/constants/subscription_constants.dart 작성
- [ ] lib/features/subscription/models/subscription_model.dart 작성
- [ ] lib/features/subscription/services/revenuecat_service.dart 작성
- [ ] lib/features/subscription/providers/subscription_provider.dart 작성
- [ ] lib/features/subscription/screens/subscription_screen.dart 작성
- [ ] RevenueCat Dashboard 설정 (Product IDs, Entitlements)
- [ ] iOS/Android 테스트

## RevenueCat Dashboard 설정

### 1. Products 생성
App Store Connect / Play Console에서 먼저 생성:
- `basic_monthly_3900`: ₩3,900/월
- `premium_monthly_5900`: ₩5,900/월
- `family_monthly_9900`: ₩9,900/월

### 2. RevenueCat Entitlements 생성
- `basic`: Basic plan access
- `premium`: Premium plan access
- `family`: Family plan access

### 3. Offerings 생성
- Default Offering 생성
- 각 Product를 해당 Entitlement와 연결

## 테스트
```bash
# 패키지 다운로드
flutter pub get

# 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs

# iOS 실행 (Sandbox)
flutter run -d ios

# Android 실행
flutter run -d android

# 구독 테스트
1. 구독 화면 진입
2. 플랜 선택 및 구매
3. 결제 확인 (샌드박스)
4. 플랜 활성화 확인
5. 구매 복원 테스트
```

## 보고서 작성
Day 43-45 완료 후 다음을 보고해줘:
1. 작성된 파일 목록
2. RevenueCat 설정 완료 여부
3. 테스트 결과 (구매/복원)
4. 다음 단계 준비 상태

완료했으면 "Day 43-45 완료 보고서"를 작성해줘.
```

---

## Day 46-48: Flutter 기본 UI/UX

### 목표
앱의 테마, 공통 위젯, 디자인 시스템을 구현합니다.

### Claude Code 프롬프트

```markdown
# Day 46-48: Flutter 기본 UI/UX

## 목표
UI/UX 가이드 v1.2를 기반으로 테마, 공통 위젯, 디자인 시스템을 구현합니다.

## 1. lib/core/theme/app_theme.dart 작성

UI/UX 가이드 v1.2 섹션 1-2 참조:

```dart
import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFF6C5CE7);      // 보라색
  static const Color secondary = Color(0xFF00B894);    // 민트색
  static const Color accent = Color(0xFFFFB8B8);       // 핑크색
  
  static const Color textPrimary = Color(0xFF2D3436);  // 진한 회색
  static const Color textSecondary = Color(0xFF636E72); // 중간 회색
  static const Color textTertiary = Color(0xFFB2BEC3);  // 연한 회색
  
  static const Color background = Color(0xFFFDFCFF);   // 연보라 배경
  static const Color surface = Colors.white;
  static const Color error = Color(0xFFD63031);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  
  // Typography (20-50세 타겟, 정보 밀도 2배)
  static const TextStyle h1 = TextStyle(
    fontSize: 24,  // 큰 제목
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 20,  // 중간 제목
    fontWeight: FontWeight.bold,
    height: 1.3,
    letterSpacing: -0.3,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 16,  // 작은 제목
    fontWeight: FontWeight.w600,
    height: 1.4,
    letterSpacing: -0.2,
  );
  
  static const TextStyle body1 = TextStyle(
    fontSize: 14,  // 본문 (감소)
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static const TextStyle body2 = TextStyle(
    fontSize: 12,  // 작은 본문 (감소)
    fontWeight: FontWeight.normal,
    height: 1.5,
    letterSpacing: 0,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 11,  // 캡션 (감소)
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: textSecondary,
  );
  
  // Spacing (밀도 2배)
  static const double spaceXs = 4.0;   // 감소
  static const double spaceSm = 8.0;   // 감소
  static const double spaceMd = 12.0;  // 감소
  static const double spaceLg = 16.0;  // 감소
  static const double spaceXl = 20.0;  // 감소
  static const double space2xl = 24.0; // 감소
  
  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  
  // Shadows
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 16,
      offset: const Offset(0, 8),
    ),
  ];
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: secondary,
        error: error,
        surface: surface,
        background: background,
      ),
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: textPrimary,
        titleTextStyle: h2,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.symmetric(vertical: spaceSm),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceLg,
            vertical: spaceMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spaceMd,
            vertical: spaceSm,
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceMd,
          vertical: spaceMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error),
        ),
      ),
    );
  }
}
```

## 2. lib/core/widgets/common_widgets.dart 작성

```dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

// Loading Indicator
class LoadingIndicator extends StatelessWidget {
  final double size;
  const LoadingIndicator({super.key, this.size = 24});
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 2),
    );
  }
}

// Error Message
class ErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  
  const ErrorMessage({
    super.key,
    required this.message,
    this.onRetry,
  });
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: AppTheme.error,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            message,
            style: AppTheme.body1.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppTheme.spaceMd),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('다시 시도'),
            ),
          ],
        ],
      ),
    );
  }
}

// Profile Avatar
class ProfileAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;
  
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
  });
  
  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        imageBuilder: (context, imageProvider) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildInitial(),
      );
    }
    
    return _buildInitial();
  }
  
  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey,
      ),
      child: const Center(
        child: LoadingIndicator(size: 16),
      ),
    );
  }
  
  Widget _buildInitial() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withOpacity(0.1),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

// Custom Card
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  
  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(AppTheme.spaceMd),
          child: child,
        ),
      ),
    );
  }
}

// Bottom Sheet Header
class BottomSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onClose;
  
  const BottomSheetHeader({
    super.key,
    required this.title,
    this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceMd,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTheme.h3,
          ),
          if (onClose != null)
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
```

## 3. lib/main.dart 업데이트

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Voice AI Health Doctor',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## 완료 기준
- [ ] lib/core/theme/app_theme.dart 작성
  - [ ] 컬러 시스템
  - [ ] 타이포그래피 (정보 밀도 2배)
  - [ ] 스페이싱 (20-30% 감소)
  - [ ] Border Radius
  - [ ] Shadows
  - [ ] ThemeData
- [ ] lib/core/widgets/common_widgets.dart 작성
  - [ ] LoadingIndicator
  - [ ] ErrorMessage
  - [ ] ProfileAvatar
  - [ ] CustomCard
  - [ ] BottomSheetHeader
- [ ] lib/main.dart 테마 적용
- [ ] 테마 미리보기 화면 작성
- [ ] 디자인 시스템 확인

## 테스트
```bash
# 실행
flutter run

# 테마 확인
1. 앱 실행
2. 각 컴포넌트 확인
3. 색상, 폰트, 스페이싱 확인
4. Dark Mode 전환 확인 (선택)
```

## 보고서 작성
Day 46-48 완료 후 다음을 보고해줘:
1. 작성된 파일 목록
2. 테마 시스템 구조
3. 공통 위젯 목록
4. 스크린샷
5. 다음 단계 준비 상태

완료했으면 "Day 46-48 완료 보고서"를 작성해줘.
```

---

## Day 49-52: Flutter 화면 구현

### 목표
홈 화면, 가족 프로필, AI 대화 화면을 구현합니다.

### Claude Code 프롬프트

```markdown
# Day 49-52: Flutter 화면 구현

## 목표
주요 화면 3개를 구현합니다: 홈, 가족 프로필, AI 대화

## 1. lib/features/home/screens/home_screen.dart 작성

UI/UX 가이드 v1.2 섹션 4.1 참조:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../characters/providers/characters_provider.dart';
import '../../family/providers/family_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);
    final familyProfilesAsync = ref.watch(familyProfilesProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice AI 건강 주치의'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 알림 화면 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 설정 화면 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(charactersProvider);
          ref.invalidate(familyProfilesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            // 웰컴 메시지
            _buildWelcomeSection(context),
            const SizedBox(height: AppTheme.spaceLg),
            
            // 가족 프로필 섹션
            _buildFamilySection(context, familyProfilesAsync),
            const SizedBox(height: AppTheme.space2xl),
            
            // AI 캐릭터 섹션
            _buildCharactersSection(context, charactersAsync),
            const SizedBox(height: AppTheme.space2xl),
            
            // 최근 활동
            _buildRecentActivitySection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 빠른 상담 시작
        },
        icon: const Icon(Icons.mic),
        label: const Text('빠른 상담'),
      ),
    );
  }
  
  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    
    if (hour < 12) {
      greeting = '좋은 아침이에요 ☀️';
    } else if (hour < 18) {
      greeting = '좋은 오후에요 ☕';
    } else {
      greeting = '좋은 저녁이에요 🌙';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTheme.h1,
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          '오늘도 건강한 하루 보내세요',
          style: AppTheme.body1.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildFamilySection(
    BuildContext context,
    AsyncValue profilesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('가족 프로필', style: AppTheme.h2),
            TextButton(
              onPressed: () {
                // TODO: 가족 프로필 목록 화면
              },
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        profilesAsync.when(
          data: (profiles) {
            if (profiles.isEmpty) {
              return CustomCard(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      '가족 프로필을 추가해보세요',
                      style: AppTheme.body1.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 프로필 추가
                      },
                      child: const Text('프로필 추가'),
                    ),
                  ],
                ),
              );
            }
            
            return SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return _buildFamilyProfileCard(context, profile);
                },
              ),
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => ErrorMessage(message: '프로필을 불러올 수 없습니다'),
        ),
      ],
    );
  }
  
  Widget _buildFamilyProfileCard(BuildContext context, dynamic profile) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppTheme.spaceMd),
      child: Column(
        children: [
          ProfileAvatar(
            imageUrl: profile.profileImageUrl,
            name: profile.name,
            size: 60,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            profile.name,
            style: AppTheme.body2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCharactersSection(
    BuildContext context,
    AsyncValue charactersAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('AI 건강 주치의', style: AppTheme.h2),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          '전문 AI 주치의와 상담해보세요',
          style: AppTheme.body2.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        charactersAsync.when(
          data: (characters) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: AppTheme.spaceMd,
                mainAxisSpacing: AppTheme.spaceMd,
              ),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return _buildCharacterCard(context, character);
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => ErrorMessage(message: 'AI 주치의를 불러올 수 없습니다'),
        ),
      ],
    );
  }
  
  Widget _buildCharacterCard(BuildContext context, dynamic character) {
    return CustomCard(
      onTap: () {
        // TODO: AI 대화 화면 이동
      },
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            imageUrl: character.profileImageUrl,
            name: character.name,
            size: 48,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            character.name,
            style: AppTheme.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            character.specialty,
            style: AppTheme.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              Icon(
                Icons.star,
                size: 14,
                color: AppTheme.warning,
              ),
              const SizedBox(width: 2),
              Text(
                '${character.experienceYears}년 경력',
                style: AppTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('최근 활동', style: AppTheme.h2),
        const SizedBox(height: AppTheme.spaceMd),
        CustomCard(
          child: ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('박지훈 주치의와 상담'),
            subtitle: const Text('어제 오후 3:24'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 대화 내역 보기
            },
          ),
        ),
      ],
    );
  }
}
```

## 2. lib/core/router/app_router.dart 작성

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/family/screens/family_list_screen.dart';
import '../../features/conversation/screens/conversation_screen.dart';
import '../../features/subscription/screens/subscription_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/families',
        builder: (context, state) => const FamilyListScreen(),
      ),
      GoRoute(
        path: '/conversation/:characterId',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          return ConversationScreen(characterId: characterId);
        },
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
    ],
  );
});
```

## 완료 기준
- [ ] lib/features/home/screens/home_screen.dart 작성
  - [ ] 웰컴 섹션
  - [ ] 가족 프로필 섹션
  - [ ] AI 캐릭터 섹션
  - [ ] 최근 활동 섹션
- [ ] lib/core/router/app_router.dart 작성
- [ ] 화면 간 내비게이션 구현
- [ ] Pull-to-Refresh 동작 확인
- [ ] 반응형 레이아웃 확인

## 테스트
```bash
# 실행
flutter run

# 화면 확인
1. 홈 화면 렌더링
2. 가족 프로필 스크롤
3. AI 캐릭터 그리드
4. 화면 전환 애니메이션
5. Pull-to-Refresh
```

## 보고서 작성
Day 49-52 완료 후 다음을 보고해줘:
1. 작성된 파일 목록
2. 구현된 화면 목록
3. 스크린샷 (홈, 가족, 대화)
4. 내비게이션 플로우
5. 다음 단계 준비 상태

완료했으면 "Day 49-52 완료 보고서"를 작성해줘.
```

---

## 📝 Week 7-8 완료 체크리스트

Day 43-52를 모두 완료하면 다음을 확인하세요:

### Backend
- ✅ Subscriptions 테이블 생성
- ✅ 구독 동기화 API

### Flutter
- ✅ RevenueCat SDK 통합
- ✅ 구독 화면 구현
- ✅ 테마 시스템 (정보 밀도 2배)
- ✅ 공통 위젯
- ✅ 홈 화면
- ✅ 가족 프로필 화면
- ✅ AI 대화 화면 (기본)
- ✅ 라우터 설정

### 다음 단계
Day 53-56로 이동: Fly.io 배포 및 CI/CD

---

**이 문서는 Claude Code 개발 프롬프트 v1.3의 Day 43-52 부분입니다.**  
**전체 문서: Claude_Code_개발_프롬프트_완전판_v1_3.md**

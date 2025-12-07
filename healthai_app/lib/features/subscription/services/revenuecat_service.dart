import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'dart:io' show Platform;

class RevenueCatService {
  // TODO: Replace with your actual API keys from RevenueCat dashboard
  static const String _apiKeyApple = 'appl_YOUR_API_KEY_HERE';
  static const String _apiKeyGoogle = 'goog_YOUR_API_KEY_HERE';

  Future<void> initialize(String userId) async {
    // RevenueCat 설정
    PurchasesConfiguration configuration;

    if (Platform.isIOS) {
      configuration = PurchasesConfiguration(_apiKeyApple);
    } else if (Platform.isAndroid) {
      configuration = PurchasesConfiguration(_apiKeyGoogle);
    } else {
      throw UnsupportedError('Unsupported platform for RevenueCat');
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
      final purchaseResult = await Purchases.purchasePackage(package);
      return purchaseResult.customerInfo;
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
    // Entitlement 확인 (우선순위 순서대로)
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

  DateTime? getExpirationDate(CustomerInfo customerInfo) {
    // 활성 구독의 만료일 반환
    for (final entitlement in customerInfo.entitlements.active.values) {
      if (entitlement.expirationDate != null) {
        return DateTime.parse(entitlement.expirationDate!);
      }
    }
    return null;
  }

  bool isInTrialPeriod(CustomerInfo customerInfo) {
    // 현재 체험판 기간 중인지 확인
    for (final entitlement in customerInfo.entitlements.active.values) {
      if (entitlement.periodType == PeriodType.trial) {
        return true;
      }
    }
    return false;
  }
}

// Provider
final revenueCatServiceProvider = Provider<RevenueCatService>((ref) {
  return RevenueCatService();
});

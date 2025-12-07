import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../models/subscription_model.dart';
import '../../../core/api/api_client.dart';

// Current Subscription State
final currentSubscriptionProvider =
    StateNotifierProvider<SubscriptionNotifier, AsyncValue<SubscriptionModel>>(
        (ref) {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  return SubscriptionNotifier(revenueCatService, apiClient);
});

class SubscriptionNotifier
    extends StateNotifier<AsyncValue<SubscriptionModel>> {
  final RevenueCatService _revenueCatService;
  final ApiClient _apiClient;

  SubscriptionNotifier(this._revenueCatService, this._apiClient)
      : super(const AsyncValue.loading()) {
    fetchCurrentSubscription();
  }

  Future<void> fetchCurrentSubscription() async {
    state = const AsyncValue.loading();

    try {
      final customerInfo = await _revenueCatService.getCustomerInfo();
      final currentPlan = _revenueCatService.getCurrentPlan(customerInfo);

      // Backend API에서 상세 정보 가져오기
      final subscription = await _fetchFromBackend(currentPlan, customerInfo);

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

  Future<SubscriptionModel> _fetchFromBackend(
      String plan, CustomerInfo customerInfo) async {
    try {
      // TODO: Backend API 호출 구현
      // GET /api/v1/subscriptions/me
      final response = await _apiClient.get('/api/v1/subscriptions/me');
      return SubscriptionModel.fromJson(response.data);
    } catch (e) {
      // Backend API 실패 시 RevenueCat 정보로 임시 모델 생성
      return SubscriptionModel(
        id: customerInfo.originalAppUserId,
        userId: customerInfo.originalAppUserId,
        plan: plan,
        status: _revenueCatService.isSubscriptionActive(customerInfo)
            ? 'active'
            : 'free',
        revenuecatCustomerId: customerInfo.originalAppUserId,
        startDate: DateTime.now(),
        endDate: _revenueCatService.getExpirationDate(customerInfo),
        trialEndDate: null,
        autoRenew: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> _syncToBackend(CustomerInfo customerInfo) async {
    try {
      // TODO: Backend API 호출 구현
      // POST /api/v1/subscriptions/sync
      final plan = _revenueCatService.getCurrentPlan(customerInfo);
      final isActive = _revenueCatService.isSubscriptionActive(customerInfo);

      await _apiClient.post('/api/v1/subscriptions/sync', data: {
        'revenuecat_customer_id': customerInfo.originalAppUserId,
        'plan': plan,
        'status': isActive ? 'active' : 'expired',
        'end_date': _revenueCatService
            .getExpirationDate(customerInfo)
            ?.toIso8601String(),
      });
    } catch (e) {
      print('Failed to sync subscription to backend: $e');
      // Backend 동기화 실패해도 RevenueCat 구매는 완료된 상태이므로 에러를 던지지 않음
    }
  }
}

// Offerings Provider
final offeringsProvider = FutureProvider<Offerings>((ref) async {
  final revenueCatService = ref.watch(revenueCatServiceProvider);
  return await revenueCatService.getOfferings();
});

// Current Plan Provider (string only)
final currentPlanProvider = Provider<String>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.plan,
    loading: () => 'free',
    error: (_, __) => 'free',
  );
});

// Is Subscription Active Provider
final isSubscriptionActiveProvider = Provider<bool>((ref) {
  final subscription = ref.watch(currentSubscriptionProvider);
  return subscription.when(
    data: (sub) => sub.status == 'active' || sub.status == 'trial',
    loading: () => false,
    error: (_, __) => false,
  );
});

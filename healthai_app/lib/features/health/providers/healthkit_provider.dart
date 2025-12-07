import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/healthkit_service.dart';
import '../../../core/api/api_client.dart';

// HealthKit Service Provider
final healthKitServiceProvider = Provider<HealthKitService>((ref) {
  return HealthKitService();
});

// HealthKit Authorization State
final healthKitAuthorizationProvider = FutureProvider<bool>((ref) async {
  final healthKitService = ref.watch(healthKitServiceProvider);
  return await healthKitService.requestAuthorization();
});

// HealthKit Data Sync Provider
final healthKitSyncProvider =
    FutureProvider.family<Map<String, dynamic>, String>(
  (ref, familyProfileId) async {
    final healthKitService = ref.watch(healthKitServiceProvider);
    final apiClient = ref.watch(apiClientProvider);

    // 1. HealthKit 데이터 읽기 (최근 7일)
    final healthData = await healthKitService.fetchHealthData(days: 7);

    if (healthData.isEmpty) {
      return {'inserted_count': 0, 'duplicate_count': 0, 'total_count': 0};
    }

    // 2. API 형식으로 변환
    final dataPoints = healthData.map((point) {
      return healthKitService.convertToApiFormat(point);
    }).toList();

    // 3. Backend로 전송 (배치 동기화)
    final response = await apiClient.post(
      '/api/v1/wearables/sync',
      data: {
        'family_profile_id': familyProfileId,
        'source': 'apple_health',
        'data_points': dataPoints.take(100).toList(), // 최대 100개
      },
    );

    return response.data as Map<String, dynamic>;
  },
);

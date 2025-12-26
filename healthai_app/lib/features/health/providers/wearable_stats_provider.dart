import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../../family/providers/family_provider.dart';

/// 오늘의 건강 데이터 모델
class TodayHealthData {
  final int steps;
  final int stepsGoal;
  final double sleepHours;
  final int heartRate;
  final String heartRateStatus;
  final bool hasData;

  TodayHealthData({
    this.steps = 0,
    this.stepsGoal = 10000,
    this.sleepHours = 0,
    this.heartRate = 0,
    this.heartRateStatus = '데이터 없음',
    this.hasData = false,
  });

  double get stepsProgress => stepsGoal > 0 ? (steps / stepsGoal).clamp(0.0, 1.0) : 0;

  double get sleepProgress {
    const targetSleep = 8.0; // 목표 수면 시간
    return (sleepHours / targetSleep).clamp(0.0, 1.0);
  }

  double get heartRateProgress {
    // 심박수 정상 범위: 60-100 BPM
    if (heartRate == 0) return 0;
    if (heartRate >= 60 && heartRate <= 100) return 0.7; // 정상
    if (heartRate < 60) return 0.5; // 서맥
    return 0.9; // 빈맥
  }

  String get sleepStatus {
    if (sleepHours == 0) return '데이터 없음';
    if (sleepHours >= 7) return '양호';
    if (sleepHours >= 5) return '부족';
    return '심각하게 부족';
  }

  String get stepsFormatted {
    if (steps >= 1000) {
      return '${(steps / 1000).toStringAsFixed(1)}k';
    }
    return steps.toString();
  }

  String get sleepFormatted {
    if (sleepHours == 0) return '-';
    final hours = sleepHours.floor();
    final minutes = ((sleepHours - hours) * 60).round();
    if (minutes > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${hours}h';
  }
}

/// 오늘의 건강 데이터 Provider
final todayHealthDataProvider = FutureProvider<TodayHealthData>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final familyProfilesAsync = ref.watch(familyProfilesProvider);

  // 가족 프로필 목록 가져오기
  final profiles = familyProfilesAsync.valueOrNull ?? [];
  debugPrint('TodayHealthData - Profiles count: ${profiles.length}');

  // self 프로필 찾기
  final selfProfile = profiles.where(
    (p) => p.relationship == 'self' || p.relationship == '본인',
  ).firstOrNull;

  if (selfProfile == null) {
    debugPrint('TodayHealthData - No self profile found');
    return TodayHealthData();
  }
  debugPrint('TodayHealthData - Self profile ID: ${selfProfile.id}');

  try {
    // 오늘 날짜
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    debugPrint('TodayHealthData - Today: $todayStr');

    // 일별 통계 조회 (최근 7일로 확장하여 데이터가 있는지 확인)
    final response = await apiClient.get(
      '/api/v1/wearables/profiles/${selfProfile.id}/stats/daily',
      queryParameters: {'days': 7},
    );

    final statsList = response.data as List<dynamic>;
    debugPrint('TodayHealthData - Stats count: ${statsList.length}');

    if (statsList.isEmpty) {
      debugPrint('TodayHealthData - No stats data returned');
      return TodayHealthData();
    }

    // 모든 데이터 로깅
    for (final stat in statsList) {
      debugPrint('TodayHealthData - Stat: ${stat['date']} - ${stat['data_type']} - total: ${stat['total_value']} - avg: ${stat['avg_value']}');
    }

    // 데이터 추출 - 각 타입별로 최신 데이터 찾기
    int steps = 0;
    double sleepHours = 0;
    int heartRate = 0;
    String heartRateStatus = '데이터 없음';

    // 타입별로 데이터 그룹화 (날짜 내림차순 정렬)
    final typeDataMap = <String, List<Map<String, dynamic>>>{};
    for (final stat in statsList) {
      final dataType = (stat['data_type'] as String).toLowerCase();
      typeDataMap.putIfAbsent(dataType, () => []).add(stat as Map<String, dynamic>);
    }

    // 각 타입별로 날짜순 정렬 (최신 먼저)
    for (final entry in typeDataMap.entries) {
      entry.value.sort((a, b) =>
        (b['date'] as String).compareTo(a['date'] as String));
    }

    debugPrint('TodayHealthData - Available types: ${typeDataMap.keys.toList()}');

    // 각 타입별 최신 데이터 추출
    // Steps - 최신 데이터 사용
    if (typeDataMap.containsKey('steps') && typeDataMap['steps']!.isNotEmpty) {
      final latestSteps = typeDataMap['steps']!.first;
      steps = (latestSteps['total_value'] as num?)?.toInt() ?? 0;
      debugPrint('TodayHealthData - Steps: $steps (from ${latestSteps['date']})');
    }

    // Sleep - 최신 데이터 사용 (수면은 전날 밤에 기록되므로 별도 처리)
    if (typeDataMap.containsKey('sleep') && typeDataMap['sleep']!.isNotEmpty) {
      final latestSleep = typeDataMap['sleep']!.first;
      final totalValue = (latestSleep['total_value'] as num?)?.toDouble() ?? 0;
      sleepHours = totalValue > 100 ? totalValue / 60 : totalValue; // 분→시간 변환
      debugPrint('TodayHealthData - Sleep: $sleepHours hours (from ${latestSleep['date']})');
    }

    // Heart Rate - 최신 데이터 사용
    if (typeDataMap.containsKey('heart_rate') && typeDataMap['heart_rate']!.isNotEmpty) {
      final latestHr = typeDataMap['heart_rate']!.first;
      heartRate = (latestHr['avg_value'] as num?)?.toInt() ?? 0;
      if (heartRate > 0) {
        if (heartRate >= 60 && heartRate <= 100) {
          heartRateStatus = '정상';
        } else if (heartRate < 60) {
          heartRateStatus = '서맥';
        } else {
          heartRateStatus = '빈맥';
        }
      }
      debugPrint('TodayHealthData - HeartRate: $heartRate ($heartRateStatus) (from ${latestHr['date']})');
    }

    debugPrint('TodayHealthData - Final: steps=$steps, sleep=$sleepHours, hr=$heartRate');
    return TodayHealthData(
      steps: steps,
      sleepHours: sleepHours,
      heartRate: heartRate,
      heartRateStatus: heartRateStatus,
      hasData: steps > 0 || sleepHours > 0 || heartRate > 0,
    );
  } catch (e, st) {
    // 에러 발생 시 로깅 후 빈 데이터 반환
    debugPrint('TodayHealthData - Error: $e');
    debugPrint('TodayHealthData - StackTrace: $st');
    return TodayHealthData();
  }
});

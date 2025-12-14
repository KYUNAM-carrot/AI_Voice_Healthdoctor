import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

/// 웨어러블 건강 데이터 수집 서비스
///
/// Health Connect (Android) 및 HealthKit (iOS)에서
/// 건강 데이터를 수집하여 AI 상담에 활용
class WearableHealthService {
  static final WearableHealthService _instance = WearableHealthService._internal();
  factory WearableHealthService() => _instance;
  WearableHealthService._internal();

  final Health _health = Health();
  bool _isAuthorized = false;
  bool _isInitialized = false;

  /// 수집할 건강 데이터 타입 목록
  static final List<HealthDataType> _dataTypes = [
    // 활동 데이터
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_DELTA,

    // 심박수 데이터
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,

    // 혈압 데이터
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,

    // 혈당 데이터
    HealthDataType.BLOOD_GLUCOSE,

    // 산소포화도
    HealthDataType.BLOOD_OXYGEN,

    // 수면 데이터
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_IN_BED,

    // 체중/체성분
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
    HealthDataType.BODY_FAT_PERCENTAGE,

    // 호흡/체온
    HealthDataType.RESPIRATORY_RATE,
    HealthDataType.BODY_TEMPERATURE,
  ];

  /// 읽기 권한만 필요
  static final List<HealthDataAccess> _permissions =
      _dataTypes.map((_) => HealthDataAccess.READ).toList();

  /// Health Connect/HealthKit 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return _isAuthorized;

    try {
      // Health Connect 설치 확인 (Android)
      if (Platform.isAndroid) {
        final status = await _health.getHealthConnectSdkStatus();
        if (status != HealthConnectSdkStatus.sdkAvailable) {
          debugPrint('Health Connect SDK not available: $status');
          _isInitialized = true;
          return false;
        }
      }

      // 권한 요청
      _isAuthorized = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );

      debugPrint('Health authorization: $_isAuthorized');
      _isInitialized = true;
      return _isAuthorized;
    } catch (e) {
      debugPrint('Health initialization error: $e');
      _isInitialized = true;
      return false;
    }
  }

  /// 권한 상태 확인
  Future<bool> hasPermissions() async {
    try {
      return await _health.hasPermissions(_dataTypes, permissions: _permissions) ?? false;
    } catch (e) {
      debugPrint('Error checking health permissions: $e');
      return false;
    }
  }

  /// 최근 7일간 건강 데이터 수집
  ///
  /// AI 상담에 활용할 수 있도록 구조화된 형태로 반환
  Future<Map<String, dynamic>> fetchRecentHealthData({int days = 7}) async {
    if (!_isAuthorized) {
      final authorized = await initialize();
      if (!authorized) {
        debugPrint('Health authorization failed');
        return {};
      }
    }

    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));
    final healthData = <String, dynamic>{};

    try {
      // 걸음 수
      healthData['steps'] = await _fetchSteps(startTime, now);

      // 심박수
      healthData['heart_rate'] = await _fetchHeartRate(startTime, now);

      // 혈압
      healthData['blood_pressure'] = await _fetchBloodPressure(startTime, now);

      // 혈당
      healthData['blood_sugar'] = await _fetchBloodGlucose(startTime, now);

      // 수면
      healthData['sleep'] = await _fetchSleep(startTime, now);

      // 산소포화도
      healthData['spo2'] = await _fetchBloodOxygen(startTime, now);

      // 활동 칼로리
      healthData['active_energy'] = await _fetchActiveEnergy(startTime, now);

      // 체중 기록
      healthData['weight_history'] = await _fetchWeightHistory(startTime, now);

      // 데이터 수집 시간 기록
      healthData['collected_at'] = now.toIso8601String();
      healthData['period_days'] = days;

      debugPrint('Health data collected: ${healthData.keys}');
      return healthData;
    } catch (e) {
      debugPrint('Error fetching health data: $e');
      return {};
    }
  }

  /// 걸음 수 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchSteps(DateTime start, DateTime end) async {
    final steps = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      // 날짜별로 집계
      final dailySteps = <String, int>{};
      for (final point in data) {
        final date = _formatDate(point.dateFrom);
        final value = (point.value as NumericHealthValue).numericValue.toInt();
        dailySteps[date] = (dailySteps[date] ?? 0) + value;
      }

      for (final entry in dailySteps.entries) {
        steps.add({
          'date': entry.key,
          'count': entry.value,
        });
      }
    } catch (e) {
      debugPrint('Error fetching steps: $e');
    }
    return steps;
  }

  /// 심박수 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchHeartRate(DateTime start, DateTime end) async {
    final heartRates = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.HEART_RATE],
        startTime: start,
        endTime: end,
      );

      for (final point in data) {
        heartRates.add({
          'time': point.dateFrom.toIso8601String(),
          'date': _formatDate(point.dateFrom),
          'bpm': (point.value as NumericHealthValue).numericValue.toInt(),
        });
      }
    } catch (e) {
      debugPrint('Error fetching heart rate: $e');
    }
    return heartRates;
  }

  /// 혈압 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchBloodPressure(DateTime start, DateTime end) async {
    final bloodPressure = <Map<String, dynamic>>[];
    try {
      final systolicData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_SYSTOLIC],
        startTime: start,
        endTime: end,
      );

      final diastolicData = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_PRESSURE_DIASTOLIC],
        startTime: start,
        endTime: end,
      );

      // 같은 시간대의 수축기/이완기 혈압 매칭
      for (var i = 0; i < systolicData.length && i < diastolicData.length; i++) {
        bloodPressure.add({
          'measured_at': systolicData[i].dateFrom.toIso8601String(),
          'date': _formatDate(systolicData[i].dateFrom),
          'systolic': (systolicData[i].value as NumericHealthValue).numericValue.toInt(),
          'diastolic': (diastolicData[i].value as NumericHealthValue).numericValue.toInt(),
        });
      }
    } catch (e) {
      debugPrint('Error fetching blood pressure: $e');
    }
    return bloodPressure;
  }

  /// 혈당 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchBloodGlucose(DateTime start, DateTime end) async {
    final bloodGlucose = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_GLUCOSE],
        startTime: start,
        endTime: end,
      );

      for (final point in data) {
        // 시간대에 따라 공복/식후 분류 (간단한 휴리스틱)
        final hour = point.dateFrom.hour;
        String type = 'random';
        if (hour >= 5 && hour <= 8) {
          type = 'fasting';
        } else if ((hour >= 9 && hour <= 11) || (hour >= 13 && hour <= 15) || (hour >= 19 && hour <= 21)) {
          type = 'post_meal';
        }

        bloodGlucose.add({
          'measured_at': point.dateFrom.toIso8601String(),
          'date': _formatDate(point.dateFrom),
          'value': (point.value as NumericHealthValue).numericValue.toDouble(),
          'type': type,
        });
      }
    } catch (e) {
      debugPrint('Error fetching blood glucose: $e');
    }
    return bloodGlucose;
  }

  /// 수면 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchSleep(DateTime start, DateTime end) async {
    final sleepData = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.SLEEP_ASLEEP, HealthDataType.SLEEP_IN_BED],
        startTime: start,
        endTime: end,
      );

      // 날짜별로 수면 시간 집계
      final dailySleep = <String, double>{};
      final dailyInBed = <String, double>{};

      for (final point in data) {
        final date = _formatDate(point.dateTo.subtract(const Duration(hours: 12))); // 전날 밤 수면으로 기록
        final durationMinutes = point.dateTo.difference(point.dateFrom).inMinutes;

        if (point.type == HealthDataType.SLEEP_ASLEEP) {
          dailySleep[date] = (dailySleep[date] ?? 0) + durationMinutes / 60;
        } else {
          dailyInBed[date] = (dailyInBed[date] ?? 0) + durationMinutes / 60;
        }
      }

      for (final entry in dailySleep.entries) {
        final inBed = dailyInBed[entry.key] ?? entry.value;
        final efficiency = inBed > 0 ? (entry.value / inBed * 100) : null;

        sleepData.add({
          'date': entry.key,
          'duration_hours': double.parse(entry.value.toStringAsFixed(1)),
          'in_bed_hours': double.parse(inBed.toStringAsFixed(1)),
          'efficiency': efficiency != null ? double.parse(efficiency.toStringAsFixed(1)) : null,
        });
      }
    } catch (e) {
      debugPrint('Error fetching sleep: $e');
    }
    return sleepData;
  }

  /// 산소포화도 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchBloodOxygen(DateTime start, DateTime end) async {
    final spo2Data = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.BLOOD_OXYGEN],
        startTime: start,
        endTime: end,
      );

      for (final point in data) {
        spo2Data.add({
          'measured_at': point.dateFrom.toIso8601String(),
          'date': _formatDate(point.dateFrom),
          'value': (point.value as NumericHealthValue).numericValue.toDouble(),
        });
      }
    } catch (e) {
      debugPrint('Error fetching blood oxygen: $e');
    }
    return spo2Data;
  }

  /// 활동 칼로리 데이터 수집
  Future<List<Map<String, dynamic>>> _fetchActiveEnergy(DateTime start, DateTime end) async {
    final energyData = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: end,
      );

      // 날짜별로 집계
      final dailyEnergy = <String, double>{};
      for (final point in data) {
        final date = _formatDate(point.dateFrom);
        final value = (point.value as NumericHealthValue).numericValue.toDouble();
        dailyEnergy[date] = (dailyEnergy[date] ?? 0) + value;
      }

      for (final entry in dailyEnergy.entries) {
        energyData.add({
          'date': entry.key,
          'kcal': double.parse(entry.value.toStringAsFixed(0)),
        });
      }
    } catch (e) {
      debugPrint('Error fetching active energy: $e');
    }
    return energyData;
  }

  /// 체중 기록 수집
  Future<List<Map<String, dynamic>>> _fetchWeightHistory(DateTime start, DateTime end) async {
    final weightData = <Map<String, dynamic>>[];
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WEIGHT],
        startTime: start,
        endTime: end,
      );

      for (final point in data) {
        weightData.add({
          'date': _formatDate(point.dateFrom),
          'kg': (point.value as NumericHealthValue).numericValue.toDouble(),
        });
      }
    } catch (e) {
      debugPrint('Error fetching weight history: $e');
    }
    return weightData;
  }

  /// 날짜 포맷팅 (yyyy-MM-dd)
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// 권한 해제 상태 초기화 (테스트용)
  void reset() {
    _isAuthorized = false;
    _isInitialized = false;
  }
}

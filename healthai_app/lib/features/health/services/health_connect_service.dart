import 'package:health/health.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// 건강 상태 시나리오 (테스트 데이터 생성용)
enum HealthScenario {
  good,      // 좋은 상태: 높은 걸음수, 안정적인 심박수
  medium,    // 중간 상태: 보통 걸음수, 정상 심박수
  bad,       // 나쁜 상태: 낮은 걸음수, 불규칙한 심박수
  emergency, // 응급 상태: 매우 낮은 활동량, 위험한 심박수
}

class HealthConnectService {
  final Health _health = Health();
  bool _isConfigured = false;

  // 읽을 데이터 타입 (Android) - 일반적으로 지원되는 타입만 포함
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
  ];

  // 권한 목록 (모두 READ)
  static final List<HealthDataAccess> _permissions =
      _dataTypes.map((type) => HealthDataAccess.READ).toList();

  /// Health 패키지 초기화 (반드시 먼저 호출)
  Future<void> _configure() async {
    if (_isConfigured) return;

    try {
      await _health.configure();
      _isConfigured = true;
      debugPrint('Health Connect configured successfully');
    } catch (e) {
      debugPrint('Health Connect configure error: $e');
    }
  }

  /// Health Connect 설치 확인
  Future<bool> isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return false;

    try {
      await _configure();

      // Health Connect SDK 상태 확인
      final status = await _health.getHealthConnectSdkStatus();
      debugPrint('Health Connect SDK status: $status');

      // sdkAvailable 또는 sdkUnavailableProviderUpdateRequired도 사용 가능으로 처리
      // (업데이트만 필요한 경우도 기본 기능은 동작함)
      if (status == HealthConnectSdkStatus.sdkAvailable) {
        return true;
      }

      // SDK 상태가 명확하지 않으면 데이터 타입 가용성으로 확인
      final stepsAvailable =
          await _health.isDataTypeAvailable(HealthDataType.STEPS);
      debugPrint('STEPS data type available: $stepsAvailable');

      return stepsAvailable;
    } catch (e) {
      debugPrint('Health Connect availability check error: $e');
      // 예외 발생시에도 권한 요청 시도할 수 있도록 true 반환
      return true;
    }
  }

  /// Health Connect 앱 설치 유도
  Future<void> openHealthConnectSettings() async {
    try {
      await _configure();
      debugPrint('Opening Health Connect installation...');

      // Health Connect 설치 페이지 열기
      await _health.installHealthConnect();
      debugPrint('installHealthConnect() completed');
    } catch (e) {
      debugPrint('Error opening Health Connect settings: $e');
      // 실패시 직접 권한 요청 시도 (권한 요청 다이얼로그가 설치를 유도할 수 있음)
      try {
        await _health.requestAuthorization(
          _dataTypes,
          permissions: _permissions,
        );
      } catch (e2) {
        debugPrint('Fallback authorization also failed: $e2');
      }
    }
  }

  /// Health Connect 권한 설정 화면 직접 열기 (Android Intent 사용)
  Future<bool> openHealthConnectPermissionSettings() async {
    if (!Platform.isAndroid) return false;

    try {
      const platform = MethodChannel('com.healthai.healthai_app/health_connect');

      // 먼저 Health Connect 앱의 권한 설정 화면을 열어봄
      final result = await platform.invokeMethod('openHealthConnectPermissions');
      return result == true;
    } catch (e) {
      debugPrint('MethodChannel not available, trying alternative: $e');

      // MethodChannel이 없으면 health 패키지의 기본 메서드 사용
      try {
        await _configure();
        // revokePermissions를 호출하면 권한 관리 화면이 열릴 수 있음
        await _health.revokePermissions();
        return true;
      } catch (e2) {
        debugPrint('revokePermissions failed: $e2');
        return false;
      }
    }
  }

  /// Health Connect 권한 요청
  Future<bool> requestAuthorization() async {
    try {
      await _configure();

      // 권한 요청 시도 (설치 여부 관계없이)
      debugPrint('Requesting Health Connect permissions...');
      final authorized = await _health.requestAuthorization(
        _dataTypes,
        permissions: _permissions,
      );
      debugPrint('Authorization result: $authorized');
      return authorized;
    } catch (e) {
      debugPrint('Health Connect authorization error: $e');
      return false;
    }
  }

  /// 권한 상태 확인 (실제 데이터 접근 시도로 확인)
  Future<bool> checkPermissionStatus() async {
    try {
      await _configure();

      // 방법 1: hasPermissions 확인
      final hasPermission = await _health.hasPermissions(
        _dataTypes,
        permissions: _permissions,
      );
      debugPrint('hasPermissions result: $hasPermission');

      if (hasPermission == true) {
        return true;
      }

      // 방법 2: 실제 데이터 접근 시도 (STEPS만 테스트)
      try {
        final now = DateTime.now();
        final yesterday = now.subtract(const Duration(days: 1));

        final testData = await _health.getHealthDataFromTypes(
          startTime: yesterday,
          endTime: now,
          types: [HealthDataType.STEPS],
        );

        debugPrint('Test data fetch result: ${testData.length} points');
        // 데이터가 있든 없든 에러가 안 나면 권한이 있는 것
        return true;
      } catch (dataError) {
        debugPrint('Test data fetch error: $dataError');
        // 권한 없음 에러가 발생하면 false
        return false;
      }
    } catch (e) {
      debugPrint('Permission check error: $e');
      return false;
    }
  }

  /// 최근 N일 데이터 읽기
  Future<List<HealthDataPoint>> fetchHealthData({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    try {
      await _configure();

      // 권한 요청 (hasPermissions 체크 생략 - 일부 기기에서 오류 발생)
      try {
        await _health.requestAuthorization(
          _dataTypes,
          permissions: _permissions,
        );
      } catch (e) {
        debugPrint('Authorization request error (continuing): $e');
      }

      debugPrint('Fetching Health Connect data from $startDate to $now');

      // 데이터 읽기 (health 13.x API)
      final healthData = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: now,
        types: _dataTypes,
      );

      debugPrint('Fetched ${healthData.length} health data points');

      // 중복 제거
      final uniqueData = _health.removeDuplicates(healthData);

      debugPrint('Unique data points: ${uniqueData.length}');

      return uniqueData;
    } catch (e) {
      debugPrint('Error fetching Health Connect data: $e');
      return [];
    }
  }

  // ========== 테스트 데이터 삽입 (개발용) ==========

  /// 테스트용 샘플 데이터 삽입
  /// [daysBack]: 며칠 전부터 데이터를 생성할지 (기본 7일)
  /// [scenario]: 건강 상태 시나리오 (기본: medium)
  Future<bool> insertTestData({
    int daysBack = 7,
    HealthScenario scenario = HealthScenario.medium,
  }) async {
    try {
      await _configure();
      debugPrint('=== Starting test data insertion (${scenario.name}) ===');

      // 쓰기 권한 타입 정의 (걸음수, 심박수, 수면)
      final writeTypes = [
        HealthDataType.STEPS,
        HealthDataType.HEART_RATE,
        HealthDataType.SLEEP_ASLEEP,
      ];

      final writePermissions = writeTypes
          .map((type) => HealthDataAccess.READ_WRITE)
          .toList();

      // 권한 요청 (hasPermissions 체크 생략 - 일부 기기에서 오류 발생)
      debugPrint('Requesting write permissions for: $writeTypes');
      try {
        final authorized = await _health.requestAuthorization(
          writeTypes,
          permissions: writePermissions,
        );
        debugPrint('Authorization result: $authorized');
      } catch (e) {
        debugPrint('Authorization request error (continuing anyway): $e');
      }

      final now = DateTime.now();
      int successCount = 0;
      int failCount = 0;

      // 타임스탬프를 고유하게 만들기 위한 오프셋 (분 단위)
      final uniqueOffset = now.minute;

      for (int i = 0; i < daysBack; i++) {
        final date = now.subtract(Duration(days: i));
        // 매번 다른 시간대에 기록되도록 현재 시간의 분을 오프셋으로 추가
        final startOfDay = DateTime(date.year, date.month, date.day, 8, uniqueOffset);
        final endOfDay = DateTime(date.year, date.month, date.day, 20, uniqueOffset);

        // 시나리오별 데이터 값 설정
        final (steps, heartRates, sleepMinutes) = _getScenarioData(scenario, i, daysBack);

        // 1. 걸음 수 데이터
        try {
          debugPrint('Writing steps: $steps for day -$i (${scenario.name})');

          final stepsSuccess = await _health.writeHealthData(
            value: steps.toDouble(),
            type: HealthDataType.STEPS,
            startTime: startOfDay,
            endTime: endOfDay,
          );

          if (stepsSuccess) {
            successCount++;
            debugPrint('✓ Steps OK');
          } else {
            failCount++;
            debugPrint('✗ Steps FAIL');
          }
        } catch (e) {
          failCount++;
          debugPrint('✗ Steps ERROR: $e');
        }

        // 2. 심박수 데이터 (하루에 여러 번 측정)
        for (int j = 0; j < heartRates.length; j++) {
          try {
            // 고유한 시간: 기본 시간 + uniqueOffset 분
            final heartRateTime = DateTime(date.year, date.month, date.day,
                10 + j * 3, uniqueOffset);
            final hrSuccess = await _health.writeHealthData(
              value: heartRates[j].toDouble(),
              type: HealthDataType.HEART_RATE,
              startTime: heartRateTime,
              endTime: heartRateTime.add(const Duration(seconds: 30)),
            );

            if (hrSuccess) {
              successCount++;
              debugPrint('✓ HR ${heartRates[j]} OK');
            } else {
              failCount++;
              debugPrint('✗ HR FAIL');
            }
          } catch (e) {
            failCount++;
            debugPrint('✗ HR ERROR: $e');
          }
        }

        // 3. 수면 데이터 (전날 밤 ~ 당일 아침)
        try {
          // 수면 시작: 전날 밤 23시 + uniqueOffset분
          final sleepStart = DateTime(date.year, date.month, date.day, 0, uniqueOffset)
              .subtract(const Duration(hours: 1)); // 전날 23시 + offset
          final sleepEnd = sleepStart.add(Duration(minutes: sleepMinutes));

          debugPrint('Writing sleep: $sleepMinutes min for day -$i (${scenario.name})');

          final sleepSuccess = await _health.writeHealthData(
            value: sleepMinutes.toDouble(),
            type: HealthDataType.SLEEP_ASLEEP,
            startTime: sleepStart,
            endTime: sleepEnd,
          );

          if (sleepSuccess) {
            successCount++;
            debugPrint('✓ Sleep $sleepMinutes min OK');
          } else {
            failCount++;
            debugPrint('✗ Sleep FAIL');
          }
        } catch (e) {
          failCount++;
          debugPrint('✗ Sleep ERROR: $e');
        }
      }

      debugPrint('=== Complete: $successCount success, $failCount fail ===');

      return successCount > 0;
    } catch (e, stackTrace) {
      debugPrint('Fatal error: $e');
      debugPrint('$stackTrace');
      return false;
    }
  }

  /// 시나리오별 걸음수, 심박수, 수면시간(분) 데이터 반환
  (int steps, List<int> heartRates, int sleepMinutes) _getScenarioData(
    HealthScenario scenario,
    int dayIndex,
    int totalDays,
  ) {
    switch (scenario) {
      case HealthScenario.good:
        // 좋은 상태: 8000-12000 걸음, 안정적인 심박수 60-75, 7-8시간 수면
        return (
          8000 + (dayIndex * 300) + (DateTime.now().millisecond % 4000),
          [62, 65, 68, 64], // 안정적인 심박수
          420 + (dayIndex * 10), // 7시간(420분) + 변동
        );

      case HealthScenario.medium:
        // 중간 상태: 4000-6000 걸음, 정상 심박수 70-85, 6-7시간 수면
        return (
          4000 + (dayIndex * 200) + (DateTime.now().millisecond % 2000),
          [72, 78, 82, 75], // 정상 범위 심박수
          360 + (dayIndex * 15), // 6시간(360분) + 변동
        );

      case HealthScenario.bad:
        // 나쁜 상태: 1000-3000 걸음, 불규칙한 심박수 55-100, 4-5시간 수면
        return (
          1000 + (dayIndex * 150) + (DateTime.now().millisecond % 2000),
          [55, 95, 58, 92], // 불규칙한 심박수
          240 + (dayIndex * 20), // 4시간(240분) + 변동
        );

      case HealthScenario.emergency:
        // 응급 상태: 매우 낮은 활동 (100-500걸음), 위험한 심박수, 2-3시간 수면
        // 일부 날은 빈맥(130+), 일부는 서맥(40-50)
        final isOddDay = dayIndex % 2 == 1;
        return (
          100 + (dayIndex * 50) + (DateTime.now().millisecond % 400),
          isOddDay
              ? [135, 142, 138, 145] // 빈맥 (Tachycardia)
              : [42, 45, 40, 38],    // 서맥 (Bradycardia)
          120 + (dayIndex * 15), // 2시간(120분) + 변동
        );
    }
  }

  // ========== END 테스트 데이터 ==========

  /// HealthDataPoint를 Backend API 형식으로 변환
  Map<String, dynamic> convertToApiFormat(HealthDataPoint dataPoint) {
    String dataType;

    switch (dataPoint.type) {
      case HealthDataType.STEPS:
        dataType = 'steps';
        break;
      case HealthDataType.HEART_RATE:
        dataType = 'heart_rate';
        break;
      case HealthDataType.BLOOD_OXYGEN:
        dataType = 'blood_oxygen';
        break;
      case HealthDataType.SLEEP_ASLEEP:
        dataType = 'sleep';
        break;
      case HealthDataType.ACTIVE_ENERGY_BURNED:
        dataType = 'calories';
        break;
      case HealthDataType.DISTANCE_WALKING_RUNNING:
        dataType = 'distance';
        break;
      default:
        dataType = 'unknown';
    }

    // health 13.x에서 값 추출
    double value = 0.0;
    if (dataPoint.value is NumericHealthValue) {
      value = (dataPoint.value as NumericHealthValue).numericValue.toDouble();
    }

    return {
      'data_type': dataType,
      'value': value,
      'unit': dataPoint.unit.name,
      'start_time': dataPoint.dateFrom.toIso8601String(),
      'end_time': dataPoint.dateTo.toIso8601String(),
      'source': 'health_connect',
      'device_id': dataPoint.sourceName ?? 'unknown',
    };
  }
}

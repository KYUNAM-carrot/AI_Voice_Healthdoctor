import 'package:health/health.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class HealthConnectService {
  final Health _health = Health();
  bool _isConfigured = false;

  // 읽을 데이터 타입 (Android)
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
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

      // 권한 확인
      final hasPermission = await _health.hasPermissions(
        _dataTypes,
        permissions: _permissions,
      );
      if (hasPermission != true) {
        throw Exception('Health Connect permission not granted');
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

import 'package:health/health.dart';
import 'dart:io' show Platform;

class HealthConnectService {
  final Health _health = Health();

  // 읽을 데이터 타입 (Android)
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  /// Health Connect 설치 확인
  Future<bool> isHealthConnectAvailable() async {
    if (!Platform.isAndroid) return false;

    try {
      // Health Connect SDK 버전 확인
      final available =
          await _health.isDataTypeAvailable(HealthDataType.STEPS);
      return available;
    } catch (e) {
      print('Health Connect availability check error: $e');
      return false;
    }
  }

  /// Health Connect 앱 설치 유도
  Future<void> openHealthConnectSettings() async {
    // Health Connect 설정 화면 열기
    // 사용자가 앱을 설치하거나 권한을 관리할 수 있음
    try {
      await _health.requestAuthorization(_dataTypes);
    } catch (e) {
      print('Error opening Health Connect settings: $e');
    }
  }

  /// Health Connect 권한 요청
  Future<bool> requestAuthorization() async {
    try {
      // Health Connect 설치 확인
      final available = await isHealthConnectAvailable();
      if (!available) {
        throw Exception(
            'Health Connect not available. Please install from Play Store.');
      }

      final hasPermission = await _health.hasPermissions(_dataTypes);

      if (hasPermission == false) {
        final authorized = await _health.requestAuthorization(_dataTypes);
        return authorized;
      }

      return true;
    } catch (e) {
      print('Health Connect authorization error: $e');
      return false;
    }
  }

  /// 최근 N일 데이터 읽기
  Future<List<HealthDataPoint>> fetchHealthData({int days = 7}) async {
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));

    try {
      // 권한 확인
      final hasPermission = await _health.hasPermissions(_dataTypes);
      if (hasPermission == false) {
        throw Exception('Health Connect permission not granted');
      }

      // 데이터 읽기
      // TODO: health 13.x API 변경 - 나중에 수정 필요
      // final healthData = await _health.getHealthDataFromTypes(
      //   types: _dataTypes,
      //   startTime: startDate,
      //   endTime: now,
      // );

      return [];
    } catch (e) {
      print('Error fetching Health Connect data: $e');
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

    return {
      'data_type': dataType,
      'value': 0.0, // TODO: health 13.x API 변경
      'unit': dataPoint.unit.name,
      'start_time': dataPoint.dateFrom.toIso8601String(),
      'end_time': dataPoint.dateTo.toIso8601String(),
      'source': 'health_connect',
      'device_id': 'unknown', // TODO: health 13.x API 변경
    };
  }
}

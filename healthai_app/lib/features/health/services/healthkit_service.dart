import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthKitService {
  final Health _health = Health();

  // 읽을 데이터 타입
  static final List<HealthDataType> _dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_OXYGEN,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  /// HealthKit 권한 요청
  Future<bool> requestAuthorization() async {
    try {
      final hasPermission = await _health.hasPermissions(_dataTypes);

      if (hasPermission == false) {
        final authorized = await _health.requestAuthorization(_dataTypes);
        return authorized;
      }

      return true;
    } catch (e) {
      print('HealthKit authorization error: $e');
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
        throw Exception('HealthKit permission not granted');
      }

      // 데이터 읽기 (health 13.x API)
      final healthData = await _health.getHealthDataFromTypes(
        startTime: startDate,
        endTime: now,
        types: _dataTypes,
      );

      // 중복 제거
      final uniqueData = _health.removeDuplicates(healthData);

      return uniqueData;
    } catch (e) {
      print('Error fetching HealthKit data: $e');
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
      'source': 'apple_health',
      'device_id': dataPoint.sourceName ?? 'unknown',
    };
  }
}

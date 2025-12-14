import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../features/settings/providers/profile_provider.dart';
import '../../features/family/models/family_profile_model.dart';

/// 세계 최고 수준의 AI 건강상담을 위한 개인화된 건강 컨텍스트 빌더
///
/// 사용자 프로필, 가족 프로필, 웨어러블 데이터를 통합하여
/// AI가 최적의 맞춤형 건강 조언을 제공할 수 있도록 함
class HealthContextService {

  /// 상담 대상의 전체 건강 컨텍스트 빌드
  ///
  /// [userProfile] - 사용자 본인의 프로필 데이터
  /// [familyProfile] - 상담 대상 가족 프로필 (본인이면 null)
  /// [healthData] - 웨어러블에서 수집된 건강 데이터
  /// [isUserItself] - 본인 상담 여부
  /// [userName] - 사용자의 실제 이름 (로그인 정보에서 가져옴)
  static Map<String, dynamic> buildHealthContext({
    required ProfileData? userProfile,
    FamilyProfileModel? familyProfile,
    Map<String, dynamic>? healthData,
    required bool isUserItself,
    String? userName,
  }) {
    final context = <String, dynamic>{};

    // 상담 대상 정보
    if (isUserItself) {
      context['consultation_target'] = _buildUserContext(userProfile, userName: userName);
    } else if (familyProfile != null) {
      context['consultation_target'] = _buildFamilyContext(familyProfile);
    }

    // 웨어러블 건강 데이터
    if (healthData != null && healthData.isNotEmpty) {
      context['wearable_health_data'] = _processWearableData(healthData);
    }

    // 건강 위험 요인 분석
    context['health_risk_analysis'] = _analyzeHealthRisks(
      userProfile: userProfile,
      familyProfile: familyProfile,
      healthData: healthData,
      isUserItself: isUserItself,
    );

    // 맞춤 상담 가이드라인
    context['personalization_guidelines'] = _buildPersonalizationGuidelines(
      userProfile: userProfile,
      familyProfile: familyProfile,
      isUserItself: isUserItself,
      userName: userName,
    );

    debugPrint('건강 컨텍스트 빌드 완료: ${context.keys}');
    return context;
  }

  /// 사용자 본인 컨텍스트 빌드
  static Map<String, dynamic> _buildUserContext(ProfileData? profile, {String? userName}) {
    // 사용자 이름 결정: 전달받은 이름 > 기본값 '사용자'
    final displayName = (userName != null && userName.isNotEmpty) ? userName : '사용자';

    if (profile == null) {
      return {'type': 'user', 'name': displayName};
    }

    final now = DateTime.now();
    int? age;
    if (profile.birthYear != null) {
      age = now.year - profile.birthYear!;
      if (profile.birthMonth != null && now.month < profile.birthMonth!) {
        age--;
      }
    }

    return {
      'type': 'user',
      'name': displayName,
      'demographics': {
        'age': age,
        'age_group': _getAgeGroup(age),
        'gender': _translateGender(profile.gender),
        'birth_year': profile.birthYear,
        'birth_month': profile.birthMonth,
      },
      'body_metrics': {
        'height_cm': profile.height,
        'weight_kg': profile.weight,
        'bmi': _calculateBMI(profile.height, profile.weight),
        'bmi_category': _getBMICategory(_calculateBMI(profile.height, profile.weight)),
        'blood_type': profile.bloodType,
      },
      'health_conditions': {
        'chronic_conditions': profile.chronicConditions,
        'allergies': profile.allergies,
        'current_medications': profile.medications,
      },
    };
  }

  /// 가족 프로필 컨텍스트 빌드
  static Map<String, dynamic> _buildFamilyContext(FamilyProfileModel profile) {
    final now = DateTime.now();
    final age = now.year - profile.birthDate.year;

    return {
      'type': 'family_member',
      'name': profile.name,
      'relationship': _translateRelationship(profile.relationship),
      'demographics': {
        'age': age,
        'age_group': _getAgeGroup(age),
        'gender': _translateGender(profile.gender),
        'birth_date': DateFormat('yyyy-MM-dd').format(profile.birthDate),
      },
      'body_metrics': {
        'height_cm': profile.height?.toInt(),
        'weight_kg': profile.weight?.toInt(),
        'bmi': _calculateBMI(profile.height?.toInt(), profile.weight?.toInt()),
        'bmi_category': _getBMICategory(_calculateBMI(profile.height?.toInt(), profile.weight?.toInt())),
        'blood_type': profile.bloodType,
      },
      'health_conditions': {
        'chronic_conditions': profile.chronicConditions,
        'allergies': profile.allergies,
        'current_medications': profile.medications,
      },
    };
  }

  /// 웨어러블 건강 데이터 처리
  static Map<String, dynamic> _processWearableData(Map<String, dynamic> rawData) {
    final processed = <String, dynamic>{};
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    // 걸음 수
    if (rawData.containsKey('steps')) {
      final steps = rawData['steps'] as List? ?? [];
      if (steps.isNotEmpty) {
        processed['steps'] = {
          'today': _getTodayValue(steps, 'count'),
          'weekly_average': _getWeeklyAverage(steps, 'count'),
          'trend': _calculateTrend(steps, 'count'),
          'last_updated': dateFormat.format(now),
        };
      }
    }

    // 심박수
    if (rawData.containsKey('heart_rate')) {
      final heartRate = rawData['heart_rate'] as List? ?? [];
      if (heartRate.isNotEmpty) {
        processed['heart_rate'] = {
          'latest_bpm': _getLatestValue(heartRate, 'bpm'),
          'resting_bpm': _getRestingHeartRate(heartRate),
          'weekly_average': _getWeeklyAverage(heartRate, 'bpm'),
          'max_recorded': _getMaxValue(heartRate, 'bpm'),
          'min_recorded': _getMinValue(heartRate, 'bpm'),
          'variability': _calculateHeartRateVariability(heartRate),
          'status': _evaluateHeartRateStatus(_getLatestValue(heartRate, 'bpm')),
        };
      }
    }

    // 혈압
    if (rawData.containsKey('blood_pressure')) {
      final bp = rawData['blood_pressure'] as List? ?? [];
      if (bp.isNotEmpty) {
        final latest = bp.last as Map<String, dynamic>?;
        processed['blood_pressure'] = {
          'latest': {
            'systolic': latest?['systolic'],
            'diastolic': latest?['diastolic'],
            'measured_at': latest?['measured_at'],
          },
          'weekly_average': {
            'systolic': _getWeeklyAverage(bp, 'systolic'),
            'diastolic': _getWeeklyAverage(bp, 'diastolic'),
          },
          'status': _evaluateBloodPressureStatus(
            latest?['systolic'] as int?,
            latest?['diastolic'] as int?,
          ),
        };
      }
    }

    // 혈당
    if (rawData.containsKey('blood_sugar')) {
      final bs = rawData['blood_sugar'] as List? ?? [];
      if (bs.isNotEmpty) {
        processed['blood_sugar'] = {
          'latest_mg_dl': _getLatestValue(bs, 'value'),
          'fasting_average': _getFastingAverage(bs),
          'post_meal_average': _getPostMealAverage(bs),
          'weekly_trend': _calculateTrend(bs, 'value'),
          'status': _evaluateBloodSugarStatus(_getLatestValue(bs, 'value')),
        };
      }
    }

    // 수면
    if (rawData.containsKey('sleep')) {
      final sleep = rawData['sleep'] as List? ?? [];
      if (sleep.isNotEmpty) {
        processed['sleep'] = {
          'last_night_hours': _getLastNightSleep(sleep),
          'weekly_average_hours': _getWeeklyAverage(sleep, 'duration_hours'),
          'sleep_quality_score': _calculateSleepQuality(sleep),
          'sleep_efficiency': _calculateSleepEfficiency(sleep),
          'status': _evaluateSleepStatus(_getLastNightSleep(sleep)),
        };
      }
    }

    // 산소포화도
    if (rawData.containsKey('spo2')) {
      final spo2 = rawData['spo2'] as List? ?? [];
      if (spo2.isNotEmpty) {
        processed['blood_oxygen'] = {
          'latest_percent': _getLatestValue(spo2, 'value'),
          'weekly_average': _getWeeklyAverage(spo2, 'value'),
          'min_recorded': _getMinValue(spo2, 'value'),
          'status': _evaluateSpO2Status(_getLatestValue(spo2, 'value')),
        };
      }
    }

    // 활동 칼로리
    if (rawData.containsKey('active_energy')) {
      final energy = rawData['active_energy'] as List? ?? [];
      if (energy.isNotEmpty) {
        processed['activity'] = {
          'today_kcal': _getTodayValue(energy, 'kcal'),
          'weekly_average_kcal': _getWeeklyAverage(energy, 'kcal'),
          'activity_level': _evaluateActivityLevel(_getTodayValue(energy, 'kcal')),
        };
      }
    }

    // 체중 변화
    if (rawData.containsKey('weight_history')) {
      final weight = rawData['weight_history'] as List? ?? [];
      if (weight.isNotEmpty) {
        processed['weight_trend'] = {
          'current_kg': _getLatestValue(weight, 'kg'),
          'change_30_days': _calculate30DayChange(weight, 'kg'),
          'trend': _calculateTrend(weight, 'kg'),
        };
      }
    }

    return processed;
  }

  /// 건강 위험 요인 분석
  static Map<String, dynamic> _analyzeHealthRisks({
    ProfileData? userProfile,
    FamilyProfileModel? familyProfile,
    Map<String, dynamic>? healthData,
    required bool isUserItself,
  }) {
    final risks = <String>[];
    final recommendations = <String>[];
    final profile = isUserItself ? userProfile : null;
    final family = !isUserItself ? familyProfile : null;

    // 만성질환 기반 위험 분석
    final conditions = isUserItself
        ? (profile?.chronicConditions ?? [])
        : (family?.chronicConditions ?? []);

    for (final condition in conditions) {
      switch (condition) {
        case '당뇨병':
          risks.add('혈당 관리 필요');
          recommendations.add('정기적인 혈당 모니터링과 식이요법 권장');
          break;
        case '고혈압':
          risks.add('혈압 관리 필요');
          recommendations.add('저염식과 규칙적인 운동 권장');
          break;
        case '고지혈증':
          risks.add('콜레스테롤 관리 필요');
          recommendations.add('포화지방 섭취 제한과 유산소 운동 권장');
          break;
        case '심장질환':
          risks.add('심혈관 건강 모니터링 필수');
          recommendations.add('정기적인 심장 검진과 스트레스 관리 권장');
          break;
      }
    }

    // BMI 기반 위험 분석
    final height = isUserItself ? profile?.height : family?.height?.toInt();
    final weight = isUserItself ? profile?.weight : family?.weight?.toInt();
    final bmi = _calculateBMI(height, weight);

    if (bmi != null) {
      if (bmi >= 30) {
        risks.add('비만으로 인한 대사질환 위험 증가');
        recommendations.add('체중 감량을 위한 식이조절과 운동 프로그램 권장');
      } else if (bmi >= 25) {
        risks.add('과체중 상태');
        recommendations.add('적정 체중 유지를 위한 생활습관 개선 권장');
      } else if (bmi < 18.5) {
        risks.add('저체중으로 인한 영양 부족 가능성');
        recommendations.add('균형 잡힌 영양 섭취 권장');
      }
    }

    // 나이 기반 위험 분석
    int? age;
    if (isUserItself && profile?.birthYear != null) {
      age = DateTime.now().year - profile!.birthYear!;
    } else if (!isUserItself && family != null) {
      age = DateTime.now().year - family.birthDate.year;
    }

    if (age != null) {
      if (age >= 65) {
        risks.add('노화로 인한 기능 저하 가능성');
        recommendations.add('정기적인 건강검진과 예방접종 권장');
      } else if (age >= 40) {
        risks.add('중년기 건강관리 필요');
        recommendations.add('암 검진 및 심혈관 검사 권장');
      }
    }

    // 알레르기 정보
    final allergies = isUserItself
        ? (profile?.allergies ?? [])
        : (family?.allergies ?? []);

    if (allergies.isNotEmpty) {
      risks.add('알레르기 반응 주의 필요: ${allergies.join(", ")}');
    }

    // 현재 복용 약물
    final medications = isUserItself
        ? (profile?.medications ?? [])
        : (family?.medications ?? []);

    if (medications.isNotEmpty) {
      recommendations.add('현재 복용 중인 약물과의 상호작용 고려 필요');
    }

    return {
      'identified_risks': risks,
      'recommendations': recommendations,
      'risk_level': _calculateOverallRiskLevel(risks.length),
    };
  }

  /// 개인화 가이드라인 빌드
  static Map<String, dynamic> _buildPersonalizationGuidelines({
    ProfileData? userProfile,
    FamilyProfileModel? familyProfile,
    required bool isUserItself,
    String? userName,
  }) {
    final guidelines = <String, dynamic>{};

    // 호칭 설정
    if (!isUserItself && familyProfile != null) {
      guidelines['addressing'] = '${familyProfile.name}님';
      guidelines['relationship_context'] = '가족(${_translateRelationship(familyProfile.relationship)})을 위한 상담';
    } else {
      // 사용자 이름이 있으면 사용, 없으면 기본값
      final displayName = (userName != null && userName.isNotEmpty) ? userName : '사용자';
      guidelines['addressing'] = '$displayName님';
      guidelines['relationship_context'] = '본인 건강 상담';
    }

    // 연령대별 맞춤 가이드
    int? age;
    if (isUserItself && userProfile?.birthYear != null) {
      age = DateTime.now().year - userProfile!.birthYear!;
    } else if (!isUserItself && familyProfile != null) {
      age = DateTime.now().year - familyProfile.birthDate.year;
    }

    if (age != null) {
      if (age < 18) {
        guidelines['age_specific'] = {
          'focus_areas': ['성장발달', '영양', '예방접종', '학교생활 건강'],
          'communication_style': '보호자와 함께하는 설명',
          'special_considerations': '소아청소년 특성 고려',
        };
      } else if (age < 40) {
        guidelines['age_specific'] = {
          'focus_areas': ['체력관리', '스트레스', '직장인 건강', '예방적 건강관리'],
          'communication_style': '간결하고 실용적인 조언',
          'special_considerations': '바쁜 일상 고려',
        };
      } else if (age < 65) {
        guidelines['age_specific'] = {
          'focus_areas': ['만성질환 예방', '암검진', '갱년기', '체중관리'],
          'communication_style': '근거 기반의 상세한 설명',
          'special_considerations': '건강검진 결과 연계',
        };
      } else {
        guidelines['age_specific'] = {
          'focus_areas': ['만성질환 관리', '낙상예방', '인지건강', '약물관리'],
          'communication_style': '천천히 명확하게, 반복 확인',
          'special_considerations': '청력/시력 저하 가능성 고려',
        };
      }
    }

    // 성별 맞춤 가이드
    final gender = isUserItself ? userProfile?.gender : familyProfile?.gender;
    if (gender != null) {
      if (gender.toLowerCase() == 'female' || gender == '여성') {
        guidelines['gender_specific'] = {
          'focus_areas': ['여성건강', '호르몬 변화', '골다공증 예방'],
          'considerations': age != null && age >= 45 ? '갱년기 증상 가능성 고려' : '생리주기 관련 건강',
        };
      } else if (gender.toLowerCase() == 'male' || gender == '남성') {
        guidelines['gender_specific'] = {
          'focus_areas': ['전립선 건강', '심혈관 건강', '탈모'],
          'considerations': age != null && age >= 50 ? '전립선 검진 권장' : '심혈관 질환 예방',
        };
      }
    }

    return guidelines;
  }

  // ==================== 유틸리티 함수들 ====================

  static String _translateGender(String? gender) {
    if (gender == null) return '미지정';
    switch (gender.toLowerCase()) {
      case 'male':
      case 'm':
        return '남성';
      case 'female':
      case 'f':
        return '여성';
      default:
        return gender;
    }
  }

  static String _translateRelationship(String relationship) {
    switch (relationship.toLowerCase()) {
      case 'father':
        return '아버지';
      case 'mother':
        return '어머니';
      case 'spouse':
        return '배우자';
      case 'child':
        return '자녀';
      case 'sibling':
        return '형제/자매';
      case 'grandparent':
        return '조부모';
      case 'other':
        return '기타 가족';
      default:
        return relationship;
    }
  }

  static String _getAgeGroup(int? age) {
    if (age == null) return '미지정';
    if (age < 13) return '어린이';
    if (age < 20) return '청소년';
    if (age < 30) return '20대';
    if (age < 40) return '30대';
    if (age < 50) return '40대';
    if (age < 60) return '50대';
    if (age < 70) return '60대';
    if (age < 80) return '70대';
    return '80대 이상';
  }

  static double? _calculateBMI(int? height, int? weight) {
    if (height == null || weight == null || height == 0) return null;
    final heightM = height / 100;
    return double.parse((weight / (heightM * heightM)).toStringAsFixed(1));
  }

  static String _getBMICategory(double? bmi) {
    if (bmi == null) return '미측정';
    if (bmi < 18.5) return '저체중';
    if (bmi < 23) return '정상';
    if (bmi < 25) return '과체중';
    if (bmi < 30) return '비만';
    return '고도비만';
  }

  static String _calculateOverallRiskLevel(int riskCount) {
    if (riskCount == 0) return '낮음';
    if (riskCount <= 2) return '보통';
    if (riskCount <= 4) return '주의';
    return '높음';
  }

  // 웨어러블 데이터 처리 유틸리티
  static double? _getLatestValue(List data, String field) {
    if (data.isEmpty) return null;
    final latest = data.last as Map<String, dynamic>?;
    return (latest?[field] as num?)?.toDouble();
  }

  static double? _getTodayValue(List data, String field) {
    if (data.isEmpty) return null;
    final today = DateTime.now();
    for (var i = data.length - 1; i >= 0; i--) {
      final item = data[i] as Map<String, dynamic>?;
      final date = DateTime.tryParse(item?['date'] ?? '');
      if (date != null && date.day == today.day && date.month == today.month) {
        return (item?[field] as num?)?.toDouble();
      }
    }
    return _getLatestValue(data, field);
  }

  static double? _getWeeklyAverage(List data, String field) {
    if (data.isEmpty) return null;
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    var sum = 0.0;
    var count = 0;
    for (final item in data) {
      final map = item as Map<String, dynamic>?;
      final date = DateTime.tryParse(map?['date'] ?? '');
      if (date != null && date.isAfter(weekAgo)) {
        final value = (map?[field] as num?)?.toDouble();
        if (value != null) {
          sum += value;
          count++;
        }
      }
    }
    return count > 0 ? double.parse((sum / count).toStringAsFixed(1)) : null;
  }

  static double? _getMaxValue(List data, String field) {
    if (data.isEmpty) return null;
    double? max;
    for (final item in data) {
      final value = ((item as Map<String, dynamic>?)?[field] as num?)?.toDouble();
      if (value != null && (max == null || value > max)) {
        max = value;
      }
    }
    return max;
  }

  static double? _getMinValue(List data, String field) {
    if (data.isEmpty) return null;
    double? min;
    for (final item in data) {
      final value = ((item as Map<String, dynamic>?)?[field] as num?)?.toDouble();
      if (value != null && (min == null || value < min)) {
        min = value;
      }
    }
    return min;
  }

  static String _calculateTrend(List data, String field) {
    if (data.length < 3) return '데이터 부족';
    final recent = _getWeeklyAverage(data.sublist(data.length - 3), field);
    final previous = _getWeeklyAverage(data.sublist(0, data.length - 3), field);
    if (recent == null || previous == null) return '분석 불가';
    final diff = recent - previous;
    if (diff.abs() < 0.05 * previous) return '유지';
    return diff > 0 ? '상승' : '하락';
  }

  static double? _calculate30DayChange(List data, String field) {
    if (data.length < 2) return null;
    final latest = _getLatestValue(data, field);
    final monthAgo = DateTime.now().subtract(const Duration(days: 30));
    for (final item in data) {
      final map = item as Map<String, dynamic>?;
      final date = DateTime.tryParse(map?['date'] ?? '');
      if (date != null && date.isBefore(monthAgo.add(const Duration(days: 3)))) {
        final oldValue = (map?[field] as num?)?.toDouble();
        if (oldValue != null && latest != null) {
          return double.parse((latest - oldValue).toStringAsFixed(1));
        }
      }
    }
    return null;
  }

  static int? _getRestingHeartRate(List data) {
    // 수면 시간대(새벽 2-5시) 심박수 평균
    final restingValues = <int>[];
    for (final item in data) {
      final map = item as Map<String, dynamic>?;
      final time = DateTime.tryParse(map?['time'] ?? '');
      if (time != null && time.hour >= 2 && time.hour <= 5) {
        final bpm = (map?['bpm'] as num?)?.toInt();
        if (bpm != null) restingValues.add(bpm);
      }
    }
    if (restingValues.isEmpty) return null;
    return restingValues.reduce((a, b) => a + b) ~/ restingValues.length;
  }

  static String _calculateHeartRateVariability(List data) {
    if (data.length < 10) return '데이터 부족';
    final values = data
        .map((e) => ((e as Map<String, dynamic>?)?['bpm'] as num?)?.toInt())
        .whereType<int>()
        .toList();
    if (values.length < 10) return '데이터 부족';

    final mean = values.reduce((a, b) => a + b) / values.length;
    final variance = values.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / values.length;
    final stdDev = variance > 0 ? variance : 0.0;

    if (stdDev < 5) return '낮음';
    if (stdDev < 15) return '정상';
    return '높음';
  }

  static double? _getFastingAverage(List data) {
    final fastingValues = <double>[];
    for (final item in data) {
      final map = item as Map<String, dynamic>?;
      if (map?['type'] == 'fasting') {
        final value = (map?['value'] as num?)?.toDouble();
        if (value != null) fastingValues.add(value);
      }
    }
    if (fastingValues.isEmpty) return null;
    return double.parse((fastingValues.reduce((a, b) => a + b) / fastingValues.length).toStringAsFixed(0));
  }

  static double? _getPostMealAverage(List data) {
    final postMealValues = <double>[];
    for (final item in data) {
      final map = item as Map<String, dynamic>?;
      if (map?['type'] == 'post_meal') {
        final value = (map?['value'] as num?)?.toDouble();
        if (value != null) postMealValues.add(value);
      }
    }
    if (postMealValues.isEmpty) return null;
    return double.parse((postMealValues.reduce((a, b) => a + b) / postMealValues.length).toStringAsFixed(0));
  }

  static double? _getLastNightSleep(List data) {
    if (data.isEmpty) return null;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    for (var i = data.length - 1; i >= 0; i--) {
      final item = data[i] as Map<String, dynamic>?;
      final date = DateTime.tryParse(item?['date'] ?? '');
      if (date != null && date.day == yesterday.day) {
        return (item?['duration_hours'] as num?)?.toDouble();
      }
    }
    return _getLatestValue(data, 'duration_hours');
  }

  static int _calculateSleepQuality(List data) {
    // 수면 효율, 깊은 수면 비율 등을 종합하여 100점 만점 점수
    if (data.isEmpty) return 0;
    final avgHours = _getWeeklyAverage(data, 'duration_hours') ?? 0;
    var score = 0;
    if (avgHours >= 7 && avgHours <= 9) score += 40;
    else if (avgHours >= 6) score += 25;
    else score += 10;

    // 규칙성 점수 (간단히 데이터 개수로 판단)
    score += data.length >= 7 ? 30 : (data.length * 4);

    // 기본 점수
    score += 30;

    return score > 100 ? 100 : score;
  }

  static double? _calculateSleepEfficiency(List data) {
    if (data.isEmpty) return null;
    var totalEfficiency = 0.0;
    var count = 0;
    for (final item in data) {
      final map = item as Map<String, dynamic>?;
      final efficiency = (map?['efficiency'] as num?)?.toDouble();
      if (efficiency != null) {
        totalEfficiency += efficiency;
        count++;
      }
    }
    return count > 0 ? double.parse((totalEfficiency / count).toStringAsFixed(1)) : null;
  }

  // 상태 평가 함수들
  static String _evaluateHeartRateStatus(double? bpm) {
    if (bpm == null) return '미측정';
    if (bpm < 60) return '서맥 (낮음)';
    if (bpm <= 100) return '정상';
    return '빈맥 (높음)';
  }

  static String _evaluateBloodPressureStatus(int? systolic, int? diastolic) {
    if (systolic == null || diastolic == null) return '미측정';
    if (systolic < 120 && diastolic < 80) return '정상';
    if (systolic < 130 && diastolic < 80) return '주의';
    if (systolic < 140 || diastolic < 90) return '고혈압 전단계';
    if (systolic < 160 || diastolic < 100) return '고혈압 1기';
    return '고혈압 2기';
  }

  static String _evaluateBloodSugarStatus(double? value) {
    if (value == null) return '미측정';
    if (value < 100) return '정상';
    if (value < 126) return '공복혈당장애';
    return '당뇨병 의심';
  }

  static String _evaluateSleepStatus(double? hours) {
    if (hours == null) return '미측정';
    if (hours < 5) return '심각한 수면 부족';
    if (hours < 6) return '수면 부족';
    if (hours <= 9) return '적정';
    return '과다 수면';
  }

  static String _evaluateSpO2Status(double? value) {
    if (value == null) return '미측정';
    if (value >= 95) return '정상';
    if (value >= 90) return '주의';
    return '위험 (즉시 확인 필요)';
  }

  static String _evaluateActivityLevel(double? kcal) {
    if (kcal == null) return '미측정';
    if (kcal < 200) return '매우 낮음';
    if (kcal < 400) return '낮음';
    if (kcal < 600) return '보통';
    if (kcal < 800) return '활발';
    return '매우 활발';
  }

  /// 건강 컨텍스트를 AI 시스템 프롬프트용 문자열로 변환
  static String toPromptString(Map<String, dynamic> context) {
    final buffer = StringBuffer();

    buffer.writeln('## 상담 대상 건강 프로필');
    buffer.writeln();

    // 상담 대상 정보
    if (context.containsKey('consultation_target')) {
      final target = context['consultation_target'] as Map<String, dynamic>;
      final name = target['name'] ?? '사용자';
      final type = target['type'] == 'family_member' ? '(가족)' : '(본인)';

      buffer.writeln('### 기본 정보 $type');
      buffer.writeln('- 이름/호칭: $name');

      if (target.containsKey('relationship')) {
        buffer.writeln('- 관계: ${target['relationship']}');
      }

      final demo = target['demographics'] as Map<String, dynamic>?;
      if (demo != null) {
        if (demo['age'] != null) buffer.writeln('- 나이: ${demo['age']}세 (${demo['age_group']})');
        if (demo['gender'] != null) buffer.writeln('- 성별: ${demo['gender']}');
      }

      final body = target['body_metrics'] as Map<String, dynamic>?;
      if (body != null) {
        buffer.writeln();
        buffer.writeln('### 신체 정보');
        if (body['height_cm'] != null) buffer.writeln('- 키: ${body['height_cm']}cm');
        if (body['weight_kg'] != null) buffer.writeln('- 체중: ${body['weight_kg']}kg');
        if (body['bmi'] != null) buffer.writeln('- BMI: ${body['bmi']} (${body['bmi_category']})');
        if (body['blood_type'] != null) buffer.writeln('- 혈액형: ${body['blood_type']}');
      }

      final health = target['health_conditions'] as Map<String, dynamic>?;
      if (health != null) {
        buffer.writeln();
        buffer.writeln('### 건강 이력');
        final conditions = health['chronic_conditions'] as List? ?? [];
        if (conditions.isNotEmpty) {
          buffer.writeln('- 만성질환: ${conditions.join(", ")}');
        }
        final allergies = health['allergies'] as List? ?? [];
        if (allergies.isNotEmpty) {
          buffer.writeln('- 알레르기: ${allergies.join(", ")}');
        }
        final meds = health['current_medications'] as List? ?? [];
        if (meds.isNotEmpty) {
          buffer.writeln('- 복용 약물: ${meds.join(", ")}');
        }
      }
    }

    // 웨어러블 건강 데이터
    if (context.containsKey('wearable_health_data')) {
      final wearable = context['wearable_health_data'] as Map<String, dynamic>;
      if (wearable.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('### 최근 건강 데이터 (웨어러블 연동)');

        if (wearable.containsKey('heart_rate')) {
          final hr = wearable['heart_rate'] as Map<String, dynamic>;
          buffer.writeln('- 심박수: ${hr['latest_bpm']}bpm (${hr['status']})');
        }

        if (wearable.containsKey('blood_pressure')) {
          final bp = wearable['blood_pressure'] as Map<String, dynamic>;
          final latest = bp['latest'] as Map<String, dynamic>?;
          if (latest != null) {
            buffer.writeln('- 혈압: ${latest['systolic']}/${latest['diastolic']} mmHg (${bp['status']})');
          }
        }

        if (wearable.containsKey('blood_sugar')) {
          final bs = wearable['blood_sugar'] as Map<String, dynamic>;
          buffer.writeln('- 혈당: ${bs['latest_mg_dl']}mg/dL (${bs['status']})');
        }

        if (wearable.containsKey('steps')) {
          final steps = wearable['steps'] as Map<String, dynamic>;
          buffer.writeln('- 오늘 걸음수: ${steps['today']?.toInt() ?? "미측정"}보');
        }

        if (wearable.containsKey('sleep')) {
          final sleep = wearable['sleep'] as Map<String, dynamic>;
          buffer.writeln('- 수면: ${sleep['last_night_hours']}시간 (${sleep['status']})');
        }

        if (wearable.containsKey('blood_oxygen')) {
          final spo2 = wearable['blood_oxygen'] as Map<String, dynamic>;
          buffer.writeln('- 산소포화도: ${spo2['latest_percent']}% (${spo2['status']})');
        }
      }
    }

    // 건강 위험 분석
    if (context.containsKey('health_risk_analysis')) {
      final risk = context['health_risk_analysis'] as Map<String, dynamic>;
      final risks = risk['identified_risks'] as List? ?? [];
      final recommendations = risk['recommendations'] as List? ?? [];

      if (risks.isNotEmpty || recommendations.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('### 건강 주의사항');
        buffer.writeln('- 위험도: ${risk['risk_level']}');

        if (risks.isNotEmpty) {
          buffer.writeln('- 주요 위험 요인:');
          for (final r in risks) {
            buffer.writeln('  * $r');
          }
        }

        if (recommendations.isNotEmpty) {
          buffer.writeln('- 권장사항:');
          for (final rec in recommendations) {
            buffer.writeln('  * $rec');
          }
        }
      }
    }

    // 개인화 가이드라인
    if (context.containsKey('personalization_guidelines')) {
      final guide = context['personalization_guidelines'] as Map<String, dynamic>;
      buffer.writeln();
      buffer.writeln('### 상담 가이드라인');
      buffer.writeln('- 호칭: ${guide['addressing']}');
      buffer.writeln('- 상담 유형: ${guide['relationship_context']}');

      final ageSpecific = guide['age_specific'] as Map<String, dynamic>?;
      if (ageSpecific != null) {
        final focus = ageSpecific['focus_areas'] as List? ?? [];
        if (focus.isNotEmpty) {
          buffer.writeln('- 중점 상담 영역: ${focus.join(", ")}');
        }
        buffer.writeln('- 소통 스타일: ${ageSpecific['communication_style']}');
      }
    }

    buffer.writeln();
    buffer.writeln('위 정보를 바탕으로 개인화된 맞춤형 건강 조언을 제공하세요.');
    buffer.writeln('단, 의료 진단이나 처방은 절대 하지 마세요.');

    return buffer.toString();
  }
}

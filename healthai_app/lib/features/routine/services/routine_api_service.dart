import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../models/routine_model.dart';

/// Routine API Service
/// Backend와 통신하여 루틴 데이터를 관리합니다.
class RoutineApiService {
  final http.Client _client;
  String? _authToken;

  RoutineApiService({http.Client? client}) : _client = client ?? http.Client();

  /// 인증 토큰 설정
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// HTTP 헤더 생성
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// 9개 루틴 항목 목록 조회
  Future<List<RoutineItemDefinition>> getRoutineItems() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.routineItemsEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = (data['items'] as List)
            .map((item) => RoutineItemDefinition.fromJson(item))
            .toList();
        return items;
      }
      throw Exception('Failed to load routine items: ${response.statusCode}');
    } catch (e) {
      print('Error fetching routine items: $e');
      rethrow;
    }
  }

  /// 오늘의 루틴 체크 조회
  Future<RoutineCheckResponse?> getTodayRoutine() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.todayRoutineEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isEmpty || body == 'null') return null;
        return RoutineCheckResponse.fromJson(json.decode(body));
      }
      return null;
    } catch (e) {
      print('Error fetching today routine: $e');
      return null;
    }
  }

  /// 특정 날짜의 루틴 체크 조회
  Future<RoutineCheckResponse?> getRoutineByDate(DateTime date) async {
    try {
      final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final response = await _client.get(
        Uri.parse(ApiConfig.routineByDateEndpoint(dateStr)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final body = response.body;
        if (body.isEmpty || body == 'null') return null;
        return RoutineCheckResponse.fromJson(json.decode(body));
      }
      return null;
    } catch (e) {
      print('Error fetching routine by date: $e');
      return null;
    }
  }

  /// 루틴 체크 생성 또는 업데이트
  Future<RoutineCheckResponse?> createOrUpdateRoutine(RoutineCheckRequest request) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConfig.routinesEndpoint),
        headers: _headers,
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return RoutineCheckResponse.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create/update routine: ${response.statusCode}');
    } catch (e) {
      print('Error creating/updating routine: $e');
      return null;
    }
  }

  /// 루틴 체크 부분 업데이트
  Future<RoutineCheckResponse?> updateRoutine(
    String checkId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client.patch(
        Uri.parse(ApiConfig.routineByIdEndpoint(checkId)),
        headers: _headers,
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return RoutineCheckResponse.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update routine: ${response.statusCode}');
    } catch (e) {
      print('Error updating routine: $e');
      return null;
    }
  }

  /// 주간 통계 조회
  Future<RoutineStatsResponse?> getWeeklyStats() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.weeklyStatsEndpoint),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return RoutineStatsResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching weekly stats: $e');
      return null;
    }
  }

  /// 월간 통계 조회
  Future<RoutineStatsResponse?> getMonthlyStats(int year, int month) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConfig.monthlyStatsEndpoint(year, month)),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return RoutineStatsResponse.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      print('Error fetching monthly stats: $e');
      return null;
    }
  }

  /// 루틴 체크 삭제
  Future<bool> deleteRoutine(String checkId) async {
    try {
      final response = await _client.delete(
        Uri.parse(ApiConfig.routineByIdEndpoint(checkId)),
        headers: _headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      print('Error deleting routine: $e');
      return false;
    }
  }

  void dispose() {
    _client.close();
  }
}

/// 루틴 항목 정의 (Backend에서 받아오는 9개 항목)
class RoutineItemDefinition {
  final String id;
  final String emoji;
  final String title;
  final int order;

  RoutineItemDefinition({
    required this.id,
    required this.emoji,
    required this.title,
    required this.order,
  });

  factory RoutineItemDefinition.fromJson(Map<String, dynamic> json) {
    return RoutineItemDefinition(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      order: json['order'] as int,
    );
  }
}

/// 루틴 체크 요청 모델
class RoutineCheckRequest {
  final DateTime? checkDate;
  final bool beddingOrganized;
  final bool waterIntake;
  final bool meditation;
  final bool stretching;
  final bool morningTea;
  final bool vitamins;
  final bool morningWalk;
  final bool planning;
  final bool gratitudeDiaryCheck;
  final int? moodScore;
  final int? energyScore;
  final String? goalToday;
  final List<String>? scheduleItems;
  final List<String>? gratitudeItems;

  RoutineCheckRequest({
    this.checkDate,
    this.beddingOrganized = false,
    this.waterIntake = false,
    this.meditation = false,
    this.stretching = false,
    this.morningTea = false,
    this.vitamins = false,
    this.morningWalk = false,
    this.planning = false,
    this.gratitudeDiaryCheck = false,
    this.moodScore,
    this.energyScore,
    this.goalToday,
    this.scheduleItems,
    this.gratitudeItems,
  });

  Map<String, dynamic> toJson() {
    return {
      if (checkDate != null)
        'check_date': '${checkDate!.year}-${checkDate!.month.toString().padLeft(2, '0')}-${checkDate!.day.toString().padLeft(2, '0')}',
      'bedding_organized': beddingOrganized,
      'water_intake': waterIntake,
      'meditation': meditation,
      'stretching': stretching,
      'morning_tea': morningTea,
      'vitamins': vitamins,
      'morning_walk': morningWalk,
      'planning': planning,
      'gratitude_diary_check': gratitudeDiaryCheck,
      if (moodScore != null) 'mood_score': moodScore,
      if (energyScore != null) 'energy_score': energyScore,
      if (goalToday != null) 'goal_today': goalToday,
      if (scheduleItems != null) 'schedule_items': scheduleItems,
      if (gratitudeItems != null) 'gratitude_items': gratitudeItems,
    };
  }

  /// DailyRoutine에서 RoutineCheckRequest 생성
  factory RoutineCheckRequest.fromDailyRoutine(DailyRoutine routine) {
    final itemMap = {for (var item in routine.items) item.id: item.isCompleted};

    return RoutineCheckRequest(
      checkDate: routine.date,
      beddingOrganized: itemMap['bedding_organized'] ?? false,
      waterIntake: itemMap['water_intake'] ?? false,
      meditation: itemMap['meditation'] ?? false,
      stretching: itemMap['stretching'] ?? false,
      morningTea: itemMap['morning_tea'] ?? false,
      vitamins: itemMap['vitamins'] ?? false,
      morningWalk: itemMap['morning_walk'] ?? false,
      planning: itemMap['planning'] ?? false,
      gratitudeDiaryCheck: itemMap['gratitude_diary_check'] ?? false,
      moodScore: routine.mood?.level,
      energyScore: routine.energy?.level,
      goalToday: routine.todayGoal,
      scheduleItems: routine.schedules,
      gratitudeItems: routine.gratitudeItems,
    );
  }
}

/// 루틴 체크 응답 모델
class RoutineCheckResponse {
  final String checkId;
  final String userId;
  final DateTime checkDate;
  final bool beddingOrganized;
  final bool waterIntake;
  final bool meditation;
  final bool stretching;
  final bool morningTea;
  final bool vitamins;
  final bool morningWalk;
  final bool planning;
  final bool gratitudeDiaryCheck;
  final int? moodScore;
  final int? energyScore;
  final String? goalToday;
  final List<String>? scheduleItems;
  final List<String>? gratitudeItems;
  final DateTime createdAt;
  final double completionRate;

  RoutineCheckResponse({
    required this.checkId,
    required this.userId,
    required this.checkDate,
    required this.beddingOrganized,
    required this.waterIntake,
    required this.meditation,
    required this.stretching,
    required this.morningTea,
    required this.vitamins,
    required this.morningWalk,
    required this.planning,
    required this.gratitudeDiaryCheck,
    this.moodScore,
    this.energyScore,
    this.goalToday,
    this.scheduleItems,
    this.gratitudeItems,
    required this.createdAt,
    required this.completionRate,
  });

  factory RoutineCheckResponse.fromJson(Map<String, dynamic> json) {
    return RoutineCheckResponse(
      checkId: json['check_id'] as String,
      userId: json['user_id'] as String,
      checkDate: DateTime.parse(json['check_date'] as String),
      beddingOrganized: json['bedding_organized'] as bool,
      waterIntake: json['water_intake'] as bool,
      meditation: json['meditation'] as bool,
      stretching: json['stretching'] as bool,
      morningTea: json['morning_tea'] as bool,
      vitamins: json['vitamins'] as bool,
      morningWalk: json['morning_walk'] as bool,
      planning: json['planning'] as bool,
      gratitudeDiaryCheck: json['gratitude_diary_check'] as bool? ?? false,
      moodScore: json['mood_score'] as int?,
      energyScore: json['energy_score'] as int?,
      goalToday: json['goal_today'] as String?,
      scheduleItems: (json['schedule_items'] as List?)?.cast<String>(),
      gratitudeItems: (json['gratitude_items'] as List?)?.cast<String>(),
      createdAt: DateTime.parse(json['created_at'] as String),
      completionRate: (json['completion_rate'] as num).toDouble(),
    );
  }

  /// DailyRoutine으로 변환
  DailyRoutine toDailyRoutine() {
    return DailyRoutine(
      id: checkId,
      date: checkDate,
      items: [
        RoutineItem(id: 'bedding_organized', title: '이불 정리', emoji: '🛏️', isCompleted: beddingOrganized, order: 0),
        RoutineItem(id: 'water_intake', title: '공복에 물 마시기', emoji: '💧', isCompleted: waterIntake, order: 1),
        RoutineItem(id: 'meditation', title: '명상, 독서', emoji: '📚', isCompleted: meditation, order: 2),
        RoutineItem(id: 'stretching', title: '한 동작 운동', emoji: '🤸', isCompleted: stretching, order: 3),
        RoutineItem(id: 'morning_tea', title: '아침 차 한 잔', emoji: '☕', isCompleted: morningTea, order: 4),
        RoutineItem(id: 'vitamins', title: '영양제 챙겨 먹기', emoji: '💊', isCompleted: vitamins, order: 5),
        RoutineItem(id: 'morning_walk', title: '러닝 30분', emoji: '🏃', isCompleted: morningWalk, order: 6),
        RoutineItem(id: 'planning', title: '하루 주요일정 및 목표설정하기', emoji: '✏️', isCompleted: planning, order: 7),
        RoutineItem(id: 'gratitude_diary_check', title: '어제 감사일기 쓰기 체크', emoji: '🙏', isCompleted: gratitudeDiaryCheck, order: 8),
      ],
      mood: moodScore != null ? ConditionLevel(type: ConditionType.mood, level: moodScore!) : null,
      energy: energyScore != null ? ConditionLevel(type: ConditionType.energy, level: energyScore!) : null,
      todayGoal: goalToday,
      schedules: scheduleItems,
      gratitudeItems: gratitudeItems,
      createdAt: createdAt,
    );
  }
}

/// 루틴 통계 응답 모델
class RoutineStatsResponse {
  final String userId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalDays;
  final int checkedDays;
  final Map<String, int> routineCounts;
  final double averageCompletionRate;
  final double? averageMood;
  final double? averageEnergy;

  RoutineStatsResponse({
    required this.userId,
    required this.periodStart,
    required this.periodEnd,
    required this.totalDays,
    required this.checkedDays,
    required this.routineCounts,
    required this.averageCompletionRate,
    this.averageMood,
    this.averageEnergy,
  });

  factory RoutineStatsResponse.fromJson(Map<String, dynamic> json) {
    return RoutineStatsResponse(
      userId: json['user_id'] as String,
      periodStart: DateTime.parse(json['period_start'] as String),
      periodEnd: DateTime.parse(json['period_end'] as String),
      totalDays: json['total_days'] as int,
      checkedDays: json['checked_days'] as int,
      routineCounts: Map<String, int>.from(json['routine_counts'] as Map),
      averageCompletionRate: (json['average_completion_rate'] as num).toDouble(),
      averageMood: (json['average_mood'] as num?)?.toDouble(),
      averageEnergy: (json['average_energy'] as num?)?.toDouble(),
    );
  }
}

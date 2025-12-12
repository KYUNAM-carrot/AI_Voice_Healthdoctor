import 'package:freezed_annotation/freezed_annotation.dart';

part 'routine_model.freezed.dart';
part 'routine_model.g.dart';

/// 루틴 항목 모델
@freezed
class RoutineItem with _$RoutineItem {
  const factory RoutineItem({
    required String id,
    required String emoji,
    required String title,
    @Default(false) bool isCompleted,
    @Default(0) int order,
  }) = _RoutineItem;

  factory RoutineItem.fromJson(Map<String, dynamic> json) =>
      _$RoutineItemFromJson(json);
}

/// 컨디션 타입 (기분, 에너지)
enum ConditionType { mood, energy }

/// 컨디션 레벨 (1-5)
@freezed
class ConditionLevel with _$ConditionLevel {
  const factory ConditionLevel({
    required ConditionType type,
    required int level, // 1-5
  }) = _ConditionLevel;

  factory ConditionLevel.fromJson(Map<String, dynamic> json) =>
      _$ConditionLevelFromJson(json);
}

/// 일일 루틴 기록 모델
@freezed
class DailyRoutine with _$DailyRoutine {
  const factory DailyRoutine({
    required String id,
    required DateTime date,
    required List<RoutineItem> items,
    ConditionLevel? mood,
    ConditionLevel? energy,
    String? todayGoal,
    List<String>? schedules,
    List<String>? gratitudeItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DailyRoutine;

  factory DailyRoutine.fromJson(Map<String, dynamic> json) =>
      _$DailyRoutineFromJson(json);
}

/// 기본 아침 루틴 항목 (Backend API와 동일한 ID 사용)
class DefaultRoutineItems {
  static List<RoutineItem> get morningRoutines => [
        const RoutineItem(
          id: 'bedding_organized',
          emoji: '🛏️',
          title: '이불 정리',
          order: 0,
        ),
        const RoutineItem(
          id: 'water_intake',
          emoji: '💧',
          title: '공복에 물 마시기',
          order: 1,
        ),
        const RoutineItem(
          id: 'meditation',
          emoji: '📚',
          title: '명상, 독서',
          order: 2,
        ),
        const RoutineItem(
          id: 'stretching',
          emoji: '🤸',
          title: '한 동작 운동',
          order: 3,
        ),
        const RoutineItem(
          id: 'morning_tea',
          emoji: '☕',
          title: '아침 차 한 잔',
          order: 4,
        ),
        const RoutineItem(
          id: 'vitamins',
          emoji: '💊',
          title: '영양제 챙겨 먹기',
          order: 5,
        ),
        const RoutineItem(
          id: 'morning_walk',
          emoji: '🏃',
          title: '러닝 30분',
          order: 6,
        ),
        const RoutineItem(
          id: 'planning',
          emoji: '✏️',
          title: '아침 일기',
          order: 7,
        ),
      ];

  /// 기분 이모지 (5단계)
  static const List<String> moodEmojis = ['😢', '😐', '🙂', '😊', '😍'];

  /// 에너지 이모지 (5단계)
  static const List<String> energyEmojis = ['🪫', '🔋', '🔋🔋', '🔋🔋🔋', '⚡'];
}

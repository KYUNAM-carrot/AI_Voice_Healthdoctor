import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/routine_model.dart';

/// 오늘 날짜의 루틴 상태 Provider
final todayRoutineProvider =
    StateNotifierProvider<TodayRoutineNotifier, AsyncValue<DailyRoutine>>(
        (ref) {
  return TodayRoutineNotifier();
});

/// 루틴 완료율 Provider
final routineCompletionRateProvider = Provider<double>((ref) {
  final routineAsync = ref.watch(todayRoutineProvider);
  return routineAsync.maybeWhen(
    data: (routine) {
      if (routine.items.isEmpty) return 0.0;
      final completed = routine.items.where((item) => item.isCompleted).length;
      return completed / routine.items.length;
    },
    orElse: () => 0.0,
  );
});

/// 완료된 루틴 개수 Provider
final completedRoutineCountProvider = Provider<int>((ref) {
  final routineAsync = ref.watch(todayRoutineProvider);
  return routineAsync.maybeWhen(
    data: (routine) => routine.items.where((item) => item.isCompleted).length,
    orElse: () => 0,
  );
});

class TodayRoutineNotifier extends StateNotifier<AsyncValue<DailyRoutine>> {
  TodayRoutineNotifier() : super(const AsyncValue.loading()) {
    _loadTodayRoutine();
  }

  static const String _storageKey = 'daily_routine';

  /// 오늘 날짜 키 생성
  String _getTodayKey() {
    final now = DateTime.now();
    return '${_storageKey}_${now.year}_${now.month}_${now.day}';
  }

  /// 오늘 루틴 로드
  Future<void> _loadTodayRoutine() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = AsyncValue.data(DailyRoutine.fromJson(json));
      } else {
        // 새로운 날짜 - 기본 루틴 생성
        final newRoutine = DailyRoutine(
          id: key,
          date: DateTime.now(),
          items: DefaultRoutineItems.morningRoutines,
          createdAt: DateTime.now(),
        );
        state = AsyncValue.data(newRoutine);
        await _saveRoutine(newRoutine);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// 루틴 저장
  Future<void> _saveRoutine(DailyRoutine routine) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getTodayKey();
      final updatedRoutine = routine.copyWith(updatedAt: DateTime.now());
      await prefs.setString(key, jsonEncode(updatedRoutine.toJson()));
    } catch (e) {
      // 저장 실패 시 로그만 출력
      print('루틴 저장 실패: $e');
    }
  }

  /// 루틴 항목 완료 토글
  Future<void> toggleRoutineItem(String itemId) async {
    state.whenData((routine) async {
      final updatedItems = routine.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(isCompleted: !item.isCompleted);
        }
        return item;
      }).toList();

      final updatedRoutine = routine.copyWith(items: updatedItems);
      state = AsyncValue.data(updatedRoutine);
      await _saveRoutine(updatedRoutine);
    });
  }

  /// 기분 설정
  Future<void> setMood(int level) async {
    state.whenData((routine) async {
      final mood = ConditionLevel(type: ConditionType.mood, level: level);
      final updatedRoutine = routine.copyWith(mood: mood);
      state = AsyncValue.data(updatedRoutine);
      await _saveRoutine(updatedRoutine);
    });
  }

  /// 에너지 설정
  Future<void> setEnergy(int level) async {
    state.whenData((routine) async {
      final energy = ConditionLevel(type: ConditionType.energy, level: level);
      final updatedRoutine = routine.copyWith(energy: energy);
      state = AsyncValue.data(updatedRoutine);
      await _saveRoutine(updatedRoutine);
    });
  }

  /// 오늘의 목표 설정
  Future<void> setTodayGoal(String goal) async {
    state.whenData((routine) async {
      final updatedRoutine = routine.copyWith(todayGoal: goal);
      state = AsyncValue.data(updatedRoutine);
      await _saveRoutine(updatedRoutine);
    });
  }

  /// 일정 추가
  Future<void> addSchedule(String schedule) async {
    state.whenData((routine) async {
      final List<String> schedules = [...(routine.schedules ?? <String>[]), schedule];
      final updatedRoutine = routine.copyWith(schedules: schedules);
      state = AsyncValue.data(updatedRoutine);
      await _saveRoutine(updatedRoutine);
    });
  }

  /// 일정 삭제
  Future<void> removeSchedule(int index) async {
    state.whenData((routine) async {
      final List<String> schedules = [...(routine.schedules ?? <String>[])];
      if (index >= 0 && index < schedules.length) {
        schedules.removeAt(index);
        final updatedRoutine = routine.copyWith(schedules: schedules);
        state = AsyncValue.data(updatedRoutine);
        await _saveRoutine(updatedRoutine);
      }
    });
  }

  /// 일정 전체 설정 (기존 일정 대체)
  Future<void> setSchedules(List<String> schedules) async {
    state.whenData((routine) async {
      final updatedRoutine = routine.copyWith(schedules: schedules);
      state = AsyncValue.data(updatedRoutine);
      await _saveRoutine(updatedRoutine);
    });
  }

  /// 감사 항목 추가
  Future<void> addGratitudeItem(String item) async {
    state.whenData((routine) async {
      final List<String> items = [...(routine.gratitudeItems ?? <String>[]), item];
      if (items.length <= 3) {
        // 최대 3개
        final updatedRoutine = routine.copyWith(gratitudeItems: items);
        state = AsyncValue.data(updatedRoutine);
        await _saveRoutine(updatedRoutine);
      }
    });
  }

  /// 감사 항목 수정
  Future<void> updateGratitudeItem(int index, String item) async {
    state.whenData((routine) async {
      final List<String> items = [...(routine.gratitudeItems ?? <String>[])];
      if (index >= 0 && index < items.length) {
        items[index] = item;
        final updatedRoutine = routine.copyWith(gratitudeItems: items);
        state = AsyncValue.data(updatedRoutine);
        await _saveRoutine(updatedRoutine);
      }
    });
  }

  /// 루틴 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    await _loadTodayRoutine();
  }
}

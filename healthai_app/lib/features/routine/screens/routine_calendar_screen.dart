import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/routine_provider.dart';
import '../models/routine_model.dart';
import '../services/routine_api_service.dart';
import '../../auth/providers/auth_provider.dart';

/// 선택된 날짜 Provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 월별 루틴 데이터 캐시 Provider
final monthlyRoutineDataProvider = StateNotifierProvider<MonthlyRoutineDataNotifier, Map<DateTime, DailyRoutine?>>((ref) {
  return MonthlyRoutineDataNotifier(ref);
});

class MonthlyRoutineDataNotifier extends StateNotifier<Map<DateTime, DailyRoutine?>> {
  final Ref _ref;

  MonthlyRoutineDataNotifier(this._ref) : super({});

  Future<void> loadMonth(int year, int month) async {
    final apiService = _ref.read(routineApiServiceProvider);
    final authService = _ref.read(authServiceProvider);

    final token = await authService.getAccessToken();
    if (token == null) return;

    apiService.setAuthToken(token);

    // 해당 월의 모든 날짜에 대해 데이터 로드
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    for (var date = firstDay; date.isBefore(lastDay.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      final normalizedDate = DateTime(date.year, date.month, date.day);
      if (!state.containsKey(normalizedDate)) {
        final response = await apiService.getRoutineByDate(date);
        state = {...state, normalizedDate: response?.toDailyRoutine()};
      }
    }
  }

  void setRoutine(DateTime date, DailyRoutine? routine) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    state = {...state, normalizedDate: routine};
  }
}

/// 루틴 캘린더 화면
class RoutineCalendarScreen extends ConsumerStatefulWidget {
  const RoutineCalendarScreen({super.key});

  @override
  ConsumerState<RoutineCalendarScreen> createState() => _RoutineCalendarScreenState();
}

class _RoutineCalendarScreenState extends ConsumerState<RoutineCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentMonth();
    });
  }

  void _loadCurrentMonth() {
    ref.read(monthlyRoutineDataProvider.notifier).loadMonth(_focusedDay.year, _focusedDay.month);
  }

  @override
  Widget build(BuildContext context) {
    final monthlyData = ref.watch(monthlyRoutineDataProvider);
    final selectedRoutineAsync = ref.watch(routineByDateProvider(_selectedDay ?? DateTime.now()));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Transform.translate(
          offset: const Offset(-16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '루틴 기록 조회',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 캘린더
          Container(
            margin: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TableCalendar(
              locale: 'ko_KR',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                ref.read(selectedDateProvider.notifier).state = selectedDay;
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
                ref.read(monthlyRoutineDataProvider.notifier).loadMonth(focusedDay.year, focusedDay.month);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final normalizedDate = DateTime(date.year, date.month, date.day);
                  final routine = monthlyData[normalizedDate];
                  if (routine != null) {
                    final completedCount = routine.items.where((item) => item.isCompleted).length;
                    final completionRate = completedCount / routine.items.length;

                    return Positioned(
                      bottom: 1,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completionRate >= 0.8
                              ? AppTheme.success
                              : completionRate >= 0.5
                                  ? AppTheme.warning
                                  : AppTheme.primary.withOpacity(0.5),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
                weekendTextStyle: const TextStyle(color: Colors.red),
                outsideDaysVisible: false,
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextFormatter: (date, locale) =>
                    DateFormat.yMMMM(locale).format(date),
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // 선택된 날짜 정보
          Expanded(
            child: selectedRoutineAsync.when(
              data: (routine) => _buildRoutineDetail(routine),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _buildRoutineDetail(null),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineDetail(DailyRoutine? routine) {
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    final selectedDate = _selectedDay ?? DateTime.now();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더
          Text(
            dateFormat.format(selectedDate),
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          if (routine == null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Column(
                children: [
                  Icon(Icons.event_busy, size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    '이 날짜에 기록된 루틴이 없습니다',
                    style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
          ] else ...[
            // 루틴 완료율
            _buildCompletionCard(routine),
            const SizedBox(height: AppTheme.spaceMd),

            // 루틴 체크리스트
            _buildRoutineChecklist(routine),
            const SizedBox(height: AppTheme.spaceMd),

            // 컨디션
            if (routine.mood != null || routine.energy != null)
              _buildConditionCard(routine),
            const SizedBox(height: AppTheme.spaceMd),

            // 오늘의 목표
            if (routine.todayGoal != null && routine.todayGoal!.isNotEmpty)
              _buildGoalCard(routine),
            const SizedBox(height: AppTheme.spaceMd),

            // 일정
            if (routine.schedules != null && routine.schedules!.isNotEmpty)
              _buildScheduleCard(routine),
            const SizedBox(height: AppTheme.spaceMd),

            // 감사일기
            if (routine.gratitudeItems != null && routine.gratitudeItems!.isNotEmpty)
              _buildGratitudeCard(routine),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletionCard(DailyRoutine routine) {
    final completedCount = routine.items.where((item) => item.isCompleted).length;
    final totalCount = routine.items.length;
    final completionRate = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primary.withOpacity(0.1),
            AppTheme.secondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          // 원형 진행률
          SizedBox(
            width: 60,
            height: 60,
            child: Stack(
              children: [
                CircularProgressIndicator(
                  value: completionRate,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    completionRate >= 0.8
                        ? AppTheme.success
                        : completionRate >= 0.5
                            ? AppTheme.warning
                            : AppTheme.primary,
                  ),
                ),
                Center(
                  child: Text(
                    '${(completionRate * 100).toInt()}%',
                    style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '루틴 달성률',
                  style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
                ),
                Text(
                  '$completedCount / $totalCount 완료',
                  style: AppTheme.h3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutineChecklist(DailyRoutine routine) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Row(
              children: [
                const Text('checklist', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Text('루틴 체크리스트', style: AppTheme.subtitle),
              ],
            ),
          ),
          const Divider(height: 1),
          ...routine.items.map((item) => ListTile(
                leading: Icon(
                  item.isCompleted ? Icons.check_circle : Icons.circle_outlined,
                  color: item.isCompleted ? AppTheme.success : Colors.grey.shade400,
                ),
                title: Text(
                  '${item.emoji} ${item.title}',
                  style: TextStyle(
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary,
                  ),
                ),
                dense: true,
              )),
        ],
      ),
    );
  }

  Widget _buildConditionCard(DailyRoutine routine) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('heart', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('컨디션', style: AppTheme.subtitle),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              if (routine.mood != null)
                Expanded(
                  child: _buildConditionItem('기분', routine.mood!.level, Icons.mood),
                ),
              if (routine.energy != null)
                Expanded(
                  child: _buildConditionItem('에너지', routine.energy!.level, Icons.bolt),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConditionItem(String label, int level, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(label, style: AppTheme.caption),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Icon(
              Icons.star,
              size: 16,
              color: index < level ? Colors.amber : Colors.grey.shade300,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGoalCard(DailyRoutine routine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('target', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('오늘의 목표', style: AppTheme.subtitle),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(routine.todayGoal!, style: AppTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(DailyRoutine routine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('calendar', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('오늘의 일정', style: AppTheme.subtitle),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ...routine.schedules!.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: AppTheme.caption.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(entry.value, style: AppTheme.bodyMedium),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGratitudeCard(DailyRoutine routine) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('pray', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              const Text('감사일기', style: AppTheme.subtitle),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ...routine.gratitudeItems!.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${entry.key + 1}. ',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: Text(entry.value, style: AppTheme.bodyMedium),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

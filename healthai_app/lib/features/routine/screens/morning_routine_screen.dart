import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../models/routine_model.dart';
import '../providers/routine_provider.dart';
import '../widgets/condition_selector.dart';
import '../widgets/routine_progress_bar.dart';

/// 아침 루틴 체크 화면 (F-ROUTINE-001)
class MorningRoutineScreen extends ConsumerStatefulWidget {
  const MorningRoutineScreen({super.key});

  @override
  ConsumerState<MorningRoutineScreen> createState() =>
      _MorningRoutineScreenState();
}

class _MorningRoutineScreenState extends ConsumerState<MorningRoutineScreen> {
  final TextEditingController _goalController = TextEditingController();
  final List<TextEditingController> _scheduleControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    _goalController.dispose();
    for (final controller in _scheduleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final routineAsync = ref.watch(todayRoutineProvider);
    final completionRate = ref.watch(routineCompletionRateProvider);
    final completedCount = ref.watch(completedRoutineCountProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('오늘의 아침 건강루틴'),
        centerTitle: false,
      ),
      resizeToAvoidBottomInset: true,
      body: routineAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: AppTheme.spaceMd),
              Text('오류가 발생했습니다: $error'),
              const SizedBox(height: AppTheme.spaceMd),
              ElevatedButton(
                onPressed: () => ref.read(todayRoutineProvider.notifier).refresh(),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (routine) {
          // 컨트롤러 초기화
          if (routine.todayGoal != null && _goalController.text.isEmpty) {
            _goalController.text = routine.todayGoal!;
          }
          if (routine.schedules != null) {
            for (int i = 0; i < routine.schedules!.length && i < 3; i++) {
              if (_scheduleControllers[i].text.isEmpty) {
                _scheduleControllers[i].text = routine.schedules![i];
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 날짜 표시
                _buildDateSection(),
                const SizedBox(height: AppTheme.spaceLg),

                // 진행률 표시
                RoutineProgressBar(
                  completionRate: completionRate,
                  completedCount: completedCount,
                  totalCount: routine.items.length,
                ),
                const SizedBox(height: AppTheme.spaceXl),

                // 루틴 체크리스트
                _buildRoutineCheckList(routine),
                const SizedBox(height: AppTheme.spaceXl),

                const Divider(height: 1),
                const SizedBox(height: AppTheme.spaceXl),

                // 오늘의 컨디션
                _buildConditionSection(routine),
                const SizedBox(height: AppTheme.spaceXl),

                const Divider(height: 1),
                const SizedBox(height: AppTheme.spaceXl),

                // 오늘의 목표
                _buildGoalSection(routine),
                const SizedBox(height: AppTheme.spaceXl),

                // 오늘 주요일정 3가지
                _buildScheduleSection(routine),
                const SizedBox(height: AppTheme.spaceXl),

                // 감사일기 바로가기 버튼
                _buildGratitudeDiaryButton(),
                const SizedBox(height: AppTheme.spaceXl),

                // 저장하기 버튼
                ElevatedButton(
                  onPressed: _saveRoutine,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                  ),
                  child: const Text('저장하기'),
                ),
                const SizedBox(height: AppTheme.space2xl),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 날짜 섹션
  Widget _buildDateSection() {
    final now = DateTime.now();
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');
    final weather = _getWeatherEmoji(now.hour);

    return Text(
      '${dateFormat.format(now)} $weather',
      style: AppTheme.bodyMedium.copyWith(
        color: AppTheme.textSecondary,
      ),
    );
  }

  String _getWeatherEmoji(int hour) {
    if (hour >= 6 && hour < 12) return '☀️';
    if (hour >= 12 && hour < 18) return '🌤️';
    if (hour >= 18 && hour < 21) return '🌅';
    return '🌙';
  }

  /// 루틴 체크리스트
  Widget _buildRoutineCheckList(DailyRoutine routine) {
    return Column(
      children: routine.items.map((item) {
        return _RoutineCheckItem(
          item: item,
          onToggle: () {
            ref.read(todayRoutineProvider.notifier).toggleRoutineItem(item.id);
          },
        );
      }).toList(),
    );
  }

  /// 컨디션 섹션 (기분만 표시)
  Widget _buildConditionSection(DailyRoutine routine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('😊', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text('오늘의 컨디션 체크', style: AppTheme.h3),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),

        // 기분 선택 - 이모지 5개 가로 배열
        Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final isSelected = routine.mood?.level == index;
              return GestureDetector(
                onTap: () {
                  ref.read(todayRoutineProvider.notifier).setMood(index);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    DefaultRoutineItems.moodEmojis[index],
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  /// 목표 섹션 (반드시 이룰 목표 1가지)
  Widget _buildGoalSection(DailyRoutine routine) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text('오늘 반드시 이룰 목표 1가지', style: AppTheme.h3),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        TextField(
          controller: _goalController,
          decoration: InputDecoration(
            hintText: '예: 30분 운동하기',
            hintStyle: AppTheme.bodyMedium.copyWith(
              color: Colors.grey.shade400,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceSm,
            ),
          ),
          maxLines: 1,
          style: AppTheme.bodyMedium,
        ),
      ],
    );
  }

  /// 일정 섹션 (오늘 주요일정 3가지)
  Widget _buildScheduleSection(DailyRoutine routine) {
    final hintTexts = [
      '예: 오전 10시 팀 회의',
      '예: 오후 2시 보고서 제출',
      '예: 저녁 7시 가족 저녁식사',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('📅', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text('오늘 주요일정 3가지', style: AppTheme.h3),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Container(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              for (int i = 0; i < 3; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i < 2 ? AppTheme.spaceMd : 0,
                  ),
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
                            '${i + 1}',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: TextField(
                          controller: _scheduleControllers[i],
                          decoration: InputDecoration(
                            hintText: hintTexts[i],
                            hintStyle: AppTheme.bodySmall.copyWith(
                              color: Colors.grey.shade400,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(left: 8),
                          ),
                          style: AppTheme.bodySmall,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 감사일기 바로가기 버튼
  Widget _buildGratitudeDiaryButton() {
    return InkWell(
      onTap: () => context.push('/gratitude'),
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: AppTheme.primary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Text('🙏', style: TextStyle(fontSize: 24)),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('감사일기 작성하기', style: AppTheme.h3),
                  const SizedBox(height: 2),
                  Text(
                    '오늘 감사한 일을 기록해보세요',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  /// 루틴 저장
  void _saveRoutine() {
    // 목표 저장
    if (_goalController.text.isNotEmpty) {
      ref.read(todayRoutineProvider.notifier).setTodayGoal(_goalController.text);
    }

    // 일정 저장
    final schedules = <String>[];
    for (final controller in _scheduleControllers) {
      if (controller.text.isNotEmpty) {
        schedules.add(controller.text);
      }
    }
    // Provider에 일정 저장 (기존 일정 교체)
    ref.read(todayRoutineProvider.notifier).setSchedules(schedules);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('저장되었습니다'),
        duration: Duration(seconds: 1),
      ),
    );

    // 홈화면으로 이동
    context.go('/home');
  }
}

/// 루틴 체크 아이템 위젯
class _RoutineCheckItem extends StatelessWidget {
  final RoutineItem item;
  final VoidCallback onToggle;

  const _RoutineCheckItem({
    required this.item,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        child: Row(
          children: [
            // 체크박스
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: item.isCompleted
                    ? AppTheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: item.isCompleted
                      ? AppTheme.primary
                      : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: item.isCompleted
                  ? const Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: AppTheme.spaceMd),

            // 이모지
            Text(
              item.emoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: AppTheme.spaceSm),

            // 제목
            Expanded(
              child: Text(
                item.title,
                style: AppTheme.bodyMedium.copyWith(
                  decoration: item.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: item.isCompleted
                      ? AppTheme.textTertiary
                      : AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/routine_provider.dart';

/// 감사일기 상태 관리 Provider
final gratitudeItemsProvider = StateNotifierProvider<GratitudeItemsNotifier, List<String>>((ref) {
  return GratitudeItemsNotifier();
});

/// 일정 완료 상태 Provider (인덱스별 체크 여부)
final scheduleCompletionProvider = StateNotifierProvider<ScheduleCompletionNotifier, List<bool>>((ref) {
  return ScheduleCompletionNotifier();
});

/// 목표 완료 상태 Provider
final goalCompletionProvider = StateProvider<bool>((ref) => false);

class GratitudeItemsNotifier extends StateNotifier<List<String>> {
  GratitudeItemsNotifier() : super(['', '', '']); // 기본 3개 항목

  void updateItem(int index, String value) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index) value else state[i],
    ];
  }

  void addItem() {
    state = [...state, ''];
  }

  void removeItem(int index) {
    if (state.length > 3) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i != index) state[i],
      ];
    }
  }

  void loadItems(List<String> items) {
    if (items.isEmpty) {
      state = ['', '', ''];
    } else if (items.length < 3) {
      state = [...items, ...List.filled(3 - items.length, '')];
    } else {
      state = items;
    }
  }
}

class ScheduleCompletionNotifier extends StateNotifier<List<bool>> {
  ScheduleCompletionNotifier() : super([false, false, false]);

  void toggle(int index) {
    if (index >= 0 && index < state.length) {
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == index) !state[i] else state[i],
      ];
    }
  }

  void reset(int count) {
    state = List.filled(count, false);
  }
}

/// 감사일기 화면
class GratitudeDiaryScreen extends ConsumerStatefulWidget {
  const GratitudeDiaryScreen({super.key});

  @override
  ConsumerState<GratitudeDiaryScreen> createState() => _GratitudeDiaryScreenState();
}

class _GratitudeDiaryScreenState extends ConsumerState<GratitudeDiaryScreen> {
  final List<TextEditingController> _controllers = [];
  final FocusNode _lastFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    // 일정 완료 상태 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScheduleCompletion();
    });
  }

  void _initializeScheduleCompletion() {
    final routineAsync = ref.read(todayRoutineProvider);
    routineAsync.whenData((routine) {
      final scheduleCount = routine.schedules?.length ?? 0;
      if (scheduleCount > 0) {
        ref.read(scheduleCompletionProvider.notifier).reset(scheduleCount);
      }
    });
  }

  void _initializeControllers() {
    final items = ref.read(gratitudeItemsProvider);
    _controllers.clear();
    for (final item in items) {
      _controllers.add(TextEditingController(text: item));
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    _lastFocusNode.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final items = ref.read(gratitudeItemsProvider);

    // 컨트롤러 수 조정
    while (_controllers.length < items.length) {
      _controllers.add(TextEditingController());
    }
    while (_controllers.length > items.length) {
      _controllers.removeLast().dispose();
    }

    // 값 동기화
    for (int i = 0; i < items.length; i++) {
      if (_controllers[i].text != items[i]) {
        _controllers[i].text = items[i];
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(gratitudeItemsProvider);
    final routineAsync = ref.watch(todayRoutineProvider);
    final scheduleCompletion = ref.watch(scheduleCompletionProvider);

    // 컨트롤러 동기화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncControllers();
    });

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
                  Icons.auto_stories,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '감사일기 작성 및 실행체크',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 날짜 표시
            _buildDateSection(),
            const SizedBox(height: AppTheme.spaceLg),

            // 안내 문구
            Container(
              padding: const EdgeInsets.all(AppTheme.spaceMd),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: Row(
                children: [
                  const Text('🙏', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppTheme.spaceMd),
                  Expanded(
                    child: Text(
                      '오늘 하루 감사한 일을 기록해보세요.\n작은 것에도 감사하는 마음이 행복을 가져옵니다.',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceXl),

            // 오늘 반드시 이룰 목표 실행 체크 섹션
            routineAsync.when(
              data: (routine) {
                final goal = routine.todayGoal;
                if (goal == null || goal.isEmpty) {
                  return const SizedBox.shrink();
                }
                return _buildGoalCheckSection(goal);
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 오늘 일정 실행 체크 섹션
            routineAsync.when(
              data: (routine) {
                final schedules = routine.schedules ?? [];
                if (schedules.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        const Text('오늘 일정 실행 체크', style: AppTheme.h3),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          for (int i = 0; i < schedules.length; i++)
                            _buildScheduleCheckItem(
                              i,
                              schedules[i],
                              i < scheduleCompletion.length ? scheduleCompletion[i] : false,
                              schedules.length,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceXl),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            // 감사 항목 섹션
            Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                const Text('오늘 감사한 일', style: AppTheme.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spaceSm),

            // 감사 항목 리스트
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < items.length; i++)
                    _buildGratitudeItem(i, items.length),
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spaceMd),

            // 항목 추가 버튼
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ref.read(gratitudeItemsProvider.notifier).addItem();
                },
                icon: const Icon(Icons.add_circle_outline, size: 20),
                label: const Text('항목 추가'),
              ),
            ),
            const SizedBox(height: AppTheme.space2xl),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          child: ElevatedButton(
            onPressed: _saveGratitude,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text('저장하기'),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final now = DateTime.now();
    final dateFormat = DateFormat('M월 d일 EEEE', 'ko_KR');

    return Text(
      '${dateFormat.format(now)} 감사일기',
      style: AppTheme.h3,
    );
  }

  /// 오늘 반드시 이룰 목표 체크 섹션
  Widget _buildGoalCheckSection(String goal) {
    final isCompleted = ref.watch(goalCompletionProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🎯', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            const Text('오늘 반드시 이룰 목표', style: AppTheme.h3),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        InkWell(
          onTap: () {
            ref.read(goalCompletionProvider.notifier).state = !isCompleted;
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppTheme.success.withOpacity(0.1)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: isCompleted
                    ? AppTheme.success
                    : Colors.grey.shade200,
                width: isCompleted ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 체크박스
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCompleted ? AppTheme.success : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 18, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppTheme.spaceMd),
                // 목표 텍스트
                Expanded(
                  child: Text(
                    goal,
                    style: AppTheme.bodyMedium.copyWith(
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // 완료 상태 표시
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.celebration, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          '달성!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXl),
      ],
    );
  }

  Widget _buildScheduleCheckItem(int index, String schedule, bool isCompleted, int totalCount) {
    return Column(
      children: [
        InkWell(
          onTap: () {
            ref.read(scheduleCompletionProvider.notifier).toggle(index);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceMd,
              vertical: AppTheme.spaceMd,
            ),
            child: Row(
              children: [
                // 체크박스
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted ? AppTheme.success : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isCompleted ? AppTheme.success : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppTheme.spaceMd),
                // 일정 텍스트
                Expanded(
                  child: Text(
                    schedule,
                    style: AppTheme.bodyMedium.copyWith(
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? AppTheme.textTertiary : AppTheme.textPrimary,
                    ),
                  ),
                ),
                // 완료 상태 표시
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '완료',
                      style: AppTheme.caption.copyWith(
                        color: AppTheme.success,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (index < totalCount - 1)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  Widget _buildGratitudeItem(int index, int totalCount) {
    // 컨트롤러가 아직 생성되지 않은 경우 대비
    while (_controllers.length <= index) {
      _controllers.add(TextEditingController());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceMd,
            vertical: AppTheme.spaceSm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
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
                  controller: _controllers[index],
                  decoration: InputDecoration(
                    hintText: '감사한 일을 적어보세요',
                    hintStyle: AppTheme.bodySmall.copyWith(
                      color: Colors.grey.shade400,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
                  ),
                  style: AppTheme.bodyMedium,
                  maxLines: 2,
                  onChanged: (value) {
                    ref.read(gratitudeItemsProvider.notifier).updateItem(index, value);
                  },
                ),
              ),
              // 3개 초과 시 삭제 버튼 표시
              if (totalCount > 3)
                IconButton(
                  icon: Icon(Icons.remove_circle_outline,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () {
                    ref.read(gratitudeItemsProvider.notifier).removeItem(index);
                  },
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
        if (index < totalCount - 1)
          Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }

  void _saveGratitude() {
    // 모든 컨트롤러의 값을 Provider에 저장
    for (int i = 0; i < _controllers.length; i++) {
      ref.read(gratitudeItemsProvider.notifier).updateItem(i, _controllers[i].text);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('감사일기가 저장되었습니다'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/routine_provider.dart';
import '../services/routine_api_service.dart';

/// 통계 기간 타입
enum StatsPeriod { weekly, monthly }

/// 선택된 통계 기간 Provider
final statsPeriodProvider = StateProvider<StatsPeriod>((ref) => StatsPeriod.weekly);

/// 선택된 월 Provider (월간 통계용)
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

/// 루틴 통계 화면
class RoutineStatsScreen extends ConsumerStatefulWidget {
  const RoutineStatsScreen({super.key});

  @override
  ConsumerState<RoutineStatsScreen> createState() => _RoutineStatsScreenState();
}

class _RoutineStatsScreenState extends ConsumerState<RoutineStatsScreen> {
  @override
  Widget build(BuildContext context) {
    final period = ref.watch(statsPeriodProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

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
                  Icons.bar_chart,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                '루틴 통계',
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
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기간 선택 탭
            _buildPeriodSelector(period),
            const SizedBox(height: AppTheme.spaceMd),

            // 월 선택 (월간 모드일 때만)
            if (period == StatsPeriod.monthly) ...[
              _buildMonthSelector(selectedMonth),
              const SizedBox(height: AppTheme.spaceMd),
            ],

            // 통계 내용
            if (period == StatsPeriod.weekly)
              _buildWeeklyStats()
            else
              _buildMonthlyStats(selectedMonth),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(StatsPeriod currentPeriod) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(statsPeriodProvider.notifier).state = StatsPeriod.weekly,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: currentPeriod == StatsPeriod.weekly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '주간 통계',
                    style: TextStyle(
                      fontWeight: currentPeriod == StatsPeriod.weekly ? FontWeight.bold : FontWeight.normal,
                      color: currentPeriod == StatsPeriod.weekly ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => ref.read(statsPeriodProvider.notifier).state = StatsPeriod.monthly,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: currentPeriod == StatsPeriod.monthly ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Center(
                  child: Text(
                    '월간 통계',
                    style: TextStyle(
                      fontWeight: currentPeriod == StatsPeriod.monthly ? FontWeight.bold : FontWeight.normal,
                      color: currentPeriod == StatsPeriod.monthly ? AppTheme.primary : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(DateTime selectedMonth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            ref.read(selectedMonthProvider.notifier).state = DateTime(
              selectedMonth.year,
              selectedMonth.month - 1,
            );
          },
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          DateFormat('yyyy년 M월').format(selectedMonth),
          style: AppTheme.h3,
        ),
        IconButton(
          onPressed: () {
            final newMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
            if (newMonth.isBefore(DateTime.now().add(const Duration(days: 31)))) {
              ref.read(selectedMonthProvider.notifier).state = newMonth;
            }
          },
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildWeeklyStats() {
    final statsAsync = ref.watch(weeklyStatsProvider);

    return statsAsync.when(
      data: (stats) {
        if (stats == null) {
          return _buildNoDataWidget();
        }
        return _buildStatsContent(stats, '최근 7일');
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorWidget(e.toString()),
    );
  }

  Widget _buildMonthlyStats(DateTime selectedMonth) {
    final statsAsync = ref.watch(
      monthlyStatsProvider((year: selectedMonth.year, month: selectedMonth.month)),
    );

    return statsAsync.when(
      data: (stats) {
        if (stats == null) {
          return _buildNoDataWidget();
        }
        return _buildStatsContent(stats, DateFormat('yyyy년 M월').format(selectedMonth));
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => _buildErrorWidget(e.toString()),
    );
  }

  Widget _buildStatsContent(RoutineStatsResponse stats, String periodLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 기간 정보
        Text(
          periodLabel,
          style: AppTheme.h3,
        ),
        const SizedBox(height: AppTheme.spaceMd),

        // 요약 카드들
        Row(
          children: [
            Expanded(child: _buildSummaryCard('기록 일수', '${stats.checkedDays}/${stats.totalDays}일', Icons.calendar_today)),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(child: _buildSummaryCard('평균 달성률', '${(stats.averageCompletionRate * 100).toInt()}%', Icons.trending_up)),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                '평균 기분',
                stats.averageMood != null ? '${stats.averageMood!.toStringAsFixed(1)}/5' : '-',
                Icons.mood,
              ),
            ),
            const SizedBox(width: AppTheme.spaceSm),
            Expanded(
              child: _buildSummaryCard(
                '평균 에너지',
                stats.averageEnergy != null ? '${stats.averageEnergy!.toStringAsFixed(1)}/5' : '-',
                Icons.bolt,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXl),

        // 루틴별 완료 횟수 차트
        _buildRoutineBarChart(stats),
        const SizedBox(height: AppTheme.spaceXl),

        // 루틴별 상세 목록
        _buildRoutineDetailList(stats),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primary, size: 24),
          const SizedBox(height: AppTheme.spaceSm),
          Text(label, style: AppTheme.caption.copyWith(color: AppTheme.textSecondary)),
          const SizedBox(height: 4),
          Text(value, style: AppTheme.h3),
        ],
      ),
    );
  }

  Widget _buildRoutineBarChart(RoutineStatsResponse stats) {
    final routineLabels = {
      'bedding_organized': '이불정리',
      'water_intake': '물마시기',
      'meditation': '명상/독서',
      'stretching': '운동',
      'morning_tea': '차한잔',
      'vitamins': '영양제',
      'morning_walk': '러닝',
      'planning': '일기',
    };

    final entries = stats.routineCounts.entries.toList();
    final maxCount = entries.isEmpty ? 1 : entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('루틴별 완료 현황', style: AppTheme.subtitle),
          const SizedBox(height: AppTheme.spaceMd),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: (maxCount + 1).toDouble(),
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.grey.shade800,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final key = entries[groupIndex].key;
                      final label = routineLabels[key] ?? key;
                      return BarTooltipItem(
                        '$label\n${rod.toY.toInt()}회',
                        const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < entries.length) {
                          final key = entries[index].key;
                          final emoji = _getRoutineEmoji(key);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(emoji, style: const TextStyle(fontSize: 14)),
                          );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value == value.toInt().toDouble()) {
                          return Text(
                            value.toInt().toString(),
                            style: AppTheme.caption,
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: entries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final count = entry.value.value;
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: _getBarColor(count, stats.totalDays),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.shade200,
                      strokeWidth: 1,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoutineEmoji(String key) {
    switch (key) {
      case 'bedding_organized':
        return 'bed';
      case 'water_intake':
        return 'droplet';
      case 'meditation':
        return 'book';
      case 'stretching':
        return 'person_cartwheeling';
      case 'morning_tea':
        return 'coffee';
      case 'vitamins':
        return 'pill';
      case 'morning_walk':
        return 'person_running';
      case 'planning':
        return 'pencil';
      default:
        return 'check';
    }
  }

  Color _getBarColor(int count, int totalDays) {
    final rate = count / totalDays;
    if (rate >= 0.8) return AppTheme.success;
    if (rate >= 0.5) return AppTheme.warning;
    return AppTheme.primary;
  }

  Widget _buildRoutineDetailList(RoutineStatsResponse stats) {
    final routineInfo = [
      {'key': 'bedding_organized', 'label': '이불 정리', 'emoji': 'bed'},
      {'key': 'water_intake', 'label': '공복에 물 마시기', 'emoji': 'droplet'},
      {'key': 'meditation', 'label': '명상, 독서', 'emoji': 'book'},
      {'key': 'stretching', 'label': '한 동작 운동', 'emoji': 'person_cartwheeling'},
      {'key': 'morning_tea', 'label': '아침 차 한 잔', 'emoji': 'coffee'},
      {'key': 'vitamins', 'label': '영양제 챙겨 먹기', 'emoji': 'pill'},
      {'key': 'morning_walk', 'label': '러닝 30분', 'emoji': 'person_running'},
      {'key': 'planning', 'label': '아침 일기', 'emoji': 'pencil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(AppTheme.spaceMd),
            child: Text('루틴별 상세', style: AppTheme.subtitle),
          ),
          const Divider(height: 1),
          ...routineInfo.map((info) {
            final count = stats.routineCounts[info['key']] ?? 0;
            final rate = count / stats.totalDays;

            return ListTile(
              leading: Text(info['emoji'] as String, style: const TextStyle(fontSize: 20)),
              title: Text(info['label'] as String),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count회',
                    style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: rate >= 0.8
                          ? AppTheme.success.withOpacity(0.1)
                          : rate >= 0.5
                              ? AppTheme.warning.withOpacity(0.1)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${(rate * 100).toInt()}%',
                      style: AppTheme.caption.copyWith(
                        color: rate >= 0.8
                            ? AppTheme.success
                            : rate >= 0.5
                                ? AppTheme.warning
                                : AppTheme.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.space2xl),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(Icons.insert_chart_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            '아직 기록된 데이터가 없습니다',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textTertiary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '루틴을 기록하면 통계를 확인할 수 있어요',
            style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.space2xl),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: AppTheme.spaceMd),
          Text(
            '데이터를 불러오는 중 오류가 발생했습니다',
            style: AppTheme.bodyMedium.copyWith(color: Colors.red.shade700),
          ),
        ],
      ),
    );
  }
}

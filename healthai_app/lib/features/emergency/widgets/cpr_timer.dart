import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/emergency_provider.dart';
import '../constants/emergency_scripts.dart';

/// CPR 2분 타이머 위젯
class CprTimerWidget extends ConsumerWidget {
  final Function(String)? onPrompt;

  const CprTimerWidget({
    super.key,
    this.onPrompt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(cprTimerProvider);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: timerState.isRunning
              ? const Color(0xFFFF4444)
              : Colors.grey[700]!,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 타이머 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: timerState.isRunning
                        ? const Color(0xFFFF4444)
                        : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'CPR 타이머',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: timerState.isRunning ? Colors.white : Colors.grey,
                    ),
                  ),
                ],
              ),
              // 사이클 카운트 + 10초 프롬프트 표시
              Row(
                children: [
                  if (timerState.isRunning)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '10초마다 안내',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: 6),
                  if (timerState.cycleCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '사이클 ${timerState.cycleCount + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF4444),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 원형 진행률 표시
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 배경 원
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[800],
                    color: Colors.grey[800],
                  ),
                ),
                // 진행률 원
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: timerState.progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.transparent,
                    color: _getProgressColor(timerState.progress),
                  ),
                ),
                // 시간 표시
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timerState.elapsedTimeFormatted,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Text(
                      '/ 02:00',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 컨트롤 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!timerState.isRunning && timerState.elapsedSeconds == 0)
                _buildControlButton(
                  context,
                  ref,
                  icon: Icons.play_arrow,
                  label: '시작',
                  color: const Color(0xFFFF4444),
                  onTap: () {
                    ref.read(cprTimerProvider.notifier).start(
                      onPrompt: onPrompt,
                    );
                  },
                )
              else if (timerState.isRunning)
                _buildControlButton(
                  context,
                  ref,
                  icon: Icons.pause,
                  label: '일시정지',
                  color: Colors.orange,
                  onTap: () {
                    ref.read(cprTimerProvider.notifier).pause();
                  },
                )
              else
                Row(
                  children: [
                    _buildControlButton(
                      context,
                      ref,
                      icon: Icons.play_arrow,
                      label: '재개',
                      color: const Color(0xFFFF4444),
                      onTap: () {
                        ref.read(cprTimerProvider.notifier).resume(
                          onPrompt: onPrompt,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildControlButton(
                      context,
                      ref,
                      icon: Icons.stop,
                      label: '종료',
                      color: Colors.grey,
                      onTap: () {
                        ref.read(cprTimerProvider.notifier).stop();
                      },
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.5) {
      return const Color(0xFF4CAF50); // 녹색
    } else if (progress < 0.75) {
      return Colors.orange; // 주황색
    } else {
      return const Color(0xFFFF4444); // 빨간색
    }
  }
}

/// 간단한 CPR 타이머 표시 (소형)
class CprTimerCompact extends ConsumerWidget {
  const CprTimerCompact({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(cprTimerProvider);

    if (!timerState.isRunning && timerState.elapsedSeconds == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4444).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFF4444),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            timerState.isRunning ? Icons.timer : Icons.pause,
            color: const Color(0xFFFF4444),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            timerState.elapsedTimeFormatted,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const Text(
            ' / 02:00',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

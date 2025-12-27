import 'package:flutter/material.dart';
import '../models/emergency_model.dart';

/// 응급 시나리오 선택 위젯
class ScenarioSelector extends StatelessWidget {
  final Function(EmergencyScenario) onScenarioSelected;
  final VoidCallback? onMedicalArrival; // 유지하되 초기 선택에서는 표시 안 함

  const ScenarioSelector({
    super.key,
    required this.onScenarioSelected,
    this.onMedicalArrival,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(
            '상황을 선택하세요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...EmergencyScenario.values.map((scenario) {
              return _ScenarioButton(
                scenario: scenario,
                onTap: () => onScenarioSelected(scenario),
              );
            }),
            // 의료진 도착 버튼은 시나리오 선택 후에만 표시 (여기서 제거)
          ],
        ),
      ],
    );
  }
}

/// 개별 시나리오 버튼 (컴팩트 버전)
class _ScenarioButton extends StatelessWidget {
  final EmergencyScenario scenario;
  final VoidCallback onTap;

  const _ScenarioButton({
    required this.scenario,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    // 3열 레이아웃을 위한 너비 계산 (패딩 16*2 + spacing 8*2 고려)
    final buttonWidth = (screenWidth - 32 - 16) / 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: buttonWidth,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: _getScenarioColor(scenario).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getScenarioColor(scenario),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getScenarioIcon(scenario),
                size: 32,
                color: _getScenarioColor(scenario),
              ),
              const SizedBox(height: 6),
              Text(
                scenario.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getScenarioColor(scenario),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getScenarioIcon(EmergencyScenario scenario) {
    switch (scenario) {
      case EmergencyScenario.cardiacArrest:
        return Icons.favorite_border; // 심장
      case EmergencyScenario.airwayObstruction:
        return Icons.air; // 기도
      case EmergencyScenario.majorBleeding:
        return Icons.water_drop; // 출혈
      case EmergencyScenario.seizure:
        return Icons.electric_bolt; // 경련
      case EmergencyScenario.unconscious:
        return Icons.hotel; // 쓰러진 사람
    }
  }

  Color _getScenarioColor(EmergencyScenario scenario) {
    switch (scenario) {
      case EmergencyScenario.cardiacArrest:
        return const Color(0xFFFF4444); // 빨간색
      case EmergencyScenario.airwayObstruction:
        return const Color(0xFFFF8C00); // 주황색
      case EmergencyScenario.majorBleeding:
        return const Color(0xFFDC143C); // 크림슨
      case EmergencyScenario.seizure:
        return const Color(0xFFFFD700); // 황금색
      case EmergencyScenario.unconscious:
        return const Color(0xFF87CEEB); // 하늘색
    }
  }
}

/// 선택된 시나리오 표시 칩 (컴팩트)
class SelectedScenarioChip extends StatelessWidget {
  final EmergencyScenario scenario;
  final VoidCallback? onReset;

  const SelectedScenarioChip({
    super.key,
    required this.scenario,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF4444).withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFF4444),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFFF4444),
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            scenario.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (onReset != null) ...[
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onReset,
              child: const Icon(
                Icons.close,
                color: Colors.white54,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 의료진 도착 확인 버튼
class _MedicalArrivalButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MedicalArrivalButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = (screenWidth - 32 - 16) / 3;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: buttonWidth,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF4CAF50),
              width: 2,
            ),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.medical_services,
                size: 32,
                color: Color(0xFF4CAF50),
              ),
              SizedBox(height: 6),
              Text(
                '의료진\n도착',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4CAF50),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 의료진 도착 확인 버튼 (시나리오 선택 후 표시용)
class MedicalArrivalChip extends StatelessWidget {
  final VoidCallback onTap;

  const MedicalArrivalChip({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4CAF50),
            width: 1,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.medical_services,
              color: Color(0xFF4CAF50),
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              '의료진 도착',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4CAF50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

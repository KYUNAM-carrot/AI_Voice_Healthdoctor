import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 컨디션 선택 위젯 (기분/에너지)
class ConditionSelector extends StatelessWidget {
  final List<String> emojis;
  final int? selectedLevel;
  final ValueChanged<int> onSelect;

  const ConditionSelector({
    super.key,
    required this.emojis,
    required this.selectedLevel,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(emojis.length, (index) {
        final level = index + 1; // 1-5
        final isSelected = selectedLevel == level;

        return GestureDetector(
          onTap: () => onSelect(level),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: isSelected
                  ? Border.all(color: AppTheme.primary, width: 2)
                  : null,
            ),
            child: Text(
              emojis[index],
              style: TextStyle(
                fontSize: 20,
                color: isSelected ? null : Colors.grey.shade400,
              ),
            ),
          ),
        );
      }),
    );
  }
}

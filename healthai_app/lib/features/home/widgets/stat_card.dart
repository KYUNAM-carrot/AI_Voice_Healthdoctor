import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// 통계 카드 위젯 (UI/UX 가이드 기반)
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final String? changeText;
  final bool isPositive;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    this.iconColor,
    this.changeText,
    this.isPositive = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 아이콘 + 제목
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: iconColor ?? AppTheme.textTertiary,
                ),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),

            // 큰 값
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),

            // 변화량 또는 부제목
            if (changeText != null)
              Text(
                changeText!,
                style: TextStyle(
                  fontSize: 12,
                  color: isPositive ? AppTheme.success : AppTheme.error,
                  fontWeight: FontWeight.w500,
                ),
              )
            else if (subtitle != null)
              Text(
                subtitle!,
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

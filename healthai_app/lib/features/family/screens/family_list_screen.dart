import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/family_provider.dart';

class FamilyListScreen extends ConsumerWidget {
  const FamilyListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final familyProfilesAsync = ref.watch(familyProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('가족 프로필'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('가족 프로필 추가 기능은 곧 구현됩니다'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: familyProfilesAsync.when(
        data: (profiles) {
          if (profiles.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
                child: _buildProfileCard(context, profile),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.error),
              const SizedBox(height: AppTheme.spaceMd),
              Text('오류: $error', style: const TextStyle(color: AppTheme.error)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.family_restroom,
            size: 80,
            color: AppTheme.textTertiary,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          const Text(
            '등록된 가족 프로필이 없습니다',
            style: AppTheme.h3,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '가족 구성원을 추가하여 건강을 관리하세요',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceLg),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('가족 프로필 추가 기능은 곧 구현됩니다'),
                  backgroundColor: AppTheme.primary,
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('가족 추가'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, dynamic profile) {
    // profile.birthDate를 사용하여 나이 계산
    final birthDate = profile.birthDate;
    final age = birthDate != null
        ? DateTime.now().year - birthDate.year
        : null;

    return CustomCard(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${profile.name}님의 상세 정보'),
            backgroundColor: AppTheme.primary,
          ),
        );
      },
      child: Row(
        children: [
          // 프로필 아바타
          ProfileAvatar(
            imageUrl: profile.profileImageUrl,
            name: profile.name,
            size: 56,
          ),
          const SizedBox(width: AppTheme.spaceMd),
          // 프로필 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  style: AppTheme.h3,
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  '${profile.relationship}${age != null ? ' · ${age}세' : ''}',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (profile.chronicConditions != null &&
                    (profile.chronicConditions as List).isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spaceXs),
                    child: Wrap(
                      spacing: AppTheme.spaceXs,
                      children: (profile.chronicConditions as List)
                          .take(2)
                          .map((condition) => Chip(
                                label: Text(
                                  condition.toString(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor: AppTheme.warning.withOpacity(0.1),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
          // 화살표 아이콘
          const Icon(
            Icons.chevron_right,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    );
  }
}

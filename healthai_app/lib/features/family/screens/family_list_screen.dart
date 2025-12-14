import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../models/family_profile_model.dart';
import '../providers/family_provider.dart';
import 'family_profile_form_screen.dart';

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
            onPressed: () => _navigateToAddProfile(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(familyProfilesProvider.notifier).refresh(),
        child: familyProfilesAsync.when(
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
                  child: _buildProfileCard(context, ref, profile),
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
                Text('오류: $error',
                    style: const TextStyle(color: AppTheme.error)),
                const SizedBox(height: AppTheme.spaceMd),
                ElevatedButton(
                  onPressed: () =>
                      ref.read(familyProfilesProvider.notifier).refresh(),
                  child: const Text('다시 시도'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
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
              onPressed: () => _navigateToAddProfile(context),
              icon: const Icon(Icons.add),
              label: const Text('가족 추가'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, WidgetRef ref, FamilyProfileModel profile) {
    final age = DateTime.now().year - profile.birthDate.year;
    final relationLabel = getRelationshipLabel(profile.relationship);

    return CustomCard(
      onTap: () => _navigateToEditProfile(context, profile),
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
                  '$relationLabel · ${age}세',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (profile.chronicConditions.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppTheme.spaceXs),
                    child: Wrap(
                      spacing: AppTheme.spaceXs,
                      children: profile.chronicConditions
                          .take(2)
                          .map((condition) => Chip(
                                label: Text(
                                  condition,
                                  style: const TextStyle(fontSize: 11),
                                ),
                                backgroundColor:
                                    AppTheme.warning.withOpacity(0.1),
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

  void _navigateToAddProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FamilyProfileFormScreen(),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, FamilyProfileModel profile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FamilyProfileFormScreen(profile: profile),
      ),
    );
  }
}

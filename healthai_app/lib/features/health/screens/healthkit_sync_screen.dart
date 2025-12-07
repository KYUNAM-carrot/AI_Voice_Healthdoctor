import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/healthkit_provider.dart';
import '../../family/providers/family_provider.dart';

class HealthKitSyncScreen extends ConsumerStatefulWidget {
  const HealthKitSyncScreen({super.key});

  @override
  ConsumerState<HealthKitSyncScreen> createState() =>
      _HealthKitSyncScreenState();
}

class _HealthKitSyncScreenState extends ConsumerState<HealthKitSyncScreen> {
  bool _isSyncing = false;

  @override
  Widget build(BuildContext context) {
    final familyProfilesAsync = ref.watch(familyProfilesProvider);
    final authorizationAsync = ref.watch(healthKitAuthorizationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthKit 동기화'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // 권한 상태
          _buildAuthorizationCard(authorizationAsync),
          const SizedBox(height: AppTheme.spaceLg),

          // 프로필 선택 및 동기화
          familyProfilesAsync.when(
            data: (profiles) => _buildProfileList(profiles),
            loading: () => const Center(child: LoadingIndicator()),
            error: (e, _) =>
                const ErrorMessage(message: '프로필을 불러올 수 없습니다'),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorizationCard(AsyncValue<bool> authAsync) {
    return authAsync.when(
      data: (authorized) {
        return CustomCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    authorized ? Icons.check_circle : Icons.warning,
                    color: authorized ? AppTheme.success : AppTheme.warning,
                  ),
                  const SizedBox(width: AppTheme.spaceSm),
                  Text(
                    authorized ? 'HealthKit 연결됨' : 'HealthKit 권한 필요',
                    style: AppTheme.h3,
                  ),
                ],
              ),
              if (!authorized) ...[
                const SizedBox(height: AppTheme.spaceMd),
                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(healthKitAuthorizationProvider);
                  },
                  child: const Text('권한 요청'),
                ),
              ],
            ],
          ),
        );
      },
      loading: () => const CustomCard(
        child: Center(child: LoadingIndicator()),
      ),
      error: (e, _) => CustomCard(
        child: Text('오류: $e', style: const TextStyle(color: AppTheme.error)),
      ),
    );
  }

  Widget _buildProfileList(List<FamilyProfile> profiles) {
    if (profiles.isEmpty) {
      return const CustomCard(
        child: Text('가족 프로필을 먼저 추가해주세요'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('동기화할 프로필 선택', style: AppTheme.h3),
        const SizedBox(height: AppTheme.spaceMd),
        ...profiles.map((profile) => _buildProfileCard(profile)),
      ],
    );
  }

  Widget _buildProfileCard(FamilyProfile profile) {
    return CustomCard(
      child: ListTile(
        leading: ProfileAvatar(
          imageUrl: profile.profileImageUrl,
          name: profile.name,
          size: 40,
        ),
        title: Text(profile.name),
        subtitle: Text('${profile.age}세, ${profile.gender}'),
        trailing: _isSyncing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: LoadingIndicator(size: 20),
              )
            : ElevatedButton(
                onPressed: () => _syncHealthData(profile.id),
                child: const Text('동기화'),
              ),
      ),
    );
  }

  Future<void> _syncHealthData(String profileId) async {
    setState(() => _isSyncing = true);

    try {
      final result = await ref.read(
        healthKitSyncProvider(profileId).future,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '동기화 완료: ${result['inserted_count']}개 추가, ${result['duplicate_count']}개 중복',
            ),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('동기화 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }
}

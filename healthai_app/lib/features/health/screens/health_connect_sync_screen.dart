import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../services/health_connect_service.dart';
import '../providers/healthkit_provider.dart';
import '../../family/providers/family_provider.dart';

class HealthConnectSyncScreen extends ConsumerStatefulWidget {
  const HealthConnectSyncScreen({super.key});

  @override
  ConsumerState<HealthConnectSyncScreen> createState() =>
      _HealthConnectSyncScreenState();
}

class _HealthConnectSyncScreenState
    extends ConsumerState<HealthConnectSyncScreen> {
  final HealthConnectService _healthConnectService = HealthConnectService();
  bool _isAvailable = false;
  bool _isAuthorized = false;
  bool _isSyncing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    if (!Platform.isAndroid) {
      setState(() => _isLoading = false);
      return;
    }

    final available = await _healthConnectService.isHealthConnectAvailable();
    final authorized =
        available ? await _healthConnectService.requestAuthorization() : false;

    setState(() {
      _isAvailable = available;
      _isAuthorized = authorized;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isAndroid) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Connect 동기화')),
        body: const Center(
          child: Text('Health Connect는 Android 전용입니다'),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Health Connect 동기화')),
        body: const Center(child: LoadingIndicator()),
      );
    }

    final familyProfilesAsync = ref.watch(familyProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Connect 동기화'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // Health Connect 상태
          _buildStatusCard(),
          const SizedBox(height: AppTheme.spaceLg),

          // 프로필 선택 및 동기화
          if (_isAvailable && _isAuthorized)
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

  Widget _buildStatusCard() {
    if (!_isAvailable) {
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: AppTheme.warning),
                const SizedBox(width: AppTheme.spaceSm),
                const Text('Health Connect 미설치', style: AppTheme.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            const Text(
              'Health Connect를 설치하면 웨어러블 데이터를 자동으로 동기화할 수 있습니다.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            ElevatedButton(
              onPressed: () async {
                await _healthConnectService.openHealthConnectSettings();
                _checkAvailability();
              },
              child: const Text('Play Store에서 설치'),
            ),
          ],
        ),
      );
    }

    if (!_isAuthorized) {
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock, color: AppTheme.warning),
                const SizedBox(width: AppTheme.spaceSm),
                const Text('권한 필요', style: AppTheme.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            const Text(
              '건강 데이터를 읽기 위해 권한이 필요합니다.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            ElevatedButton(
              onPressed: () => _checkAvailability(),
              child: const Text('권한 요청'),
            ),
          ],
        ),
      );
    }

    return CustomCard(
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppTheme.success),
          const SizedBox(width: AppTheme.spaceSm),
          const Text('Health Connect 연결됨', style: AppTheme.h3),
        ],
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
      // 1. Health Connect 데이터 읽기
      final healthData =
          await _healthConnectService.fetchHealthData(days: 7);

      if (healthData.isEmpty) {
        throw Exception('데이터가 없습니다');
      }

      // 2. API 형식으로 변환
      final dataPoints = healthData.map((point) {
        return _healthConnectService.convertToApiFormat(point);
      }).toList();

      // 3. Backend로 전송
      final apiClient = ref.read(apiClientProvider);
      final response = await apiClient.post(
        '/api/v1/wearables/sync',
        data: {
          'family_profile_id': profileId,
          'source': 'health_connect',
          'data_points': dataPoints.take(100).toList(),
        },
      );

      if (mounted) {
        final result = response.data as Map<String, dynamic>;
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/api/api_client.dart';
import '../services/health_connect_service.dart';
import '../providers/healthkit_provider.dart';
import '../../family/providers/family_provider.dart';
import '../../family/models/family_profile_model.dart';

class HealthConnectSyncScreen extends ConsumerStatefulWidget {
  const HealthConnectSyncScreen({super.key});

  @override
  ConsumerState<HealthConnectSyncScreen> createState() =>
      _HealthConnectSyncScreenState();
}

class _HealthConnectSyncScreenState
    extends ConsumerState<HealthConnectSyncScreen> {
  final HealthConnectService _healthConnectService = HealthConnectService();
  bool _isAuthorized = false;
  bool _isSyncing = false;
  bool _isLoading = true;
  bool _isRequesting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAndRequestPermission();
  }

  /// 권한 확인 및 요청
  Future<void> _checkAndRequestPermission() async {
    if (!Platform.isAndroid) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 먼저 권한 상태 확인 (실제 데이터 접근 시도 포함)
      final authorized = await _healthConnectService.checkPermissionStatus();

      setState(() {
        _isAuthorized = authorized;
        _isLoading = false;
        if (!authorized) {
          _errorMessage = '헬스 커넥트에서 권한을 허용해주세요.';
        }
      });
    } catch (e) {
      setState(() {
        _isAuthorized = false;
        _isLoading = false;
        _errorMessage = '연결 확인 실패: $e';
      });
    }
  }

  /// 권한 요청 버튼 클릭
  Future<void> _onRequestPermissionPressed() async {
    setState(() => _isRequesting = true);

    try {
      // 먼저 Health Connect 권한 설정 화면을 직접 열어봄
      final opened = await _healthConnectService.openHealthConnectPermissionSettings();

      if (opened) {
        // 권한 설정 화면이 열렸으면 사용자가 돌아올 때까지 대기
        if (mounted) {
          setState(() => _isRequesting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('헬스 커넥트에서 "음성 건강주치의" 앱의 권한을 허용해주세요.'),
              duration: Duration(seconds: 5),
            ),
          );
        }
        return;
      }

      // 설정 화면을 열지 못했으면 기본 권한 요청 시도
      final authorized = await _healthConnectService.requestAuthorization();

      if (mounted) {
        setState(() {
          _isAuthorized = authorized;
          _isRequesting = false;
          _errorMessage = authorized ? null : '헬스 커넥트에서 권한을 허용해주세요.';
        });

        if (!authorized) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('헬스 커넥트 앱에서 권한을 직접 설정해주세요.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRequesting = false;
          _errorMessage = '권한 요청 실패: $e';
        });
      }
    }
  }

  /// Health Connect 설치/설정 버튼 클릭
  Future<void> _onInstallPressed() async {
    // 헬스 커넥트 앱의 권한 설정 화면을 직접 열기
    await _healthConnectService.openHealthConnectPermissionSettings();
  }

  /// 새로고침 버튼 클릭
  Future<void> _onRefreshPressed() async {
    _checkAndRequestPermission();
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
          if (_isAuthorized)
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
    // 권한 승인됨
    if (_isAuthorized) {
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

    // 권한 필요 또는 설치 필요
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.health_and_safety, color: AppTheme.primary),
              const SizedBox(width: AppTheme.spaceSm),
              const Text('Health Connect 연결', style: AppTheme.h3),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          const Text(
            'Health Connect를 통해 웨어러블 기기의 건강 데이터를 동기화할 수 있습니다.',
            style: AppTheme.bodyMedium,
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              _errorMessage!,
              style: AppTheme.bodySmall.copyWith(color: AppTheme.warning),
            ),
          ],
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              // 권한 요청 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _onRequestPermissionPressed,
                  child: _isRequesting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('권한 설정 열기'),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              // 새로고침 버튼
              IconButton(
                onPressed: _onRefreshPressed,
                icon: const Icon(Icons.refresh),
                tooltip: '상태 새로고침',
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          // 안내 문구
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '권한 설정 방법:',
                  style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                const Text('1. "권한 설정 열기" 버튼을 누르세요', style: AppTheme.bodySmall),
                const Text('2. 헬스 커넥트 앱이 열립니다', style: AppTheme.bodySmall),
                const Text('3. "음성 건강주치의" 앱을 찾아 선택하세요', style: AppTheme.bodySmall),
                const Text('4. 모든 데이터 권한을 허용해주세요', style: AppTheme.bodySmall),
                const Text('5. 이 화면으로 돌아와서 🔄 버튼을 누르세요', style: AppTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList(List<FamilyProfileModel> profiles) {
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

  Widget _buildProfileCard(FamilyProfileModel profile) {
    return CustomCard(
      child: ListTile(
        leading: ProfileAvatar(
          imageUrl: profile.profileImageUrl,
          name: profile.name,
          size: 40,
        ),
        title: Text(profile.name),
        subtitle: Text(profile.relationship),
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

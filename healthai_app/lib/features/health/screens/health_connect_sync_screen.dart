import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io' show Platform;
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/api/api_client.dart';
import '../services/health_connect_service.dart';
import '../providers/healthkit_provider.dart';
import '../providers/wearable_stats_provider.dart';
import '../../family/providers/family_provider.dart';
import '../../family/models/family_profile_model.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/auth_model.dart';

class HealthConnectSyncScreen extends ConsumerStatefulWidget {
  const HealthConnectSyncScreen({super.key});

  @override
  ConsumerState<HealthConnectSyncScreen> createState() =>
      _HealthConnectSyncScreenState();
}

class _HealthConnectSyncScreenState
    extends ConsumerState<HealthConnectSyncScreen> {
  final HealthConnectService _healthConnectService = HealthConnectService();
  final AuthService _authService = AuthService();
  bool _isAuthorized = false;
  bool _isSyncing = false;
  bool _isLoading = true;
  bool _isRequesting = false;
  bool _isInsertingTestData = false;
  String? _errorMessage;
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
    _checkAndRequestPermission();
  }

  /// 현재 로그인 사용자 정보 로드
  Future<void> _loadCurrentUser() async {
    final user = await _authService.getSavedUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
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
              data: (profiles) {
                debugPrint('HealthConnectSyncScreen - Loaded ${profiles.length} profiles');
                return _buildProfileList(profiles);
              },
              loading: () => const Center(child: LoadingIndicator()),
              error: (e, st) {
                debugPrint('HealthConnectSyncScreen - Error loading profiles: $e');
                debugPrint('Stack trace: $st');
                return ErrorMessage(message: '프로필을 불러올 수 없습니다: $e');
              },
            ),
        ],
      ),
    );
  }

  /// 테스트 데이터 시나리오 선택 다이얼로그
  Future<void> _showTestDataScenarioDialog() async {
    final scenario = await showDialog<HealthScenario>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('테스트 데이터 시나리오 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.green),
              title: const Text('좋은 상태'),
              subtitle: const Text('걸음수 8000+, 심박수 60-75'),
              onTap: () => Navigator.pop(context, HealthScenario.good),
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.orange),
              title: const Text('보통 상태'),
              subtitle: const Text('걸음수 4000-6000, 심박수 70-85'),
              onTap: () => Navigator.pop(context, HealthScenario.medium),
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('나쁜 상태'),
              subtitle: const Text('걸음수 1000-3000, 불규칙한 심박수'),
              onTap: () => Navigator.pop(context, HealthScenario.bad),
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.purple),
              title: const Text('응급 상태'),
              subtitle: const Text('걸음수 100-500, 빈맥/서맥 심박수'),
              onTap: () => Navigator.pop(context, HealthScenario.emergency),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (scenario != null) {
      await _insertTestData(scenario);
    }
  }

  /// 테스트 데이터 삽입 및 자동 동기화
  Future<void> _insertTestData(HealthScenario scenario) async {
    setState(() => _isInsertingTestData = true);

    try {
      debugPrint('Starting test data insertion (${scenario.name}) from UI...');

      final success = await _healthConnectService.insertTestData(
        daysBack: 7,
        scenario: scenario,
      );

      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('테스트 데이터 생성 실패. Health Connect 앱에서 쓰기 권한을 직접 허용해주세요.'),
              backgroundColor: AppTheme.error,
              duration: Duration(seconds: 5),
            ),
          );

          // 실패 시 Health Connect 설정 열기 제안
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('권한 설정 필요'),
              content: const Text(
                'Health Connect 앱에서 "음성 건강주치의" 앱의 쓰기 권한을 직접 허용해야 합니다.\n\n'
                '1. Health Connect 앱 열기\n'
                '2. 앱 권한 > 음성 건강주치의 선택\n'
                '3. 걸음 수, 심박수 등 쓰기 권한 허용',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('닫기'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _healthConnectService.openHealthConnectPermissionSettings();
                  },
                  child: const Text('Health Connect 열기'),
                ),
              ],
            ),
          );
        }
        return;
      }

      // 테스트 데이터 생성 성공 - 자동으로 기존 데이터 삭제 후 동기화
      if (mounted) {
        final scenarioName = _getScenarioName(scenario);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$scenarioName 테스트 데이터 생성 완료. 서버 동기화 중...'),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 2),
          ),
        );

        // self 프로필 찾기
        final profilesAsync = ref.read(familyProfilesProvider);
        final profiles = profilesAsync.valueOrNull ?? [];
        final selfProfile = profiles.where(
          (p) => p.relationship == 'self' || p.relationship == '본인',
        ).firstOrNull;

        if (selfProfile != null) {
          // 기존 데이터 삭제 후 새 데이터 동기화
          await _syncHealthData(selfProfile.id, deleteFirst: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('본인 프로필을 찾을 수 없습니다. 수동으로 동기화해주세요.'),
              backgroundColor: AppTheme.warning,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Test data insertion error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류 발생: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isInsertingTestData = false);
      }
    }
  }

  String _getScenarioName(HealthScenario scenario) {
    switch (scenario) {
      case HealthScenario.good:
        return '좋은 상태';
      case HealthScenario.medium:
        return '보통 상태';
      case HealthScenario.bad:
        return '나쁜 상태';
      case HealthScenario.emergency:
        return '응급 상태';
    }
  }

  Widget _buildStatusCard() {
    // 권한 승인됨
    if (_isAuthorized) {
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success),
                const SizedBox(width: AppTheme.spaceSm),
                const Text('Health Connect 연결됨', style: AppTheme.h3),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            // 테스트 데이터 생성 버튼 (개발용)
            OutlinedButton.icon(
              onPressed: _isInsertingTestData ? null : _showTestDataScenarioDialog,
              icon: _isInsertingTestData
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.science, size: 18),
              label: Text(_isInsertingTestData ? '생성 중...' : '테스트 데이터 생성 (개발용)'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textSecondary,
              ),
            ),
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
    // 본인 프로필이 로드되지 않은 경우
    if (_currentUser == null) {
      return const CustomCard(
        child: Center(child: LoadingIndicator()),
      );
    }

    // API에서 가져온 프로필 중 "self" 관계인 프로필 찾기
    // (웨어러블 데이터는 본인만 연동 가능)
    final selfProfile = profiles.where(
      (p) => p.relationship == 'self' || p.relationship == '본인',
    ).firstOrNull;

    if (selfProfile == null) {
      return CustomCard(
        child: Column(
          children: [
            const Icon(Icons.info_outline, color: AppTheme.warning, size: 48),
            const SizedBox(height: AppTheme.spaceMd),
            const Text(
              '본인 프로필이 없습니다',
              style: AppTheme.h3,
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              '가족 관리에서 "본인" 프로필을 먼저 추가해주세요.',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('동기화할 프로필', style: AppTheme.h3),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          '웨어러블 데이터는 본인 프로필에만 연동됩니다.',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        _buildProfileCard(selfProfile),
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

  Future<void> _syncHealthData(String profileId, {bool deleteFirst = false}) async {
    setState(() => _isSyncing = true);

    try {
      final apiClient = ref.read(apiClientProvider);

      // 0. 기존 데이터 삭제 (옵션)
      if (deleteFirst) {
        debugPrint('Deleting existing wearable data for profile: $profileId');
        await apiClient.delete('/api/v1/wearables/profiles/$profileId?days=7');
        debugPrint('Existing data deleted');
      }

      // 1. Health Connect 데이터 읽기
      final healthData =
          await _healthConnectService.fetchHealthData(days: 7);

      debugPrint('=== Health Connect 데이터 읽기 결과 ===');
      debugPrint('총 데이터 포인트: ${healthData.length}');

      // 데이터 타입별 개수 집계
      final typeCounts = <String, int>{};
      for (final point in healthData) {
        final typeName = point.type.name;
        typeCounts[typeName] = (typeCounts[typeName] ?? 0) + 1;
      }
      debugPrint('타입별 개수: $typeCounts');

      if (healthData.isEmpty) {
        throw Exception('데이터가 없습니다');
      }

      // 2. API 형식으로 변환
      final dataPoints = healthData.map((point) {
        return _healthConnectService.convertToApiFormat(point);
      }).toList();

      // 변환된 데이터 타입별 개수
      final apiTypeCounts = <String, int>{};
      for (final point in dataPoints) {
        final typeName = point['data_type'] as String;
        apiTypeCounts[typeName] = (apiTypeCounts[typeName] ?? 0) + 1;
      }
      debugPrint('API 변환 후 타입별 개수: $apiTypeCounts');

      // 3. Backend로 전송 (날짜별/타입별로 최신 1개만 선택)
      // Health Connect에 누적된 데이터 중 각 날짜/타입 조합에서 가장 최신 데이터만 전송
      final selectedPoints = <Map<String, dynamic>>[];

      // 날짜+타입 키로 그룹화
      final dateTypeGroups = <String, List<Map<String, dynamic>>>{};
      for (final point in dataPoints) {
        final dataType = point['data_type'] as String;
        final startTime = point['start_time'] as String;
        // 날짜 부분만 추출 (YYYY-MM-DD)
        final dateKey = startTime.substring(0, 10);
        final groupKey = '$dateKey|$dataType';
        dateTypeGroups.putIfAbsent(groupKey, () => []).add(point);
      }

      // 각 날짜/타입별로 가장 최신 데이터 1개만 선택
      for (final entry in dateTypeGroups.entries) {
        final groupData = entry.value;
        // start_time 기준 최신순 정렬 후 첫 번째만 선택
        groupData.sort((a, b) =>
          (b['start_time'] as String).compareTo(a['start_time'] as String));
        selectedPoints.add(groupData.first);
      }

      debugPrint('선택된 데이터: ${selectedPoints.length}개 (날짜/타입별 최신 1개)');

      final response = await apiClient.post(
        '/api/v1/wearables/sync',
        data: {
          'family_profile_id': profileId,
          'source': 'health_connect',
          'data_points': selectedPoints.take(100).toList(),
        },
      );

      if (mounted) {
        final result = response.data as Map<String, dynamic>;

        // 동기화 성공 후 오늘의 건강 데이터 provider 즉시 갱신
        await ref.refresh(todayHealthDataProvider.future);

        // 실제 전송된 데이터 타입별 개수
        final sentTypeCounts = <String, int>{};
        for (final point in selectedPoints) {
          final typeName = point['data_type'] as String;
          sentTypeCounts[typeName] = (sentTypeCounts[typeName] ?? 0) + 1;
        }
        final typeInfo = sentTypeCounts.entries
            .map((e) => '${e.key}:${e.value}')
            .join(', ');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '동기화 완료: ${result['inserted_count']}개 추가\n[$typeInfo]',
            ),
            backgroundColor: AppTheme.success,
            duration: const Duration(seconds: 5),
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

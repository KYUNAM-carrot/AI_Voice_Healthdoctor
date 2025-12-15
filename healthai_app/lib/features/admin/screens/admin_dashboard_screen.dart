import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/withdrawal_provider.dart';

/// 관리자 대시보드 화면
class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdminAsync = ref.watch(isAdminProvider);

    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) {
          return _buildAccessDeniedScreen(context);
        }
        return _buildAdminDashboard();
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (_, __) => _buildAccessDeniedScreen(context),
    );
  }

  Widget _buildAccessDeniedScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              '접근 권한이 없습니다',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '관리자 계정으로 로그인해주세요',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDashboard() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('관리자'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: '대시보드'),
            Tab(icon: Icon(Icons.person_off), text: '탈퇴 관리'),
            Tab(icon: Icon(Icons.people), text: '회원 관리'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _WithdrawalManagementTab(),
          _UserManagementTab(),
        ],
      ),
    );
  }
}

/// 대시보드 탭
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawals = ref.watch(withdrawalListProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 요약 카드
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.people,
                  title: '총 회원',
                  value: '1,234',
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.person_off,
                  title: '탈퇴 회원',
                  value: '${withdrawals.length}',
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.chat,
                  title: '오늘 상담',
                  value: '56',
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.card_membership,
                  title: '유료 구독',
                  value: '89',
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 탈퇴 사유 통계
          if (withdrawals.isNotEmpty) ...[
            Text(
              '탈퇴 사유 분석',
              style: AppTheme.h3.copyWith(color: AppTheme.primary),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            _buildReasonStats(ref),
          ],

          const SizedBox(height: AppTheme.spaceLg),

          // 최근 탈퇴자
          Text(
            '최근 탈퇴자',
            style: AppTheme.h3.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          if (withdrawals.isEmpty)
            const CustomCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spaceLg),
                  child: Text('탈퇴 회원이 없습니다'),
                ),
              ),
            )
          else
            ...withdrawals.take(5).map((info) => _buildWithdrawalCard(info)),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return CustomCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasonStats(WidgetRef ref) {
    final stats = ref.watch(withdrawalListProvider.notifier).getReasonStatistics();

    if (stats.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = stats.values.fold(0, (sum, count) => sum + count);
    final sortedEntries = stats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return CustomCard(
      child: Column(
        children: sortedEntries.map((entry) {
          final percentage = (entry.value / total * 100).toStringAsFixed(1);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '${entry.value}명 ($percentage%)',
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: entry.value / total,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getReasonColor(entry.key),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getReasonColor(String reason) {
    if (reason.contains('비용')) return Colors.red;
    if (reason.contains('기능')) return Colors.orange;
    if (reason.contains('어려움')) return Colors.amber;
    if (reason.contains('다른 서비스')) return Colors.blue;
    if (reason.contains('개인정보')) return Colors.purple;
    return Colors.grey;
  }

  Widget _buildWithdrawalCard(WithdrawalInfo info) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red.shade100,
          child: Text(
            info.userName.isNotEmpty ? info.userName[0] : '?',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ),
        title: Text(info.userName),
        subtitle: Text(
          info.reason,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          dateFormat.format(info.withdrawalDate),
          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

/// 탈퇴 관리 탭
class _WithdrawalManagementTab extends ConsumerWidget {
  const _WithdrawalManagementTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final withdrawals = ref.watch(withdrawalListProvider);
    final dateFormat = DateFormat('yyyy년 MM월 dd일 HH:mm');

    if (withdrawals.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('탈퇴한 회원이 없습니다'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      itemCount: withdrawals.length,
      itemBuilder: (context, index) {
        // 최신 순으로 정렬
        final sortedList = [...withdrawals]
          ..sort((a, b) => b.withdrawalDate.compareTo(a.withdrawalDate));
        final info = sortedList[index];

        return Card(
          margin: const EdgeInsets.only(bottom: AppTheme.spaceMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 이름, 날짜
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.red.shade100,
                      radius: 24,
                      child: Text(
                        info.userName.isNotEmpty ? info.userName[0] : '?',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            info.userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'ID: ${info.userId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '탈퇴',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // 탈퇴 정보
                _buildInfoRow(
                  icon: Icons.calendar_today,
                  label: '탈퇴일시',
                  value: dateFormat.format(info.withdrawalDate),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  icon: Icons.help_outline,
                  label: '탈퇴 사유',
                  value: info.reason,
                  isMultiline: true,
                ),

                // 액션 버튼
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _exportWithdrawalInfo(context, info),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('내보내기'),
                    ),
                    const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: () => _deleteWithdrawalRecord(context, ref, info),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      label: const Text('삭제'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment:
          isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }

  void _exportWithdrawalInfo(BuildContext context, WithdrawalInfo info) {
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final data = '''
회원 탈퇴 정보
================
이름: ${info.userName}
사용자 ID: ${info.userId}
탈퇴 일시: ${dateFormat.format(info.withdrawalDate)}
탈퇴 사유: ${info.reason}
''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('탈퇴 정보가 클립보드에 복사되었습니다'),
        action: SnackBarAction(
          label: '확인',
          onPressed: () {},
        ),
      ),
    );

    print(data); // 실제로는 클립보드에 복사하거나 파일로 저장
  }

  void _deleteWithdrawalRecord(
    BuildContext context,
    WidgetRef ref,
    WithdrawalInfo info,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('기록 삭제'),
        content: Text('${info.userName}님의 탈퇴 기록을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(withdrawalListProvider.notifier).removeWithdrawal(info.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('탈퇴 기록이 삭제되었습니다')),
        );
      }
    }
  }
}

/// 회원 관리 탭
class _UserManagementTab extends ConsumerWidget {
  const _UserManagementTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 회원 통계
          Text(
            '회원 통계',
            style: AppTheme.h3.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          CustomCard(
            child: Column(
              children: [
                _buildStatRow('전체 회원', '1,234명'),
                const Divider(),
                _buildStatRow('활성 회원', '1,189명'),
                const Divider(),
                _buildStatRow('비활성 회원', '45명'),
                const Divider(),
                _buildStatRow('오늘 가입', '12명'),
                const Divider(),
                _buildStatRow('이번 달 가입', '156명'),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 구독 통계
          Text(
            '구독 통계',
            style: AppTheme.h3.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          CustomCard(
            child: Column(
              children: [
                _buildStatRow('무료 플랜', '1,089명', color: Colors.grey),
                const Divider(),
                _buildStatRow('베이직 플랜', '56명', color: Colors.blue),
                const Divider(),
                _buildStatRow('프리미엄 플랜', '67명', color: Colors.purple),
                const Divider(),
                _buildStatRow('패밀리 플랜', '22명', color: Colors.orange),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 상담 통계
          Text(
            '상담 통계',
            style: AppTheme.h3.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          CustomCard(
            child: Column(
              children: [
                _buildStatRow('오늘 상담', '56건'),
                const Divider(),
                _buildStatRow('이번 주 상담', '324건'),
                const Divider(),
                _buildStatRow('이번 달 상담', '1,456건'),
                const Divider(),
                _buildStatRow('총 상담', '12,345건'),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 관리자 기능
          Text(
            '관리자 기능',
            style: AppTheme.h3.copyWith(color: AppTheme.primary),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications, color: AppTheme.primary),
                  title: const Text('공지사항 관리'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공지사항 관리 기능 준비 중')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.campaign, color: AppTheme.primary),
                  title: const Text('푸시 알림 발송'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('푸시 알림 기능 준비 중')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.download, color: AppTheme.primary),
                  title: const Text('데이터 내보내기'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('데이터 내보내기 기능 준비 중')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.settings, color: AppTheme.primary),
                  title: const Text('시스템 설정'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('시스템 설정 기능 준비 중')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

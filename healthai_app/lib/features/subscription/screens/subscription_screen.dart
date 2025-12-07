import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/subscription_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/subscription_constants.dart';

class SubscriptionScreen extends ConsumerWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offeringsAsync = ref.watch(offeringsProvider);
    final currentSubscription = ref.watch(currentSubscriptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        elevation: 0,
      ),
      body: offeringsAsync.when(
        data: (offerings) {
          if (offerings.current == null) {
            return const Center(child: Text('이용 가능한 구독 플랜이 없습니다'));
          }

          return ListView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            children: [
              // 현재 플랜
              currentSubscription.when(
                data: (subscription) => _buildCurrentPlanCard(subscription),
                loading: () => const CustomCard(
                  child: Center(child: LoadingIndicator()),
                ),
                error: (e, _) => CustomCard(
                  child: Text('오류: $e',
                      style: const TextStyle(color: AppTheme.error)),
                ),
              ),

              const SizedBox(height: AppTheme.spaceLg),

              // 플랜 안내 텍스트
              const Text(
                '플랜 선택',
                style: AppTheme.h2,
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                '가족 건강을 위한 최적의 플랜을 선택하세요',
                style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppTheme.spaceLg),

              // 플랜 목록
              ...offerings.current!.availablePackages.map((package) {
                return _buildPlanCard(context, ref, package);
              }),

              const SizedBox(height: AppTheme.spaceLg),

              // 구매 복원 버튼
              OutlinedButton.icon(
                onPressed: () => _restorePurchases(context, ref),
                icon: const Icon(Icons.restore),
                label: const Text('구매 복원'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spaceLg, vertical: AppTheme.spaceMd),
                ),
              ),

              const SizedBox(height: AppTheme.spaceMd),

              // 주의사항
              _buildNotice(),
            ],
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (e, _) => Center(
          child: ErrorMessage(message: '구독 정보를 불러올 수 없습니다\n$e'),
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(subscription) {
    final planName =
        SubscriptionPlans.planNames[subscription.plan] ?? subscription.plan;
    final features = SubscriptionPlans.features[subscription.plan];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '현재 플랜',
                    style: AppTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    planName,
                    style: AppTheme.h2,
                  ),
                ],
              ),
              if (subscription.status == 'active')
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    '활성',
                    style: TextStyle(
                      color: AppTheme.success,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          if (subscription.endDate != null) ...[
            const SizedBox(height: AppTheme.spaceMd),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  '다음 결제일: ${_formatDate(subscription.endDate!)}',
                  style: AppTheme.bodySmall,
                ),
              ],
            ),
          ],
          if (features != null) ...[
            const SizedBox(height: AppTheme.spaceMd),
            const Divider(),
            const SizedBox(height: AppTheme.spaceMd),
            _buildFeatureRow(Icons.people, '가족 프로필', features.profilesLimit),
            _buildFeatureRow(
                Icons.chat, 'AI 상담', features.conversationsLimit),
            _buildFeatureRow(Icons.storage, '데이터 보관',
                '${features.dataRetentionDays}일'),
            if (features.advancedAnalytics)
              _buildFeatureRow(Icons.analytics, '고급 분석', '포함'),
            if (features.prioritySupport)
              _buildFeatureRow(Icons.support_agent, '우선 지원', '포함'),
          ],
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Text(label, style: AppTheme.bodyMedium),
          const Spacer(),
          Text(value,
              style: AppTheme.bodyMedium
                  .copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context, WidgetRef ref, package) {
    final product = package.storeProduct;
    final planId = _getPlanIdFromPackage(package.identifier);
    final features = SubscriptionPlans.features[planId];

    return CustomCard(
      child: InkWell(
        onTap: () => _purchasePackage(context, ref, package),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      product.title,
                      style: AppTheme.h3,
                    ),
                  ),
                  Text(
                    product.priceString,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                product.description,
                style: AppTheme.bodySmall,
              ),
              if (features != null) ...[
                const SizedBox(height: AppTheme.spaceMd),
                const Divider(),
                const SizedBox(height: AppTheme.spaceSm),
                _buildCompactFeature(
                    Icons.people, features.profilesLimit),
                _buildCompactFeature(
                    Icons.chat, features.conversationsLimit),
                if (features.advancedAnalytics)
                  _buildCompactFeature(Icons.analytics, '고급 분석'),
              ],
              const SizedBox(height: AppTheme.spaceMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _purchasePackage(context, ref, package),
                  child: const Text('구독하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactFeature(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(text, style: AppTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('주의사항', style: AppTheme.bodyMedium),
          const SizedBox(height: 8),
          _buildNoticeItem('• 구독은 자동으로 갱신됩니다'),
          _buildNoticeItem('• 결제일 최소 24시간 전에 취소하면 자동 갱신되지 않습니다'),
          _buildNoticeItem('• 구독 관리는 앱스토어/플레이스토어 계정 설정에서 가능합니다'),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
      ),
    );
  }

  Future<void> _purchasePackage(
      BuildContext context, WidgetRef ref, package) async {
    try {
      await ref.read(currentSubscriptionProvider.notifier).purchasePackage(package);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구독이 완료되었습니다'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구독 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(currentSubscriptionProvider.notifier).restorePurchases();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('구매가 복원되었습니다'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('구매 복원 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  String _getPlanIdFromPackage(String packageIdentifier) {
    // RevenueCat package identifier에서 plan ID 추출
    if (packageIdentifier.contains('family')) return 'family';
    if (packageIdentifier.contains('premium')) return 'premium';
    if (packageIdentifier.contains('basic')) return 'basic';
    return 'free';
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy년 MM월 dd일').format(date);
  }
}

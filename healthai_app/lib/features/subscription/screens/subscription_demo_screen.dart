import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/constants/subscription_constants.dart';

class SubscriptionDemoScreen extends StatelessWidget {
  const SubscriptionDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('구독 관리'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // 현재 플랜 카드
          _buildCurrentPlanCard(),
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

          // 플랜 카드들
          _buildPlanCard(
            context,
            plan: 'FREE',
            name: '무료',
            price: '₩0',
            features: SubscriptionPlans.features['free']!,
            isCurrentPlan: true,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildPlanCard(
            context,
            plan: 'BASIC',
            name: '베이직',
            price: '₩3,900/월',
            features: SubscriptionPlans.features['basic']!,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildPlanCard(
            context,
            plan: 'PREMIUM',
            name: '프리미엄',
            price: '₩5,900/월',
            features: SubscriptionPlans.features['premium']!,
            isPopular: true,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildPlanCard(
            context,
            plan: 'FAMILY',
            name: '패밀리',
            price: '₩9,900/월',
            features: SubscriptionPlans.features['family']!,
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 구매 복원 버튼
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('데모 모드입니다. RevenueCat API 키를 설정해주세요.'),
                  backgroundColor: AppTheme.warning,
                ),
              );
            },
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
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('현재 플랜', style: AppTheme.h3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceSm,
                  vertical: AppTheme.spaceXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Text(
                  '무료',
                  style: TextStyle(
                    color: AppTheme.success,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceMd),
          const Text(
            '무료 플랜',
            style: AppTheme.h2,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            '데모 모드로 실행 중입니다.',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(
    BuildContext context, {
    required String plan,
    required String name,
    required String price,
    required PlanFeatures features,
    bool isCurrentPlan = false,
    bool isPopular = false,
  }) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 플랜 이름 및 가격
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTheme.h3,
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          Text(
                            price,
                            style: AppTheme.h2.copyWith(
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceSm,
                          vertical: AppTheme.spaceXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: const Text(
                          '현재 플랜',
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: AppTheme.spaceMd),

                // 플랜 기능 목록
                _buildFeatureItem('가족 프로필', '${features.familyProfiles == -1 ? '무제한' : '${features.familyProfiles}개'}'),
                _buildFeatureItem(
                  'AI 상담',
                  features.aiConversations == -1
                      ? '무제한'
                      : '${features.aiConversations}회/월',
                ),
                _buildFeatureItem(
                  '데이터 보관',
                  '${features.dataRetentionDays}일',
                ),
                _buildFeatureItem(
                  '고급 분석',
                  features.advancedAnalytics ? '포함' : '미포함',
                ),
                _buildFeatureItem(
                  '우선 지원',
                  features.prioritySupport ? '포함' : '미포함',
                ),

                const SizedBox(height: AppTheme.spaceMd),

                // 구독 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isCurrentPlan
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '데모 모드입니다. RevenueCat API 키를 설정해주세요.'),
                                backgroundColor: AppTheme.warning,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPopular ? AppTheme.accent : null,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppTheme.spaceMd,
                      ),
                    ),
                    child: Text(
                      isCurrentPlan ? '현재 사용 중' : '구독하기',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 인기 배지
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceMd,
                  vertical: AppTheme.spaceXs,
                ),
                decoration: const BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppTheme.radiusMd),
                    bottomLeft: Radius.circular(AppTheme.radiusMd),
                  ),
                ),
                child: const Text(
                  '인기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceXs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주의사항',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _buildNoticeItem('구독은 언제든지 취소할 수 있습니다'),
          _buildNoticeItem('결제는 구독 시작일에 자동으로 처리됩니다'),
          _buildNoticeItem('무료 체험 기간 종료 전 언제든 취소 가능합니다'),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            '데모 모드: RevenueCat API 키 설정 필요',
            style: AppTheme.caption.copyWith(
              color: AppTheme.warning,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: AppTheme.caption),
          Expanded(
            child: Text(
              text,
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

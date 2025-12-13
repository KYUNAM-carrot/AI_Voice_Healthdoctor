import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/auth_model.dart';
import '../providers/auth_provider.dart';

/// 로그인 화면
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    // 인증 성공 시 홈으로 이동
    ref.listen<AuthState>(authStateProvider, (previous, next) {
      next.maybeWhen(
        authenticated: (user, tokens) {
          context.go('/home');
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
          // 에러 상태 초기화
          ref.read(authStateProvider.notifier).clearError();
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 앱 로고 및 타이틀
                _buildHeader(theme),

                const Spacer(flex: 1),

                // 소셜 로그인 버튼들
                _buildSocialLoginButtons(context, ref, authState),

                const SizedBox(height: 24),

                // 서비스 이용약관
                _buildTermsText(theme),

                const Spacer(flex: 1),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      children: [
        // 앱 아이콘
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.health_and_safety,
            size: 60,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),

        // 앱 타이틀
        Text(
          'AI 건강 주치의',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),

        Text(
          '당신의 건강을 위한 AI 음성 상담',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final isLoading = authState is AuthStateLoading;

    return Column(
      children: [
        // 카카오 로그인
        _SocialLoginButton(
          provider: SocialProvider.kakao,
          onPressed: isLoading
              ? null
              : () => ref.read(authStateProvider.notifier).loginWithKakao(),
          isLoading: isLoading,
        ),

        const SizedBox(height: 12),

        // 구글 로그인
        _SocialLoginButton(
          provider: SocialProvider.google,
          onPressed: isLoading
              ? null
              : () => ref.read(authStateProvider.notifier).loginWithGoogle(),
          isLoading: isLoading,
        ),

        const SizedBox(height: 12),

        // 애플 로그인 (iOS만)
        if (Platform.isIOS)
          _SocialLoginButton(
            provider: SocialProvider.apple,
            onPressed: isLoading
                ? null
                : () => ref.read(authStateProvider.notifier).loginWithApple(),
            isLoading: isLoading,
          ),
      ],
    );
  }

  Widget _buildTermsText(ThemeData theme) {
    return Column(
      children: [
        Text(
          '로그인하면 아래 약관에 동의하는 것으로 간주됩니다.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                // TODO: 서비스 이용약관 페이지로 이동
              },
              child: Text(
                '서비스 이용약관',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            Text(
              ' 및 ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: 개인정보 처리방침 페이지로 이동
              },
              child: Text(
                '개인정보 처리방침',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 소셜 로그인 버튼
class _SocialLoginButton extends StatelessWidget {
  final SocialProvider provider;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.provider,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getProviderConfig(provider);

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: config.backgroundColor,
          foregroundColor: config.foregroundColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: config.hasBorder
                ? BorderSide(color: Colors.grey.shade300)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: config.foregroundColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(config.icon, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    config.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  _ProviderConfig _getProviderConfig(SocialProvider provider) {
    switch (provider) {
      case SocialProvider.kakao:
        return _ProviderConfig(
          backgroundColor: const Color(0xFFFEE500),
          foregroundColor: const Color(0xFF191919),
          icon: Icons.chat_bubble,
          label: '카카오로 계속하기',
          hasBorder: false,
        );
      case SocialProvider.google:
        return _ProviderConfig(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          icon: Icons.g_mobiledata,
          label: 'Google로 계속하기',
          hasBorder: true,
        );
      case SocialProvider.apple:
        return _ProviderConfig(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          icon: Icons.apple,
          label: 'Apple로 계속하기',
          hasBorder: false,
        );
    }
  }
}

class _ProviderConfig {
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String label;
  final bool hasBorder;

  _ProviderConfig({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.label,
    required this.hasBorder,
  });
}

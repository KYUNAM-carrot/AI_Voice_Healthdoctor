import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/subscription/screens/subscription_demo_screen.dart';
import '../../features/health/screens/healthkit_sync_screen.dart';
import '../../features/health/screens/health_connect_sync_screen.dart';
import '../../features/health/screens/wearable_sync_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/family/screens/family_list_screen.dart';
import '../../features/conversation/screens/conversation_screen.dart';
import '../../features/conversation/screens/voice_conversation_screen.dart';
import '../../features/conversation/screens/conversation_history_screen.dart';
import '../../features/conversation/screens/conversation_history_detail_screen.dart';
import '../../features/character/screens/character_selection_screen.dart';
import '../../features/routine/screens/morning_routine_screen.dart';
import '../../features/routine/screens/gratitude_diary_screen.dart';
import '../../features/routine/screens/routine_calendar_screen.dart';
import '../../features/routine/screens/routine_stats_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/auth_model.dart';
import '../../features/settings/screens/profile_edit_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/notification/screens/notification_settings_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/medical_consent/screens/medical_disclaimer_consent_screen.dart';

/// 전역 NavigatorKey (알림 클릭 시 화면 이동용)
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

/// 전역 GoRouter 인스턴스 (알림 클릭 시 화면 이동용)
GoRouter? globalRouter;

// Router configuration with authentication
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/onboarding',
    redirect: (context, state) async {
      final isOnboardingRoute = state.matchedLocation == '/onboarding';
      final isLoginRoute = state.matchedLocation == '/login';
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isLoading = authState is AuthStateLoading;
      final isInitial = authState is AuthStateInitial;

      // 온보딩 완료 여부 확인
      final prefs = await SharedPreferences.getInstance();
      final onboardingCompleted = prefs.getBool('onboarding_completed') ?? false;

      // 초기 상태나 로딩 중에는 리다이렉트하지 않음
      if (isInitial || isLoading) {
        return null;
      }

      // 온보딩 미완료 시 온보딩으로 리다이렉트
      if (!onboardingCompleted && !isOnboardingRoute) {
        return '/onboarding';
      }

      // 온보딩 완료 후 온보딩 페이지 접근 시 로그인으로 리다이렉트
      if (onboardingCompleted && isOnboardingRoute) {
        return '/login';
      }

      // 인증되지 않은 상태에서 보호된 페이지 접근 시 로그인으로 리다이렉트
      if (!isAuthenticated && !isLoginRoute && !isOnboardingRoute) {
        return '/login';
      }

      // 이미 인증된 상태에서 로그인 페이지 접근 시 홈으로 리다이렉트
      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/subscription',
        name: 'subscription',
        builder: (context, state) => const SubscriptionDemoScreen(),
      ),
      GoRoute(
        path: '/health/healthkit',
        name: 'healthkit',
        builder: (context, state) => const HealthKitSyncScreen(),
      ),
      GoRoute(
        path: '/health/health-connect',
        name: 'health-connect',
        builder: (context, state) => const HealthConnectSyncScreen(),
      ),
      GoRoute(
        path: '/health/wearable',
        name: 'wearable',
        builder: (context, state) => const WearableSyncScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notification-settings',
        name: 'notification-settings',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/families',
        name: 'families',
        builder: (context, state) => const FamilyListScreen(),
      ),
      GoRoute(
        path: '/characters',
        name: 'characters',
        builder: (context, state) => const CharacterSelectionScreen(),
      ),
      GoRoute(
        path: '/routine',
        name: 'routine',
        builder: (context, state) => const MorningRoutineScreen(),
      ),
      GoRoute(
        path: '/gratitude',
        name: 'gratitude',
        builder: (context, state) => const GratitudeDiaryScreen(),
      ),
      GoRoute(
        path: '/routine-calendar',
        name: 'routine-calendar',
        builder: (context, state) => const RoutineCalendarScreen(),
      ),
      GoRoute(
        path: '/routine-stats',
        name: 'routine-stats',
        builder: (context, state) => const RoutineStatsScreen(),
      ),
      GoRoute(
        path: '/conversation-history',
        name: 'conversation-history',
        builder: (context, state) => const ConversationHistoryScreen(),
      ),
      GoRoute(
        path: '/conversation-history/:id',
        name: 'conversation-history-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ConversationHistoryDetailScreen(conversationId: id);
        },
      ),
      GoRoute(
        path: '/conversation/:characterId',
        name: 'conversation',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          return ConversationScreen(characterId: characterId);
        },
      ),
      GoRoute(
        path: '/medical-consent/:characterId',
        name: 'medical-consent',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          final characterName = state.uri.queryParameters['name'] ?? '의사 선생님';
          final familyProfileId = state.uri.queryParameters['profileId'];
          final familyProfileName = state.uri.queryParameters['profileName'];
          return MedicalDisclaimerConsentScreen(
            characterId: characterId,
            characterName: characterName,
            familyProfileId: familyProfileId,
            familyProfileName: familyProfileName,
          );
        },
      ),
      GoRoute(
        path: '/voice-conversation/:characterId',
        name: 'voice-conversation',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          final characterName = state.uri.queryParameters['name'] ?? '의사 선생님';
          final familyProfileId = state.uri.queryParameters['profileId'];
          final familyProfileName = state.uri.queryParameters['profileName'];
          return VoiceConversationScreen(
            characterId: characterId,
            characterName: characterName,
            familyProfileId: familyProfileId,
            familyProfileName: familyProfileName,
          );
        },
      ),
    ],
  );

  // 전역 라우터 인스턴스 설정 (알림 클릭 시 화면 이동용)
  globalRouter = router;

  return router;
});

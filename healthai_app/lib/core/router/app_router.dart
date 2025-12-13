import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/subscription/screens/subscription_demo_screen.dart';
import '../../features/health/screens/healthkit_sync_screen.dart';
import '../../features/health/screens/health_connect_sync_screen.dart';
import '../../features/health/screens/wearable_sync_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/family/screens/family_list_screen.dart';
import '../../features/conversation/screens/conversation_screen.dart';
import '../../features/conversation/screens/voice_conversation_screen.dart';
import '../../features/character/screens/character_selection_screen.dart';
import '../../features/routine/screens/morning_routine_screen.dart';
import '../../features/routine/screens/gratitude_diary_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/models/auth_model.dart';

// Router configuration with authentication
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';
      final isAuthenticated = authState is AuthStateAuthenticated;
      final isLoading = authState is AuthStateLoading;
      final isInitial = authState is AuthStateInitial;

      // 초기 상태나 로딩 중에는 리다이렉트하지 않음
      if (isInitial || isLoading) {
        return null;
      }

      // 인증되지 않은 상태에서 보호된 페이지 접근 시 로그인으로 리다이렉트
      if (!isAuthenticated && !isLoginRoute) {
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
        path: '/conversation/:characterId',
        name: 'conversation',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          return ConversationScreen(characterId: characterId);
        },
      ),
      GoRoute(
        path: '/voice-conversation/:characterId',
        name: 'voice-conversation',
        builder: (context, state) {
          final characterId = state.pathParameters['characterId']!;
          final characterName = state.uri.queryParameters['name'] ?? '의사 선생님';
          return VoiceConversationScreen(
            characterId: characterId,
            characterName: characterName,
          );
        },
      ),
    ],
  );
});

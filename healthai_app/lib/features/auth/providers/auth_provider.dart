import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// 인증 상태 Provider
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});

/// 로그인 상태 확인 Provider
final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.isLoggedIn();
});

/// 현재 사용자 Provider
final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.maybeWhen(
    authenticated: (user, tokens) => user,
    orElse: () => null,
  );
});

/// 인증 상태 관리 Notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthStateNotifier(this._authService) : super(const AuthState.initial()) {
    _checkAuthStatus();
  }

  /// 앱 시작 시 인증 상태 확인
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // 저장된 사용자 정보 로드
        final user = await _authService.getSavedUser();
        final accessToken = await _authService.getAccessToken();
        final refreshToken = await _authService.getRefreshToken();

        if (user != null && accessToken != null && refreshToken != null) {
          state = AuthState.authenticated(
            user: user,
            tokens: AuthTokens(
              accessToken: accessToken,
              refreshToken: refreshToken,
            ),
          );

          // 백그라운드에서 최신 사용자 정보 갱신
          _refreshUserInfo();
        } else {
          state = const AuthState.unauthenticated();
        }
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = const AuthState.unauthenticated();
    }
  }

  /// 사용자 정보 갱신
  Future<void> _refreshUserInfo() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user != null && state is AuthStateAuthenticated) {
        final currentState = state as AuthStateAuthenticated;
        state = AuthState.authenticated(
          user: user,
          tokens: currentState.tokens,
        );
      }
    } catch (e) {
      // 토큰이 만료된 경우 갱신 시도
      await refreshToken();
    }
  }

  /// 카카오 로그인
  Future<void> loginWithKakao() async {
    state = const AuthState.loading();

    try {
      final tokens = await _authService.loginWithKakao();
      final user = await _authService.getCurrentUser();

      if (user != null) {
        state = AuthState.authenticated(user: user, tokens: tokens);
      } else {
        state = const AuthState.error('사용자 정보를 가져올 수 없습니다.');
      }
    } catch (e) {
      state = AuthState.error('카카오 로그인 실패: ${e.toString()}');
    }
  }

  /// 구글 로그인
  Future<void> loginWithGoogle() async {
    state = const AuthState.loading();

    try {
      final tokens = await _authService.loginWithGoogle();
      final user = await _authService.getCurrentUser();

      if (user != null) {
        state = AuthState.authenticated(user: user, tokens: tokens);
      } else {
        state = const AuthState.error('사용자 정보를 가져올 수 없습니다.');
      }
    } catch (e) {
      state = AuthState.error('구글 로그인 실패: ${e.toString()}');
    }
  }

  /// 애플 로그인
  Future<void> loginWithApple() async {
    state = const AuthState.loading();

    try {
      final tokens = await _authService.loginWithApple();
      final user = await _authService.getCurrentUser();

      if (user != null) {
        state = AuthState.authenticated(user: user, tokens: tokens);
      } else {
        state = const AuthState.error('사용자 정보를 가져올 수 없습니다.');
      }
    } catch (e) {
      state = AuthState.error('Apple 로그인 실패: ${e.toString()}');
    }
  }

  /// 토큰 갱신
  Future<void> refreshToken() async {
    try {
      final newTokens = await _authService.refreshToken();

      if (newTokens != null && state is AuthStateAuthenticated) {
        final currentState = state as AuthStateAuthenticated;
        state = AuthState.authenticated(
          user: currentState.user,
          tokens: newTokens,
        );
      } else {
        // 토큰 갱신 실패 시 로그아웃
        await logout();
      }
    } catch (e) {
      await logout();
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    state = const AuthState.loading();

    try {
      await _authService.logout();
    } catch (e) {
      // 로그아웃 API 실패해도 로컬에서는 로그아웃 처리
    }

    state = const AuthState.unauthenticated();
  }

  /// 회원 탈퇴
  Future<void> withdraw() async {
    state = const AuthState.loading();

    try {
      await _authService.withdraw();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error('회원 탈퇴 실패: ${e.toString()}');
    }
  }

  /// 에러 상태 초기화
  void clearError() {
    if (state is AuthStateError) {
      state = const AuthState.unauthenticated();
    }
  }
}

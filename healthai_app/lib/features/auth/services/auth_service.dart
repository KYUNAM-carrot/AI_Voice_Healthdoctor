import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../models/auth_model.dart';
import '../../../core/config/api_config.dart';

/// 인증 서비스
class AuthService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final GoogleSignIn _googleSignIn;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  // Google OAuth Client IDs (Google Cloud Console에서 발급)
  // Web Client ID (백엔드 토큰 검증용)
  static const String _googleWebClientId =
      '83948001824-5q786rp9nr3qu8cb184n20kv4emnufhl.apps.googleusercontent.com';
  // iOS Client ID
  static const String _googleIosClientId =
      '83948001824-lfml21ngg7ngh4f88catp27ofns5dcm5.apps.googleusercontent.com';

  AuthService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
    GoogleSignIn? googleSignIn,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _googleSignIn = googleSignIn ?? _createGoogleSignIn();

  static GoogleSignIn _createGoogleSignIn() {
    if (Platform.isIOS) {
      // iOS: clientId 필수
      return GoogleSignIn(
        scopes: ['email', 'profile'],
        clientId: _googleIosClientId,
        serverClientId: _googleWebClientId,
      );
    }
    // Android: serverClientId는 Web Client ID 사용 (백엔드 검증용)
    // Android Client는 Google Cloud Console에서 SHA-1과 패키지명으로 자동 매칭
    return GoogleSignIn(
      scopes: ['email', 'profile'],
      serverClientId: _googleWebClientId,
    );
  }

  /// 카카오 로그인
  Future<AuthTokens> loginWithKakao() async {
    try {
      // 카카오톡 설치 여부에 따라 로그인 방식 선택
      kakao.OAuthToken token;
      if (await kakao.isKakaoTalkInstalled()) {
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      // 백엔드로 토큰 전송
      return await _socialLogin('kakao', token.accessToken);
    } catch (e) {
      debugPrint('Kakao login error: $e');
      rethrow;
    }
  }

  /// 구글 로그인
  Future<AuthTokens> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google login cancelled');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        throw Exception('Failed to get Google access token');
      }

      // 백엔드로 토큰 전송
      return await _socialLogin('google', accessToken);
    } catch (e) {
      debugPrint('Google login error: $e');
      rethrow;
    }
  }

  /// 애플 로그인
  Future<AuthTokens> loginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String? idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to get Apple ID token');
      }

      // 백엔드로 토큰 전송
      return await _socialLogin('apple', idToken);
    } catch (e) {
      debugPrint('Apple login error: $e');
      rethrow;
    }
  }

  /// 백엔드 소셜 로그인 API 호출
  Future<AuthTokens> _socialLogin(String provider, String token) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login/social',
        data: {
          'provider': provider,
          'token': token,
        },
      );

      final data = response.data;
      final tokens = AuthTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
        tokenType: data['token_type'] ?? 'bearer',
      );

      // 토큰 저장
      await saveTokens(tokens);

      // 사용자 정보 저장
      if (data['user'] != null) {
        await _saveUserData(data['user']);
      }

      return tokens;
    } on DioException catch (e) {
      final message = e.response?.data?['detail'] ?? 'Login failed';
      throw Exception(message);
    }
  }

  /// 토큰 갱신
  Future<AuthTokens?> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: _refreshTokenKey);
      if (refreshToken == null) {
        return null;
      }

      final response = await _dio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      final data = response.data;
      final tokens = AuthTokens(
        accessToken: data['access_token'],
        refreshToken: data['refresh_token'],
        tokenType: data['token_type'] ?? 'bearer',
      );

      await saveTokens(tokens);
      return tokens;
    } catch (e) {
      debugPrint('Token refresh error: $e');
      return null;
    }
  }

  /// 로그아웃
  Future<void> logout() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken != null) {
        await _dio.post(
          '/api/v1/auth/logout',
          options: Options(
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );
      }
    } catch (e) {
      debugPrint('Logout API error: $e');
    }

    // 로컬 데이터 삭제
    await _clearLocalData();

    // 소셜 로그인 세션 종료
    try {
      await _googleSignIn.signOut();
    } catch (_) {}

    try {
      await kakao.UserApi.instance.logout();
    } catch (_) {}
  }

  /// 회원 탈퇴
  Future<void> withdraw() async {
    try {
      final accessToken = await _secureStorage.read(key: _accessTokenKey);
      if (accessToken != null) {
        await _dio.delete(
          '/api/v1/auth/withdraw',
          options: Options(
            headers: {'Authorization': 'Bearer $accessToken'},
          ),
        );
      }
    } catch (e) {
      debugPrint('Withdraw API error: $e');
      rethrow;
    }

    // 로컬 데이터 삭제
    await _clearLocalData();

    // 소셜 로그인 연결 해제
    try {
      await _googleSignIn.disconnect();
    } catch (_) {}

    try {
      await kakao.UserApi.instance.unlink();
    } catch (_) {}
  }

  /// 토큰 저장
  Future<void> saveTokens(AuthTokens tokens) async {
    await _secureStorage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _secureStorage.write(
        key: _refreshTokenKey, value: tokens.refreshToken);
  }

  /// 액세스 토큰 가져오기
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// 리프레시 토큰 가져오기
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// 저장된 사용자 정보 가져오기
  Future<UserModel?> getSavedUser() async {
    try {
      final userData = await _secureStorage.read(key: _userKey);
      if (userData == null) return null;

      // JSON 파싱 (간단한 구현)
      final parts = userData.split('|');
      if (parts.length < 2) return null;

      return UserModel(
        userId: parts[0],
        name: parts[1],
        email: parts.length > 2 ? parts[2] : null,
        profileImageUrl: parts.length > 3 ? parts[3] : null,
      );
    } catch (e) {
      debugPrint('Get saved user error: $e');
      return null;
    }
  }

  /// 현재 사용자 정보 조회 (API)
  Future<UserModel?> getCurrentUser() async {
    try {
      final accessToken = await getAccessToken();
      if (accessToken == null) return null;

      final response = await _dio.get(
        '/api/v1/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      final data = response.data;
      final user = UserModel(
        userId: data['user_id'],
        name: data['name'],
        email: data['email'],
        profileImageUrl: data['profile_image_url'],
        subscriptionTier: data['subscription_tier'] ?? 'free',
        subscriptionStatus: data['subscription_status'] ?? 'active',
      );

      await _saveUserData(data);
      return user;
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  /// 로그인 상태 확인
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null;
  }

  /// 사용자 데이터 저장
  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final dataString = [
      userData['user_id'] ?? '',
      userData['name'] ?? '',
      userData['email'] ?? '',
      userData['profile_image_url'] ?? '',
    ].join('|');

    await _secureStorage.write(key: _userKey, value: dataString);
  }

  /// 로컬 데이터 삭제
  Future<void> _clearLocalData() async {
    await _secureStorage.delete(key: _accessTokenKey);
    await _secureStorage.delete(key: _refreshTokenKey);
    await _secureStorage.delete(key: _userKey);
  }
}

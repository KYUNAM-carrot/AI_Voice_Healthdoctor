import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

/// 사용자 정보 모델
@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String userId,
    required String name,
    String? email,
    String? profileImageUrl,
    @Default('free') String subscriptionTier,
    @Default('active') String subscriptionStatus,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

/// 인증 토큰 모델
@freezed
class AuthTokens with _$AuthTokens {
  const factory AuthTokens({
    required String accessToken,
    required String refreshToken,
    @Default('bearer') String tokenType,
  }) = _AuthTokens;

  factory AuthTokens.fromJson(Map<String, dynamic> json) =>
      _$AuthTokensFromJson(json);
}

/// 인증 상태 모델
@freezed
class AuthState with _$AuthState {
  /// 초기 상태 (로딩 중)
  const factory AuthState.initial() = AuthStateInitial;

  /// 인증되지 않은 상태
  const factory AuthState.unauthenticated() = AuthStateUnauthenticated;

  /// 인증된 상태
  const factory AuthState.authenticated({
    required UserModel user,
    required AuthTokens tokens,
  }) = AuthStateAuthenticated;

  /// 로딩 상태
  const factory AuthState.loading() = AuthStateLoading;

  /// 에러 상태
  const factory AuthState.error(String message) = AuthStateError;
}

/// 소셜 로그인 제공자
enum SocialProvider {
  kakao,
  google,
  apple,
}

extension SocialProviderExtension on SocialProvider {
  String get name {
    switch (this) {
      case SocialProvider.kakao:
        return 'kakao';
      case SocialProvider.google:
        return 'google';
      case SocialProvider.apple:
        return 'apple';
    }
  }

  String get displayName {
    switch (this) {
      case SocialProvider.kakao:
        return '카카오';
      case SocialProvider.google:
        return 'Google';
      case SocialProvider.apple:
        return 'Apple';
    }
  }
}

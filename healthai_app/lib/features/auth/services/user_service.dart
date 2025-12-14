import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/api_config.dart';

/// 프로필 업데이트 요청 모델
class ProfileUpdateRequest {
  final String? name;
  final String? phoneNumber;
  final DateTime? birthDate;
  final String? gender;
  final String? profileImageUrl;
  final int? heightCm;
  final int? weightKg;
  final String? bloodType;
  final List<String>? chronicConditions;
  final List<String>? medications;
  final List<String>? allergies;

  ProfileUpdateRequest({
    this.name,
    this.phoneNumber,
    this.birthDate,
    this.gender,
    this.profileImageUrl,
    this.heightCm,
    this.weightKg,
    this.bloodType,
    this.chronicConditions,
    this.medications,
    this.allergies,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (name != null) map['name'] = name;
    if (phoneNumber != null) map['phone_number'] = phoneNumber;
    if (birthDate != null) map['birth_date'] = birthDate!.toIso8601String();
    if (gender != null) map['gender'] = gender;
    if (profileImageUrl != null) map['profile_image_url'] = profileImageUrl;
    if (heightCm != null) map['height_cm'] = heightCm;
    if (weightKg != null) map['weight_kg'] = weightKg;
    if (bloodType != null) map['blood_type'] = bloodType;
    if (chronicConditions != null) map['chronic_conditions'] = chronicConditions;
    if (medications != null) map['medications'] = medications;
    if (allergies != null) map['allergies'] = allergies;
    return map;
  }
}

/// 사용자 프로필 응답 모델
class UserProfile {
  final String userId;
  final String? email;
  final String? phoneNumber;
  final String name;
  final DateTime? birthDate;
  final String? gender;
  final String? profileImageUrl;
  final String? oauthProvider;
  final int? heightCm;
  final int? weightKg;
  final String? bloodType;
  final List<String>? chronicConditions;
  final List<String>? medications;
  final List<String>? allergies;
  final String subscriptionTier;
  final String subscriptionStatus;
  final DateTime? subscriptionEndDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.userId,
    this.email,
    this.phoneNumber,
    required this.name,
    this.birthDate,
    this.gender,
    this.profileImageUrl,
    this.oauthProvider,
    this.heightCm,
    this.weightKg,
    this.bloodType,
    this.chronicConditions,
    this.medications,
    this.allergies,
    required this.subscriptionTier,
    required this.subscriptionStatus,
    this.subscriptionEndDate,
    required this.createdAt,
    required this.updatedAt,
    this.lastLoginAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      name: json['name'],
      birthDate: json['birth_date'] != null ? DateTime.parse(json['birth_date']) : null,
      gender: json['gender'],
      profileImageUrl: json['profile_image_url'],
      oauthProvider: json['oauth_provider'],
      heightCm: json['height_cm'],
      weightKg: json['weight_kg'],
      bloodType: json['blood_type'],
      chronicConditions: json['chronic_conditions'] != null
          ? List<String>.from(json['chronic_conditions'])
          : null,
      medications: json['medications'] != null
          ? List<String>.from(json['medications'])
          : null,
      allergies: json['allergies'] != null
          ? List<String>.from(json['allergies'])
          : null,
      subscriptionTier: json['subscription_tier'] ?? 'free',
      subscriptionStatus: json['subscription_status'] ?? 'active',
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }
}

/// 사용자 서비스 - 백엔드 API 연동
class UserService {
  final Dio _dio;

  UserService({Dio? dio})
      : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  /// 현재 사용자 프로필 조회
  Future<UserProfile?> getMyProfile(String accessToken) async {
    try {
      final response = await _dio.get(
        '/api/v1/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Get profile error: ${e.response?.data}');
      return null;
    } catch (e) {
      debugPrint('Get profile error: $e');
      return null;
    }
  }

  /// 현재 사용자 프로필 업데이트
  Future<UserProfile?> updateMyProfile(
    String accessToken,
    ProfileUpdateRequest request,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v1/users/me',
        data: request.toJson(),
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );

      return UserProfile.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Update profile error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  /// 사용자 계정 삭제
  Future<bool> deleteMyAccount(String accessToken) async {
    try {
      await _dio.delete(
        '/api/v1/users/me',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
      return true;
    } on DioException catch (e) {
      debugPrint('Delete account error: ${e.response?.data}');
      return false;
    } catch (e) {
      debugPrint('Delete account error: $e');
      return false;
    }
  }
}

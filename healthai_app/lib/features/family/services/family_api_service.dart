import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/api_config.dart';
import '../../auth/services/auth_service.dart';
import '../models/family_profile_model.dart';

/// 구독 업그레이드 필요 예외
class UpgradeRequiredException implements Exception {
  final String currentPlan;
  final String currentPlanName;
  final int currentLimit;
  final int currentCount;
  final String? nextPlan;
  final String? nextPlanName;
  final int nextPlanLimit;
  final String message;

  UpgradeRequiredException({
    required this.currentPlan,
    required this.currentPlanName,
    required this.currentLimit,
    required this.currentCount,
    this.nextPlan,
    this.nextPlanName,
    required this.nextPlanLimit,
    required this.message,
  });

  /// 백엔드 오류 메시지 파싱
  factory UpgradeRequiredException.fromErrorMessage(String detail) {
    // 형식: UPGRADE_REQUIRED|plan|plan_name|limit|count|next_plan|next_plan_name|next_limit|message
    final parts = detail.split('|');
    if (parts.length >= 9) {
      return UpgradeRequiredException(
        currentPlan: parts[1],
        currentPlanName: parts[2],
        currentLimit: int.tryParse(parts[3]) ?? 0,
        currentCount: int.tryParse(parts[4]) ?? 0,
        nextPlan: parts[5].isNotEmpty ? parts[5] : null,
        nextPlanName: parts[6].isNotEmpty ? parts[6] : null,
        nextPlanLimit: int.tryParse(parts[7]) ?? 0,
        message: parts[8],
      );
    }
    // 파싱 실패 시 기본값
    return UpgradeRequiredException(
      currentPlan: 'unknown',
      currentPlanName: '알 수 없음',
      currentLimit: 0,
      currentCount: 0,
      nextPlanLimit: 0,
      message: detail,
    );
  }

  @override
  String toString() => message;
}

/// 가족 프로필 API 서비스
class FamilyApiService {
  final Dio _dio;
  final AuthService _authService;

  FamilyApiService({
    Dio? dio,
    AuthService? authService,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
        _authService = authService ?? AuthService();

  /// 인증 헤더 가져오기
  Future<Options> _getAuthOptions() async {
    final token = await _authService.getAccessToken();
    debugPrint('FamilyApiService - Access token: ${token != null ? "exists (${token.length} chars)" : "NULL"}');
    if (token == null || token.isEmpty) {
      throw Exception('인증 토큰이 없습니다. 다시 로그인해주세요.');
    }
    return Options(
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  /// 모든 가족 프로필 조회
  Future<List<FamilyProfileModel>> getProfiles() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '/api/v1/families',
        options: options,
      );

      final List<dynamic> data = response.data;
      return data.map((json) => _mapResponseToModel(json)).toList();
    } on DioException catch (e) {
      debugPrint('Get family profiles error: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      }
      final message = e.response?.data?['detail'] ?? '가족 프로필을 불러오는데 실패했습니다';
      throw Exception(message);
    }
  }

  /// 특정 가족 프로필 조회
  Future<FamilyProfileModel> getProfile(String profileId) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '/api/v1/families/$profileId',
        options: options,
      );

      return _mapResponseToModel(response.data);
    } on DioException catch (e) {
      debugPrint('Get family profile error: $e');
      final message = e.response?.data?['detail'] ?? '프로필을 불러오는데 실패했습니다';
      throw Exception(message);
    }
  }

  /// 가족 프로필 생성
  Future<FamilyProfileModel> createProfile({
    required String name,
    required String relationshipType,
    DateTime? birthDate,
    String? gender,
    String? profileImageUrl,
    int? heightCm,
    int? weightKg,
    String? bloodType,
    List<String>? chronicConditions,
    List<String>? medications,
    List<String>? allergies,
  }) async {
    try {
      final options = await _getAuthOptions();

      final response = await _dio.post(
        '/api/v1/families',
        data: {
          'name': name,
          'relationship_type': relationshipType,
          if (birthDate != null) 'birth_date': birthDate.toIso8601String(),
          if (gender != null) 'gender': gender,
          if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
          if (heightCm != null) 'height_cm': heightCm,
          if (weightKg != null) 'weight_kg': weightKg,
          if (bloodType != null) 'blood_type': bloodType,
          if (chronicConditions != null) 'chronic_conditions': chronicConditions,
          if (medications != null) 'medications': medications,
          if (allergies != null) 'allergies': allergies,
        },
        options: options,
      );

      debugPrint('Create family profile success: ${response.data}');
      return _mapResponseToModel(response.data);
    } on DioException catch (e) {
      debugPrint('Create family profile error: ${e.response?.statusCode} - ${e.response?.data}');
      debugPrint('Request headers: ${e.requestOptions.headers}');

      // 401 인증 오류
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      }

      final detail = e.response?.data?['detail'] ?? '프로필 생성에 실패했습니다';

      // 403 오류이고 업그레이드 필요 메시지인 경우
      if (e.response?.statusCode == 403 &&
          (detail.toString().startsWith('UPGRADE_REQUIRED') ||
           detail.toString().startsWith('LIMIT_REACHED'))) {
        throw UpgradeRequiredException.fromErrorMessage(detail.toString());
      }

      throw Exception(detail);
    }
  }

  /// 가족 프로필 수정
  Future<FamilyProfileModel> updateProfile({
    required String profileId,
    String? name,
    String? profileImageUrl,
    int? heightCm,
    int? weightKg,
    String? bloodType,
    List<String>? chronicConditions,
    List<String>? medications,
    List<String>? allergies,
  }) async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.patch(
        '/api/v1/families/$profileId',
        data: {
          if (name != null) 'name': name,
          if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
          if (heightCm != null) 'height_cm': heightCm,
          if (weightKg != null) 'weight_kg': weightKg,
          if (bloodType != null) 'blood_type': bloodType,
          if (chronicConditions != null) 'chronic_conditions': chronicConditions,
          if (medications != null) 'medications': medications,
          if (allergies != null) 'allergies': allergies,
        },
        options: options,
      );

      return _mapResponseToModel(response.data);
    } on DioException catch (e) {
      debugPrint('Update family profile error: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      }
      final message = e.response?.data?['detail'] ?? '프로필 수정에 실패했습니다';
      throw Exception(message);
    }
  }

  /// 가족 프로필 삭제
  Future<void> deleteProfile(String profileId) async {
    try {
      final options = await _getAuthOptions();
      await _dio.delete(
        '/api/v1/families/$profileId',
        options: options,
      );
    } on DioException catch (e) {
      debugPrint('Delete family profile error: ${e.response?.statusCode} - ${e.response?.data}');
      if (e.response?.statusCode == 401) {
        throw Exception('인증이 만료되었습니다. 다시 로그인해주세요.');
      }
      final message = e.response?.data?['detail'] ?? '프로필 삭제에 실패했습니다';
      throw Exception(message);
    }
  }

  /// 백엔드 응답을 모델로 변환
  FamilyProfileModel _mapResponseToModel(Map<String, dynamic> json) {
    return FamilyProfileModel(
      id: json['profile_id'],
      userId: json['owner_id'],
      name: json['name'],
      relationship: json['relationship_type'],
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'])
          : DateTime.now(),
      gender: json['gender'],
      profileImageUrl: json['profile_image_url'],
      bloodType: json['blood_type'],
      height: json['height_cm']?.toDouble(),
      weight: json['weight_kg']?.toDouble(),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      chronicConditions: List<String>.from(json['chronic_conditions'] ?? []),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }
}

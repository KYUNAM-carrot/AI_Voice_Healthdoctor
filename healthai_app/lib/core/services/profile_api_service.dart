import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../../features/settings/providers/profile_provider.dart';

/// 프로필 API 서비스
///
/// 백엔드 서버와 프로필 데이터를 동기화
class ProfileApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  static const String _accessTokenKey = 'access_token';

  ProfileApiService({
    Dio? dio,
    FlutterSecureStorage? secureStorage,
  })  : _dio = dio ?? Dio(BaseOptions(baseUrl: ApiConfig.baseUrl)),
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// 액세스 토큰 가져오기
  Future<String?> _getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// 인증 헤더 생성
  Future<Options> _getAuthOptions() async {
    final token = await _getAccessToken();
    return Options(
      headers: token != null ? {'Authorization': 'Bearer $token'} : null,
    );
  }

  /// 서버에서 프로필 데이터 가져오기
  Future<ProfileData?> fetchProfile() async {
    try {
      final options = await _getAuthOptions();
      final response = await _dio.get(
        '/api/v1/users/me',
        options: options,
      );

      final data = response.data;
      debugPrint('[ProfileAPI] 서버에서 프로필 가져오기 성공');

      return _serverToProfileData(data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        debugPrint('[ProfileAPI] 인증 토큰 만료');
      } else {
        debugPrint('[ProfileAPI] 프로필 가져오기 실패: ${e.response?.statusCode}');
      }
      return null;
    } catch (e) {
      debugPrint('[ProfileAPI] 프로필 가져오기 오류');
      return null;
    }
  }

  /// 서버에 프로필 데이터 저장
  Future<bool> saveProfile(ProfileData profile) async {
    try {
      final options = await _getAuthOptions();
      final data = _profileDataToServer(profile);

      await _dio.patch(
        '/api/v1/users/me',
        data: data,
        options: options,
      );

      debugPrint('[ProfileAPI] 서버 프로필 저장 성공');
      return true;
    } on DioException catch (e) {
      debugPrint('[ProfileAPI] 프로필 저장 실패: ${e.response?.statusCode}');
      return false;
    } catch (e) {
      debugPrint('[ProfileAPI] 프로필 저장 오류');
      return false;
    }
  }

  /// 서버 응답을 ProfileData로 변환
  ProfileData _serverToProfileData(Map<String, dynamic> data) {
    // 생년월일 파싱 (YYYY-MM-DD 형식)
    int? birthYear;
    int? birthMonth;
    if (data['birth_date'] != null) {
      try {
        final birthDate = DateTime.parse(data['birth_date']);
        birthYear = birthDate.year;
        birthMonth = birthDate.month;
      } catch (e) {
        debugPrint('생년월일 파싱 오류: $e');
      }
    }

    // 성별 변환 (M/F -> male/female)
    String? gender;
    if (data['gender'] != null) {
      gender = data['gender'] == 'M' ? 'male' :
               data['gender'] == 'F' ? 'female' : null;
    }

    return ProfileData(
      gender: gender,
      birthYear: birthYear,
      birthMonth: birthMonth,
      height: data['height_cm']?.toInt(),
      weight: data['weight_kg']?.toInt(),
      bloodType: data['blood_type'],
      chronicConditions: List<String>.from(data['chronic_conditions'] ?? []),
      allergies: List<String>.from(data['allergies'] ?? []),
      medications: List<String>.from(data['medications'] ?? []),
      profileImagePath: data['profile_image_url'],
    );
  }

  /// ProfileData를 서버 요청 형식으로 변환
  Map<String, dynamic> _profileDataToServer(ProfileData profile) {
    final data = <String, dynamic>{};

    // 생년월일 (YYYY-MM-DD 형식)
    if (profile.birthYear != null) {
      final month = profile.birthMonth ?? 1;
      data['birth_date'] = '${profile.birthYear}-${month.toString().padLeft(2, '0')}-01';
    }

    // 성별 변환 (male/female -> M/F)
    if (profile.gender != null) {
      data['gender'] = profile.gender == 'male' ? 'M' :
                       profile.gender == 'female' ? 'F' : null;
    }

    // 키, 체중
    if (profile.height != null) {
      data['height_cm'] = profile.height!.toDouble();
    }
    if (profile.weight != null) {
      data['weight_kg'] = profile.weight!.toDouble();
    }

    // 혈액형
    if (profile.bloodType != null) {
      data['blood_type'] = profile.bloodType;
    }

    // 만성질환, 알레르기, 복용약물
    data['chronic_conditions'] = profile.chronicConditions;
    data['allergies'] = profile.allergies;
    data['medications'] = profile.medications;

    return data;
  }
}

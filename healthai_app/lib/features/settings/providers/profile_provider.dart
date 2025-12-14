import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/profile_api_service.dart';
import '../../../core/services/secure_storage_service.dart';

/// 프로필 데이터 모델
class ProfileData {
  final String? gender;
  final int? birthYear;
  final int? birthMonth;
  final int? height;
  final int? weight;
  final String? bloodType;
  final List<String> chronicConditions;
  final List<String> allergies;
  final List<String> medications;
  final String? profileImagePath;

  ProfileData({
    this.gender,
    this.birthYear,
    this.birthMonth,
    this.height,
    this.weight,
    this.bloodType,
    this.chronicConditions = const [],
    this.allergies = const [],
    this.medications = const [],
    this.profileImagePath,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      gender: json['gender'],
      birthYear: json['birthYear'],
      birthMonth: json['birthMonth'],
      height: json['height'],
      weight: json['weight'],
      bloodType: json['bloodType'],
      chronicConditions: List<String>.from(json['chronicConditions'] ?? []),
      allergies: List<String>.from(json['allergies'] ?? []),
      medications: List<String>.from(json['medications'] ?? []),
      profileImagePath: json['profileImagePath'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gender': gender,
      'birthYear': birthYear,
      'birthMonth': birthMonth,
      'height': height,
      'weight': weight,
      'bloodType': bloodType,
      'chronicConditions': chronicConditions,
      'allergies': allergies,
      'medications': medications,
      'profileImagePath': profileImagePath,
    };
  }

  ProfileData copyWith({
    String? gender,
    int? birthYear,
    int? birthMonth,
    int? height,
    int? weight,
    String? bloodType,
    List<String>? chronicConditions,
    List<String>? allergies,
    List<String>? medications,
    String? profileImagePath,
  }) {
    return ProfileData(
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      birthMonth: birthMonth ?? this.birthMonth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bloodType: bloodType ?? this.bloodType,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      allergies: allergies ?? this.allergies,
      medications: medications ?? this.medications,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }
}

/// 프로필 상태 관리 Notifier
///
/// 민감한 건강 정보는 FlutterSecureStorage를 통해 암호화되어 저장됨
class ProfileNotifier extends StateNotifier<ProfileData?> {
  final String _userId;
  final ProfileApiService _apiService;
  Future<void>? _loadingFuture;
  bool _isSyncing = false;

  ProfileNotifier(this._userId)
      : _apiService = ProfileApiService(),
        super(null) {
    _loadingFuture = _loadProfile();
  }

  /// 프로필 데이터 로드 (암호화된 로컬 저장소 → 서버 동기화)
  Future<void> _loadProfile() async {
    try {
      // 1. 암호화된 로컬 저장소에서 먼저 로드 (빠른 응답)
      final json = await SecureStorageService.readProfileJson(_userId);

      if (json != null) {
        state = ProfileData.fromJson(json);
        debugPrint('[Profile] 암호화된 로컬 프로필 로드 완료');
      } else {
        debugPrint('[Profile] 저장된 로컬 프로필 없음');
      }

      // 2. 서버에서 최신 데이터 동기화 (백그라운드)
      _syncFromServer();
    } catch (e) {
      debugPrint('[Profile] 로드 오류: $e');
    }
  }

  /// 서버에서 프로필 동기화
  Future<void> _syncFromServer() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      debugPrint('[Profile] 서버 동기화 시작...');
      final serverProfile = await _apiService.fetchProfile();

      if (serverProfile != null) {
        final hasServerData = _hasProfileData(serverProfile);
        final hasLocalData = state != null && _hasProfileData(state!);

        if (hasServerData) {
          // 서버 데이터로 로컬 업데이트
          state = serverProfile;
          await _saveToLocal(serverProfile);
          debugPrint('[Profile] 서버 → 로컬 동기화 완료');
        } else if (hasLocalData) {
          // 로컬에 데이터가 있고 서버에 없으면 서버에 업로드
          await _apiService.saveProfile(state!);
          debugPrint('[Profile] 로컬 → 서버 업로드 완료');
        }
      }
    } catch (e) {
      debugPrint('[Profile] 서버 동기화 오류: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 프로필 데이터가 유효한지 확인
  bool _hasProfileData(ProfileData profile) {
    return profile.gender != null ||
           profile.birthYear != null ||
           profile.height != null ||
           profile.weight != null ||
           profile.bloodType != null ||
           profile.chronicConditions.isNotEmpty ||
           profile.allergies.isNotEmpty ||
           profile.medications.isNotEmpty;
  }

  /// 로컬에 프로필 저장 (암호화)
  Future<void> _saveToLocal(ProfileData data) async {
    try {
      await SecureStorageService.saveProfileJson(_userId, data.toJson());
    } catch (e) {
      debugPrint('[Profile] 암호화 저장 오류: $e');
    }
  }

  /// 프로필 데이터 로드 완료까지 대기
  Future<ProfileData?> loadAndGetProfile() async {
    if (_loadingFuture != null) {
      await _loadingFuture;
    }
    return state;
  }

  /// 프로필 데이터 저장 (암호화된 로컬 + 서버)
  Future<bool> saveProfile(ProfileData data) async {
    try {
      // 1. 암호화된 로컬 저장소에 저장
      await SecureStorageService.saveProfileJson(_userId, data.toJson());
      state = data;
      debugPrint('[Profile] 암호화 저장 완료');

      // 2. 서버에 동기화 (백그라운드)
      _syncToServer(data);

      return true;
    } catch (e) {
      debugPrint('[Profile] 저장 오류: $e');
      return false;
    }
  }

  /// 서버에 프로필 동기화
  Future<void> _syncToServer(ProfileData data) async {
    try {
      final success = await _apiService.saveProfile(data);
      debugPrint('[Profile] 서버 동기화: ${success ? '성공' : '실패'}');
    } catch (e) {
      debugPrint('[Profile] 서버 동기화 오류: $e');
    }
  }

  /// 서버에서 강제로 다시 동기화
  Future<void> forceSync() async {
    await _syncFromServer();
  }

  /// 프로필 데이터 삭제
  Future<void> clearProfile() async {
    try {
      await SecureStorageService.deleteProfile(_userId);
      state = null;
      debugPrint('[Profile] 프로필 삭제 완료');
    } catch (e) {
      debugPrint('[Profile] 삭제 오류: $e');
    }
  }
}

/// 프로필 Provider (사용자별)
final profileProvider = StateNotifierProvider.family<ProfileNotifier, ProfileData?, String>(
  (ref, userId) => ProfileNotifier(userId),
);

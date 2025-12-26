import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_profile_model.dart';
import '../services/family_api_service.dart';
import '../../auth/providers/auth_provider.dart';

/// 가족 API 서비스 프로바이더
final familyApiServiceProvider = Provider<FamilyApiService>((ref) {
  return FamilyApiService();
});

/// 가족 프로필 목록 프로바이더
final familyProfilesProvider =
    AsyncNotifierProvider<FamilyProfilesNotifier, List<FamilyProfileModel>>(
  FamilyProfilesNotifier.new,
);

/// 선택된 가족 프로필 프로바이더 (상담 시 사용)
final selectedFamilyProfileProvider =
    StateProvider<FamilyProfileModel?>((ref) => null);

/// 가족 프로필 Notifier
class FamilyProfilesNotifier extends AsyncNotifier<List<FamilyProfileModel>> {
  late FamilyApiService _apiService;

  @override
  Future<List<FamilyProfileModel>> build() async {
    // authState를 watch하여 로그인/로그아웃 시 자동으로 프로필 목록 갱신
    final authState = ref.watch(authStateProvider);

    // 인증되지 않은 경우 빈 목록 반환 및 선택된 프로필 초기화
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_, __) => true,
      orElse: () => false,
    );

    if (!isAuthenticated) {
      // 로그아웃 시 선택된 프로필 초기화
      ref.read(selectedFamilyProfileProvider.notifier).state = null;
      return [];
    }

    _apiService = ref.read(familyApiServiceProvider);
    return _fetchProfiles();
  }

  /// 프로필 목록 조회
  Future<List<FamilyProfileModel>> _fetchProfiles() async {
    try {
      return await _apiService.getProfiles();
    } catch (e) {
      // 로그인되지 않은 경우 빈 리스트 반환
      return [];
    }
  }

  /// 프로필 목록 새로고침
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchProfiles());
  }

  /// 프로필 생성
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
    final newProfile = await _apiService.createProfile(
      name: name,
      relationshipType: relationshipType,
      birthDate: birthDate,
      gender: gender,
      profileImageUrl: profileImageUrl,
      heightCm: heightCm,
      weightKg: weightKg,
      bloodType: bloodType,
      chronicConditions: chronicConditions,
      medications: medications,
      allergies: allergies,
    );

    // 목록에 추가
    final currentProfiles = state.value ?? [];
    state = AsyncValue.data([newProfile, ...currentProfiles]);

    return newProfile;
  }

  /// 프로필 수정
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
    final updatedProfile = await _apiService.updateProfile(
      profileId: profileId,
      name: name,
      profileImageUrl: profileImageUrl,
      heightCm: heightCm,
      weightKg: weightKg,
      bloodType: bloodType,
      chronicConditions: chronicConditions,
      medications: medications,
      allergies: allergies,
    );

    // 목록에서 업데이트
    final currentProfiles = state.value ?? [];
    state = AsyncValue.data(
      currentProfiles.map((p) {
        return p.id == profileId ? updatedProfile : p;
      }).toList(),
    );

    return updatedProfile;
  }

  /// 프로필 삭제
  Future<void> deleteProfile(String profileId) async {
    await _apiService.deleteProfile(profileId);

    // 목록에서 제거
    final currentProfiles = state.value ?? [];
    state = AsyncValue.data(
      currentProfiles.where((p) => p.id != profileId).toList(),
    );

    // 선택된 프로필이 삭제된 경우 선택 해제
    final selectedProfile = ref.read(selectedFamilyProfileProvider);
    if (selectedProfile?.id == profileId) {
      ref.read(selectedFamilyProfileProvider.notifier).state = null;
    }
  }
}

/// 관계 타입 한글 변환
String getRelationshipLabel(String relationshipType) {
  switch (relationshipType) {
    case 'father':
      return '아버지';
    case 'mother':
      return '어머니';
    case 'spouse':
      return '배우자';
    case 'child':
      return '자녀';
    case 'sibling':
      return '형제/자매';
    case 'grandparent':
      return '조부모';
    case 'grandchild':
      return '손자녀';
    case 'self':
      return '본인';
    case 'other':
    default:
      return '기타';
  }
}

/// 관계 타입 목록 (생성/수정 폼에서 사용)
const List<Map<String, String>> relationshipTypes = [
  {'value': 'spouse', 'label': '배우자'},
  {'value': 'father', 'label': '아버지'},
  {'value': 'mother', 'label': '어머니'},
  {'value': 'child', 'label': '자녀'},
  {'value': 'sibling', 'label': '형제/자매'},
  {'value': 'grandparent', 'label': '조부모'},
  {'value': 'grandchild', 'label': '손자녀'},
  {'value': 'other', 'label': '기타'},
];

/// 성별 목록
const List<Map<String, String>> genderTypes = [
  {'value': 'male', 'label': '남성'},
  {'value': 'female', 'label': '여성'},
  {'value': 'other', 'label': '기타'},
];

/// 혈액형 목록
const List<String> bloodTypes = [
  'A+',
  'A-',
  'B+',
  'B-',
  'O+',
  'O-',
  'AB+',
  'AB-',
];

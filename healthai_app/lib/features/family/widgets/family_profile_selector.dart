import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../models/family_profile_model.dart';
import '../providers/family_provider.dart';
import '../screens/family_profile_form_screen.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/auth_model.dart';

/// 가족 프로필 선택 다이얼로그
/// 상담 시작 전 누구를 위한 상담인지 선택
class FamilyProfileSelector extends ConsumerStatefulWidget {
  final String characterName;
  final Function(FamilyProfileModel profile) onProfileSelected;

  const FamilyProfileSelector({
    super.key,
    required this.characterName,
    required this.onProfileSelected,
  });

  @override
  ConsumerState<FamilyProfileSelector> createState() =>
      _FamilyProfileSelectorState();
}

class _FamilyProfileSelectorState extends ConsumerState<FamilyProfileSelector> {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getSavedUser();
    if (mounted) {
      setState(() {
        _currentUser = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(familyProfilesProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              children: [
                Text(
                  '누구를 위한 상담인가요?',
                  style: AppTheme.h2,
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.characterName} 선생님과 상담을 시작합니다',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 프로필 목록
          Flexible(
            child: profilesAsync.when(
              data: (profiles) => _buildProfileList(context, ref, profiles),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: AppTheme.error),
                    const SizedBox(height: 12),
                    Text(
                      '프로필을 불러오는데 실패했습니다',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          ref.read(familyProfilesProvider.notifier).refresh(),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 하단 여백
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildProfileList(
      BuildContext context, WidgetRef ref, List<FamilyProfileModel> profiles) {
    // "본인" 프로필을 맨 위에 추가 (현재 로그인 사용자)
    final bool hasCurrentUser = _currentUser != null;

    // 총 아이템 수: 본인(있으면) + 가족 프로필들 + 추가 버튼
    final totalItems = (hasCurrentUser ? 1 : 0) + profiles.length + 1;

    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: totalItems,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
      itemBuilder: (context, index) {
        // 본인 프로필 (맨 위)
        if (hasCurrentUser && index == 0) {
          return _buildSelfProfileTile();
        }

        // 인덱스 조정 (본인 프로필이 있으면 1 감소)
        final adjustedIndex = hasCurrentUser ? index - 1 : index;

        // 가족 프로필 추가 버튼 (맨 마지막)
        if (adjustedIndex == profiles.length) {
          return ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppTheme.primary,
              ),
            ),
            title: const Text(
              '새 가족 프로필 추가',
              style: TextStyle(
                color: AppTheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            onTap: () => _navigateToAddProfile(context),
          );
        }

        // 가족 프로필
        final profile = profiles[adjustedIndex];
        final age = DateTime.now().year - profile.birthDate.year;
        final relationLabel = getRelationshipLabel(profile.relationship);

        return ListTile(
          leading: ProfileAvatar(
            imageUrl: profile.profileImageUrl,
            name: profile.name,
            size: 48,
          ),
          title: Text(
            profile.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '$relationLabel · ${age}세',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).pop();
            widget.onProfileSelected(profile);
          },
        );
      },
    );
  }

  /// 본인 프로필 타일 위젯
  Widget _buildSelfProfileTile() {
    final user = _currentUser!;

    // 본인 프로필을 FamilyProfileModel로 변환하여 선택 시 전달
    final selfProfile = FamilyProfileModel(
      id: 'self_${user.userId}',  // "self_" 접두사로 본인 식별
      userId: user.userId,
      name: user.name,
      relationship: 'self',  // 본인
      birthDate: DateTime(1990, 1, 1),  // 기본값 (사용자 정보에 없음)
      profileImageUrl: user.profileImageUrl,
    );

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primary.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primary,
            width: 2,
          ),
        ),
        child: user.profileImageUrl != null
            ? ClipOval(
                child: Image.network(
                  user.profileImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.person,
                    color: AppTheme.primary,
                    size: 24,
                  ),
                ),
              )
            : const Icon(
                Icons.person,
                color: AppTheme.primary,
                size: 24,
              ),
      ),
      title: Row(
        children: [
          Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '본인',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        '나를 위한 상담',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).pop();
        widget.onProfileSelected(selfProfile);
      },
    );
  }

  void _navigateToAddProfile(BuildContext context) {
    Navigator.of(context).pop(); // 다이얼로그 닫기
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FamilyProfileFormScreen(),
      ),
    );
  }
}

/// 가족 프로필 선택 바텀시트 표시
Future<FamilyProfileModel?> showFamilyProfileSelector({
  required BuildContext context,
  required String characterName,
}) async {
  FamilyProfileModel? selectedProfile;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    constraints: BoxConstraints(
      maxHeight: MediaQuery.of(context).size.height * 0.7,
    ),
    builder: (context) => FamilyProfileSelector(
      characterName: characterName,
      onProfileSelected: (profile) {
        selectedProfile = profile;
      },
    ),
  );

  return selectedProfile;
}

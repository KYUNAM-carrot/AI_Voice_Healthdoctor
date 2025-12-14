import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/user_service.dart';
import '../../family/providers/family_provider.dart';
import '../providers/withdrawal_provider.dart';
import '../providers/profile_provider.dart';

/// 주요 만성질환 목록
const List<String> commonChronicConditions = [
  '고혈압',
  '당뇨병',
  '고지혈증',
  '심장질환',
  '뇌혈관질환',
  '관절염',
  '골다공증',
  '천식',
  '갑상선질환',
  '위장질환',
  '신장질환',
  '간질환',
];

/// 주요 알레르기 목록
const List<String> commonAllergies = [
  '페니실린',
  '아스피린',
  '땅콩',
  '갑각류(새우/게)',
  '계란',
  '우유',
  '밀(글루텐)',
  '대두',
  '견과류',
  '꽃가루',
  '먼지/진드기',
  '동물털',
];

/// 주요 복용 약물 목록
const List<String> commonMedications = [
  '혈압약',
  '당뇨약',
  '고지혈증약',
  '아스피린',
  '혈전용해제',
  '갑상선약',
  '위장약',
  '수면제',
  '진통제',
  '비타민',
  '칼슘제',
  '철분제',
];

/// 프로필 수정 화면
class ProfileEditScreen extends ConsumerStatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  ConsumerState<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends ConsumerState<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  // 기본 정보
  String? _selectedGender;
  String? _selectedBloodType;
  int? _selectedBirthYear;
  int? _selectedBirthMonth;

  // 건강정보 체크박스 상태
  Set<String> _selectedChronicConditions = {};
  Set<String> _selectedAllergies = {};
  Set<String> _selectedMedications = {};

  bool _isLoading = false;
  bool _isDataLoaded = false;

  // 프로필 이미지
  File? _selectedImage;
  final ImagePicker _imagePicker = ImagePicker();

  // 연도 목록 생성 (1920 ~ 현재년도)
  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1920 + 1, (i) => currentYear - i);
  }

  // 월 목록
  List<int> get _months => List.generate(12, (i) => i + 1);

  @override
  void initState() {
    super.initState();
    // 데이터 로드 시작
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      setState(() => _isDataLoaded = true);
      return;
    }

    debugPrint('프로필 화면 데이터 로드 - userId: ${user.userId}');

    // 기본 사용자 정보 로드
    _nameController.text = user.name;
    _emailController.text = user.email ?? '';

    // 프로필 데이터를 비동기로 로드
    final profileNotifier = ref.read(profileProvider(user.userId).notifier);
    final profile = await profileNotifier.loadAndGetProfile();

    debugPrint('로드된 프로필 데이터: ${profile?.toJson()}');

    if (mounted && profile != null) {
      // 저장된 프로필 이미지 로드
      File? savedImage;
      if (profile.profileImagePath != null) {
        final imageFile = File(profile.profileImagePath!);
        if (await imageFile.exists()) {
          savedImage = imageFile;
          debugPrint('저장된 프로필 이미지 로드: ${profile.profileImagePath}');
        } else {
          debugPrint('프로필 이미지 파일이 존재하지 않음: ${profile.profileImagePath}');
        }
      }

      setState(() {
        _selectedGender = profile.gender;
        _selectedBirthYear = profile.birthYear;
        _selectedBirthMonth = profile.birthMonth;
        _heightController.text = profile.height?.toString() ?? '';
        _weightController.text = profile.weight?.toString() ?? '';
        _selectedBloodType = profile.bloodType;
        _selectedChronicConditions = Set.from(profile.chronicConditions);
        _selectedAllergies = Set.from(profile.allergies);
        _selectedMedications = Set.from(profile.medications);
        _selectedImage = savedImage;
      });
      debugPrint('UI에 프로필 데이터 적용 완료');
    } else {
      debugPrint('프로필 데이터 없음 또는 unmounted');
    }

    if (mounted) {
      setState(() => _isDataLoaded = true);
    }
  }

  /// 이미지 선택 옵션 표시
  Future<void> _showImagePickerOptions() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                '프로필 사진 변경',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.blue),
                ),
                title: const Text('카메라로 촬영'),
                subtitle: const Text('새 사진을 촬영합니다'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library, color: Colors.green),
                ),
                title: const Text('갤러리에서 선택'),
                subtitle: const Text('저장된 사진을 선택합니다'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImage != null) ...[
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete, color: Colors.red),
                  ),
                  title: const Text('사진 삭제'),
                  subtitle: const Text('선택한 사진을 제거합니다'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => _selectedImage = null);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 이미지 선택
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (pickedFile != null && mounted) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필 사진이 선택되었습니다. 저장하기를 눌러주세요.'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    debugPrint('=== _saveProfile() 호출됨 ===');

    if (!_formKey.currentState!.validate()) {
      debugPrint('폼 유효성 검사 실패');
      return;
    }
    debugPrint('폼 유효성 검사 통과');

    final user = ref.read(currentUserProvider);
    if (user == null) {
      debugPrint('user가 null임');
      return;
    }
    debugPrint('user 확인됨: ${user.userId}');

    setState(() => _isLoading = true);

    try {
      final newName = _nameController.text.trim();
      final newEmail = _emailController.text.trim();
      debugPrint('이름: $newName, 이메일: $newEmail');

      // 생년월일 생성
      DateTime? birthDate;
      if (_selectedBirthYear != null) {
        birthDate = DateTime(
          _selectedBirthYear!,
          _selectedBirthMonth ?? 1,
          1,
        );
      }

      // 백엔드 API 호출 시도
      bool backendSuccess = false;
      final accessToken = await ref.read(authServiceProvider).getAccessToken();
      debugPrint('accessToken: ${accessToken?.substring(0, 20)}...');

      if (accessToken != null && !accessToken.startsWith('test_')) {
        debugPrint('실제 토큰 - 백엔드 API 호출 시도');
        // 실제 토큰인 경우 백엔드 API 호출
        try {
          final userService = ref.read(userServiceProvider);
          final request = ProfileUpdateRequest(
            name: newName,
            birthDate: birthDate,
            gender: _selectedGender,
            heightCm: int.tryParse(_heightController.text),
            weightKg: int.tryParse(_weightController.text),
            bloodType: _selectedBloodType,
            chronicConditions: _selectedChronicConditions.toList(),
            medications: _selectedMedications.toList(),
            allergies: _selectedAllergies.toList(),
          );

          debugPrint('userService.updateMyProfile() 호출 중...');
          final updatedProfile = await userService.updateMyProfile(
            accessToken,
            request,
          );
          debugPrint('updateMyProfile 결과: $updatedProfile');

          if (updatedProfile != null) {
            backendSuccess = true;
            debugPrint('백엔드 저장 성공!');
            // AuthState 업데이트
            await ref.read(authStateProvider.notifier).updateUserProfile(
                  name: updatedProfile.name,
                  email: updatedProfile.email,
                );
          } else {
            debugPrint('updatedProfile이 null임');
          }
        } catch (e) {
          debugPrint('백엔드 API 호출 실패, 로컬 저장으로 대체: $e');
        }
      } else {
        debugPrint('테스트 토큰이거나 토큰 없음 - 로컬 저장 진행');
      }

      // 프로필 이미지 로컬 저장
      String? savedImagePath;
      if (_selectedImage != null) {
        try {
          final appDir = await getApplicationDocumentsDirectory();
          final profileImagesDir = Directory('${appDir.path}/profile_images');
          if (!await profileImagesDir.exists()) {
            await profileImagesDir.create(recursive: true);
          }

          final fileName = 'profile_${user.userId}.jpg';
          final savedFile = File('${profileImagesDir.path}/$fileName');

          // 이미 저장된 파일이 아닌 경우에만 복사
          if (_selectedImage!.path != savedFile.path) {
            await _selectedImage!.copy(savedFile.path);
            debugPrint('프로필 이미지 저장: ${savedFile.path}');
          }
          savedImagePath = savedFile.path;
        } catch (e) {
          debugPrint('프로필 이미지 저장 실패: $e');
        }
      }

      // 항상 로컬 저장 (백엔드 성공 여부와 관계없이 로컬 캐시도 유지)
      final profileData = ProfileData(
        gender: _selectedGender,
        birthYear: _selectedBirthYear,
        birthMonth: _selectedBirthMonth,
        height: int.tryParse(_heightController.text),
        weight: int.tryParse(_weightController.text),
        bloodType: _selectedBloodType,
        chronicConditions: _selectedChronicConditions.toList(),
        allergies: _selectedAllergies.toList(),
        medications: _selectedMedications.toList(),
        profileImagePath: savedImagePath,
      );

      debugPrint('로컬 프로필 저장 - userId: ${user.userId}');
      debugPrint('저장할 데이터: ${profileData.toJson()}');

      final saved = await ref
          .read(profileProvider(user.userId).notifier)
          .saveProfile(profileData);
      debugPrint('로컬 저장 결과: $saved');

      // 이름과 이메일 로컬 업데이트 (백엔드 실패 시에만)
      if (!backendSuccess) {
        await ref.read(authStateProvider.notifier).updateUserProfile(
              name: newName,
              email: newEmail.isNotEmpty ? newEmail : null,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 저장되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('내 프로필'),
      ),
      body: user == null
          ? const Center(child: Text('로그인이 필요합니다'))
          : !_isDataLoaded
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('프로필 데이터를 불러오는 중...'),
                    ],
                  ),
                )
              : Column(
              children: [
                // 스크롤 가능한 폼 영역
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(AppTheme.spaceMd),
                      children: [
                        // 프로필 이미지
                        _buildProfileImage(user),
                        const SizedBox(height: AppTheme.spaceLg),

                        // 기본 정보 섹션
                        _buildSectionTitle('기본 정보'),
                        const SizedBox(height: AppTheme.spaceSm),
                        _buildNameField(),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildEmailField(),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildGenderField(),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildBirthYearMonthField(),

                        const SizedBox(height: AppTheme.spaceLg),

                        // 신체 정보 섹션
                        _buildSectionTitle('신체 정보'),
                        const SizedBox(height: AppTheme.spaceSm),
                        Row(
                          children: [
                            Expanded(child: _buildHeightField()),
                            const SizedBox(width: AppTheme.spaceMd),
                            Expanded(child: _buildWeightField()),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildBloodTypeField(),
                        const SizedBox(height: AppTheme.spaceSm),
                        _buildBmiInfo(),

                        const SizedBox(height: AppTheme.spaceLg),

                        // 건강 정보 섹션
                        _buildSectionTitle('건강 정보'),
                        const SizedBox(height: AppTheme.spaceSm),
                        _buildChronicConditionsSection(),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildAllergiesSection(),
                        const SizedBox(height: AppTheme.spaceMd),
                        _buildMedicationsSection(),

                        const SizedBox(height: AppTheme.spaceLg),

                        // 계정 정보 섹션
                        _buildSectionTitle('계정 정보'),
                        const SizedBox(height: AppTheme.spaceSm),
                        _buildAccountInfo(user),

                        const SizedBox(height: AppTheme.spaceXl),

                        // 회원 탈퇴 (작게 배치)
                        _buildWithdrawSection(),

                        const SizedBox(height: AppTheme.spaceLg),
                      ],
                    ),
                  ),
                ),

                // 하단 고정 저장 버튼
                _buildBottomSaveButton(),
              ],
            ),
    );
  }

  /// 하단 고정 저장 버튼
  Widget _buildBottomSaveButton() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () {
              debugPrint('=== 저장 버튼 클릭됨! ===');
              debugPrint('_isLoading: $_isLoading');
              _saveProfile();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    '저장하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage(dynamic user) {
    // 이미지 소스 결정: 선택된 이미지 > 서버 이미지 > 기본 아바타
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider = FileImage(_selectedImage!);
    } else if (user.profileImageUrl != null) {
      imageProvider = NetworkImage(user.profileImageUrl!);
    }

    return Center(
      child: Stack(
        children: [
          GestureDetector(
            onTap: _showImagePickerOptions,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _selectedImage != null ? Colors.green : AppTheme.primary.withOpacity(0.3),
                  width: _selectedImage != null ? 3 : 2,
                ),
              ),
              child: CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      )
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _showImagePickerOptions,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          if (_selectedImage != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTheme.h3.copyWith(color: AppTheme.primary),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(
        labelText: '이름 *',
        hintText: '이름을 입력하세요',
        prefixIcon: Icon(Icons.person_outline),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: '이메일',
        hintText: '이메일을 입력하세요',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
          if (!emailRegex.hasMatch(value)) {
            return '올바른 이메일 형식이 아닙니다';
          }
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      decoration: const InputDecoration(
        labelText: '성별',
        prefixIcon: Icon(Icons.wc),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('선택 안함')),
        ...genderTypes.map((type) {
          return DropdownMenuItem(
            value: type['value'],
            child: Text(type['label']!),
          );
        }),
      ],
      onChanged: (value) => setState(() => _selectedGender = value),
    );
  }

  Widget _buildBirthYearMonthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.cake_outlined, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Text(
              '생년월',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                value: _selectedBirthYear,
                decoration: const InputDecoration(
                  hintText: '연도',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('연도 선택')),
                  ..._years.map((year) {
                    return DropdownMenuItem(value: year, child: Text('$year년'));
                  }),
                ],
                onChanged: (value) => setState(() => _selectedBirthYear = value),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<int>(
                value: _selectedBirthMonth,
                decoration: const InputDecoration(
                  hintText: '월',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text('월')),
                  ..._months.map((month) {
                    return DropdownMenuItem(value: month, child: Text('$month월'));
                  }),
                ],
                onChanged: (value) => setState(() => _selectedBirthMonth = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeightField() {
    return TextFormField(
      controller: _heightController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '키 (cm)',
        prefixIcon: Icon(Icons.height),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final height = int.tryParse(value);
          if (height == null || height < 30 || height > 300) {
            return '올바른 키를 입력해주세요';
          }
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: TextInputType.number,
      decoration: const InputDecoration(
        labelText: '몸무게 (kg)',
        prefixIcon: Icon(Icons.monitor_weight_outlined),
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value != null && value.isNotEmpty) {
          final weight = int.tryParse(value);
          if (weight == null || weight < 1 || weight > 500) {
            return '올바른 몸무게를 입력해주세요';
          }
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildBloodTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      decoration: const InputDecoration(
        labelText: '혈액형',
        prefixIcon: Icon(Icons.bloodtype),
        border: OutlineInputBorder(),
      ),
      items: [
        const DropdownMenuItem(value: null, child: Text('선택 안함')),
        ...bloodTypes.map((type) {
          return DropdownMenuItem(value: type, child: Text(type));
        }),
      ],
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  Widget _buildBmiInfo() {
    final height = int.tryParse(_heightController.text);
    final weight = int.tryParse(_weightController.text);

    if (height == null || weight == null || height <= 0) {
      return const SizedBox.shrink();
    }

    final heightM = height / 100;
    final bmi = weight / (heightM * heightM);
    final bmiCategory = _getBmiCategory(bmi);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getBmiColor(bmi).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getBmiColor(bmi).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.fitness_center, color: _getBmiColor(bmi)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI: ${bmi.toStringAsFixed(1)}',
                style: TextStyle(fontWeight: FontWeight.bold, color: _getBmiColor(bmi)),
              ),
              Text(
                bmiCategory,
                style: TextStyle(fontSize: 12, color: _getBmiColor(bmi)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return '저체중';
    if (bmi < 23) return '정상';
    if (bmi < 25) return '과체중';
    if (bmi < 30) return '비만';
    return '고도비만';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 23) return Colors.green;
    if (bmi < 25) return Colors.orange;
    return Colors.red;
  }

  Widget _buildChronicConditionsSection() {
    return _buildCheckboxSection(
      title: '만성 질환',
      icon: Icons.medical_information,
      items: commonChronicConditions,
      selectedItems: _selectedChronicConditions,
      onChanged: (item, selected) {
        setState(() {
          if (selected) {
            _selectedChronicConditions.add(item);
          } else {
            _selectedChronicConditions.remove(item);
          }
        });
      },
    );
  }

  Widget _buildAllergiesSection() {
    return _buildCheckboxSection(
      title: '알레르기',
      icon: Icons.warning_amber,
      items: commonAllergies,
      selectedItems: _selectedAllergies,
      onChanged: (item, selected) {
        setState(() {
          if (selected) {
            _selectedAllergies.add(item);
          } else {
            _selectedAllergies.remove(item);
          }
        });
      },
    );
  }

  Widget _buildMedicationsSection() {
    return _buildCheckboxSection(
      title: '복용 중인 약물',
      icon: Icons.medication,
      items: commonMedications,
      selectedItems: _selectedMedications,
      onChanged: (item, selected) {
        setState(() {
          if (selected) {
            _selectedMedications.add(item);
          } else {
            _selectedMedications.remove(item);
          }
        });
      },
    );
  }

  Widget _buildCheckboxSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Set<String> selectedItems,
    required Function(String item, bool selected) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppTheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                const Spacer(),
                if (selectedItems.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectedItems.length}개 선택',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: items.map((item) {
                final isSelected = selectedItems.contains(item);
                return FilterChip(
                  label: Text(
                    item,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) => onChanged(item, selected),
                  selectedColor: AppTheme.primary,
                  checkmarkColor: Colors.white,
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo(dynamic user) {
    return CustomCard(
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: '사용자 ID',
            value: user.userId,
          ),
          const Divider(),
          _buildInfoRow(
            icon: Icons.card_membership,
            label: '구독 플랜',
            value: _getSubscriptionLabel(user.subscriptionTier),
          ),
          const Divider(),
          _buildInfoRow(
            icon: Icons.verified_outlined,
            label: '구독 상태',
            value: _getSubscriptionStatusLabel(user.subscriptionStatus),
            valueColor: user.subscriptionStatus == 'active' ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: AppTheme.spaceSm),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w500, color: valueColor),
          ),
        ],
      ),
    );
  }

  /// 회원 탈퇴 섹션 (작게 배치)
  Widget _buildWithdrawSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '더 이상 서비스를 이용하지 않으시나요?',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          TextButton(
            onPressed: _showWithdrawSurveyDialog,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              '회원탈퇴',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSubscriptionLabel(String tier) {
    switch (tier) {
      case 'free': return '무료 플랜';
      case 'basic': return '베이직 플랜';
      case 'premium': return '프리미엄 플랜';
      case 'family': return '패밀리 플랜';
      default: return tier;
    }
  }

  String _getSubscriptionStatusLabel(String status) {
    switch (status) {
      case 'active': return '활성';
      case 'expired': return '만료됨';
      case 'cancelled': return '취소됨';
      default: return status;
    }
  }

  /// 회원탈퇴 설문조사 다이얼로그
  Future<void> _showWithdrawSurveyDialog() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    String? selectedReason;
    final otherReasonController = TextEditingController();
    bool showOtherField = false;

    final reasons = [
      '서비스를 더 이상 이용하지 않음',
      '다른 서비스를 이용하게 됨',
      '개인정보 보호 우려',
      '원하는 기능이 없음',
      '사용법이 어려움',
      '비용 문제',
      '기타',
    ];

    final result = await showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.sentiment_dissatisfied, color: Colors.orange[700]),
              const SizedBox(width: 8),
              const Text('회원 탈퇴'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '탈퇴하시는 이유를 알려주세요.\n서비스 개선에 큰 도움이 됩니다.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ...reasons.map((reason) {
                  return RadioListTile<String>(
                    title: Text(reason, style: const TextStyle(fontSize: 14)),
                    value: reason,
                    groupValue: selectedReason,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedReason = value;
                        showOtherField = value == '기타';
                      });
                    },
                  );
                }),
                if (showOtherField) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: otherReasonController,
                    decoration: const InputDecoration(
                      hintText: '탈퇴 사유를 입력해주세요',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(12),
                    ),
                    maxLines: 3,
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '탈퇴 시 모든 데이터가 삭제되며\n복구할 수 없습니다.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: selectedReason == null
                  ? null
                  : () {
                      final reason = selectedReason == '기타'
                          ? otherReasonController.text.trim().isEmpty
                              ? '기타'
                              : '기타: ${otherReasonController.text.trim()}'
                          : selectedReason!;
                      Navigator.pop(context, {
                        'reason': reason,
                        'userName': user.name,
                        'userId': user.userId,
                      });
                    },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('탈퇴하기'),
            ),
          ],
        ),
      ),
    );

    otherReasonController.dispose();

    if (result != null && mounted) {
      await _processWithdrawal(result);
    }
  }

  /// 탈퇴 처리
  Future<void> _processWithdrawal(Map<String, String> surveyResult) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('최종 확인'),
        content: const Text('정말 탈퇴하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 탈퇴 정보 저장
      final withdrawalInfo = WithdrawalInfo(
        userId: surveyResult['userId']!,
        userName: surveyResult['userName']!,
        reason: surveyResult['reason']!,
        withdrawalDate: DateTime.now(),
      );

      // 탈퇴 정보를 Provider에 저장
      ref.read(withdrawalListProvider.notifier).addWithdrawal(withdrawalInfo);

      // 실제 탈퇴 처리
      await ref.read(authStateProvider.notifier).withdraw();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원 탈퇴가 완료되었습니다'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }
}

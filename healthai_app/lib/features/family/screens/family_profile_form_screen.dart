import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../models/family_profile_model.dart';
import '../providers/family_provider.dart';
import '../services/family_api_service.dart';

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

/// 가족 프로필 추가/수정 화면
class FamilyProfileFormScreen extends ConsumerStatefulWidget {
  /// 수정할 프로필 (null이면 새로 생성)
  final FamilyProfileModel? profile;

  const FamilyProfileFormScreen({
    super.key,
    this.profile,
  });

  @override
  ConsumerState<FamilyProfileFormScreen> createState() =>
      _FamilyProfileFormScreenState();
}

class _FamilyProfileFormScreenState
    extends ConsumerState<FamilyProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  String _selectedRelationship = 'spouse';
  String? _selectedGender;
  String? _selectedBloodType;
  int? _selectedBirthYear;
  int? _selectedBirthMonth;

  // 건강정보 체크박스 상태
  Set<String> _selectedChronicConditions = {};
  Set<String> _selectedAllergies = {};
  Set<String> _selectedMedications = {};

  bool _isLoading = false;

  bool get _isEditing => widget.profile != null;

  // 연도 목록 생성 (1900 ~ 현재년도)
  List<int> get _years {
    final currentYear = DateTime.now().year;
    return List.generate(currentYear - 1900 + 1, (i) => currentYear - i);
  }

  // 월 목록
  List<int> get _months => List.generate(12, (i) => i + 1);

  @override
  void initState() {
    super.initState();

    final profile = widget.profile;

    _nameController = TextEditingController(text: profile?.name ?? '');
    _heightController = TextEditingController(
      text: profile?.height?.toInt().toString() ?? '',
    );
    _weightController = TextEditingController(
      text: profile?.weight?.toInt().toString() ?? '',
    );

    if (profile != null) {
      _selectedRelationship = profile.relationship;
      _selectedGender = profile.gender;
      _selectedBloodType = profile.bloodType;
      _selectedBirthYear = profile.birthDate.year;
      _selectedBirthMonth = profile.birthDate.month;
      _selectedChronicConditions = profile.chronicConditions.toSet();
      _selectedAllergies = profile.allergies.toSet();
      _selectedMedications = profile.medications.toSet();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // 그라데이션 앱바
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            elevation: 0,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _isEditing ? '프로필 수정' : '가족 추가',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -20,
                      bottom: -40,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              if (_isEditing)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _showDeleteConfirmation,
                ),
            ],
          ),
          // 폼 내용
          SliverToBoxAdapter(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 기본 정보 카드
                    _buildSectionCard(
                      title: '기본 정보',
                      icon: Icons.person_outline,
                      iconColor: AppTheme.primary,
                      children: [
                        _buildNameField(),
                        const SizedBox(height: 16),
                        _buildRelationshipField(),
                        const SizedBox(height: 16),
                        _buildGenderField(),
                        const SizedBox(height: 16),
                        _buildBirthYearMonthField(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 신체 정보 카드
                    _buildSectionCard(
                      title: '신체 정보',
                      icon: Icons.accessibility_new,
                      iconColor: AppTheme.secondary,
                      children: [
                        Row(
                          children: [
                            Expanded(child: _buildHeightField()),
                            const SizedBox(width: 12),
                            Expanded(child: _buildWeightField()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildBloodTypeField(),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 건강 정보 카드
                    _buildSectionCard(
                      title: '건강 정보',
                      icon: Icons.favorite_outline,
                      iconColor: AppTheme.error,
                      children: [
                        _buildChronicConditionsSection(),
                        const SizedBox(height: 16),
                        _buildAllergiesSection(),
                        const SizedBox(height: 16),
                        _buildMedicationsSection(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // 저장 버튼
                    _buildGradientButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 섹션 카드 위젯
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 20, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ],
            ),
          ),
          // 내용
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  /// 그라데이션 저장 버튼
  Widget _buildGradientButton() {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        gradient: _isLoading ? null : AppTheme.primaryGradient,
        color: _isLoading ? Colors.grey.shade300 : null,
        borderRadius: BorderRadius.circular(14),
        boxShadow: _isLoading
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _saveProfile,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEditing ? Icons.check_circle : Icons.add_circle,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEditing ? '수정 완료' : '가족 추가하기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextFormField(
      controller: _nameController,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: '이름',
        hintText: '가족 구성원 이름을 입력하세요',
        prefixIcon: Icon(Icons.person, color: AppTheme.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '이름을 입력해주세요';
        }
        return null;
      },
    );
  }

  Widget _buildRelationshipField() {
    return DropdownButtonFormField<String>(
      value: _selectedRelationship,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: '관계',
        prefixIcon: Icon(Icons.family_restroom, color: AppTheme.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: relationshipTypes.map((type) {
        return DropdownMenuItem(
          value: type['value'],
          child: Text(type['label']!),
        );
      }).toList(),
      onChanged: _isEditing
          ? null // 수정 모드에서는 관계 변경 불가
          : (value) {
              if (value != null) {
                setState(() => _selectedRelationship = value);
              }
            },
    );
  }

  Widget _buildGenderField() {
    return DropdownButtonFormField<String>(
      value: _selectedGender,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: '성별',
        prefixIcon: Icon(Icons.wc, color: AppTheme.primary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('선택 안함'),
        ),
        ...genderTypes.map((type) {
          return DropdownMenuItem(
            value: type['value'],
            child: Text(type['label']!),
          );
        }),
      ],
      onChanged: _isEditing
          ? null
          : (value) => setState(() => _selectedGender = value),
    );
  }

  /// 생년월 선택 필드 (연도, 월 드롭다운)
  Widget _buildBirthYearMonthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.cake, color: AppTheme.primary.withOpacity(0.7), size: 20),
            const SizedBox(width: 8),
            Text(
              '생년월',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            // 연도 선택
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                value: _selectedBirthYear,
                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: '연도 선택',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('연도 선택', style: TextStyle(color: Colors.grey.shade400)),
                  ),
                  ..._years.map((year) {
                    return DropdownMenuItem(
                      value: year,
                      child: Text('$year년'),
                    );
                  }),
                ],
                onChanged: _isEditing
                    ? null
                    : (value) => setState(() => _selectedBirthYear = value),
              ),
            ),
            const SizedBox(width: 12),
            // 월 선택
            Expanded(
              flex: 1,
              child: DropdownButtonFormField<int>(
                value: _selectedBirthMonth,
                style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: '월',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                items: [
                  DropdownMenuItem<int>(
                    value: null,
                    child: Text('월', style: TextStyle(color: Colors.grey.shade400)),
                  ),
                  ..._months.map((month) {
                    return DropdownMenuItem(
                      value: month,
                      child: Text('$month월'),
                    );
                  }),
                ],
                onChanged: _isEditing
                    ? null
                    : (value) => setState(() => _selectedBirthMonth = value),
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
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: '키 (cm)',
        hintText: '170',
        prefixIcon: Icon(Icons.height, color: AppTheme.secondary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  Widget _buildWeightField() {
    return TextFormField(
      controller: _weightController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: '몸무게 (kg)',
        hintText: '65',
        prefixIcon: Icon(Icons.monitor_weight, color: AppTheme.secondary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
    );
  }

  Widget _buildBloodTypeField() {
    return DropdownButtonFormField<String>(
      value: _selectedBloodType,
      style: const TextStyle(fontSize: 15, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: '혈액형',
        prefixIcon: Icon(Icons.bloodtype, color: AppTheme.secondary.withOpacity(0.7)),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.secondary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('선택 안함'),
        ),
        ...bloodTypes.map((type) {
          return DropdownMenuItem(
            value: type,
            child: Text(type),
          );
        }),
      ],
      onChanged: (value) => setState(() => _selectedBloodType = value),
    );
  }

  /// 만성질환 체크박스 섹션
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

  /// 알레르기 체크박스 섹션
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

  /// 복용약물 체크박스 섹션
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

  /// 공통 체크박스 섹션 위젯
  Widget _buildCheckboxSection({
    required String title,
    required IconData icon,
    required List<String> items,
    required Set<String> selectedItems,
    required Function(String item, bool selected) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: AppTheme.error),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const Spacer(),
                if (selectedItems.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${selectedItems.length}개',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 구분선
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          // 체크박스 그리드
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: items.map((item) {
                final isSelected = selectedItems.contains(item);
                return GestureDetector(
                  onTap: () => onChanged(item, !isSelected),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                        width: 1,
                      ),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ] : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSelected) ...[
                          const Icon(Icons.check, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(familyProfilesProvider.notifier);

      // 생년월 -> DateTime 변환 (일은 1일로 설정)
      DateTime? birthDate;
      if (_selectedBirthYear != null && _selectedBirthMonth != null) {
        birthDate = DateTime(_selectedBirthYear!, _selectedBirthMonth!, 1);
      }

      if (_isEditing) {
        // 수정
        await notifier.updateProfile(
          profileId: widget.profile!.id,
          name: _nameController.text.trim(),
          heightCm: int.tryParse(_heightController.text),
          weightKg: int.tryParse(_weightController.text),
          bloodType: _selectedBloodType,
          allergies: _selectedAllergies.toList(),
          medications: _selectedMedications.toList(),
          chronicConditions: _selectedChronicConditions.toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필이 수정되었습니다'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } else {
        // 생성
        await notifier.createProfile(
          name: _nameController.text.trim(),
          relationshipType: _selectedRelationship,
          birthDate: birthDate,
          gender: _selectedGender,
          heightCm: int.tryParse(_heightController.text),
          weightKg: int.tryParse(_weightController.text),
          bloodType: _selectedBloodType,
          allergies: _selectedAllergies.toList(),
          medications: _selectedMedications.toList(),
          chronicConditions: _selectedChronicConditions.toList(),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('가족 프로필이 추가되었습니다'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on UpgradeRequiredException catch (e) {
      if (mounted) {
        _showUpgradeDialog(e);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 구독 업그레이드 안내 다이얼로그
  void _showUpgradeDialog(UpgradeRequiredException e) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.upgrade, color: Colors.orange.shade700, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '구독 업그레이드 필요',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.message,
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 14),
            // 플랜 비교 정보
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  // 현재 플랜
                  _buildPlanInfoRow(
                    '현재',
                    e.currentPlanName,
                    '가족 ${e.currentLimit}명',
                    Colors.grey.shade600,
                  ),
                  if (e.nextPlan != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Icon(Icons.arrow_downward,
                        color: Colors.green.shade400, size: 18),
                    ),
                    // 추천 플랜
                    _buildPlanInfoRow(
                      '추천',
                      e.nextPlanName ?? '',
                      e.nextPlanLimit >= 999 ? '무제한' : '가족 ${e.nextPlanLimit}명',
                      Colors.green.shade600,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text('닫기', style: TextStyle(fontSize: 13)),
          ),
          if (e.nextPlan != null)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                // 구독 페이지로 이동
                context.push('/subscription');
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: const Text('업그레이드', style: TextStyle(fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            ),
        ],
      ),
    );
  }

  /// 플랜 정보 행 위젯
  Widget _buildPlanInfoRow(
      String label, String planName, String limit, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                planName,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              limit,
              style: TextStyle(
                color: color,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDeleteConfirmation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 삭제'),
        content: Text(
            '${widget.profile!.name}님의 프로필을 삭제하시겠습니까?\n관련된 모든 상담 기록도 함께 삭제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteProfile();
    }
  }

  Future<void> _deleteProfile() async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(familyProfilesProvider.notifier);
      await notifier.deleteProfile(widget.profile!.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 삭제되었습니다'),
            backgroundColor: AppTheme.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('오류: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }
}

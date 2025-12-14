import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/character_model.dart';
import '../../../core/services/character_api_service.dart';
import '../../family/widgets/family_profile_selector.dart';

/// 캐릭터 선택 화면
class CharacterSelectionScreen extends ConsumerStatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState
    extends ConsumerState<CharacterSelectionScreen> {
  final CharacterApiService _apiService = CharacterApiService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<CharacterModel>? _characters;
  bool _isLoading = true;
  String? _error;
  String? _playingCharacterId;

  @override
  void initState() {
    super.initState();
    _loadCharacters();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadCharacters() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final characters = await _apiService.getAllCharacters();

      setState(() {
        _characters = characters;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playIntroductionAudio(String characterId) async {
    try {
      // 이미 재생 중인 오디오 정지
      if (_playingCharacterId == characterId) {
        await _audioPlayer.stop();
        setState(() => _playingCharacterId = null);
        return;
      }

      await _audioPlayer.stop();

      // 오디오 URL 설정 및 재생
      // Android 에뮬레이터에서는 10.0.2.2 사용
      final audioUrl = _apiService.getIntroductionAudioUrl(characterId);
      print('오디오 URL: $audioUrl'); // 디버깅용

      await _audioPlayer.setUrl(audioUrl);

      setState(() => _playingCharacterId = characterId);

      await _audioPlayer.play();

      // 재생 완료 시 상태 업데이트
      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          setState(() => _playingCharacterId = null);
        }
      });
    } catch (e) {
      print('오디오 재생 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오디오를 재생할 수 없습니다')),
      );
      setState(() => _playingCharacterId = null);
    }
  }

  /// 캐릭터 선택 시 가족 프로필 선택 후 상담 시작
  Future<void> _onCharacterSelected(CharacterModel character) async {
    final displayName =
        '${character.name} ${_formatSpecialty(character.specialty)}';

    // 가족 프로필 선택 다이얼로그 표시
    final selectedProfile = await showFamilyProfileSelector(
      context: context,
      characterName: displayName,
    );

    // 프로필이 선택되면 상담 화면으로 이동
    if (selectedProfile != null && mounted) {
      context.push(
        '/voice-conversation/${character.id}'
        '?name=${Uri.encodeComponent(displayName)}'
        '&profileId=${selectedProfile.id}'
        '&profileName=${Uri.encodeComponent(selectedProfile.name)}',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 건강주치의 선택'),
        centerTitle: true,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI 건강주치의를 불러오는 중...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('오류가 발생했습니다'),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCharacters,
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (_characters == null || _characters!.isEmpty) {
      return const Center(child: Text('캐릭터가 없습니다'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _characters!.length,
      itemBuilder: (context, index) {
        final character = _characters![index];
        return _buildCharacterCard(character);
      },
    );
  }

  Widget _buildCharacterCard(CharacterModel character) {
    final isPlaying = _playingCharacterId == character.id;
    final themeColor = _getSpecialtyColor(character.specialty);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: themeColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: () => _onCharacterSelected(character),
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 프로필 헤더 (그라데이션 배경)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    themeColor.withOpacity(0.1),
                    themeColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  // 프로필 이미지
                  _buildCharacterAvatar(character),
                  const SizedBox(width: 16),
                  // 캐릭터 기본 정보
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 이름 + 성별 태그
                        Row(
                          children: [
                            Text(
                              character.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _getGenderColor(character.gender),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                character.gender == 'male' ? '남성' : '여성',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 전문분야 배지
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            character.specialty,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // 전문분야 상세
                        Text(
                          character.specialtyDetail,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 하단: 자기소개 영역
            if (character.introductionText != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 자기소개 헤더
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          size: 20,
                          color: themeColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '자기소개',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: themeColor,
                          ),
                        ),
                        const Spacer(),
                        // 음성 자기소개 버튼
                        GestureDetector(
                          onTap: () => _playIntroductionAudio(character.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isPlaying
                                  ? Colors.red.shade50
                                  : themeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isPlaying
                                    ? Colors.red.shade300
                                    : themeColor.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isPlaying
                                      ? Icons.stop_rounded
                                      : Icons.volume_up_rounded,
                                  size: 16,
                                  color: isPlaying ? Colors.red : themeColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isPlaying ? '정지' : '음성 듣기',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isPlaying ? Colors.red : themeColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // 자기소개 텍스트
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: themeColor.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        character.introductionText!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF4A4A4A),
                          height: 1.6,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // 상담 시작 버튼 힌트
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_outlined,
                    size: 14,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '카드를 탭하여 상담 시작',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 전문분야별 테마 컬러
  Color _getSpecialtyColor(String specialty) {
    if (specialty.contains('내과')) {
      return const Color(0xFF2E7D32); // 녹색 - 내과
    } else if (specialty.contains('정신') || specialty.contains('의학과')) {
      return const Color(0xFF5C6BC0); // 보라색 - 정신건강의학과
    } else if (specialty.contains('영양')) {
      return const Color(0xFFFF7043); // 주황색 - 영양사
    } else if (specialty.contains('여성')) {
      return const Color(0xFFEC407A); // 핑크 - 여성건강
    } else if (specialty.contains('소아') || specialty.contains('청소년')) {
      return const Color(0xFF26A69A); // 청록색 - 소아청소년과
    } else if (specialty.contains('노인')) {
      return const Color(0xFF8D6E63); // 브라운 - 노인의학
    }
    return const Color(0xFF1976D2); // 기본 파란색
  }

  Widget _buildCharacterAvatar(CharacterModel character) {
    // 로컬 assets에서 Lottie 파일 로드
    final lottieAssetPath = 'assets/lottie/${character.id}.json';

    return SizedBox(
      width: 80,
      height: 80,
      child: Lottie.asset(
        lottieAssetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // Lottie 로드 실패 시 기본 아이콘 표시
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _getGenderColor(character.gender).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person,
              size: 40,
              color: _getGenderColor(character.gender),
            ),
          );
        },
      ),
    );
  }

  Color _getGenderColor(String gender) {
    return gender == 'male' ? Colors.blue : Colors.pink;
  }

  /// 전문분야를 표시용 포맷으로 변환 (전문의 접미사 추가)
  String _formatSpecialty(String specialty) {
    // 이미 "전문의"가 포함된 경우 그대로 반환
    if (specialty.contains('전문의')) {
      return specialty;
    }
    // "임상영양사"는 그대로 사용
    if (specialty.contains('영양사')) {
      return specialty;
    }
    // "노인의학" -> "노인의학과 전문의"
    if (specialty == '노인의학') {
      return '노인의학과 전문의';
    }
    // "내과", "정신건강의학과", "소아청소년과" 등 -> "~ 전문의"
    return '$specialty 전문의';
  }
}

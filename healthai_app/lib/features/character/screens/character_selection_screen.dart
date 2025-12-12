import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/character_model.dart';
import '../../../core/services/character_api_service.dart';

/// 캐릭터 선택 화면
class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CharacterSelectionScreen> createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
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
        SnackBar(content: Text('오디오를 재생할 수 없습니다')),
      );
      setState(() => _playingCharacterId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 주치의 선택'),
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
            Text('AI 주치의를 불러오는 중...'),
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
            Text('오류가 발생했습니다'),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: InkWell(
        onTap: () {
          // 캐릭터 선택 시 음성 상담 화면으로 이동
          // 이름과 전문분야를 함께 전달 (전문의 접미사 추가)
          final displayName = '${character.name} ${_formatSpecialty(character.specialty)}';
          context.push('/voice-conversation/${character.id}?name=${Uri.encodeComponent(displayName)}');
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Lottie 애니메이션 (있으면 표시)
              _buildCharacterAvatar(character),
              const SizedBox(width: 16),

              // 캐릭터 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          character.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getGenderColor(character.gender),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            character.gender == 'male' ? '남성' : '여성',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.specialty,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      character.specialtyDetail,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.school, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '경력 ${character.experienceYears}년',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (character.introductionText != null)
                      Text(
                        character.introductionText!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // 오디오 재생 버튼
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.stop_circle : Icons.play_circle,
                      size: 40,
                      color: isPlaying ? Colors.red : Colors.blue,
                    ),
                    onPressed: () => _playIntroductionAudio(character.id),
                  ),
                  Text(
                    '자기소개',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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

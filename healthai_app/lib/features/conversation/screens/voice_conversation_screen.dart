import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../models/conversation_model.dart';
import '../services/conversation_websocket_service.dart';
import '../services/audio_service.dart';

/// 음성 상담 화면 (Voice-First 설계)
/// OpenAI Realtime API 기반 실시간 음성 대화
class VoiceConversationScreen extends ConsumerStatefulWidget {
  final String characterId;

  const VoiceConversationScreen({
    super.key,
    required this.characterId,
  });

  @override
  ConsumerState<VoiceConversationScreen> createState() =>
      _VoiceConversationScreenState();
}

class _VoiceConversationScreenState
    extends ConsumerState<VoiceConversationScreen> {
  final ConversationWebSocketService _websocketService =
      ConversationWebSocketService();
  final AudioService _audioService = AudioService();

  final ScrollController _scrollController = ScrollController();
  final List<TranscriptMessage> _transcripts = [];

  bool _isConnecting = false;
  bool _isConnected = false;
  bool _isTalking = false;
  String? _error;
  int _elapsedSeconds = 0;
  int _maxDurationSeconds = 300; // 기본 5분

  @override
  void initState() {
    super.initState();
    _initializeConversation();
  }

  /// 대화 세션 초기화
  Future<void> _initializeConversation() async {
    setState(() {
      _isConnecting = true;
      _error = null;
    });

    try {
      // 1. 마이크 권한 요청
      final hasPermission = await _audioService.requestPermission();
      if (!hasPermission) {
        throw Exception('마이크 권한이 필요합니다');
      }

      // 2. 백엔드 API로 대화 세션 생성
      // TODO: 실제 API 호출로 conversation_id와 websocket_url 받기
      // final conversation = await _createConversation();

      // 현재는 데모용 WebSocket URL 사용
      final websocketUrl =
          'ws://10.0.2.2:8004/ws/conversations/demo-${DateTime.now().millisecondsSinceEpoch}?character_id=${widget.characterId}';

      // 3. WebSocket 연결
      await _websocketService.connect(websocketUrl);

      // 4. WebSocket 이벤트 리스너 등록
      _setupWebSocketListeners();

      // 5. 오디오 녹음 시작 및 스트리밍
      await _audioService.startRecording();

      // 6. 녹음된 오디오를 WebSocket으로 전송
      _audioService.audioStream.listen((audioChunk) {
        _websocketService.sendAudio(audioChunk);
      });

      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });

      // 7. 타이머 시작 (시간 제한)
      _startTimer();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isConnecting = false;
        _isConnected = false;
      });
    }
  }

  /// WebSocket 이벤트 리스너 설정
  void _setupWebSocketListeners() {
    // Transcript 수신
    _websocketService.transcriptStream.listen((transcript) {
      setState(() {
        _transcripts.add(transcript);
      });
      _scrollToBottom();
    });

    // 오디오 수신 (AI 응답)
    _websocketService.audioStream.listen((audioData) async {
      // AI 응답 오디오 재생
      await _audioService.playAudio(audioData);
    });

    // 에러 수신
    _websocketService.errorStream.listen((error) {
      setState(() {
        _error = error;
      });
    });
  }

  /// 타이머 시작 (시간 제한)
  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isConnected && mounted) {
        setState(() {
          _elapsedSeconds++;
        });

        // 시간 초과 시 세션 종료
        if (_elapsedSeconds >= _maxDurationSeconds) {
          _endConversation();
        } else {
          _startTimer();
        }
      }
    });
  }

  /// 대화 종료
  Future<void> _endConversation() async {
    try {
      // 1. 녹음 중지
      await _audioService.stopRecording();

      // 2. 재생 중지
      await _audioService.stopPlaying();

      // 3. WebSocket 세션 종료 요청
      _websocketService.endSession();

      // 4. WebSocket 연결 종료
      await _websocketService.disconnect();

      setState(() {
        _isConnected = false;
        _isTalking = false;
      });

      // 5. 화면 닫기
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('대화 종료 오류: $e');
    }
  }

  /// 스크롤 아래로
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// 남은 시간 포맷 (mm:ss)
  String _formatRemainingTime() {
    final remaining = _maxDurationSeconds - _elapsedSeconds;
    final minutes = remaining ~/ 60;
    final seconds = remaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getCharacterName()),
        elevation: 0,
        actions: [
          // 남은 시간 표시
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _formatRemainingTime(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // 연결 중
    if (_isConnecting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('AI 주치의와 연결 중...'),
          ],
        ),
      );
    }

    // 에러 발생
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text('연결 오류'),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => _error = null);
                _initializeConversation();
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    // 정상 연결: 음성 대화 UI
    return Column(
      children: [
        // Transcript 목록
        Expanded(
          child: _transcripts.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _transcripts.length,
                  itemBuilder: (context, index) {
                    final transcript = _transcripts[index];
                    return _buildTranscriptBubble(transcript);
                  },
                ),
        ),

        // 음성 파형 애니메이션 영역
        _buildVoiceWaveform(),

        // 종료 버튼
        _buildControlButtons(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mic,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            '대화를 시작하세요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI 주치의가 듣고 있습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBubble(TranscriptMessage transcript) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            transcript.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!transcript.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: transcript.isUser
                    ? AppTheme.primary
                    : Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                transcript.text,
                style: TextStyle(
                  fontSize: 14,
                  color: transcript.isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          if (transcript.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.secondary.withOpacity(0.1),
              child: const Icon(
                Icons.person,
                size: 20,
                color: AppTheme.secondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVoiceWaveform() {
    return Container(
      height: 80,
      color: Colors.grey[100],
      child: Center(
        child: _audioService.isRecording
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300 + index * 100),
                    width: 4,
                    height: _isTalking ? 40.0 + (index * 5) : 20.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              )
            : const Text(
                '음성 대화 준비 중...',
                style: TextStyle(color: Colors.grey),
              ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 종료 버튼
            ElevatedButton.icon(
              onPressed: _endConversation,
              icon: const Icon(Icons.call_end),
              label: const Text('상담 종료'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCharacterName() {
    switch (widget.characterId) {
      case 'park_jihoon':
        return '박지훈 의사';
      case 'choi_hyunwoo':
        return '최현우 의사';
      case 'oh_kyungmi':
        return '오경미 영양사';
      case 'lee_soojin':
        return '이수진 의사';
      case 'park_eunseo':
        return '박은서 의사';
      case 'jung_yujin':
        return '정유진 의사';
      default:
        return 'AI 주치의';
    }
  }

  @override
  void dispose() {
    _endConversation();
    _websocketService.dispose();
    _audioService.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

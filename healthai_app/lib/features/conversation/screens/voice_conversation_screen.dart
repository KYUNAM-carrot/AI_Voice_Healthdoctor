import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../../core/config/api_config.dart';
import '../services/audio_service.dart';
import '../services/conversation_websocket_service.dart';
import '../models/conversation_model.dart';

/// 음성 상담 화면 (프로덕션 버전)
///
/// OpenAI Realtime API를 사용한 실시간 음성 대화
/// - 상단 40%: AI 캐릭터 Lottie 애니메이션
/// - 하단 60%: 대화 텍스트 (자동 스크롤)
class VoiceConversationScreen extends StatefulWidget {
  final String characterId;
  final String characterName;

  const VoiceConversationScreen({
    super.key,
    required this.characterId,
    required this.characterName,
  });

  @override
  State<VoiceConversationScreen> createState() => _VoiceConversationScreenState();
}

class _VoiceConversationScreenState extends State<VoiceConversationScreen> {
  final AudioService _audioService = AudioService();
  final ConversationWebSocketService _websocketService = ConversationWebSocketService();
  final ScrollController _scrollController = ScrollController();

  bool _isConnecting = true;
  bool _isConnected = false;
  bool _isWelcomeCompleted = false;  // 환영 메시지 완료 여부
  bool _isDisposed = false;  // dispose 상태 추적
  bool _isAiResponding = true;  // AI 응답 중 여부 (에코 방지용) - 초기값 true (환영 메시지 때문)
  bool _isTranscriptDone = false;  // AI transcript 완료 여부 (<<TRANSCRIPT_DONE>> 수신)
  bool _isAudioBuffering = true;   // 오디오 버퍼링 중 여부 (전체 응답 수집 중) - 초기값 true
  Timer? _playbackSafetyTimer;  // 재생 완료 후 추가 안전 대기 타이머
  String? _error;
  int _elapsedSeconds = 0;
  final int _maxDurationSeconds = 600; // 10분

  // 대화 메시지
  final List<ConversationMessage> _messages = [];
  String _currentUserTranscript = '';
  String _currentAiTranscript = '';

  // 캐릭터별 Lottie 파일 매핑
  String get _lottieAssetPath => 'assets/lottie/${widget.characterId}.json';

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _playbackSafetyTimer?.cancel();
    _scrollController.dispose();
    _endConversation();
    super.dispose();
  }

  /// 대화 초기화 및 시작
  Future<void> _initConversation() async {
    try {
      print('🚀 음성 상담 초기화 시작: ${widget.characterId}');

      // 1. 오디오 서비스 초기화
      await _audioService.initialize();
      print('✅ 오디오 서비스 초기화 완료');

      // 2. 대화 세션 ID 생성 (실제로는 백엔드에서 생성해야 함)
      final conversationId = 'demo-${DateTime.now().millisecondsSinceEpoch}';
      final websocketUrl = '${ApiConfig.conversationWebSocket(conversationId)}?character_id=${widget.characterId}';

      print('🔗 WebSocket 연결 시작: $websocketUrl');

      // 3. WebSocket 연결
      await _websocketService.connect(websocketUrl);
      print('✅ WebSocket 연결 완료');

      // 4. WebSocket 이벤트 리스너 등록
      _setupWebSocketListeners();
      print('✅ WebSocket 리스너 설정 완료');

      // 5. 마이크 녹음 시작 (OpenAI VAD가 자동으로 발화 감지)
      // 환영 메시지는 백엔드에서 OpenAI Realtime API로 자동 생성됨
      print('🎤 마이크 녹음 시작');
      await _audioService.startRecording();
      print('✅ 마이크 녹음 시작 완료');

      // 6. 녹음된 오디오를 WebSocket으로 스트리밍
      // AI가 응답 중일 때는 오디오를 보내지 않음 (에코 방지)
      _audioService.audioStream.listen(
        (audioChunk) {
          if (_isDisposed) {
            return;
          }
          if (!mounted) {
            return;
          }
          // AI가 응답 중이면 오디오 전송 안함 (에코/피드백 방지)
          if (_isAiResponding) {
            return;
          }
          _websocketService.sendAudio(audioChunk);
        },
        onError: (error) {
          print('⚠️ 오디오 스트림 에러: $error');
        },
        cancelOnError: false,
      );

      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });

      // 7. 타이머 시작 (시간 제한)
      _startTimer();

      print('✅ 음성 상담 초기화 완료');
    } catch (e) {
      print('❌ 음성 상담 초기화 실패: $e');
      setState(() {
        _error = e.toString();
        _isConnecting = false;
        _isConnected = false;
      });
    }
  }

  /// WebSocket 이벤트 리스너 설정
  void _setupWebSocketListeners() {
    // 오디오 수신 (AI 응답 음성)
    _websocketService.audioStream.listen(
      (audioChunk) {
        if (_isDisposed || !mounted) return;
        // AI가 응답 중임을 표시 (에코 방지)
        if (!_isAiResponding) {
          _isAiResponding = true;
          _isTranscriptDone = false;  // 새 응답 시작, transcript 완료 플래그 리셋
          _isAudioBuffering = true;   // 오디오 버퍼링 시작
          print('🤖 AI 응답 시작 - 오디오 전송 일시 중지');
        }
        // 안전 타이머 취소 (새 오디오가 들어왔으므로)
        _playbackSafetyTimer?.cancel();
        _audioService.playAudio(audioChunk);
      },
      onError: (error) {
        print('⚠️ WebSocket 오디오 스트림 에러: $error');
      },
      cancelOnError: false,
    );

    // 오디오 재생 완료 리스너 (에코 방지 - 재생 완료 + transcript 완료 후에만 오디오 전송 재개)
    _audioService.playbackCompletedStream.listen(
      (_) {
        if (_isDisposed || !mounted) return;
        // 버퍼링 완료 표시
        _isAudioBuffering = false;
        print('🔊 playbackCompletedStream 수신 - transcript완료: $_isTranscriptDone, buffering: $_isAudioBuffering');

        // transcript도 완료되었을 때만 오디오 전송 재개
        // 추가로 1.5초 대기 후 재개 (스피커 -> 마이크 에코 방지)
        if (_isTranscriptDone) {
          _playbackSafetyTimer?.cancel();
          _playbackSafetyTimer = Timer(const Duration(milliseconds: 1500), () {
            if (_isDisposed || !mounted) return;
            // 대기 중에 새 오디오가 안 들어왔으면 전송 재개
            if (_isTranscriptDone && _isAiResponding && !_isAudioBuffering) {
              _isAiResponding = false;
              _isTranscriptDone = false;
              print('✅ AI 오디오 재생 완료 + 안전 대기 완료 - 오디오 전송 재개');
            }
          });
        }
      },
      onError: (error) {
        print('⚠️ playbackCompleted 스트림 에러: $error');
      },
      cancelOnError: false,
    );

    // 텍스트 수신 (음성 인식 결과 또는 AI 응답 텍스트)
    _websocketService.transcriptStream.listen(
      (transcript) {
        if (_isDisposed || !mounted) return;

        setState(() {
          if (transcript.isUser) {
            // 사용자 발화 - 전체 transcript를 한 번에 받음
            if (transcript.text.trim().isNotEmpty) {
              _messages.add(ConversationMessage(
                text: transcript.text.trim(),
                isUser: true,
                timestamp: DateTime.now(),
              ));
              _scrollToBottom();
            }
          } else {
            // AI 응답 처리
            if (transcript.text == '<<TRANSCRIPT_DONE>>') {
              // AI transcript 완료 신호
              if (_currentAiTranscript.trim().isNotEmpty) {
                _messages.add(ConversationMessage(
                  text: _currentAiTranscript.trim(),
                  isUser: false,
                  timestamp: DateTime.now(),
                ));
                _currentAiTranscript = ''; // 리셋
                _scrollToBottom();
              }
              // transcript 완료 플래그 설정
              _isTranscriptDone = true;

              // 만약 오디오가 이미 재생 완료된 상태라면 (버퍼링도 완료, 재생도 완료)
              // 안전 대기 후 전송 재개
              if (!_audioService.isPlaying && !_isAudioBuffering) {
                _playbackSafetyTimer?.cancel();
                _playbackSafetyTimer = Timer(const Duration(milliseconds: 1500), () {
                  if (_isDisposed || !mounted) return;
                  if (_isTranscriptDone && _isAiResponding && !_isAudioBuffering) {
                    _isAiResponding = false;
                    _isTranscriptDone = false;
                    print('✅ AI transcript 완료 + 안전 대기 완료 - 오디오 전송 재개');
                  }
                });
              }
            } else {
              // AI 응답 델타 누적
              _currentAiTranscript += transcript.text;
            }
          }
        });
      },
      onError: (error) {
        print('⚠️ WebSocket transcript 스트림 에러: $error');
      },
      cancelOnError: false,
    );

    // 에러 수신
    _websocketService.errorStream.listen(
      (error) {
        if (_isDisposed || !mounted) return;
        print('⚠️ WebSocket 에러 수신: $error');
        setState(() {
          _error = error;
        });
      },
      onError: (error) {
        print('⚠️ WebSocket 에러 스트림 에러: $error');
      },
      cancelOnError: false,
    );

    // 환영 메시지 완료 수신
    _websocketService.welcomeCompletedStream.listen(
      (completed) {
        if (_isDisposed || !mounted) return;
        print('🎉 환영 메시지 완료 신호 수신');
        setState(() {
          _isWelcomeCompleted = true;
        });
      },
      onError: (error) {
        print('⚠️ WebSocket welcome 스트림 에러: $error');
      },
      cancelOnError: false,
    );
  }

  /// 대화 목록 맨 아래로 스크롤
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
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
    // 이미 연결이 끊긴 상태면 중복 실행 방지
    if (!_isConnected) {
      return;
    }

    try {
      print('🛑 대화 종료 시작');

      // 연결 상태를 먼저 false로 설정하여 중복 호출 방지
      _isConnected = false;

      // 1. 녹음 중지
      await _audioService.stopRecording();

      // 2. WebSocket 종료 메시지 전송
      await _websocketService.endSession();

      // 3. 연결 종료
      await _websocketService.disconnect();

      // 4. 오디오 서비스 정리
      await _audioService.dispose();

      if (mounted && !_isDisposed) {
        setState(() {});
      }

      // 5. 이전 화면으로 돌아가기
      if (mounted && !_isDisposed) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('⚠️ 대화 종료 중 오류: $e');
    }
  }

  /// 경과 시간 포맷 (MM:SS)
  String _formatElapsedTime() {
    final minutes = _elapsedSeconds ~/ 60;
    final seconds = _elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('상담을 종료하려면 "상담 종료" 버튼을 눌러주세요'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: Column(
            children: [
              // 상단 헤더
              _buildHeader(),

              // 에러 표시
              if (_error != null) _buildErrorBanner(),

              // 연결 중 표시
              if (_isConnecting)
                const LinearProgressIndicator(),

              // 메인 콘텐츠
              Expanded(
                child: Column(
                  children: [
                    // 상단 40%: Lottie 애니메이션
                    Expanded(
                      flex: 40,
                      child: _buildLottieSection(),
                    ),

                    // 하단 60%: 대화 텍스트
                    Expanded(
                      flex: 60,
                      child: _buildChatSection(),
                    ),
                  ],
                ),
              ),

              // 하단 컨트롤
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  /// 상단 헤더
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 캐릭터 이름 (flexible하게 공간 차지, 필요시 줄바꿈 없이 축소)
          Expanded(
            child: Text(
              widget.characterName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const SizedBox(width: 8),

          // 경과 시간 (고정 크기)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Color(0xFF4CAF50),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatElapsedTime(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 배너
  Widget _buildErrorBanner() {
    return Container(
      color: Colors.red.shade100,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '오류: $_error',
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Lottie 애니메이션 섹션 (상단 40%)
  Widget _buildLottieSection() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFF5F7FA),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lottie 애니메이션
          Lottie.asset(
            _lottieAssetPath,
            fit: BoxFit.contain,
            repeat: true,
            animate: true,
          ),

          // 상태 표시 오버레이
          Positioned(
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _isAiResponding
                    ? const Color(0xFF2196F3).withOpacity(0.9)
                    : const Color(0xFF4CAF50).withOpacity(0.9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isAiResponding ? Icons.volume_up : Icons.mic,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isAiResponding
                        ? '말하는 중...'
                        : _isWelcomeCompleted
                            ? '듣고 있어요'
                            : '연결 중...',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 대화 텍스트 섹션 (하단 60%)
  Widget _buildChatSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 대화 목록
          Expanded(
            child: _buildConversationList(),
          ),
        ],
      ),
    );
  }

  /// 대화 목록
  Widget _buildConversationList() {
    final allMessages = <Widget>[];

    // 완료된 메시지들
    for (final message in _messages) {
      allMessages.add(_buildMessageBubble(message.text, message.isUser));
    }

    // 현재 입력 중인 AI 응답
    if (_currentAiTranscript.isNotEmpty) {
      allMessages.add(_buildMessageBubble(_currentAiTranscript, false, isPartial: true));
    }

    // 대화 내용이 있으면 끝에 복사/공유 버튼 추가
    if (_messages.isNotEmpty) {
      allMessages.add(_buildShareCopyButtons());
    }

    if (allMessages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 12),
            Text(
              '대화가 시작되면 여기에 표시됩니다',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: allMessages.length,
      itemBuilder: (context, index) => allMessages[index],
    );
  }

  /// 복사/공유 버튼 (대화 영역 끝에 표시)
  Widget _buildShareCopyButtons() {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 복사 버튼
          _buildActionButton(
            icon: Icons.copy_outlined,
            label: '복사',
            onTap: _copyConversation,
          ),
          Container(
            width: 1,
            height: 24,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey.shade300,
          ),
          // 공유 버튼
          _buildActionButton(
            icon: Icons.share_outlined,
            label: '공유',
            onTap: _shareConversation,
          ),
        ],
      ),
    );
  }

  /// 메시지 말풍선 (사용자: 박스 스타일, AI: 전체 폭 텍스트)
  Widget _buildMessageBubble(String text, bool isUser, {bool isPartial = false}) {
    if (isUser) {
      // 사용자 메시지: 기존 박스 스타일 유지
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2196F3).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      // AI 응답: 박스 없이 전체 폭 사용
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI 아이콘과 레이블
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.smart_toy_outlined,
                    size: 14,
                    color: Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'AI 주치의',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (isPartial) ...[
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 10,
                    height: 10,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.grey.shade400,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            // AI 응답 텍스트 (전체 폭)
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: const Color(0xFF1A1A2E),
                fontStyle: isPartial ? FontStyle.italic : FontStyle.normal,
              ),
            ),
            // 구분선
            const SizedBox(height: 12),
            Divider(
              height: 1,
              color: Colors.grey.shade200,
            ),
          ],
        ),
      );
    }
  }

  /// 하단 컨트롤
  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 음성 상태 표시
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isConnected
                          ? (_isAiResponding
                              ? const Color(0xFF2196F3)
                              : const Color(0xFF4CAF50))
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _isConnected
                        ? (_isAiResponding ? 'AI 응답 중' : '음성 인식 중')
                        : '연결 끊김',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            // 종료 버튼
            ElevatedButton.icon(
              onPressed: _endConversation,
              icon: const Icon(Icons.call_end, size: 16),
              label: const Text('상담 종료'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 액션 버튼 (복사, 공유)
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 대화 내용을 텍스트로 변환
  String _getConversationText() {
    final buffer = StringBuffer();
    buffer.writeln('═══════════════════════════════');
    buffer.writeln('AI 건강 상담 기록');
    buffer.writeln('상담사: ${widget.characterName}');
    buffer.writeln('날짜: ${DateTime.now().toString().substring(0, 16)}');
    buffer.writeln('═══════════════════════════════\n');

    for (final message in _messages) {
      if (message.isUser) {
        buffer.writeln('👤 나: ${message.text}');
      } else {
        buffer.writeln('🩺 AI 주치의: ${message.text}');
      }
      buffer.writeln();
    }

    buffer.writeln('═══════════════════════════════');
    buffer.writeln('HealthAI - AI 건강 주치의 앱');
    return buffer.toString();
  }

  /// 대화 내용 복사
  void _copyConversation() {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('복사할 대화 내용이 없습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final text = _getConversationText();
    Clipboard.setData(ClipboardData(text: text));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text('대화 내용이 클립보드에 복사되었습니다'),
          ],
        ),
        backgroundColor: Color(0xFF4CAF50),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 대화 내용 공유
  void _shareConversation() {
    if (_messages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('공유할 대화 내용이 없습니다'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final text = _getConversationText();

    // 공유 다이얼로그 표시 (Share 패키지가 없으므로 복사 + 안내)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.share, color: Color(0xFF2196F3)),
            SizedBox(width: 8),
            Text('상담 내용 공유'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('상담 내용이 클립보드에 복사되었습니다.\n메시지, 이메일, 메모 앱 등에 붙여넣기 하세요.'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                text.length > 200 ? '${text.substring(0, 200)}...' : text,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade700,
                ),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );

    // 클립보드에 복사
    Clipboard.setData(ClipboardData(text: text));
  }
}

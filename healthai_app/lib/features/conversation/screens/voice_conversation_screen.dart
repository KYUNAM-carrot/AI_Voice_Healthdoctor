import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import '../../../core/config/api_config.dart';
import '../../../core/services/health_context_service.dart';
import '../../../core/services/wearable_health_service.dart';
import '../../../core/services/conversation_history_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/profile_provider.dart';
import '../../family/models/family_profile_model.dart';
import '../../family/providers/family_provider.dart';
import '../services/audio_service.dart';
import '../services/conversation_websocket_service.dart';
import '../models/conversation_model.dart';

/// 음성 상담 화면 (프로덕션 버전)
///
/// OpenAI Realtime API를 사용한 실시간 음성 대화
/// - 상단 40%: AI 캐릭터 Lottie 애니메이션
/// - 하단 60%: 대화 텍스트 (자동 스크롤)
/// - 개인화된 건강 컨텍스트를 AI에 제공
class VoiceConversationScreen extends ConsumerStatefulWidget {
  final String characterId;
  final String characterName;
  final String? familyProfileId;
  final String? familyProfileName;

  const VoiceConversationScreen({
    super.key,
    required this.characterId,
    required this.characterName,
    this.familyProfileId,
    this.familyProfileName,
  });

  @override
  ConsumerState<VoiceConversationScreen> createState() => _VoiceConversationScreenState();
}

class _VoiceConversationScreenState extends ConsumerState<VoiceConversationScreen> {
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

  // 건강 컨텍스트 (UI 표시용)
  Map<String, dynamic>? _healthContext;
  bool _hasWearableData = false;

  // 대화 기록 저장용
  String _conversationId = '';
  DateTime? _sessionStartTime;

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

      // 2. 대화 세션 ID 생성 및 시작 시간 기록
      _conversationId = 'conv-${DateTime.now().millisecondsSinceEpoch}';
      _sessionStartTime = DateTime.now();
      var websocketUrl = '${ApiConfig.conversationWebSocket(_conversationId)}?character_id=${widget.characterId}';

      // 가족 프로필이 선택된 경우 URL에 추가
      if (widget.familyProfileId != null) {
        websocketUrl += '&family_profile_id=${widget.familyProfileId}';
        if (widget.familyProfileName != null) {
          websocketUrl += '&family_profile_name=${Uri.encodeComponent(widget.familyProfileName!)}';
        }
      }

      print('🔗 WebSocket 연결 시작: $websocketUrl');

      // 3. WebSocket 연결
      await _websocketService.connect(websocketUrl);
      print('✅ WebSocket 연결 완료');

      // 4. 건강 컨텍스트 빌드 및 전송
      await _buildAndSendHealthContext();
      print('✅ 건강 컨텍스트 전송 완료');

      // 5. WebSocket 이벤트 리스너 등록
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

  /// 건강 컨텍스트 빌드 및 전송
  ///
  /// 사용자/가족 프로필과 웨어러블 건강 데이터를 수집하여
  /// AI가 개인화된 상담을 제공할 수 있도록 컨텍스트 전송
  Future<void> _buildAndSendHealthContext() async {
    try {
      print('📋 건강 컨텍스트 빌드 시작');

      // 현재 로그인한 사용자 정보
      final user = ref.read(currentUserProvider);
      if (user == null) {
        print('⚠️ 사용자 정보 없음 - 기본 컨텍스트만 전송');
        return;
      }

      // 사용자 본인의 프로필 데이터 로드
      final profileNotifier = ref.read(profileProvider(user.userId).notifier);
      final userProfile = await profileNotifier.loadAndGetProfile();
      print('📊 사용자 프로필 로드: ${userProfile?.toJson()}');

      // 가족 프로필 로드 (선택된 경우)
      // selectedFamilyProfileProvider를 통해 이미 선택된 프로필 가져오기
      // 또는 familyProfilesProvider에서 ID로 검색
      final familyProfile = widget.familyProfileId != null
          ? ref.read(selectedFamilyProfileProvider) ??
            _findFamilyProfileById(ref, widget.familyProfileId!)
          : null;
      print('👨‍👩‍👧 가족 프로필: ${familyProfile?.name ?? "본인 상담"}');

      // 웨어러블 건강 데이터 수집 (추후 HealthKit/Health Connect 연동)
      final healthData = await _fetchWearableHealthData();

      // 본인 상담인지 가족 상담인지 결정
      final isUserItself = widget.familyProfileId == null;

      // 건강 컨텍스트 빌드 (사용자 이름 포함)
      final healthContext = HealthContextService.buildHealthContext(
        userProfile: userProfile,
        familyProfile: familyProfile,
        healthData: healthData,
        isUserItself: isUserItself,
        userName: user.name,  // 로그인한 사용자의 이름 전달
      );

      // 컨텍스트를 프롬프트 문자열로 변환하여 전송
      final contextPrompt = HealthContextService.toPromptString(healthContext);
      print('📝 건강 컨텍스트 프롬프트 길이: ${contextPrompt.length}자');

      // 상태 저장 (UI 표시용)
      setState(() {
        _healthContext = healthContext;
        _hasWearableData = healthData.isNotEmpty;
      });

      // WebSocket으로 전송
      _websocketService.sendHealthContext({
        'context': healthContext,
        'prompt': contextPrompt,
        'is_user_itself': isUserItself,
        'user_name': user.name,  // 사용자 이름 명시적 전달
        'consultation_target_name': isUserItself
            ? user.name
            : (familyProfile?.name ?? widget.familyProfileName ?? '가족'),
      });

      print('✅ 건강 컨텍스트 전송 완료');
    } catch (e) {
      print('⚠️ 건강 컨텍스트 빌드 실패 (기본 상담으로 진행): $e');
    }
  }

  /// 가족 프로필을 ID로 검색
  FamilyProfileModel? _findFamilyProfileById(WidgetRef ref, String profileId) {
    try {
      final profilesAsync = ref.read(familyProfilesProvider);
      return profilesAsync.when(
        data: (profiles) => profiles.firstWhere(
          (p) => p.id == profileId,
          orElse: () => throw Exception('Profile not found'),
        ),
        loading: () => null,
        error: (_, __) => null,
      );
    } catch (e) {
      print('⚠️ 가족 프로필 검색 실패: $e');
      return null;
    }
  }

  /// 웨어러블 건강 데이터 수집
  ///
  /// HealthKit (iOS) 또는 Health Connect (Android)에서 데이터 수집
  Future<Map<String, dynamic>> _fetchWearableHealthData() async {
    try {
      final wearableService = WearableHealthService();

      // Health Connect/HealthKit 초기화 및 권한 확인
      final hasPermission = await wearableService.initialize();
      if (!hasPermission) {
        print('⚠️ 웨어러블 데이터 권한 없음 - 기본 상담으로 진행');
        return {};
      }

      // 최근 7일간 건강 데이터 수집
      final healthData = await wearableService.fetchRecentHealthData(days: 7);
      print('✅ 웨어러블 데이터 수집 완료: ${healthData.keys}');

      // 수집된 데이터 요약 로그
      if (healthData.containsKey('steps')) {
        final steps = healthData['steps'] as List;
        print('   - 걸음수 데이터: ${steps.length}일');
      }
      if (healthData.containsKey('heart_rate')) {
        final hr = healthData['heart_rate'] as List;
        print('   - 심박수 데이터: ${hr.length}건');
      }
      if (healthData.containsKey('sleep')) {
        final sleep = healthData['sleep'] as List;
        print('   - 수면 데이터: ${sleep.length}일');
      }

      return healthData;
    } catch (e) {
      print('⚠️ 웨어러블 데이터 수집 실패: $e');
      return {};
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

    // 오디오 재생 완료 리스너 (에코 방지)
    _audioService.playbackCompletedStream.listen(
      (_) {
        if (_isDisposed || !mounted) return;
        _isAudioBuffering = false;
        print('🔊 playbackCompletedStream 수신 - transcript완료: $_isTranscriptDone');

        // transcript도 완료되었으면 짧은 대기 후 바로 재개
        if (_isTranscriptDone && _isAiResponding) {
          _resumeAudioTransmission();
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

              // 오디오 재생이 완료되었으면 바로 재개
              if (!_audioService.isPlaying && !_isAudioBuffering) {
                _resumeAudioTransmission();
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

  /// 오디오 전송 재개 (에코 방지 후)
  ///
  /// AI 응답 완료 후 짧은 대기 시간(300ms)을 두고 오디오 전송을 재개합니다.
  /// 이 대기 시간은 스피커에서 나온 소리가 마이크에 남아있는 잔향을 피하기 위함입니다.
  void _resumeAudioTransmission() {
    _playbackSafetyTimer?.cancel();
    _playbackSafetyTimer = Timer(const Duration(milliseconds: 300), () {
      if (_isDisposed || !mounted) return;
      if (_isAiResponding) {
        _isAiResponding = false;
        _isTranscriptDone = false;
        _isAudioBuffering = false;
        print('✅ AI 응답 완료 + 300ms 대기 완료 - 오디오 전송 재개');
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

      // 1. 대화 기록 저장 (메시지가 있는 경우에만)
      await _saveConversationHistory();

      // 2. 녹음 중지
      await _audioService.stopRecording();

      // 3. WebSocket 종료 메시지 전송
      await _websocketService.endSession();

      // 4. 연결 종료
      await _websocketService.disconnect();

      // 5. 오디오 서비스 정리
      await _audioService.dispose();

      if (mounted && !_isDisposed) {
        setState(() {});
      }

      // 6. 이전 화면으로 돌아가기
      if (mounted && !_isDisposed) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('⚠️ 대화 종료 중 오류: $e');
    }
  }

  /// 대화 기록 저장
  Future<void> _saveConversationHistory() async {
    if (_messages.isEmpty || _sessionStartTime == null) {
      print('⚠️ 저장할 대화 내용이 없습니다');
      return;
    }

    try {
      // 메시지를 ConversationHistoryMessage로 변환
      final historyMessages = _messages.map((m) => ConversationHistoryMessage(
        text: m.text,
        isUser: m.isUser,
        timestamp: m.timestamp,
      )).toList();

      // ConversationHistory 생성
      final history = ConversationHistory(
        id: _conversationId,
        characterId: widget.characterId,
        characterName: widget.characterName,
        familyProfileId: widget.familyProfileId,
        familyProfileName: widget.familyProfileName,
        startTime: _sessionStartTime!,
        endTime: DateTime.now(),
        durationSeconds: _elapsedSeconds,
        messages: historyMessages,
        summary: _generateSimpleSummary(),
      );

      // 저장
      await ConversationHistoryService.saveConversation(history);
      print('✅ 대화 기록 저장 완료: ${_messages.length}개 메시지');
    } catch (e) {
      print('⚠️ 대화 기록 저장 실패: $e');
    }
  }

  /// 간단한 대화 요약 생성
  String? _generateSimpleSummary() {
    if (_messages.isEmpty) return null;

    // 첫 번째 사용자 메시지를 기준으로 간단한 요약
    final firstUserMessage = _messages.firstWhere(
      (m) => m.isUser,
      orElse: () => _messages.first,
    );

    final topic = firstUserMessage.text.length > 50
        ? '${firstUserMessage.text.substring(0, 50)}...'
        : firstUserMessage.text;

    return '상담 주제: $topic';
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
          // 캐릭터 이름 및 가족 프로필
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.characterName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.familyProfileName != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 12,
                        color: Color(0xFF666666),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.familyProfileName}님 상담',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 8),

          // 건강 정보 버튼
          if (_healthContext != null)
            GestureDetector(
              onTap: _showHealthContextBottomSheet,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _hasWearableData ? Icons.favorite : Icons.health_and_safety,
                      size: 14,
                      color: const Color(0xFF2196F3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '건강정보',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                  ],
                ),
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

  /// 건강 컨텍스트 바텀시트 표시
  void _showHealthContextBottomSheet() {
    if (_healthContext == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
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

              // 헤더
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      _hasWearableData ? Icons.favorite : Icons.person,
                      color: _hasWearableData
                          ? const Color(0xFF2196F3)
                          : const Color(0xFFFF9800),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI에게 전달된 건강 정보',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            _hasWearableData
                                ? '프로필 + 웨어러블 데이터'
                                : '프로필 정보만 전달됨',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // 컨텐츠
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // 상담 대상 정보
                    _buildContextSection(
                      title: '상담 대상 정보',
                      icon: Icons.person_outline,
                      child: _buildConsultationTargetInfo(),
                    ),

                    const SizedBox(height: 16),

                    // 신체 정보
                    _buildContextSection(
                      title: '신체 정보',
                      icon: Icons.accessibility_new,
                      child: _buildBodyMetricsInfo(),
                    ),

                    const SizedBox(height: 16),

                    // 건강 이력
                    _buildContextSection(
                      title: '건강 이력',
                      icon: Icons.medical_services_outlined,
                      child: _buildHealthConditionsInfo(),
                    ),

                    if (_hasWearableData) ...[
                      const SizedBox(height: 16),

                      // 웨어러블 데이터
                      _buildContextSection(
                        title: '웨어러블 건강 데이터',
                        icon: Icons.watch,
                        child: _buildWearableDataInfo(),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // 건강 주의사항
                    _buildContextSection(
                      title: '건강 주의사항',
                      icon: Icons.warning_amber_outlined,
                      child: _buildHealthRiskInfo(),
                    ),

                    const SizedBox(height: 24),

                    // 안내 문구
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI는 이 정보를 바탕으로 개인화된 건강 조언을 제공합니다. '
                              '단, 의료 진단이나 처방이 아닌 참고용 정보입니다.',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 컨텍스트 섹션 빌더
  Widget _buildContextSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF4CAF50)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  /// 상담 대상 정보 위젯
  Widget _buildConsultationTargetInfo() {
    final target = _healthContext?['consultation_target'] as Map<String, dynamic>?;
    if (target == null) return const Text('정보 없음');

    final demo = target['demographics'] as Map<String, dynamic>?;
    final isFamily = target['type'] == 'family_member';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('호칭', target['name'] ?? '사용자'),
        if (isFamily && target['relationship'] != null)
          _infoRow('관계', target['relationship']),
        if (demo != null) ...[
          if (demo['age'] != null)
            _infoRow('나이', '${demo['age']}세 (${demo['age_group'] ?? ""})'),
          if (demo['gender'] != null)
            _infoRow('성별', demo['gender']),
        ],
      ],
    );
  }

  /// 신체 정보 위젯
  Widget _buildBodyMetricsInfo() {
    final target = _healthContext?['consultation_target'] as Map<String, dynamic>?;
    final body = target?['body_metrics'] as Map<String, dynamic>?;
    if (body == null) return const Text('정보 없음');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (body['height_cm'] != null)
          _infoRow('키', '${body['height_cm']}cm'),
        if (body['weight_kg'] != null)
          _infoRow('체중', '${body['weight_kg']}kg'),
        if (body['bmi'] != null)
          _infoRow('BMI', '${body['bmi']} (${body['bmi_category'] ?? ""})'),
        if (body['blood_type'] != null)
          _infoRow('혈액형', body['blood_type']),
      ],
    );
  }

  /// 건강 이력 위젯
  Widget _buildHealthConditionsInfo() {
    final target = _healthContext?['consultation_target'] as Map<String, dynamic>?;
    final health = target?['health_conditions'] as Map<String, dynamic>?;
    if (health == null) return const Text('정보 없음');

    final conditions = health['chronic_conditions'] as List? ?? [];
    final allergies = health['allergies'] as List? ?? [];
    final medications = health['current_medications'] as List? ?? [];

    if (conditions.isEmpty && allergies.isEmpty && medications.isEmpty) {
      return const Text('등록된 건강 이력 없음', style: TextStyle(color: Colors.grey));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (conditions.isNotEmpty)
          _infoRow('만성질환', conditions.join(', ')),
        if (allergies.isNotEmpty)
          _infoRow('알레르기', allergies.join(', ')),
        if (medications.isNotEmpty)
          _infoRow('복용 약물', medications.join(', ')),
      ],
    );
  }

  /// 웨어러블 데이터 위젯
  Widget _buildWearableDataInfo() {
    final wearable = _healthContext?['wearable_health_data'] as Map<String, dynamic>?;
    if (wearable == null || wearable.isEmpty) {
      return const Text('웨어러블 데이터 없음', style: TextStyle(color: Colors.grey));
    }

    final widgets = <Widget>[];

    if (wearable['steps'] != null) {
      final steps = wearable['steps'] as Map<String, dynamic>;
      widgets.add(_infoRow('오늘 걸음수', '${steps['today']?.toInt() ?? "미측정"}보'));
    }
    if (wearable['heart_rate'] != null) {
      final hr = wearable['heart_rate'] as Map<String, dynamic>;
      widgets.add(_infoRow('심박수', '${hr['latest_bpm']}bpm (${hr['status'] ?? ""})'));
    }
    if (wearable['blood_pressure'] != null) {
      final bp = wearable['blood_pressure'] as Map<String, dynamic>;
      final latest = bp['latest'] as Map<String, dynamic>?;
      if (latest != null) {
        widgets.add(_infoRow('혈압', '${latest['systolic']}/${latest['diastolic']} mmHg'));
      }
    }
    if (wearable['sleep'] != null) {
      final sleep = wearable['sleep'] as Map<String, dynamic>;
      widgets.add(_infoRow('수면', '${sleep['last_night_hours']}시간 (${sleep['status'] ?? ""})'));
    }
    if (wearable['blood_oxygen'] != null) {
      final spo2 = wearable['blood_oxygen'] as Map<String, dynamic>;
      widgets.add(_infoRow('산소포화도', '${spo2['latest_percent']}% (${spo2['status'] ?? ""})'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// 건강 위험 정보 위젯
  Widget _buildHealthRiskInfo() {
    final risk = _healthContext?['health_risk_analysis'] as Map<String, dynamic>?;
    if (risk == null) return const Text('분석 정보 없음');

    final risks = risk['identified_risks'] as List? ?? [];
    final recommendations = risk['recommendations'] as List? ?? [];
    final riskLevel = risk['risk_level'] as String? ?? '낮음';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getRiskLevelColor(riskLevel).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '위험도: $riskLevel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getRiskLevelColor(riskLevel),
            ),
          ),
        ),
        if (risks.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('주요 위험 요인:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ...risks.map((r) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 12)),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )),
        ],
        if (recommendations.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('권장사항:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ...recommendations.map((r) => Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 12)),
                Expanded(child: Text(r, style: const TextStyle(fontSize: 12))),
              ],
            ),
          )),
        ],
      ],
    );
  }

  /// 정보 행 위젯
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 위험도 색상
  Color _getRiskLevelColor(String level) {
    switch (level) {
      case '높음':
        return Colors.red;
      case '주의':
        return Colors.orange;
      case '보통':
        return Colors.amber;
      default:
        return Colors.green;
    }
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import '../../../core/config/api_config.dart';

/// 응급 상황용 하이브리드 TTS 서비스
///
/// 기본: OpenAI TTS API 사용 (고품질)
/// 폴백: flutter_tts 사용 (오프라인/네트워크 실패 시)
class EmergencyTtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  bool _isSpeaking = false;
  bool _useOpenAiTts = true; // OpenAI TTS 사용 여부

  // 동시 실행 방지를 위한 뮤텍스
  Completer<void>? _currentSpeakCompleter;
  bool _isProcessing = false;

  /// 현재 말하고 있는지 여부
  bool get isSpeaking => _isSpeaking;

  /// OpenAI TTS 사용 여부
  bool get useOpenAiTts => _useOpenAiTts;

  /// OpenAI TTS 사용 설정
  set useOpenAiTts(bool value) => _useOpenAiTts = value;

  /// TTS 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // flutter_tts 초기화 (폴백용)
      await _flutterTts.setLanguage('ko-KR');
      await _flutterTts.setSpeechRate(0.5); // 응급 상황에 맞게 천천히
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // 완료 핸들러 설정
      _flutterTts.setCompletionHandler(() {
        debugPrint('🔊 [TTS] flutter_tts 완료');
        _onSpeechComplete();
      });

      _flutterTts.setErrorHandler((error) {
        debugPrint('❌ [TTS] flutter_tts 에러: $error');
        _onSpeechComplete();
      });

      _flutterTts.setCancelHandler(() {
        debugPrint('⚠️ [TTS] flutter_tts 취소됨');
        _onSpeechComplete();
      });

      _isInitialized = true;
      debugPrint('✅ EmergencyTtsService 초기화 완료');
    } catch (e) {
      debugPrint('❌ EmergencyTtsService 초기화 실패: $e');
      rethrow;
    }
  }

  /// 음성 완료 처리 (공통)
  void _onSpeechComplete() {
    _isSpeaking = false;
    if (_currentSpeakCompleter != null && !_currentSpeakCompleter!.isCompleted) {
      _currentSpeakCompleter!.complete();
    }
  }

  /// 텍스트를 음성으로 변환하여 재생 (순차 실행 보장)
  ///
  /// [text]: 재생할 텍스트
  /// [forceLocal]: true이면 로컬 TTS만 사용
  Future<void> speak(String text, {bool forceLocal = false}) async {
    if (!_isInitialized) {
      await initialize();
    }

    // 이미 처리 중이면 대기
    while (_isProcessing) {
      debugPrint('⏳ [TTS] 이전 음성 완료 대기 중...');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    _isProcessing = true;
    debugPrint('🎤 [TTS] 재생 시작: "$text"');

    // 이미 재생 중이면 중지
    if (_isSpeaking) {
      await stop();
      await Future.delayed(const Duration(milliseconds: 200));
    }

    _isSpeaking = true;
    _currentSpeakCompleter = Completer<void>();

    try {
      bool success = false;

      // OpenAI TTS 시도 (네트워크 연결 시)
      if (_useOpenAiTts && !forceLocal) {
        success = await _speakWithOpenAi(text);
        if (!success) {
          debugPrint('⚠️ [TTS] OpenAI TTS 실패, flutter_tts로 폴백');
        }
      }

      // 로컬 TTS (flutter_tts) 사용
      if (!success) {
        await _speakWithFlutterTts(text);
      }

      // 완료 대기 (최대 15초)
      if (!_currentSpeakCompleter!.isCompleted) {
        await _currentSpeakCompleter!.future.timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            debugPrint('⚠️ [TTS] 타임아웃 (15초)');
          },
        );
      }

      debugPrint('✅ [TTS] 재생 완료: "$text"');
    } catch (e) {
      debugPrint('❌ [TTS] 재생 실패: $e');
    } finally {
      _isSpeaking = false;
      _isProcessing = false;
      _currentSpeakCompleter = null;
    }
  }

  /// OpenAI TTS API로 음성 재생
  Future<bool> _speakWithOpenAi(String text) async {
    try {
      final url = '${ApiConfig.conversationBaseUrl}/tts';
      debugPrint('🌐 [TTS] OpenAI API 호출: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'text': text,
          'voice': 'alloy', // 명확한 음성
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final audioData = response.bodyBytes;
        debugPrint('🔊 [TTS] OpenAI 오디오 수신: ${audioData.length} bytes');
        await _playAudioData(audioData);
        return true;
      }

      debugPrint('⚠️ [TTS] OpenAI 응답 오류: ${response.statusCode}');
      return false;
    } catch (e) {
      debugPrint('⚠️ [TTS] OpenAI API 호출 실패: $e');
      return false;
    }
  }

  /// flutter_tts로 음성 재생 (로컬)
  Future<void> _speakWithFlutterTts(String text) async {
    debugPrint('📱 [TTS] flutter_tts 재생: "$text"');
    await _flutterTts.speak(text);
    // 완료는 completionHandler에서 처리됨
  }

  /// 오디오 데이터 재생 (MP3/WAV)
  Future<void> _playAudioData(Uint8List audioData) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.dataFromBytes(audioData, mimeType: 'audio/mpeg'),
        ),
      );

      await _audioPlayer.play();

      // 재생 완료 대기
      await _audioPlayer.playerStateStream.firstWhere(
        (state) => state.processingState == ProcessingState.completed,
      );

      _onSpeechComplete();
    } catch (e) {
      debugPrint('⚠️ [TTS] 오디오 재생 실패: $e');
      _onSpeechComplete();
    }
  }

  /// 음성 재생 중지
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      await _audioPlayer.stop();
      _isSpeaking = false;
      if (_currentSpeakCompleter != null && !_currentSpeakCompleter!.isCompleted) {
        _currentSpeakCompleter!.complete();
      }
    } catch (e) {
      debugPrint('⚠️ [TTS] 중지 실패: $e');
    }
  }

  /// 리소스 정리
  Future<void> dispose() async {
    await stop();
    await _audioPlayer.dispose();
    _isInitialized = false;
  }
}

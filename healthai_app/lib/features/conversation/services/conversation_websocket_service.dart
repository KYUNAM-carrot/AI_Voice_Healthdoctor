import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/conversation_model.dart';

/// WebSocket 기반 Conversation Service
/// OpenAI Realtime API와 통신하는 백엔드 WebSocket에 연결
class ConversationWebSocketService {
  WebSocketChannel? _channel;
  final StreamController<TranscriptMessage> _transcriptController =
      StreamController<TranscriptMessage>.broadcast();
  final StreamController<Uint8List> _audioController =
      StreamController<Uint8List>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  bool _isConnected = false;

  /// Transcript 메시지 스트림
  Stream<TranscriptMessage> get transcriptStream =>
      _transcriptController.stream;

  /// 오디오 델타 스트림 (AI 응답 오디오)
  Stream<Uint8List> get audioStream => _audioController.stream;

  /// 에러 스트림
  Stream<String> get errorStream => _errorController.stream;

  /// 연결 상태
  bool get isConnected => _isConnected;

  /// WebSocket 연결
  ///
  /// [websocketUrl]: ws://10.0.2.2:8004/ws/conversations/{conversation_id}?character_id={character_id}
  Future<void> connect(String websocketUrl) async {
    try {
      print('WebSocket 연결 시도: $websocketUrl');

      _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));

      _isConnected = true;
      print('WebSocket 연결 성공');

      // 메시지 수신 리스너
      _channel!.stream.listen(
        (message) {
          _handleMessage(message);
        },
        onError: (error) {
          print('WebSocket 에러: $error');
          _errorController.add('WebSocket 에러: $error');
          _isConnected = false;
        },
        onDone: () {
          print('WebSocket 연결 종료');
          _isConnected = false;
        },
        cancelOnError: false,
      );
    } catch (e) {
      print('WebSocket 연결 실패: $e');
      _errorController.add('연결 실패: $e');
      _isConnected = false;
      rethrow;
    }
  }

  /// 메시지 처리
  void _handleMessage(dynamic message) {
    try {
      if (message is String) {
        // JSON 텍스트 메시지 (Transcript, 에러 등)
        final data = json.decode(message);
        final event = WebSocketEvent.fromJson(data);

        switch (event.type) {
          case WebSocketEventType.transcript:
            final transcriptMsg = TranscriptMessage.fromJson(event.data);
            _transcriptController.add(transcriptMsg);
            break;

          case WebSocketEventType.error:
            final errorMessage = event.data['message'] as String? ?? 'Unknown error';
            _errorController.add(errorMessage);
            break;

          case WebSocketEventType.sessionEnded:
            final summary = event.data['summary'] as String?;
            print('세션 종료: $summary');
            disconnect();
            break;
        }
      } else if (message is List<int>) {
        // Binary 메시지 (오디오 델타)
        final audioBytes = Uint8List.fromList(message);
        _audioController.add(audioBytes);
      }
    } catch (e) {
      print('메시지 처리 오류: $e');
      _errorController.add('메시지 처리 오류: $e');
    }
  }

  /// 오디오 데이터 전송 (사용자 음성)
  ///
  /// [audioData]: PCM16 오디오 데이터 (bytes)
  void sendAudio(Uint8List audioData) {
    if (!_isConnected || _channel == null) {
      print('WebSocket 연결되지 않음 - 오디오 전송 불가');
      return;
    }

    // Binary 메시지로 전송
    _channel!.sink.add(audioData);
  }

  /// 세션 종료 요청
  void endSession() {
    if (!_isConnected || _channel == null) {
      print('WebSocket 연결되지 않음 - 세션 종료 불가');
      return;
    }

    final command = json.encode({
      'command': 'end_session',
    });

    _channel!.sink.add(command);
  }

  /// 연결 종료
  Future<void> disconnect() async {
    if (_channel != null) {
      await _channel!.sink.close();
      _channel = null;
    }
    _isConnected = false;
    print('WebSocket 연결 해제');
  }

  /// 리소스 정리
  void dispose() {
    disconnect();
    _transcriptController.close();
    _audioController.close();
    _errorController.close();
  }
}

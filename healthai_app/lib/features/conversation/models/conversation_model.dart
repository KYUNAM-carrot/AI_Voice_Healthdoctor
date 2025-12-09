/// Conversation 모델
class ConversationModel {
  final String conversationId;
  final String characterId;
  final String websocketUrl;
  final int maxDurationSeconds;
  final DateTime startedAt;
  final String? summary;

  ConversationModel({
    required this.conversationId,
    required this.characterId,
    required this.websocketUrl,
    required this.maxDurationSeconds,
    required this.startedAt,
    this.summary,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      conversationId: json['conversation_id'] as String,
      characterId: json['character_id'] as String,
      websocketUrl: json['websocket_url'] as String,
      maxDurationSeconds: json['max_duration_seconds'] as int,
      startedAt: DateTime.parse(json['started_at'] as String? ?? DateTime.now().toIso8601String()),
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'character_id': characterId,
      'websocket_url': websocketUrl,
      'max_duration_seconds': maxDurationSeconds,
      'started_at': startedAt.toIso8601String(),
      'summary': summary,
    };
  }
}

/// Transcript 메시지 모델
class TranscriptMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  TranscriptMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  factory TranscriptMessage.fromJson(Map<String, dynamic> json) {
    return TranscriptMessage(
      text: json['text'] as String,
      isUser: json['is_user'] as bool,
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_user': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

/// WebSocket 이벤트 타입
enum WebSocketEventType {
  transcript,
  error,
  sessionEnded,
}

/// WebSocket 이벤트
class WebSocketEvent {
  final WebSocketEventType type;
  final Map<String, dynamic> data;

  WebSocketEvent({
    required this.type,
    required this.data,
  });

  factory WebSocketEvent.fromJson(Map<String, dynamic> json) {
    final typeString = json['type'] as String;
    WebSocketEventType type;

    switch (typeString) {
      case 'transcript':
        type = WebSocketEventType.transcript;
        break;
      case 'error':
        type = WebSocketEventType.error;
        break;
      case 'session_ended':
        type = WebSocketEventType.sessionEnded;
        break;
      default:
        type = WebSocketEventType.error;
    }

    return WebSocketEvent(
      type: type,
      data: json,
    );
  }
}

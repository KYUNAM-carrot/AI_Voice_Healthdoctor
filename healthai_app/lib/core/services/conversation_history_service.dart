import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 대화 기록 모델
class ConversationHistory {
  final String id;
  final String characterId;
  final String characterName;
  final String? familyProfileId;
  final String? familyProfileName;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final List<ConversationHistoryMessage> messages;
  final String? summary;

  ConversationHistory({
    required this.id,
    required this.characterId,
    required this.characterName,
    this.familyProfileId,
    this.familyProfileName,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.messages,
    this.summary,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'characterId': characterId,
    'characterName': characterName,
    'familyProfileId': familyProfileId,
    'familyProfileName': familyProfileName,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime?.toIso8601String(),
    'durationSeconds': durationSeconds,
    'messages': messages.map((m) => m.toJson()).toList(),
    'summary': summary,
  };

  factory ConversationHistory.fromJson(Map<String, dynamic> json) {
    return ConversationHistory(
      id: json['id'],
      characterId: json['characterId'],
      characterName: json['characterName'],
      familyProfileId: json['familyProfileId'],
      familyProfileName: json['familyProfileName'],
      startTime: DateTime.parse(json['startTime']),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime']) : null,
      durationSeconds: json['durationSeconds'],
      messages: (json['messages'] as List)
          .map((m) => ConversationHistoryMessage.fromJson(m))
          .toList(),
      summary: json['summary'],
    );
  }
}

/// 대화 메시지 모델
class ConversationHistoryMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ConversationHistoryMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ConversationHistoryMessage.fromJson(Map<String, dynamic> json) {
    return ConversationHistoryMessage(
      text: json['text'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

/// 대화 기록 저장 서비스
class ConversationHistoryService {
  static const String _storageKey = 'conversation_histories';
  static const int _maxHistories = 50; // 최대 저장 개수

  /// 대화 기록 저장
  static Future<void> saveConversation(ConversationHistory history) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await getConversationHistories();

      // 기존에 같은 ID가 있으면 업데이트
      final existingIndex = histories.indexWhere((h) => h.id == history.id);
      if (existingIndex >= 0) {
        histories[existingIndex] = history;
      } else {
        histories.insert(0, history); // 최신 기록을 앞에 추가
      }

      // 최대 저장 개수 제한
      if (histories.length > _maxHistories) {
        histories.removeRange(_maxHistories, histories.length);
      }

      // 저장
      final jsonList = histories.map((h) => h.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      debugPrint('대화 기록 저장 완료: ${history.id}');
    } catch (e) {
      debugPrint('대화 기록 저장 실패: $e');
    }
  }

  /// 모든 대화 기록 조회
  static Future<List<ConversationHistory>> getConversationHistories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List;
      return jsonList
          .map((json) => ConversationHistory.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('대화 기록 조회 실패: $e');
      return [];
    }
  }

  /// 특정 대화 기록 조회
  static Future<ConversationHistory?> getConversationById(String id) async {
    final histories = await getConversationHistories();
    try {
      return histories.firstWhere((h) => h.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 대화 기록 삭제
  static Future<void> deleteConversation(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final histories = await getConversationHistories();

      histories.removeWhere((h) => h.id == id);

      final jsonList = histories.map((h) => h.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));

      debugPrint('대화 기록 삭제 완료: $id');
    } catch (e) {
      debugPrint('대화 기록 삭제 실패: $e');
    }
  }

  /// 모든 대화 기록 삭제
  static Future<void> clearAllConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      debugPrint('모든 대화 기록 삭제 완료');
    } catch (e) {
      debugPrint('모든 대화 기록 삭제 실패: $e');
    }
  }

  /// 캐릭터별 대화 기록 조회
  static Future<List<ConversationHistory>> getHistoriesByCharacter(
      String characterId) async {
    final histories = await getConversationHistories();
    return histories.where((h) => h.characterId == characterId).toList();
  }

  /// 가족 프로필별 대화 기록 조회
  static Future<List<ConversationHistory>> getHistoriesByFamilyProfile(
      String familyProfileId) async {
    final histories = await getConversationHistories();
    return histories.where((h) => h.familyProfileId == familyProfileId).toList();
  }

  /// 최근 대화 기록 조회 (개수 제한)
  static Future<List<ConversationHistory>> getRecentHistories({
    int limit = 10,
  }) async {
    final histories = await getConversationHistories();
    return histories.take(limit).toList();
  }
}

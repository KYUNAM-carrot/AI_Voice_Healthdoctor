import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';
import '../config/api_config.dart';

/// 캐릭터 API 서비스
class CharacterApiService {
  // Core API 베이스 URL (port 8002)
  static String get baseUrl => ApiConfig.baseUrl.replaceFirst('8004', '8002');

  /// 모든 캐릭터 조회
  Future<List<CharacterModel>> getAllCharacters() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/characters'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> charactersJson = jsonData['characters'];

        return charactersJson
            .map((json) => CharacterModel.fromJson(json))
            .toList();
      } else {
        throw Exception(
            'Failed to load characters: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error loading characters: $e');
      rethrow;
    }
  }

  /// 특정 캐릭터 조회
  Future<CharacterModel> getCharacter(String characterId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/v1/characters/$characterId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return CharacterModel.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load character: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error loading character: $e');
      rethrow;
    }
  }

  /// 캐릭터 자기소개 오디오 URL 가져오기
  /// Conversation Service의 welcome-audio 엔드포인트 사용
  String getIntroductionAudioUrl(String characterId) {
    return ApiConfig.welcomeAudioEndpoint(characterId);
  }

  /// 캐릭터 자기소개 오디오 다운로드 (바이트 데이터)
  Future<List<int>> downloadIntroductionAudio(String characterId) async {
    try {
      final response = await http.get(
        Uri.parse(getIntroductionAudioUrl(characterId)),
      );

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception(
            'Failed to download audio: ${response.statusCode}');
      }
    } catch (e) {
      print('Error downloading audio: $e');
      rethrow;
    }
  }
}

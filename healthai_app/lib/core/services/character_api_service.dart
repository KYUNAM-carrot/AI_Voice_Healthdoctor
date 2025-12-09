import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/character_model.dart';

/// 캐릭터 API 서비스
class CharacterApiService {
  // 로컬 테스트 서버
  // Android 에뮬레이터: 10.0.2.2 = 호스트 PC의 localhost
  // iOS 시뮬레이터/실제 기기: localhost 또는 PC IP 주소
  static const String baseUrl = 'http://10.0.2.2:8002';

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
  String getIntroductionAudioUrl(String characterId) {
    return '$baseUrl/api/v1/characters/$characterId/introduction';
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

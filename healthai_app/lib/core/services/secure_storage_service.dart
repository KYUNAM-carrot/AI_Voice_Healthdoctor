import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// 민감 데이터 암호화 저장소 서비스
///
/// FlutterSecureStorage를 사용하여 민감한 건강 정보를 암호화하여 저장
/// - Android: AES 암호화 (Keystore)
/// - iOS: Keychain
class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// 프로필 데이터 저장 키 접두사
  static const String _profileKeyPrefix = 'secure_profile_';

  /// 민감 데이터 저장
  static Future<void> saveSecureData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[SecureStorage] 저장 오류: $e');
      rethrow;
    }
  }

  /// 민감 데이터 읽기
  static Future<String?> readSecureData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[SecureStorage] 읽기 오류: $e');
      return null;
    }
  }

  /// 민감 데이터 삭제
  static Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[SecureStorage] 삭제 오류: $e');
    }
  }

  /// 사용자별 프로필 저장 키 생성
  static String getProfileKey(String userId) {
    return '$_profileKeyPrefix$userId';
  }

  /// 프로필 JSON 저장 (암호화)
  static Future<void> saveProfileJson(String userId, Map<String, dynamic> profileData) async {
    final key = getProfileKey(userId);
    final jsonString = jsonEncode(profileData);
    await saveSecureData(key, jsonString);
  }

  /// 프로필 JSON 읽기 (복호화)
  static Future<Map<String, dynamic>?> readProfileJson(String userId) async {
    final key = getProfileKey(userId);
    final jsonString = await readSecureData(key);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[SecureStorage] JSON 파싱 오류: $e');
      return null;
    }
  }

  /// 프로필 삭제
  static Future<void> deleteProfile(String userId) async {
    final key = getProfileKey(userId);
    await deleteSecureData(key);
  }

  /// 모든 저장된 데이터 삭제 (로그아웃 시 사용)
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
    } catch (e) {
      debugPrint('[SecureStorage] 전체 삭제 오류: $e');
    }
  }
}

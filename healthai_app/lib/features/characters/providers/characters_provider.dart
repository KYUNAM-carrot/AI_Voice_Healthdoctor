import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_model.dart';

// Mock data for now - will be replaced with API call
final charactersProvider = FutureProvider<List<CharacterModel>>((ref) async {
  // TODO: Replace with actual API call
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    CharacterModel(
      id: '1',
      name: '박지훈 주치의',
      specialty: '가정의학과',
      experienceYears: 15,
      profileImageUrl: null,
      description: '가족 건강 관리 전문가',
      expertiseAreas: ['건강검진', '만성질환 관리', '예방의학'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: '2',
      name: '김서연 주치의',
      specialty: '소아청소년과',
      experienceYears: 12,
      profileImageUrl: null,
      description: '아이들 건강 전문가',
      expertiseAreas: ['성장발달', '예방접종', '소아질환'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: '3',
      name: '이민호 주치의',
      specialty: '내과',
      experienceYears: 20,
      profileImageUrl: null,
      description: '성인 건강 관리 전문가',
      expertiseAreas: ['고혈압', '당뇨병', '고지혈증'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: '4',
      name: '최유진 주치의',
      specialty: '정신건강의학과',
      experienceYears: 10,
      profileImageUrl: null,
      description: '마음 건강 전문가',
      expertiseAreas: ['스트레스 관리', '불안', '우울'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

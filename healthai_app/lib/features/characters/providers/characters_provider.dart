import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/character_model.dart';

/// 실제 6명의 AI 캐릭터 데이터 (Backend seed 데이터와 동일)
final charactersProvider = FutureProvider<List<CharacterModel>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return [
    CharacterModel(
      id: 'park_jihoon',
      name: '박지훈',
      specialty: '내과',
      experienceYears: 20,
      profileImageUrl: null,
      description: '당뇨, 고혈압, 고지혈증 등 만성질환 관리 전문',
      expertiseAreas: ['당뇨병 관리', '고혈압 관리', '고지혈증', '만성 피로'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: 'choi_hyunwoo',
      name: '최현우',
      specialty: '정신건강의학과',
      experienceYears: 15,
      profileImageUrl: null,
      description: '스트레스, 불면증, 우울감, 불안 상담 전문',
      expertiseAreas: ['스트레스 관리', '불면증', '우울감', '불안'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: 'oh_kyungmi',
      name: '오경미',
      specialty: '임상영양사',
      experienceYears: 12,
      profileImageUrl: null,
      description: '식단 분석, 영양제 추천, 다이어트, 만성질환 식이요법',
      expertiseAreas: ['식단 분석', '영양제 추천', '다이어트', '만성질환 식이'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: 'lee_soojin',
      name: '이수진',
      specialty: '여성건강 전문의',
      experienceYears: 18,
      profileImageUrl: null,
      description: '갱년기 증상 관리, 생리불순, 생리통, 여성 호르몬 건강',
      expertiseAreas: ['갱년기 관리', '생리 건강', '여성 호르몬', '골다공증 예방'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: 'park_eunseo',
      name: '박은서',
      specialty: '소아청소년과',
      experienceYears: 15,
      profileImageUrl: null,
      description: '아이 성장발달, 영유아 영양, 수면, 예방접종',
      expertiseAreas: ['성장발달', '영유아 영양', '수면 교육', '예방접종'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    CharacterModel(
      id: 'jung_yujin',
      name: '정유진',
      specialty: '노인의학',
      experienceYears: 25,
      profileImageUrl: null,
      description: '치매 예방 및 조기 발견, 노인 만성질환 통합 관리',
      expertiseAreas: ['치매 예방', '노인 영양', '낙상 예방', '다약제 복용 관리'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

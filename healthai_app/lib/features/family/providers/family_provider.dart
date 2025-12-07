import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/family_profile_model.dart';

// Mock data for now - will be replaced with API call
final familyProfilesProvider =
    FutureProvider<List<FamilyProfileModel>>((ref) async {
  // TODO: Replace with actual API call
  await Future.delayed(const Duration(milliseconds: 500));

  return [
    FamilyProfileModel(
      id: '1',
      userId: 'user123',
      name: '홍길동',
      relationship: 'self',
      birthDate: DateTime(1985, 5, 15),
      gender: 'male',
      profileImageUrl: null,
      bloodType: 'A+',
      height: 175.0,
      weight: 70.0,
      allergies: ['페니실린'],
      medications: [],
      chronicConditions: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FamilyProfileModel(
      id: '2',
      userId: 'user123',
      name: '김영희',
      relationship: 'spouse',
      birthDate: DateTime(1987, 8, 20),
      gender: 'female',
      profileImageUrl: null,
      bloodType: 'B+',
      height: 162.0,
      weight: 55.0,
      allergies: [],
      medications: ['비타민D'],
      chronicConditions: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    FamilyProfileModel(
      id: '3',
      userId: 'user123',
      name: '홍지민',
      relationship: 'child',
      birthDate: DateTime(2015, 3, 10),
      gender: 'male',
      profileImageUrl: null,
      bloodType: 'A+',
      height: 120.0,
      weight: 25.0,
      allergies: ['땅콩'],
      medications: [],
      chronicConditions: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

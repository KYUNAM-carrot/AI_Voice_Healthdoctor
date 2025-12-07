// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'family_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FamilyProfileModelImpl _$$FamilyProfileModelImplFromJson(
  Map<String, dynamic> json,
) => _$FamilyProfileModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  name: json['name'] as String,
  relationship: json['relationship'] as String,
  birthDate: DateTime.parse(json['birthDate'] as String),
  gender: json['gender'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  bloodType: json['bloodType'] as String?,
  height: (json['height'] as num?)?.toDouble(),
  weight: (json['weight'] as num?)?.toDouble(),
  allergies:
      (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  medications:
      (json['medications'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  chronicConditions:
      (json['chronicConditions'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$FamilyProfileModelImplToJson(
  _$FamilyProfileModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'name': instance.name,
  'relationship': instance.relationship,
  'birthDate': instance.birthDate.toIso8601String(),
  'gender': instance.gender,
  'profileImageUrl': instance.profileImageUrl,
  'bloodType': instance.bloodType,
  'height': instance.height,
  'weight': instance.weight,
  'allergies': instance.allergies,
  'medications': instance.medications,
  'chronicConditions': instance.chronicConditions,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

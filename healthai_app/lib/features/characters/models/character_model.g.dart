// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CharacterModelImpl _$$CharacterModelImplFromJson(Map<String, dynamic> json) =>
    _$CharacterModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      experienceYears: (json['experienceYears'] as num).toInt(),
      profileImageUrl: json['profileImageUrl'] as String?,
      description: json['description'] as String?,
      expertiseAreas:
          (json['expertiseAreas'] as List<dynamic>?)
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

Map<String, dynamic> _$$CharacterModelImplToJson(
  _$CharacterModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'specialty': instance.specialty,
  'experienceYears': instance.experienceYears,
  'profileImageUrl': instance.profileImageUrl,
  'description': instance.description,
  'expertiseAreas': instance.expertiseAreas,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

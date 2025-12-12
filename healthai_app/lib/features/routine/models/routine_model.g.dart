// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routine_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RoutineItemImpl _$$RoutineItemImplFromJson(Map<String, dynamic> json) =>
    _$RoutineItemImpl(
      id: json['id'] as String,
      emoji: json['emoji'] as String,
      title: json['title'] as String,
      isCompleted: json['isCompleted'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$RoutineItemImplToJson(_$RoutineItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'emoji': instance.emoji,
      'title': instance.title,
      'isCompleted': instance.isCompleted,
      'order': instance.order,
    };

_$ConditionLevelImpl _$$ConditionLevelImplFromJson(Map<String, dynamic> json) =>
    _$ConditionLevelImpl(
      type: $enumDecode(_$ConditionTypeEnumMap, json['type']),
      level: (json['level'] as num).toInt(),
    );

Map<String, dynamic> _$$ConditionLevelImplToJson(
  _$ConditionLevelImpl instance,
) => <String, dynamic>{
  'type': _$ConditionTypeEnumMap[instance.type]!,
  'level': instance.level,
};

const _$ConditionTypeEnumMap = {
  ConditionType.mood: 'mood',
  ConditionType.energy: 'energy',
};

_$DailyRoutineImpl _$$DailyRoutineImplFromJson(Map<String, dynamic> json) =>
    _$DailyRoutineImpl(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => RoutineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      mood: json['mood'] == null
          ? null
          : ConditionLevel.fromJson(json['mood'] as Map<String, dynamic>),
      energy: json['energy'] == null
          ? null
          : ConditionLevel.fromJson(json['energy'] as Map<String, dynamic>),
      todayGoal: json['todayGoal'] as String?,
      schedules: (json['schedules'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      gratitudeItems: (json['gratitudeItems'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$DailyRoutineImplToJson(_$DailyRoutineImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date.toIso8601String(),
      'items': instance.items,
      'mood': instance.mood,
      'energy': instance.energy,
      'todayGoal': instance.todayGoal,
      'schedules': instance.schedules,
      'gratitudeItems': instance.gratitudeItems,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

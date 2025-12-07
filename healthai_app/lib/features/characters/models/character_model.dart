import 'package:freezed_annotation/freezed_annotation.dart';

part 'character_model.freezed.dart';
part 'character_model.g.dart';

@freezed
class CharacterModel with _$CharacterModel {
  const factory CharacterModel({
    required String id,
    required String name,
    required String specialty,
    required int experienceYears,
    String? profileImageUrl,
    String? description,
    @Default([]) List<String> expertiseAreas,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _CharacterModel;

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);
}

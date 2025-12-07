import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_profile_model.freezed.dart';
part 'family_profile_model.g.dart';

@freezed
class FamilyProfileModel with _$FamilyProfileModel {
  const factory FamilyProfileModel({
    required String id,
    required String userId,
    required String name,
    required String relationship,
    required DateTime birthDate,
    String? gender,
    String? profileImageUrl,
    String? bloodType,
    double? height,
    double? weight,
    @Default([]) List<String> allergies,
    @Default([]) List<String> medications,
    @Default([]) List<String> chronicConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _FamilyProfileModel;

  factory FamilyProfileModel.fromJson(Map<String, dynamic> json) =>
      _$FamilyProfileModelFromJson(json);
}

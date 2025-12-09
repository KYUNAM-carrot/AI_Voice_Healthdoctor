/// AI 캐릭터 모델
class CharacterModel {
  final String id;
  final String name;
  final String nameEn;
  final String gender;
  final String ageRange;
  final String specialty;
  final String specialtyDetail;
  final int experienceYears;
  final String personality;
  final String conversationStyle;
  final String openaiVoice;
  final String? profileImageUrl;
  final String? lottieAnimationUrl;
  final String? introductionAudioUrl;
  final String? introductionText;

  CharacterModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.gender,
    required this.ageRange,
    required this.specialty,
    required this.specialtyDetail,
    required this.experienceYears,
    required this.personality,
    required this.conversationStyle,
    required this.openaiVoice,
    this.profileImageUrl,
    this.lottieAnimationUrl,
    this.introductionAudioUrl,
    this.introductionText,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['name_en'] as String,
      gender: json['gender'] as String,
      ageRange: json['age_range'] as String,
      specialty: json['specialty'] as String,
      specialtyDetail: json['specialty_detail'] as String,
      experienceYears: json['experience_years'] as int,
      personality: json['personality'] as String,
      conversationStyle: json['conversation_style'] as String,
      openaiVoice: json['openai_voice'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      lottieAnimationUrl: json['lottie_animation_url'] as String?,
      introductionAudioUrl: json['introduction_audio_url'] as String?,
      introductionText: json['introduction_text'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'gender': gender,
      'age_range': ageRange,
      'specialty': specialty,
      'specialty_detail': specialtyDetail,
      'experience_years': experienceYears,
      'personality': personality,
      'conversation_style': conversationStyle,
      'openai_voice': openaiVoice,
      'profile_image_url': profileImageUrl,
      'lottie_animation_url': lottieAnimationUrl,
      'introduction_audio_url': introductionAudioUrl,
      'introduction_text': introductionText,
    };
  }
}

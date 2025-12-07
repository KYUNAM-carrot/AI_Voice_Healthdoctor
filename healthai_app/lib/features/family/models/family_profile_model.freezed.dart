// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'family_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FamilyProfileModel _$FamilyProfileModelFromJson(Map<String, dynamic> json) {
  return _FamilyProfileModel.fromJson(json);
}

/// @nodoc
mixin _$FamilyProfileModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get relationship => throw _privateConstructorUsedError;
  DateTime get birthDate => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get profileImageUrl => throw _privateConstructorUsedError;
  String? get bloodType => throw _privateConstructorUsedError;
  double? get height => throw _privateConstructorUsedError;
  double? get weight => throw _privateConstructorUsedError;
  List<String> get allergies => throw _privateConstructorUsedError;
  List<String> get medications => throw _privateConstructorUsedError;
  List<String> get chronicConditions => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FamilyProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FamilyProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FamilyProfileModelCopyWith<FamilyProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FamilyProfileModelCopyWith<$Res> {
  factory $FamilyProfileModelCopyWith(
    FamilyProfileModel value,
    $Res Function(FamilyProfileModel) then,
  ) = _$FamilyProfileModelCopyWithImpl<$Res, FamilyProfileModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String relationship,
    DateTime birthDate,
    String? gender,
    String? profileImageUrl,
    String? bloodType,
    double? height,
    double? weight,
    List<String> allergies,
    List<String> medications,
    List<String> chronicConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$FamilyProfileModelCopyWithImpl<$Res, $Val extends FamilyProfileModel>
    implements $FamilyProfileModelCopyWith<$Res> {
  _$FamilyProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FamilyProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? relationship = null,
    Object? birthDate = null,
    Object? gender = freezed,
    Object? profileImageUrl = freezed,
    Object? bloodType = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? allergies = null,
    Object? medications = null,
    Object? chronicConditions = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            relationship: null == relationship
                ? _value.relationship
                : relationship // ignore: cast_nullable_to_non_nullable
                      as String,
            birthDate: null == birthDate
                ? _value.birthDate
                : birthDate // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            bloodType: freezed == bloodType
                ? _value.bloodType
                : bloodType // ignore: cast_nullable_to_non_nullable
                      as String?,
            height: freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                      as double?,
            weight: freezed == weight
                ? _value.weight
                : weight // ignore: cast_nullable_to_non_nullable
                      as double?,
            allergies: null == allergies
                ? _value.allergies
                : allergies // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            medications: null == medications
                ? _value.medications
                : medications // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            chronicConditions: null == chronicConditions
                ? _value.chronicConditions
                : chronicConditions // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FamilyProfileModelImplCopyWith<$Res>
    implements $FamilyProfileModelCopyWith<$Res> {
  factory _$$FamilyProfileModelImplCopyWith(
    _$FamilyProfileModelImpl value,
    $Res Function(_$FamilyProfileModelImpl) then,
  ) = __$$FamilyProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String name,
    String relationship,
    DateTime birthDate,
    String? gender,
    String? profileImageUrl,
    String? bloodType,
    double? height,
    double? weight,
    List<String> allergies,
    List<String> medications,
    List<String> chronicConditions,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$FamilyProfileModelImplCopyWithImpl<$Res>
    extends _$FamilyProfileModelCopyWithImpl<$Res, _$FamilyProfileModelImpl>
    implements _$$FamilyProfileModelImplCopyWith<$Res> {
  __$$FamilyProfileModelImplCopyWithImpl(
    _$FamilyProfileModelImpl _value,
    $Res Function(_$FamilyProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FamilyProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? name = null,
    Object? relationship = null,
    Object? birthDate = null,
    Object? gender = freezed,
    Object? profileImageUrl = freezed,
    Object? bloodType = freezed,
    Object? height = freezed,
    Object? weight = freezed,
    Object? allergies = null,
    Object? medications = null,
    Object? chronicConditions = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$FamilyProfileModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        relationship: null == relationship
            ? _value.relationship
            : relationship // ignore: cast_nullable_to_non_nullable
                  as String,
        birthDate: null == birthDate
            ? _value.birthDate
            : birthDate // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        bloodType: freezed == bloodType
            ? _value.bloodType
            : bloodType // ignore: cast_nullable_to_non_nullable
                  as String?,
        height: freezed == height
            ? _value.height
            : height // ignore: cast_nullable_to_non_nullable
                  as double?,
        weight: freezed == weight
            ? _value.weight
            : weight // ignore: cast_nullable_to_non_nullable
                  as double?,
        allergies: null == allergies
            ? _value._allergies
            : allergies // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        medications: null == medications
            ? _value._medications
            : medications // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        chronicConditions: null == chronicConditions
            ? _value._chronicConditions
            : chronicConditions // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FamilyProfileModelImpl implements _FamilyProfileModel {
  const _$FamilyProfileModelImpl({
    required this.id,
    required this.userId,
    required this.name,
    required this.relationship,
    required this.birthDate,
    this.gender,
    this.profileImageUrl,
    this.bloodType,
    this.height,
    this.weight,
    final List<String> allergies = const [],
    final List<String> medications = const [],
    final List<String> chronicConditions = const [],
    this.createdAt,
    this.updatedAt,
  }) : _allergies = allergies,
       _medications = medications,
       _chronicConditions = chronicConditions;

  factory _$FamilyProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FamilyProfileModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String name;
  @override
  final String relationship;
  @override
  final DateTime birthDate;
  @override
  final String? gender;
  @override
  final String? profileImageUrl;
  @override
  final String? bloodType;
  @override
  final double? height;
  @override
  final double? weight;
  final List<String> _allergies;
  @override
  @JsonKey()
  List<String> get allergies {
    if (_allergies is EqualUnmodifiableListView) return _allergies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allergies);
  }

  final List<String> _medications;
  @override
  @JsonKey()
  List<String> get medications {
    if (_medications is EqualUnmodifiableListView) return _medications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_medications);
  }

  final List<String> _chronicConditions;
  @override
  @JsonKey()
  List<String> get chronicConditions {
    if (_chronicConditions is EqualUnmodifiableListView)
      return _chronicConditions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chronicConditions);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'FamilyProfileModel(id: $id, userId: $userId, name: $name, relationship: $relationship, birthDate: $birthDate, gender: $gender, profileImageUrl: $profileImageUrl, bloodType: $bloodType, height: $height, weight: $weight, allergies: $allergies, medications: $medications, chronicConditions: $chronicConditions, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FamilyProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.relationship, relationship) ||
                other.relationship == relationship) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.bloodType, bloodType) ||
                other.bloodType == bloodType) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            const DeepCollectionEquality().equals(
              other._allergies,
              _allergies,
            ) &&
            const DeepCollectionEquality().equals(
              other._medications,
              _medications,
            ) &&
            const DeepCollectionEquality().equals(
              other._chronicConditions,
              _chronicConditions,
            ) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    userId,
    name,
    relationship,
    birthDate,
    gender,
    profileImageUrl,
    bloodType,
    height,
    weight,
    const DeepCollectionEquality().hash(_allergies),
    const DeepCollectionEquality().hash(_medications),
    const DeepCollectionEquality().hash(_chronicConditions),
    createdAt,
    updatedAt,
  );

  /// Create a copy of FamilyProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FamilyProfileModelImplCopyWith<_$FamilyProfileModelImpl> get copyWith =>
      __$$FamilyProfileModelImplCopyWithImpl<_$FamilyProfileModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FamilyProfileModelImplToJson(this);
  }
}

abstract class _FamilyProfileModel implements FamilyProfileModel {
  const factory _FamilyProfileModel({
    required final String id,
    required final String userId,
    required final String name,
    required final String relationship,
    required final DateTime birthDate,
    final String? gender,
    final String? profileImageUrl,
    final String? bloodType,
    final double? height,
    final double? weight,
    final List<String> allergies,
    final List<String> medications,
    final List<String> chronicConditions,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$FamilyProfileModelImpl;

  factory _FamilyProfileModel.fromJson(Map<String, dynamic> json) =
      _$FamilyProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get name;
  @override
  String get relationship;
  @override
  DateTime get birthDate;
  @override
  String? get gender;
  @override
  String? get profileImageUrl;
  @override
  String? get bloodType;
  @override
  double? get height;
  @override
  double? get weight;
  @override
  List<String> get allergies;
  @override
  List<String> get medications;
  @override
  List<String> get chronicConditions;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of FamilyProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FamilyProfileModelImplCopyWith<_$FamilyProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

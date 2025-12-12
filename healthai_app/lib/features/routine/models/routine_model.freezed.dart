// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'routine_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

RoutineItem _$RoutineItemFromJson(Map<String, dynamic> json) {
  return _RoutineItem.fromJson(json);
}

/// @nodoc
mixin _$RoutineItem {
  String get id => throw _privateConstructorUsedError;
  String get emoji => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  bool get isCompleted => throw _privateConstructorUsedError;
  int get order => throw _privateConstructorUsedError;

  /// Serializes this RoutineItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RoutineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RoutineItemCopyWith<RoutineItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutineItemCopyWith<$Res> {
  factory $RoutineItemCopyWith(
    RoutineItem value,
    $Res Function(RoutineItem) then,
  ) = _$RoutineItemCopyWithImpl<$Res, RoutineItem>;
  @useResult
  $Res call({
    String id,
    String emoji,
    String title,
    bool isCompleted,
    int order,
  });
}

/// @nodoc
class _$RoutineItemCopyWithImpl<$Res, $Val extends RoutineItem>
    implements $RoutineItemCopyWith<$Res> {
  _$RoutineItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RoutineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? emoji = null,
    Object? title = null,
    Object? isCompleted = null,
    Object? order = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            emoji: null == emoji
                ? _value.emoji
                : emoji // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            isCompleted: null == isCompleted
                ? _value.isCompleted
                : isCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
            order: null == order
                ? _value.order
                : order // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RoutineItemImplCopyWith<$Res>
    implements $RoutineItemCopyWith<$Res> {
  factory _$$RoutineItemImplCopyWith(
    _$RoutineItemImpl value,
    $Res Function(_$RoutineItemImpl) then,
  ) = __$$RoutineItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String emoji,
    String title,
    bool isCompleted,
    int order,
  });
}

/// @nodoc
class __$$RoutineItemImplCopyWithImpl<$Res>
    extends _$RoutineItemCopyWithImpl<$Res, _$RoutineItemImpl>
    implements _$$RoutineItemImplCopyWith<$Res> {
  __$$RoutineItemImplCopyWithImpl(
    _$RoutineItemImpl _value,
    $Res Function(_$RoutineItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RoutineItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? emoji = null,
    Object? title = null,
    Object? isCompleted = null,
    Object? order = null,
  }) {
    return _then(
      _$RoutineItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        emoji: null == emoji
            ? _value.emoji
            : emoji // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        isCompleted: null == isCompleted
            ? _value.isCompleted
            : isCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
        order: null == order
            ? _value.order
            : order // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutineItemImpl implements _RoutineItem {
  const _$RoutineItemImpl({
    required this.id,
    required this.emoji,
    required this.title,
    this.isCompleted = false,
    this.order = 0,
  });

  factory _$RoutineItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutineItemImplFromJson(json);

  @override
  final String id;
  @override
  final String emoji;
  @override
  final String title;
  @override
  @JsonKey()
  final bool isCompleted;
  @override
  @JsonKey()
  final int order;

  @override
  String toString() {
    return 'RoutineItem(id: $id, emoji: $emoji, title: $title, isCompleted: $isCompleted, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutineItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.emoji, emoji) || other.emoji == emoji) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.isCompleted, isCompleted) ||
                other.isCompleted == isCompleted) &&
            (identical(other.order, order) || other.order == order));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, emoji, title, isCompleted, order);

  /// Create a copy of RoutineItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutineItemImplCopyWith<_$RoutineItemImpl> get copyWith =>
      __$$RoutineItemImplCopyWithImpl<_$RoutineItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutineItemImplToJson(this);
  }
}

abstract class _RoutineItem implements RoutineItem {
  const factory _RoutineItem({
    required final String id,
    required final String emoji,
    required final String title,
    final bool isCompleted,
    final int order,
  }) = _$RoutineItemImpl;

  factory _RoutineItem.fromJson(Map<String, dynamic> json) =
      _$RoutineItemImpl.fromJson;

  @override
  String get id;
  @override
  String get emoji;
  @override
  String get title;
  @override
  bool get isCompleted;
  @override
  int get order;

  /// Create a copy of RoutineItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RoutineItemImplCopyWith<_$RoutineItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ConditionLevel _$ConditionLevelFromJson(Map<String, dynamic> json) {
  return _ConditionLevel.fromJson(json);
}

/// @nodoc
mixin _$ConditionLevel {
  ConditionType get type => throw _privateConstructorUsedError;
  int get level => throw _privateConstructorUsedError;

  /// Serializes this ConditionLevel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ConditionLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ConditionLevelCopyWith<ConditionLevel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ConditionLevelCopyWith<$Res> {
  factory $ConditionLevelCopyWith(
    ConditionLevel value,
    $Res Function(ConditionLevel) then,
  ) = _$ConditionLevelCopyWithImpl<$Res, ConditionLevel>;
  @useResult
  $Res call({ConditionType type, int level});
}

/// @nodoc
class _$ConditionLevelCopyWithImpl<$Res, $Val extends ConditionLevel>
    implements $ConditionLevelCopyWith<$Res> {
  _$ConditionLevelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ConditionLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? level = null}) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ConditionType,
            level: null == level
                ? _value.level
                : level // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ConditionLevelImplCopyWith<$Res>
    implements $ConditionLevelCopyWith<$Res> {
  factory _$$ConditionLevelImplCopyWith(
    _$ConditionLevelImpl value,
    $Res Function(_$ConditionLevelImpl) then,
  ) = __$$ConditionLevelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({ConditionType type, int level});
}

/// @nodoc
class __$$ConditionLevelImplCopyWithImpl<$Res>
    extends _$ConditionLevelCopyWithImpl<$Res, _$ConditionLevelImpl>
    implements _$$ConditionLevelImplCopyWith<$Res> {
  __$$ConditionLevelImplCopyWithImpl(
    _$ConditionLevelImpl _value,
    $Res Function(_$ConditionLevelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ConditionLevel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? type = null, Object? level = null}) {
    return _then(
      _$ConditionLevelImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ConditionType,
        level: null == level
            ? _value.level
            : level // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ConditionLevelImpl implements _ConditionLevel {
  const _$ConditionLevelImpl({required this.type, required this.level});

  factory _$ConditionLevelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ConditionLevelImplFromJson(json);

  @override
  final ConditionType type;
  @override
  final int level;

  @override
  String toString() {
    return 'ConditionLevel(type: $type, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ConditionLevelImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.level, level) || other.level == level));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, type, level);

  /// Create a copy of ConditionLevel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ConditionLevelImplCopyWith<_$ConditionLevelImpl> get copyWith =>
      __$$ConditionLevelImplCopyWithImpl<_$ConditionLevelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ConditionLevelImplToJson(this);
  }
}

abstract class _ConditionLevel implements ConditionLevel {
  const factory _ConditionLevel({
    required final ConditionType type,
    required final int level,
  }) = _$ConditionLevelImpl;

  factory _ConditionLevel.fromJson(Map<String, dynamic> json) =
      _$ConditionLevelImpl.fromJson;

  @override
  ConditionType get type;
  @override
  int get level;

  /// Create a copy of ConditionLevel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ConditionLevelImplCopyWith<_$ConditionLevelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

DailyRoutine _$DailyRoutineFromJson(Map<String, dynamic> json) {
  return _DailyRoutine.fromJson(json);
}

/// @nodoc
mixin _$DailyRoutine {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  List<RoutineItem> get items => throw _privateConstructorUsedError;
  ConditionLevel? get mood => throw _privateConstructorUsedError;
  ConditionLevel? get energy => throw _privateConstructorUsedError;
  String? get todayGoal => throw _privateConstructorUsedError;
  List<String>? get schedules => throw _privateConstructorUsedError;
  List<String>? get gratitudeItems => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this DailyRoutine to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyRoutineCopyWith<DailyRoutine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyRoutineCopyWith<$Res> {
  factory $DailyRoutineCopyWith(
    DailyRoutine value,
    $Res Function(DailyRoutine) then,
  ) = _$DailyRoutineCopyWithImpl<$Res, DailyRoutine>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    List<RoutineItem> items,
    ConditionLevel? mood,
    ConditionLevel? energy,
    String? todayGoal,
    List<String>? schedules,
    List<String>? gratitudeItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  $ConditionLevelCopyWith<$Res>? get mood;
  $ConditionLevelCopyWith<$Res>? get energy;
}

/// @nodoc
class _$DailyRoutineCopyWithImpl<$Res, $Val extends DailyRoutine>
    implements $DailyRoutineCopyWith<$Res> {
  _$DailyRoutineCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? items = null,
    Object? mood = freezed,
    Object? energy = freezed,
    Object? todayGoal = freezed,
    Object? schedules = freezed,
    Object? gratitudeItems = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<RoutineItem>,
            mood: freezed == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as ConditionLevel?,
            energy: freezed == energy
                ? _value.energy
                : energy // ignore: cast_nullable_to_non_nullable
                      as ConditionLevel?,
            todayGoal: freezed == todayGoal
                ? _value.todayGoal
                : todayGoal // ignore: cast_nullable_to_non_nullable
                      as String?,
            schedules: freezed == schedules
                ? _value.schedules
                : schedules // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
            gratitudeItems: freezed == gratitudeItems
                ? _value.gratitudeItems
                : gratitudeItems // ignore: cast_nullable_to_non_nullable
                      as List<String>?,
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

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionLevelCopyWith<$Res>? get mood {
    if (_value.mood == null) {
      return null;
    }

    return $ConditionLevelCopyWith<$Res>(_value.mood!, (value) {
      return _then(_value.copyWith(mood: value) as $Val);
    });
  }

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ConditionLevelCopyWith<$Res>? get energy {
    if (_value.energy == null) {
      return null;
    }

    return $ConditionLevelCopyWith<$Res>(_value.energy!, (value) {
      return _then(_value.copyWith(energy: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$DailyRoutineImplCopyWith<$Res>
    implements $DailyRoutineCopyWith<$Res> {
  factory _$$DailyRoutineImplCopyWith(
    _$DailyRoutineImpl value,
    $Res Function(_$DailyRoutineImpl) then,
  ) = __$$DailyRoutineImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    List<RoutineItem> items,
    ConditionLevel? mood,
    ConditionLevel? energy,
    String? todayGoal,
    List<String>? schedules,
    List<String>? gratitudeItems,
    DateTime? createdAt,
    DateTime? updatedAt,
  });

  @override
  $ConditionLevelCopyWith<$Res>? get mood;
  @override
  $ConditionLevelCopyWith<$Res>? get energy;
}

/// @nodoc
class __$$DailyRoutineImplCopyWithImpl<$Res>
    extends _$DailyRoutineCopyWithImpl<$Res, _$DailyRoutineImpl>
    implements _$$DailyRoutineImplCopyWith<$Res> {
  __$$DailyRoutineImplCopyWithImpl(
    _$DailyRoutineImpl _value,
    $Res Function(_$DailyRoutineImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? items = null,
    Object? mood = freezed,
    Object? energy = freezed,
    Object? todayGoal = freezed,
    Object? schedules = freezed,
    Object? gratitudeItems = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$DailyRoutineImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<RoutineItem>,
        mood: freezed == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as ConditionLevel?,
        energy: freezed == energy
            ? _value.energy
            : energy // ignore: cast_nullable_to_non_nullable
                  as ConditionLevel?,
        todayGoal: freezed == todayGoal
            ? _value.todayGoal
            : todayGoal // ignore: cast_nullable_to_non_nullable
                  as String?,
        schedules: freezed == schedules
            ? _value._schedules
            : schedules // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
        gratitudeItems: freezed == gratitudeItems
            ? _value._gratitudeItems
            : gratitudeItems // ignore: cast_nullable_to_non_nullable
                  as List<String>?,
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
class _$DailyRoutineImpl implements _DailyRoutine {
  const _$DailyRoutineImpl({
    required this.id,
    required this.date,
    required final List<RoutineItem> items,
    this.mood,
    this.energy,
    this.todayGoal,
    final List<String>? schedules,
    final List<String>? gratitudeItems,
    this.createdAt,
    this.updatedAt,
  }) : _items = items,
       _schedules = schedules,
       _gratitudeItems = gratitudeItems;

  factory _$DailyRoutineImpl.fromJson(Map<String, dynamic> json) =>
      _$$DailyRoutineImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  final List<RoutineItem> _items;
  @override
  List<RoutineItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  final ConditionLevel? mood;
  @override
  final ConditionLevel? energy;
  @override
  final String? todayGoal;
  final List<String>? _schedules;
  @override
  List<String>? get schedules {
    final value = _schedules;
    if (value == null) return null;
    if (_schedules is EqualUnmodifiableListView) return _schedules;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _gratitudeItems;
  @override
  List<String>? get gratitudeItems {
    final value = _gratitudeItems;
    if (value == null) return null;
    if (_gratitudeItems is EqualUnmodifiableListView) return _gratitudeItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'DailyRoutine(id: $id, date: $date, items: $items, mood: $mood, energy: $energy, todayGoal: $todayGoal, schedules: $schedules, gratitudeItems: $gratitudeItems, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyRoutineImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._items, _items) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            (identical(other.energy, energy) || other.energy == energy) &&
            (identical(other.todayGoal, todayGoal) ||
                other.todayGoal == todayGoal) &&
            const DeepCollectionEquality().equals(
              other._schedules,
              _schedules,
            ) &&
            const DeepCollectionEquality().equals(
              other._gratitudeItems,
              _gratitudeItems,
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
    date,
    const DeepCollectionEquality().hash(_items),
    mood,
    energy,
    todayGoal,
    const DeepCollectionEquality().hash(_schedules),
    const DeepCollectionEquality().hash(_gratitudeItems),
    createdAt,
    updatedAt,
  );

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyRoutineImplCopyWith<_$DailyRoutineImpl> get copyWith =>
      __$$DailyRoutineImplCopyWithImpl<_$DailyRoutineImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DailyRoutineImplToJson(this);
  }
}

abstract class _DailyRoutine implements DailyRoutine {
  const factory _DailyRoutine({
    required final String id,
    required final DateTime date,
    required final List<RoutineItem> items,
    final ConditionLevel? mood,
    final ConditionLevel? energy,
    final String? todayGoal,
    final List<String>? schedules,
    final List<String>? gratitudeItems,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$DailyRoutineImpl;

  factory _DailyRoutine.fromJson(Map<String, dynamic> json) =
      _$DailyRoutineImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  List<RoutineItem> get items;
  @override
  ConditionLevel? get mood;
  @override
  ConditionLevel? get energy;
  @override
  String? get todayGoal;
  @override
  List<String>? get schedules;
  @override
  List<String>? get gratitudeItems;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of DailyRoutine
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyRoutineImplCopyWith<_$DailyRoutineImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscription_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SubscriptionModel _$SubscriptionModelFromJson(Map<String, dynamic> json) {
  return _SubscriptionModel.fromJson(json);
}

/// @nodoc
mixin _$SubscriptionModel {
  String get id => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  String get plan =>
      throw _privateConstructorUsedError; // 'free', 'basic', 'premium', 'family'
  String get status =>
      throw _privateConstructorUsedError; // 'active', 'cancelled', 'expired', 'trial'
  String? get revenuecatCustomerId => throw _privateConstructorUsedError;
  DateTime? get startDate => throw _privateConstructorUsedError;
  DateTime? get endDate => throw _privateConstructorUsedError;
  DateTime? get trialEndDate => throw _privateConstructorUsedError;
  bool get autoRenew => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this SubscriptionModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubscriptionModelCopyWith<SubscriptionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubscriptionModelCopyWith<$Res> {
  factory $SubscriptionModelCopyWith(
    SubscriptionModel value,
    $Res Function(SubscriptionModel) then,
  ) = _$SubscriptionModelCopyWithImpl<$Res, SubscriptionModel>;
  @useResult
  $Res call({
    String id,
    String userId,
    String plan,
    String status,
    String? revenuecatCustomerId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    bool autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$SubscriptionModelCopyWithImpl<$Res, $Val extends SubscriptionModel>
    implements $SubscriptionModelCopyWith<$Res> {
  _$SubscriptionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? plan = null,
    Object? status = null,
    Object? revenuecatCustomerId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? trialEndDate = freezed,
    Object? autoRenew = null,
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
            plan: null == plan
                ? _value.plan
                : plan // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            revenuecatCustomerId: freezed == revenuecatCustomerId
                ? _value.revenuecatCustomerId
                : revenuecatCustomerId // ignore: cast_nullable_to_non_nullable
                      as String?,
            startDate: freezed == startDate
                ? _value.startDate
                : startDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            endDate: freezed == endDate
                ? _value.endDate
                : endDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            trialEndDate: freezed == trialEndDate
                ? _value.trialEndDate
                : trialEndDate // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            autoRenew: null == autoRenew
                ? _value.autoRenew
                : autoRenew // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$SubscriptionModelImplCopyWith<$Res>
    implements $SubscriptionModelCopyWith<$Res> {
  factory _$$SubscriptionModelImplCopyWith(
    _$SubscriptionModelImpl value,
    $Res Function(_$SubscriptionModelImpl) then,
  ) = __$$SubscriptionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String userId,
    String plan,
    String status,
    String? revenuecatCustomerId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    bool autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$SubscriptionModelImplCopyWithImpl<$Res>
    extends _$SubscriptionModelCopyWithImpl<$Res, _$SubscriptionModelImpl>
    implements _$$SubscriptionModelImplCopyWith<$Res> {
  __$$SubscriptionModelImplCopyWithImpl(
    _$SubscriptionModelImpl _value,
    $Res Function(_$SubscriptionModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? plan = null,
    Object? status = null,
    Object? revenuecatCustomerId = freezed,
    Object? startDate = freezed,
    Object? endDate = freezed,
    Object? trialEndDate = freezed,
    Object? autoRenew = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$SubscriptionModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as String,
        plan: null == plan
            ? _value.plan
            : plan // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        revenuecatCustomerId: freezed == revenuecatCustomerId
            ? _value.revenuecatCustomerId
            : revenuecatCustomerId // ignore: cast_nullable_to_non_nullable
                  as String?,
        startDate: freezed == startDate
            ? _value.startDate
            : startDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        endDate: freezed == endDate
            ? _value.endDate
            : endDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        trialEndDate: freezed == trialEndDate
            ? _value.trialEndDate
            : trialEndDate // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        autoRenew: null == autoRenew
            ? _value.autoRenew
            : autoRenew // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$SubscriptionModelImpl implements _SubscriptionModel {
  const _$SubscriptionModelImpl({
    required this.id,
    required this.userId,
    required this.plan,
    required this.status,
    this.revenuecatCustomerId,
    this.startDate,
    this.endDate,
    this.trialEndDate,
    this.autoRenew = true,
    this.createdAt,
    this.updatedAt,
  });

  factory _$SubscriptionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubscriptionModelImplFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String plan;
  // 'free', 'basic', 'premium', 'family'
  @override
  final String status;
  // 'active', 'cancelled', 'expired', 'trial'
  @override
  final String? revenuecatCustomerId;
  @override
  final DateTime? startDate;
  @override
  final DateTime? endDate;
  @override
  final DateTime? trialEndDate;
  @override
  @JsonKey()
  final bool autoRenew;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, userId: $userId, plan: $plan, status: $status, revenuecatCustomerId: $revenuecatCustomerId, startDate: $startDate, endDate: $endDate, trialEndDate: $trialEndDate, autoRenew: $autoRenew, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubscriptionModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.plan, plan) || other.plan == plan) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.revenuecatCustomerId, revenuecatCustomerId) ||
                other.revenuecatCustomerId == revenuecatCustomerId) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.trialEndDate, trialEndDate) ||
                other.trialEndDate == trialEndDate) &&
            (identical(other.autoRenew, autoRenew) ||
                other.autoRenew == autoRenew) &&
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
    plan,
    status,
    revenuecatCustomerId,
    startDate,
    endDate,
    trialEndDate,
    autoRenew,
    createdAt,
    updatedAt,
  );

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      __$$SubscriptionModelImplCopyWithImpl<_$SubscriptionModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SubscriptionModelImplToJson(this);
  }
}

abstract class _SubscriptionModel implements SubscriptionModel {
  const factory _SubscriptionModel({
    required final String id,
    required final String userId,
    required final String plan,
    required final String status,
    final String? revenuecatCustomerId,
    final DateTime? startDate,
    final DateTime? endDate,
    final DateTime? trialEndDate,
    final bool autoRenew,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$SubscriptionModelImpl;

  factory _SubscriptionModel.fromJson(Map<String, dynamic> json) =
      _$SubscriptionModelImpl.fromJson;

  @override
  String get id;
  @override
  String get userId;
  @override
  String get plan; // 'free', 'basic', 'premium', 'family'
  @override
  String get status; // 'active', 'cancelled', 'expired', 'trial'
  @override
  String? get revenuecatCustomerId;
  @override
  DateTime? get startDate;
  @override
  DateTime? get endDate;
  @override
  DateTime? get trialEndDate;
  @override
  bool get autoRenew;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of SubscriptionModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubscriptionModelImplCopyWith<_$SubscriptionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PackageModel _$PackageModelFromJson(Map<String, dynamic> json) {
  return _PackageModel.fromJson(json);
}

/// @nodoc
mixin _$PackageModel {
  String get identifier => throw _privateConstructorUsedError;
  String get packageType => throw _privateConstructorUsedError;
  ProductModel get product => throw _privateConstructorUsedError;
  String get offeringIdentifier => throw _privateConstructorUsedError;

  /// Serializes this PackageModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PackageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PackageModelCopyWith<PackageModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PackageModelCopyWith<$Res> {
  factory $PackageModelCopyWith(
    PackageModel value,
    $Res Function(PackageModel) then,
  ) = _$PackageModelCopyWithImpl<$Res, PackageModel>;
  @useResult
  $Res call({
    String identifier,
    String packageType,
    ProductModel product,
    String offeringIdentifier,
  });

  $ProductModelCopyWith<$Res> get product;
}

/// @nodoc
class _$PackageModelCopyWithImpl<$Res, $Val extends PackageModel>
    implements $PackageModelCopyWith<$Res> {
  _$PackageModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PackageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? packageType = null,
    Object? product = null,
    Object? offeringIdentifier = null,
  }) {
    return _then(
      _value.copyWith(
            identifier: null == identifier
                ? _value.identifier
                : identifier // ignore: cast_nullable_to_non_nullable
                      as String,
            packageType: null == packageType
                ? _value.packageType
                : packageType // ignore: cast_nullable_to_non_nullable
                      as String,
            product: null == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as ProductModel,
            offeringIdentifier: null == offeringIdentifier
                ? _value.offeringIdentifier
                : offeringIdentifier // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of PackageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductModelCopyWith<$Res> get product {
    return $ProductModelCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PackageModelImplCopyWith<$Res>
    implements $PackageModelCopyWith<$Res> {
  factory _$$PackageModelImplCopyWith(
    _$PackageModelImpl value,
    $Res Function(_$PackageModelImpl) then,
  ) = __$$PackageModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String identifier,
    String packageType,
    ProductModel product,
    String offeringIdentifier,
  });

  @override
  $ProductModelCopyWith<$Res> get product;
}

/// @nodoc
class __$$PackageModelImplCopyWithImpl<$Res>
    extends _$PackageModelCopyWithImpl<$Res, _$PackageModelImpl>
    implements _$$PackageModelImplCopyWith<$Res> {
  __$$PackageModelImplCopyWithImpl(
    _$PackageModelImpl _value,
    $Res Function(_$PackageModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PackageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? packageType = null,
    Object? product = null,
    Object? offeringIdentifier = null,
  }) {
    return _then(
      _$PackageModelImpl(
        identifier: null == identifier
            ? _value.identifier
            : identifier // ignore: cast_nullable_to_non_nullable
                  as String,
        packageType: null == packageType
            ? _value.packageType
            : packageType // ignore: cast_nullable_to_non_nullable
                  as String,
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as ProductModel,
        offeringIdentifier: null == offeringIdentifier
            ? _value.offeringIdentifier
            : offeringIdentifier // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$PackageModelImpl implements _PackageModel {
  const _$PackageModelImpl({
    required this.identifier,
    required this.packageType,
    required this.product,
    required this.offeringIdentifier,
  });

  factory _$PackageModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$PackageModelImplFromJson(json);

  @override
  final String identifier;
  @override
  final String packageType;
  @override
  final ProductModel product;
  @override
  final String offeringIdentifier;

  @override
  String toString() {
    return 'PackageModel(identifier: $identifier, packageType: $packageType, product: $product, offeringIdentifier: $offeringIdentifier)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PackageModelImpl &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.packageType, packageType) ||
                other.packageType == packageType) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.offeringIdentifier, offeringIdentifier) ||
                other.offeringIdentifier == offeringIdentifier));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    identifier,
    packageType,
    product,
    offeringIdentifier,
  );

  /// Create a copy of PackageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PackageModelImplCopyWith<_$PackageModelImpl> get copyWith =>
      __$$PackageModelImplCopyWithImpl<_$PackageModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PackageModelImplToJson(this);
  }
}

abstract class _PackageModel implements PackageModel {
  const factory _PackageModel({
    required final String identifier,
    required final String packageType,
    required final ProductModel product,
    required final String offeringIdentifier,
  }) = _$PackageModelImpl;

  factory _PackageModel.fromJson(Map<String, dynamic> json) =
      _$PackageModelImpl.fromJson;

  @override
  String get identifier;
  @override
  String get packageType;
  @override
  ProductModel get product;
  @override
  String get offeringIdentifier;

  /// Create a copy of PackageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PackageModelImplCopyWith<_$PackageModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) {
  return _ProductModel.fromJson(json);
}

/// @nodoc
mixin _$ProductModel {
  String get identifier => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  String get priceString => throw _privateConstructorUsedError;
  String get currencyCode => throw _privateConstructorUsedError;

  /// Serializes this ProductModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductModelCopyWith<ProductModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductModelCopyWith<$Res> {
  factory $ProductModelCopyWith(
    ProductModel value,
    $Res Function(ProductModel) then,
  ) = _$ProductModelCopyWithImpl<$Res, ProductModel>;
  @useResult
  $Res call({
    String identifier,
    String description,
    String title,
    double price,
    String priceString,
    String currencyCode,
  });
}

/// @nodoc
class _$ProductModelCopyWithImpl<$Res, $Val extends ProductModel>
    implements $ProductModelCopyWith<$Res> {
  _$ProductModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? description = null,
    Object? title = null,
    Object? price = null,
    Object? priceString = null,
    Object? currencyCode = null,
  }) {
    return _then(
      _value.copyWith(
            identifier: null == identifier
                ? _value.identifier
                : identifier // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as double,
            priceString: null == priceString
                ? _value.priceString
                : priceString // ignore: cast_nullable_to_non_nullable
                      as String,
            currencyCode: null == currencyCode
                ? _value.currencyCode
                : currencyCode // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductModelImplCopyWith<$Res>
    implements $ProductModelCopyWith<$Res> {
  factory _$$ProductModelImplCopyWith(
    _$ProductModelImpl value,
    $Res Function(_$ProductModelImpl) then,
  ) = __$$ProductModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String identifier,
    String description,
    String title,
    double price,
    String priceString,
    String currencyCode,
  });
}

/// @nodoc
class __$$ProductModelImplCopyWithImpl<$Res>
    extends _$ProductModelCopyWithImpl<$Res, _$ProductModelImpl>
    implements _$$ProductModelImplCopyWith<$Res> {
  __$$ProductModelImplCopyWithImpl(
    _$ProductModelImpl _value,
    $Res Function(_$ProductModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? identifier = null,
    Object? description = null,
    Object? title = null,
    Object? price = null,
    Object? priceString = null,
    Object? currencyCode = null,
  }) {
    return _then(
      _$ProductModelImpl(
        identifier: null == identifier
            ? _value.identifier
            : identifier // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as double,
        priceString: null == priceString
            ? _value.priceString
            : priceString // ignore: cast_nullable_to_non_nullable
                  as String,
        currencyCode: null == currencyCode
            ? _value.currencyCode
            : currencyCode // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductModelImpl implements _ProductModel {
  const _$ProductModelImpl({
    required this.identifier,
    required this.description,
    required this.title,
    required this.price,
    required this.priceString,
    required this.currencyCode,
  });

  factory _$ProductModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductModelImplFromJson(json);

  @override
  final String identifier;
  @override
  final String description;
  @override
  final String title;
  @override
  final double price;
  @override
  final String priceString;
  @override
  final String currencyCode;

  @override
  String toString() {
    return 'ProductModel(identifier: $identifier, description: $description, title: $title, price: $price, priceString: $priceString, currencyCode: $currencyCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductModelImpl &&
            (identical(other.identifier, identifier) ||
                other.identifier == identifier) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceString, priceString) ||
                other.priceString == priceString) &&
            (identical(other.currencyCode, currencyCode) ||
                other.currencyCode == currencyCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    identifier,
    description,
    title,
    price,
    priceString,
    currencyCode,
  );

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      __$$ProductModelImplCopyWithImpl<_$ProductModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductModelImplToJson(this);
  }
}

abstract class _ProductModel implements ProductModel {
  const factory _ProductModel({
    required final String identifier,
    required final String description,
    required final String title,
    required final double price,
    required final String priceString,
    required final String currencyCode,
  }) = _$ProductModelImpl;

  factory _ProductModel.fromJson(Map<String, dynamic> json) =
      _$ProductModelImpl.fromJson;

  @override
  String get identifier;
  @override
  String get description;
  @override
  String get title;
  @override
  double get price;
  @override
  String get priceString;
  @override
  String get currencyCode;

  /// Create a copy of ProductModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductModelImplCopyWith<_$ProductModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

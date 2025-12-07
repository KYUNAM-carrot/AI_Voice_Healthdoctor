// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
  Map<String, dynamic> json,
) => _$SubscriptionModelImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  plan: json['plan'] as String,
  status: json['status'] as String,
  revenuecatCustomerId: json['revenuecatCustomerId'] as String?,
  startDate: json['startDate'] == null
      ? null
      : DateTime.parse(json['startDate'] as String),
  endDate: json['endDate'] == null
      ? null
      : DateTime.parse(json['endDate'] as String),
  trialEndDate: json['trialEndDate'] == null
      ? null
      : DateTime.parse(json['trialEndDate'] as String),
  autoRenew: json['autoRenew'] as bool? ?? true,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$$SubscriptionModelImplToJson(
  _$SubscriptionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'plan': instance.plan,
  'status': instance.status,
  'revenuecatCustomerId': instance.revenuecatCustomerId,
  'startDate': instance.startDate?.toIso8601String(),
  'endDate': instance.endDate?.toIso8601String(),
  'trialEndDate': instance.trialEndDate?.toIso8601String(),
  'autoRenew': instance.autoRenew,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

_$PackageModelImpl _$$PackageModelImplFromJson(Map<String, dynamic> json) =>
    _$PackageModelImpl(
      identifier: json['identifier'] as String,
      packageType: json['packageType'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      offeringIdentifier: json['offeringIdentifier'] as String,
    );

Map<String, dynamic> _$$PackageModelImplToJson(_$PackageModelImpl instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'packageType': instance.packageType,
      'product': instance.product,
      'offeringIdentifier': instance.offeringIdentifier,
    };

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      identifier: json['identifier'] as String,
      description: json['description'] as String,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      priceString: json['priceString'] as String,
      currencyCode: json['currencyCode'] as String,
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'identifier': instance.identifier,
      'description': instance.description,
      'title': instance.title,
      'price': instance.price,
      'priceString': instance.priceString,
      'currencyCode': instance.currencyCode,
    };

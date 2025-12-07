import 'package:freezed_annotation/freezed_annotation.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    required String userId,
    required String plan, // 'free', 'basic', 'premium', 'family'
    required String status, // 'active', 'cancelled', 'expired', 'trial'
    String? revenuecatCustomerId,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? trialEndDate,
    @Default(true) bool autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) =>
      _$SubscriptionModelFromJson(json);
}

@freezed
class PackageModel with _$PackageModel {
  const factory PackageModel({
    required String identifier,
    required String packageType,
    required ProductModel product,
    required String offeringIdentifier,
  }) = _PackageModel;

  factory PackageModel.fromJson(Map<String, dynamic> json) =>
      _$PackageModelFromJson(json);
}

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String identifier,
    required String description,
    required String title,
    required double price,
    required String priceString,
    required String currencyCode,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

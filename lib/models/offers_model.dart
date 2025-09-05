class Offer {
  final String offerId;
  final String? offerName;
  final double discountValue;
  final String discountType;
  final List<String> eligibilityCriteria;
  final double discountedPrice;
  final String? entityId;
  final String? startDate;
  final String? endDate;
  final bool isApplicable;
  final double? price;
  final bool isCodeBased;
  final String couponCode;
  final int? usageLimit;
  final int currentUsage;

  Offer({
    required this.offerId,
    this.offerName,
    required this.discountValue,
    required this.discountType,
    required this.eligibilityCriteria,
    required this.discountedPrice,
    this.entityId,
    this.startDate,
    this.endDate,
    required this.isApplicable,
    this.price,
    required this.isCodeBased,
    required this.couponCode,
    required this.usageLimit,
    required this.currentUsage,
  });

  factory Offer.fromJson(Map<String, dynamic> json) {
    return Offer(
      offerId: json["offerId"],
      offerName: json["offerName"],
      discountValue: (json["discountValue"] ?? 0).toDouble(),
      discountType: json["discountType"],
      eligibilityCriteria: List<String>.from(json["eligibilityCriteria"] ?? []),
      discountedPrice: (json["discountedPrice"] ?? 0).toDouble(),
      entityId: json["entityId"],
      startDate: json["startDate"],
      endDate: json["endDate"],
      isApplicable: json["isApplicable"] ?? false,
      price: (json["price"] ?? 0).toDouble(),
      isCodeBased: json["isCodeBased"] ?? false,
      couponCode: json["couponCode"] ?? "",
      usageLimit: json["usageLimit"],
      currentUsage: json["currentUsage"] ?? 0,
    );
  }
}

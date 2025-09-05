import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aroundu/models/offers_model.dart';

// State class to manage coupon validation state
class CouponState {
  final bool isLoading;
  final String? errorMessage;
  final Offer? validatedOffer;
  final String couponCode;

  CouponState({
    this.isLoading = false,
    this.errorMessage,
    this.validatedOffer,
    this.couponCode = '',
  });

  CouponState copyWith({
    bool? isLoading,
    String? errorMessage,
    Offer? validatedOffer,
    String? couponCode,
  }) {
    return CouponState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage, // Passing null will clear the error
      validatedOffer: validatedOffer ?? this.validatedOffer,
      couponCode: couponCode ?? this.couponCode,
    );
  }
}

// Coupon state notifier to handle validation logic
class CouponNotifier extends StateNotifier<CouponState> {
  CouponNotifier() : super(CouponState());

  final ApiService _apiService = ApiService();

  void updateCouponCode(String code) {
    // If code is empty, clear the entire state including validatedOffer
    if (code.isEmpty) {
      clearCoupon();
      return;
    }

    // If code changes after validation, clear the validated offer
    if (state.validatedOffer != null && code != state.couponCode) {
      state = state.copyWith(
        couponCode: code,
        errorMessage: null, // Clear error when code changes
        validatedOffer: null, // Clear validated offer when code changes
      );
    } else {
      state = state.copyWith(
        couponCode: code,
        errorMessage: null, // Clear error when code changes
      );
    }
  }

  Future<void> validateCoupon(String entityId, String entityType) async {
    final couponCode = state.couponCode.trim();

    if (couponCode.isEmpty) {
      state = state.copyWith(
        errorMessage: 'Please enter a coupon code',
        isLoading: false,
      );
      return;
    }

    // Set loading state
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _apiService.post(
        "match/offers/validate",
        body: {"couponCode": couponCode, "entityId": entityId, "entityType": entityType},
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Check if the response has the new format with 'valid' field
        if (data['valid'] == true) {
          // Create an Offer object from the new response format
          final offer = Offer(
            offerId: data['offerId'] ?? '',
            offerName: couponCode, // Use coupon code as name if not provided
            discountValue: (data['discountValue'] ?? 0).toDouble(),
            discountType: data['discountType'] ?? 'FLAT',
            eligibilityCriteria: [], // Empty as not provided in new format
            discountedPrice: 0, // Will be calculated in calculateDiscount
            isApplicable: true,
            isCodeBased: true,
            couponCode: couponCode,
            usageLimit: 0,
            currentUsage: 0,
          );

          // Update state with validated offer
          state = state.copyWith(
            validatedOffer: offer,
            isLoading: false,
          );
        } else if (data['success'] == true) {
          // Handle the old response format
          final offer = Offer.fromJson(data['data']);
          state = state.copyWith(
            validatedOffer: offer,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            errorMessage: data['errorMessage'] ?? data['message'] ?? 'Invalid coupon code',
            isLoading: false,
          );
        }
      } else {
        state = state.copyWith(
          errorMessage: 'Failed to validate coupon',
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to validate coupon',
        isLoading: false,
      );
      print("Error validating coupon: $e");
    }
  }

  void clearCoupon() {
    state = CouponState();
  }

  // Method to check if coupon is valid
  bool isCouponValid() {
    return state.validatedOffer != null && !state.isLoading && state.errorMessage == null;
  }

  // Method to check if coupon is invalid
  bool isCouponInvalid() {
    return state.errorMessage != null && !state.isLoading;
  }
}

// Provider for coupon state
final couponProvider = StateNotifierProvider.autoDispose<CouponNotifier, CouponState>((ref) {
  return CouponNotifier();
});

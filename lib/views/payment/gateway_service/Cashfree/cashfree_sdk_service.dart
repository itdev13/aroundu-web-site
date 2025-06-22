
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/checkout.view.lobby.dart';
import 'package:aroundu/views/offer/apply.offer.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfwebcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

typedef PaymentSuccessCallback = void Function(
    String orderId, Map<String, dynamic> orderData);
typedef PaymentErrorCallback = void Function(
    String errorMessage, String? orderId);

class CashFreeService {
  final bool _isProduction;
  // final String _baseUrl;

  // Cashfree payment gateway service
  final CFPaymentGatewayService _cfPaymentGatewayService =
      CFPaymentGatewayService();

  // Callback handlers
  PaymentSuccessCallback? _onPaymentSuccess;
  PaymentErrorCallback? _onPaymentError;

  // Constructor
  CashFreeService({
    // required String baseUrl,
    bool isProduction = false,
  }) :
        // _baseUrl = baseUrl,
        _isProduction = isProduction;

  // Initialize the service and set up callbacks
  void initialize({
    required PaymentSuccessCallback onPaymentSuccess,
    required PaymentErrorCallback onPaymentError,
  }) {
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;

    // Set up Cashfree callbacks
    _cfPaymentGatewayService.setCallback(
        _handlePaymentSuccess, _handlePaymentError);
  }

  // Internal success callback handler
  void _handlePaymentSuccess(String orderId) async {
    try {
      // Verify payment with server
      final orderData = await verifyPayment(orderId);

      if (_onPaymentSuccess != null) {
        _onPaymentSuccess!(orderId, orderData);
      }
    } catch (e, s) {
      if (_onPaymentError != null) {
        kLogger.error("error", error: e, stackTrace: s);
        _onPaymentError!("Payment verification failed: $e", orderId);
      }
    }
  }

  // Internal error callback handler
  void _handlePaymentError(CFErrorResponse errorResponse, String orderId) {
    if (_onPaymentError != null) {
      kLogger.error("error", error: errorResponse.getMessage());
      _onPaymentError!(errorResponse.getMessage() ?? "error", orderId);
    }
  }

  // Create a Cashfree session
  Future<CFSession?> _createSession(
      String orderId, String paymentSessionId) async {
    try {
      // Set environment based on isProduction flag
      var environment =
          _isProduction ? CFEnvironment.PRODUCTION : CFEnvironment.SANDBOX;

      var session = CFSessionBuilder()
          .setEnvironment(environment)
          .setOrderId(orderId)
          .setPaymentSessionId(paymentSessionId)
          .build();
      return session;

      // Build and return the session
      // return CFSessionBuilder()
      // .setEnvironment(environment)
      // .setOrderId(orderId)
      // .setPaymentSessionId(paymentSessionId)
      // // .setOrderToken(paymentSessionId)
      // .build();
    } on CFException catch (e, s) {
      if (_onPaymentError != null) {
        kLogger.error("error", error: e, stackTrace: s);
        _onPaymentError!("Session creation error: ${e.message}", orderId);
      }
      return null;
    }
  }

  // Create order and get payment session from backend
  Future<Map<String, dynamic>> createOrder({
    required Lobby lobby,
    required String userId,
    required String lobbyId,
    required WidgetRef ref,
    String? accessRequestId,
    String? offerId,
    int? accessRequestCount,
    Map<String, dynamic>? form,
    List<Map<String, dynamic>>? formList,
  }) async {
    try {
      // Prepare request body
      Map<String, dynamic> requestBody = {};
      if (lobby.isPrivate &&
          accessRequestId != null &&
          accessRequestCount != null) {
        requestBody = {
          // "currentProvider": "cashfree",
          "userId": userId,
          "lobbyId": lobbyId,
          // "amount": amount,
          "currency": "INR",
          "entityDetails": {
            "entityId": accessRequestId,
            "paymentEntityType":
                "ACCESS_REQUEST" // INVITATION, ACCESS_REQUEST, PUBLIC
          },

          'slots': accessRequestCount,
        };
      } else {
        requestBody = {
          // "currentProvider": "cashfree",
          "userId": userId,
          "lobbyId": lobbyId,
          // "amount": amount,
          "currency": "INR",
          "entityDetails": {
            "entityId": userId,
            "paymentEntityType": "PUBLIC" // INVITATION, ACCESS_REQUEST, PUBLIC
          },
          'slots': ref.read(counterProvider),
          // "offerId":"67b0457d2e57d66d56063f30"
        };
        if (form != null && form.isNotEmpty) {
          requestBody['form'] = form;
        }
        if (formList != null && formList.isNotEmpty) {
          requestBody['forms'] = formList;
        }
      }

      if (offerId != null && offerId.isNotEmpty) {
        requestBody['offerId'] = offerId;
      }

      // Make API call to your backend
      // final response = await http.post(
      //   Uri.parse('$_baseUrl/create-cashfree-order'),
      //   headers: {'Content-Type': 'application/json'},
      //   body: json.encode(requestBody),
      // );

      final response = await ApiService()
          .post('/payment/api/v1/initiate', body: requestBody);

      ref.read(selectedOfferProvider.notifier).state = null;

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to create order: ${response.data}');
      }
    } catch (e, stack) {
      throw Exception('Error creating order: $e \n $stack');
    }
  }

  // Verify payment with your backend
  Future<Map<String, dynamic>> verifyPayment(String orderId) async {
    try {
      // final response = await http.get(
      //   Uri.parse('$_baseUrl/verify-cashfree-payment?orderId=$orderId'),
      // );

      final response = await ApiService()
          .get('payment/api/v1/transactions/$orderId/enquiry');

      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw Exception('Failed to verify payment: ${response.data}');
      }
    } catch (e, stack) {
      throw Exception('Error verifying payment: $e \n $stack');
    }
  }

  // Initiate payment process
  Future<void> initiatePayment({
    required String orderId,
    required String paymentSessionId,
  }) async {
    try {
      // Create session with order details
      final session = await _createSession(orderId, paymentSessionId);

      if (session == null) {
        throw Exception('Failed to create payment session');
      }
var theme = CFThemeBuilder()
           .setPrimaryFont("Inter-Regular")
          // .setPrimaryFontColor("#000000")
          // .setNavigationBarBackgroundColor("#FFFFFF")
           .setNavigationBarTextColor("#000000")
          .setButtonBackgroundColor("#EC4B5D")
          .setButtonTextColor("#FFFFFF")
          // .setSafeAreaTopPadding(true) // Enable top padding for safe area
          // .setSafeAreaBottomPadding(true) // Enable bottom padding for safe area
          .build();

      // Create Web Checkout payment object with safe area configuration
      final cfWebCheckout = CFWebCheckoutPaymentBuilder()
          .setSession(session)
          // Add theme configuration to respect safe area
          .setTheme(theme)
      .build();

      // Initiate payment using the Web Checkout
      _cfPaymentGatewayService.doPayment(cfWebCheckout);
    } on CFException catch (e, s) {
      if (_onPaymentError != null) {
        kLogger.error("error", error: e, stackTrace: s);
        _onPaymentError!("Payment error: ${e.message}", orderId);
      }
    } catch (e, s) {
      if (_onPaymentError != null) {
        kLogger.error("error", error: e, stackTrace: s);
        _onPaymentError!("Payment initialization error: $e", orderId);
      }
    }
  }
}

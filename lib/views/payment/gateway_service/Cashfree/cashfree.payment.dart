
import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:aroundu/views/offer/apply.offer.dart';
import 'package:aroundu/views/payment/gateway_service/Cashfree/cashfree.response.view.dart';
import 'package:aroundu/views/payment/gateway_service/Cashfree/cashfree_sdk_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';



class CashFreePaymentView extends ConsumerStatefulWidget {
  final String userId;
  final Lobby lobby;
  final FormModel? formModel;
  final List<FormModel>? formList;
  final String? requestText;

  const CashFreePaymentView({
    super.key,
    required this.userId,
    required this.lobby,
    this.formModel,
    this.formList,
    this.requestText,
  });

  @override
  ConsumerState<CashFreePaymentView> createState() =>
      _CashFreePaymentViewState();
}

// Define payment stages for better UX feedback
enum PaymentStage {
  initializing,
  creatingOrder,
  initiatingPayment,
  completed,
  error
}

class _CashFreePaymentViewState extends ConsumerState<CashFreePaymentView> {
  // Initialize the Cashfree service
  late final CashFreeService _cashFeeService;

  bool _isLoading = true;
  String _statusMessage = 'Preparing for payment...';
  PaymentStatus _paymentStatus = PaymentStatus.pending;

  // Track payment stage for better UX
  PaymentStage _paymentStage = PaymentStage.initializing;
  String? _orderId;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    // Initialize Cashfree service
    _cashFeeService = CashFreeService(
      isProduction: ApiConstants.cashfreeProduction, // Set to true for production
    );

    // Set up callback handlers
    _cashFeeService.initialize(
      onPaymentSuccess: _handlePaymentSuccess,
      onPaymentError: _handlePaymentError,
    );

    // Start payment process after a short delay to allow UI to render
    Future.microtask(() => _initializeAndStartPayment());
  }

  // Handle successful payment
  void _handlePaymentSuccess(String orderId, Map<String, dynamic> orderData) {
    kLogger.trace("_handlePaymentSuccess : \n $orderId \n $orderData");
    // Create payment response and pass it to parent widget
    // final response = PaymentResponse(
    //   orderId: orderId,
    //   status: PaymentStatus.success,
    //   message: "Payment successful",
    //   data: orderData,
    // );

    if (orderData['txnSuccessDate'] != null &&
        (orderData['status'] == 'success' ||
            orderData['status'] == 'processing')) {
      setState(() {
        _isLoading = false;
        _paymentStatus = PaymentStatus.success;
        _paymentStage = PaymentStage.completed;
        _statusMessage = "Payment successful!";
        _orderId = orderId;
      });
      // Navigate to response screen
      Get.off(() => CashFreeResponseView(
            orderId: orderId,
            lobby: widget.lobby,
            formModel: widget.formModel,
            formList: widget.formList,
            requestText: widget.requestText,
          ));
    } else {
      setState(() {
        _isLoading = false;
        _paymentStatus = PaymentStatus.cancelled;
        _paymentStage = PaymentStage.error;
        _statusMessage = "Payment failed or cancelled";
        _orderId = orderId;
      });
    }
  }

  // Handle payment error
  void _handlePaymentError(String errorMessage, String? orderId) {
    setState(() {
      _isLoading = false;
      _paymentStatus = PaymentStatus.failed;
      _paymentStage = PaymentStage.error;
      _statusMessage = "Payment failed";
      _errorMessage = errorMessage;
      _orderId = orderId;
    });
    kLogger.trace("_handlePaymentError : \n  $orderId \n $errorMessage");

    // Create payment response and pass it to parent widget
    final response = PaymentResponse(
      orderId: orderId,
      status: PaymentStatus.failed,
      message: errorMessage,
      data: {},
    );

    // Show error dialog with better navigation handling
    // showDialog(
    //     context: context,
    //     barrierDismissible: false,
    //     builder: (context) => AlertDialog(
    //           title: Text('Payment Error'),
    //           content: Text('Failed to process payment: $errorMessage'),
    //           actions: [
    //             TextButton(
    //                 onPressed: () {
    //                   Navigator.pop(context); // Close dialog
    //                   Get.back(); // Go back to previous screen properly
    //                 },
    //                 child: Text('OK'))
    //           ],
    //         ));
  }

  // Initialize and start payment process
  Future<void> _initializeAndStartPayment() async {
    try {
      setState(() {
        _paymentStage = PaymentStage.initializing;
        _statusMessage = 'Initializing payment gateway...';
      });

      // Short delay to show initialization stage
      await Future.delayed(Duration(milliseconds: 500));

      // Start payment process
      await _startPayment();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _paymentStage = PaymentStage.error;
        _errorMessage = e.toString();
      });

      // Show error dialog with better navigation handling
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Payment Error'),
                content: Text('Failed to initialize payment: $e'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Get.back(); // Go back to previous screen properly
                      },
                      child: Text('OK'))
                ],
              ));
    }
  }

  // Start payment process
  Future<void> _startPayment() async {
    try {
      // Update state to creating order
      setState(() {
        _paymentStage = PaymentStage.creatingOrder;
        _statusMessage = 'Creating your order...';
      });

      final offer = ref.watch(selectedOfferProvider);
      kLogger.trace("formList : ${widget.formList}");
      // Create order with backend
      final orderData = await _cashFeeService.createOrder(
        lobby: widget.lobby,
        userId: widget.userId,
        lobbyId: widget.lobby.id,
        accessRequestId: widget.lobby.accessRequestData?.accessId,
        accessRequestCount: widget.lobby.accessRequestData?.count,
        offerId: offer?.offerId,
        ref: ref,
        form: widget.formModel?.toJson() ?? {},
        formList:
            widget.formList?.skip(1).map((form) => form.toJson()).toList() ??
                [],
      );

      final orderId = orderData['order_id'];
      final paymentSessionId = orderData['payment_session_id'];

      // Update state to initiating payment
      setState(() {
        _orderId = orderId;
        _paymentStage = PaymentStage.initiatingPayment;
        _statusMessage = 'Initiating payment gateway...';
      });

      // Initiate payment with Cashfree
      await _cashFeeService.initiatePayment(
        orderId: orderId,
        paymentSessionId: paymentSessionId,
      );
    } catch (e, stack) {
      setState(() {
        _isLoading = false;
        _paymentStatus = PaymentStatus.failed;
        _paymentStage = PaymentStage.error;
        _errorMessage = e.toString();
      });
      print("$e \n $stack");

      // Show error dialog with better navigation handling
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: Text('Payment Error'),
                content: Text('Failed to start payment: $e'),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Get.back(); // Go back to previous screen properly
                      },
                      child: Text('OK'))
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        // If the pop is already happening, just return
        ref.read(lobbyDetailsProvider(widget.lobby.id).notifier).reset();
        await ref
            .read(lobbyDetailsProvider(widget.lobby.id).notifier)
            .fetchLobbyDetails(widget.lobby.id);
        if (didPop) {
          return;
        }
        // Handle back navigation properly
        Get.back();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: DesignText(
            text: 'Payment',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF323232),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Payment stage animation
                _buildPaymentStageAnimation(),

                SizedBox(height: 24),

                // Payment stage indicator
                _buildPaymentStageIndicator(),

                SizedBox(height: 16),

                // Status message
                DesignText(
                  text: _statusMessage,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF444444),
                  textAlign: TextAlign.center,
                ),

                // Show order ID if available
                if (_orderId != null && _paymentStage != PaymentStage.error)
                  Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: DesignText(
                      text: 'Order ID: $_orderId',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),

                // Show error message if available
                if (_errorMessage != null &&
                    _paymentStage == PaymentStage.error)
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: DesignText(
                      text: _errorMessage!,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get color based on payment status
  MaterialColor _getStatusColor() {
    switch (_paymentStatus) {
      case PaymentStatus.success:
        return Colors.green;
      case PaymentStatus.failed:
        return Colors.red;
      case PaymentStatus.pending:
      default:
        return Colors.blue;
    }
  }

  // Build payment stage animation
  Widget _buildPaymentStageAnimation() {
    switch (_paymentStage) {
      case PaymentStage.initializing:
      case PaymentStage.creatingOrder:
      case PaymentStage.initiatingPayment:
        return SizedBox(
          height: 120,
          width: 120,
          child: CircularProgressIndicator(
            color: DesignColors.accent,
            strokeWidth: 6,
          ),
        );
      case PaymentStage.completed:
        return Lottie.asset(
          'assets/animations/payment_success.json',
          height: 150,
          width: 150,
          repeat: true,
          // color: DesignColors.accent,
        );
      case PaymentStage.error:
        return Lottie.asset(
          'assets/animations/payment_failed.json',
          height: 150,
          width: 150,
          repeat: true,
        );
    }
  }

  // Build payment stage indicator
  Widget _buildPaymentStageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStageIndicator(PaymentStage.initializing, 'Initialize'),
        _buildStageSeparator(PaymentStage.initializing),
        _buildStageIndicator(PaymentStage.creatingOrder, 'Create Order'),
        _buildStageSeparator(PaymentStage.creatingOrder),
        _buildStageIndicator(PaymentStage.initiatingPayment, 'Payment'),
      ],
    );
  }

  // Build individual stage indicator
  Widget _buildStageIndicator(PaymentStage stage, String label) {
    final isActive = _paymentStage.index >= stage.index;
    final isError = _paymentStage == PaymentStage.error;

    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? (isError ? Colors.red : DesignColors.accent)
                : Colors.grey.shade300,
          ),
          child: isActive
              ? Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                )
              : null,
        ),
        SizedBox(height: 4),
        DesignText(
          text: label,
          fontSize: 12,
          fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          color: isActive
              ? (isError ? Colors.red : DesignColors.accent)
              : Colors.grey.shade500,
        ),
      ],
    );
  }

  // Build separator between stages
  Widget _buildStageSeparator(PaymentStage beforeStage) {
    final isActive = _paymentStage.index > beforeStage.index;
    final isError = _paymentStage == PaymentStage.error;

    return Container(
      width: 40,
      height: 2,
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      color: isActive
          ? (isError ? Colors.red : DesignColors.accent)
          : Colors.grey.shade300,
    );
  }
}

// Enum to represent payment status
enum PaymentStatus {
  pending,
  success,
  failed,
  cancelled,
}

// Class to handle payment response
class PaymentResponse {
  final String? orderId;
  final PaymentStatus status;
  final String message;
  final Map<String, dynamic> data;

  PaymentResponse({
    this.orderId,
    required this.status,
    required this.message,
    required this.data,
  });

  // Convert payment response to map
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'status': status.toString(),
      'message': message,
      'data': data,
    };
  }

  // Create payment response from map
  factory PaymentResponse.fromMap(Map<String, dynamic> map) {
    return PaymentResponse(
      orderId: map['orderId'],
      status: _statusFromString(map['status']),
      message: map['message'],
      data: Map<String, dynamic>.from(map['data']),
    );
  }

  // Helper method to convert string to PaymentStatus enum
  static PaymentStatus _statusFromString(String statusStr) {
    switch (statusStr) {
      case 'PaymentStatus.success':
        return PaymentStatus.success;
      case 'PaymentStatus.failed':
        return PaymentStatus.failed;
      case 'PaymentStatus.cancelled':
        return PaymentStatus.cancelled;
      case 'PaymentStatus.pending':
      default:
        return PaymentStatus.pending;
    }
  }

  // Helper method to check if payment is successful
  bool get isSuccess => status == PaymentStatus.success;

  // Helper method to check if payment is failed
  bool get isFailed => status == PaymentStatus.failed;

  // Helper method to check if payment is cancelled
  bool get isCancelled => status == PaymentStatus.cancelled;

  // Helper method to check if payment is pending
  bool get isPending => status == PaymentStatus.pending;

  @override
  String toString() {
    return 'PaymentResponse(orderId: $orderId, status: $status, message: $message)';
  }
}

// Example usage in parent widget
/*
void initiatePayment() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CashfreePaymentScreen(
        amount: "100.00",
        customerName: "John Doe",
        customerEmail: "john@example.com",
        customerPhone: "9999999999",
        onPaymentComplete: (PaymentResponse response) {
          // Handle payment result
          if (response.status == PaymentStatus.success) {
            // Payment successful
            showSuccessScreen(response.orderId!);
          } else {
            // Payment failed
            showErrorMessage(response.message);
          }
        },
      ),
    ),
  );
}
*/


import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/lobby_access_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../../designs/widgets/space.widget.designs.dart';
import '../../../../models/lobby.dart';
import '../../../lobby/access_request.view.dart';
import '../../../lobby/checkout.view.lobby.dart';
import '../../../lobby/lobby.view.dart';
import 'cashfree_sdk_service.dart';

class CashFreeResponseView extends ConsumerWidget {
  final CashFreeService _cashFreeService = CashFreeService(isProduction: false);
  final String orderId;
  final Lobby lobby;
  final FormModel? formModel;
  final List<FormModel>? formList;
  final String? requestText;

  CashFreeResponseView({
    super.key,
    required this.orderId,
    required this.lobby,
    this.formModel,
    this.formList,
    this.requestText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double sh = MediaQuery.of(context).size.height;
double sw = MediaQuery.of(context).size.width;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          // Pop twice to go back to the main screen
          Navigator.pop(context);
          // Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFEC4B5D),
        body: FutureBuilder(
          future: _handlePaymentAndAccess(ref),
          builder: (context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              Map<String, dynamic> data = snapshot.data!;
              String orderStatus = data['status'] ?? "Unknown";
              String orderStatusMessage =
                  data['statusMessage'] ?? "Something went wrong";
              double orderAmount = data['amount'] ?? 0.0;

              String statusImage = "";
              String orderStatusText = "";
              String lobbyJoinStatus = data['lobbyJoinStatus'] ?? "Unknown";

              switch (orderStatus) {
                //SUCCESS, FAILED, PROCESSING, REFUNDED, PENDING
                case "success":
                  orderStatusText = "Payment Successful!";
                  statusImage = "assets/animations/payment_success.json";
                  break;
                case "failed":
                  orderStatusText = "Payment Failed!";
                  statusImage = "assets/animations/payment_failed.json";
                  break;
                default:
                  orderStatusText = "Payment Processing!";
                  statusImage = "assets/animations/payment_processing.json";
                  break;
              }

              return Stack(
                children: [
                  Image.asset(
                    "assets/images/splash_bg_red.png",
                    height: 1*sh,
                    width: 1*sw,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                      top: 0.2*sh,
                      right: 24,
                      left: 24,
                      child: Stack(
                        children: [
                          Container(
                            width: 1*sw,
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              children: [
                                Lottie.asset(
                                  height: 0.12*sh,
                                  fit: BoxFit.cover,
                                  statusImage,
                                  repeat: false,
                                ),
                                DesignText(
                                  text: orderStatusText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF323232),
                                ),
                                Space.h(height: 32),
                                DottedDivider(
                                  dashWidth: 7,
                                  dashSpace: 5,
                                ),
                                Space.h(height: 8),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 24),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          DesignText(
                                            text: "Status",
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                          DesignText(
                                            text: data['status']
                                                .toString()
                                                .toUpperCase(),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      Space.h(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          DesignText(
                                            text: "Transaction Id",
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                          DesignText(
                                            text: "${data['transactionId']}",
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                      Space.h(height: 16),
                                      DottedDivider(),
                                      Space.h(height: 16),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          DesignText(
                                            text: "Amount",
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                          DesignText(
                                            text: "INR ${data['amount']}",
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 188,
                            left: 0,
                            child: Container(
                              height: 25,
                              width: 12,
                              decoration: BoxDecoration(
                                color: Color(0xFFEC4B5D),
                                borderRadius: BorderRadius.horizontal(
                                  right: Radius.circular(50),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 188,
                            right: 0,
                            child: Container(
                              height: 25,
                              width: 12,
                              decoration: BoxDecoration(
                                color: Color(0xFFEC4B5D),
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(50),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )),
                  Positioned(
                    bottom: 0.05*sh,
                    right: 24,
                    left: 24,
                    child: GestureDetector(
                      onTap: () async {
                        
                        Get.dialog(
                          barrierDismissible: false,
                          Dialog(
                            backgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    height: 64,
                                    width: 64,
                                    child: CircularProgressIndicator(
                                      color: DesignColors.accent,
                                      strokeWidth: 6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );

                        if (lobbyJoinStatus != 'SUCCESS') {
                          if (lobby.isPrivate) {
                            if (lobby.accessRequestData != null) {
                              final body = {
                                "lobbyId": lobby.id,
                                "requestAccessDTOList": [
                                  {
                                    "accessRequestId":
                                        lobby.accessRequestData?.accessId ?? "",
                                    "paymentDone": true,
                                  }
                                ],
                                "afterPayment": true
                              };

                              final permissionAccessRequestProviderResponse =
                                  await ref.read(
                                      permissionAccessRequestProvider(body)
                                          .future);
                              lobbyJoinStatus =
                                  permissionAccessRequestProviderResponse[
                                      'status'];
                            }
                          } else {
                            final handleLobbyAccessProviderResponse =
                                await ref.read(handleLobbyAccessProvider(
                              lobby.id,
                              false, // isPrivate
                              text: "",
                              hasForm: false,
                            ).future);
                            lobbyJoinStatus =
                                handleLobbyAccessProviderResponse['status'];
                          }
                        }

                        ref
                            .read(lobbyDetailsProvider(lobby.id).notifier)
                            .reset();

                        await ref
                            .read(lobbyDetailsProvider(lobby.id).notifier)
                            .fetchLobbyDetails(lobby.id);

                        Get.back();
                        if (lobbyJoinStatus == 'SUCCESS') {
                            Get.off(() => LobbyLoadingAnimation());

                          await Future.delayed(Duration(seconds: 3));
                        }

                      

                        // Navigator.pop(context);
                        kLogger.trace("lobbyJoinStatus : $lobbyJoinStatus");

                        Get.back();
                        if (lobbyJoinStatus == 'SUCCESS') {
                          Get.dialog(
                            Dialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Lottie.asset(
                                          'assets/animations/success_badge.json',
                                          repeat: false,
                                          fit: BoxFit.fitHeight,
                                          height: 0.2*sh,
                                          width: 0.9*sw,
                                        ),
                                        Space.h(height: 8),
                                        DesignText(
                                          text: "  Congratulations 🎉",
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF323232),
                                        ),
                                        Space.h(height: 8),
                                        DesignText(
                                          text:
                                              "you have successfully joined the lobby",
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF444444),
                                          maxLines: 3,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Lottie.asset(
                                    'assets/animations/confetti.json',
                                    repeat: false,
                                    fit: BoxFit.fill,
                                  ),
                                ],
                              ),
                            ),
                            barrierDismissible: true,
                          );
                        } else {
                          Fluttertoast.showToast(
                              msg: "Something went wrong!!!");
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: DesignText(
                            text: "Back to Lobby",
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFEC4B5D),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              );
            } else {
              return Stack(
                children: [
                  Image.asset(
                    "assets/images/splash_bg_red.png",
                    height: 1*sh,
                    width: 1*sw,
                    fit: BoxFit.cover,
                  ),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: Colors.white,
                        ),
                        SizedBox(height: 16),
                        DesignText(
                          text: "Checking payment status...",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _handlePaymentAndAccess(WidgetRef ref) async {
    // First, get payment status
    final paymentData = await _pollPaymentStatus();

    // If payment is successful, handle access
    if (paymentData['status'] == 'success') {
      if (lobby.isPrivate && lobby.accessRequestData != null) {
        final body = {
          "lobbyId": lobby.id,
          "requestAccessDTOList": [
            {
              "accessRequestId": lobby.accessRequestData?.accessId ?? "",
              "paymentDone": true,
            }
          ],
          "afterPayment": true
        };

        // Chain the second API call
        final accessResponse =
            await ref.read(permissionAccessRequestProvider(body).future);

        // Combine the results
        return {...paymentData, 'lobbyJoinStatus': accessResponse['status']};
      } else {
        final slots = ref.read(counterProvider);
        if (formModel != null) {
          if (slots > 1) {
            final accessResponse = await ref.read(handleLobbyAccessProvider(
              lobby.id,
              false,
              text: requestText ?? "",
              hasForm: true,
              form: formModel?.toJson() ?? {},
              formList:
                  formList?.sublist(1).map((form) => form.toJson()).toList() ??
                      [],
              slots: slots,
            ).future);

            return {
              ...paymentData,
              'lobbyJoinStatus': accessResponse['status']
            };
          } else {
            final accessResponse = await ref.read(handleLobbyAccessProvider(
              lobby.id,
              false,
              text: requestText ?? "",
              hasForm: true,
              form: formModel?.toJson() ?? {},
            ).future);

            return {
              ...paymentData,
              'lobbyJoinStatus': accessResponse['status']
            };
          }
        } else {
          if (slots > 1) {
            final accessResponse = await ref.read(handleLobbyAccessProvider(
              lobby.id,
              false,
              text: "",
              hasForm: false,
              slots: slots,
            ).future);

            return {
              ...paymentData,
              'lobbyJoinStatus': accessResponse['status']
            };
          } else {
            final accessResponse = await ref.read(handleLobbyAccessProvider(
              lobby.id,
              false,
              text: "",
              hasForm: false,
            ).future);

            return {
              ...paymentData,
              'lobbyJoinStatus': accessResponse['status']
            };
          }
        }
      }
    }

    // Return just payment data for non-success cases
    return paymentData;
  }

  Future<Map<String, dynamic>> _pollPaymentStatus() async {
    // Maximum number of attempts
    const int maxAttempts = 5;
    // Interval between attempts (in seconds)
    const int intervalSeconds = 2;

    Map<String, dynamic> result = {};
    int attempts = 0;

    while (attempts < maxAttempts) {
      try {
        // Call the payment status API
        result = await _cashFreeService.verifyPayment(orderId);

        // Check if payment is successful
        if (result['status'] == 'success') {
          // If successful, stop polling
          break;
        }

        // If payment failed, stop polling
        if (result['status'] == 'failed') {
          break;
        }

        // Increment attempt counter
        attempts++;

        // If we haven't reached max attempts, wait before trying again
        if (attempts < maxAttempts) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }
      } catch (e) {
        // In case of error, return the error in the result
        return {
          'status': 'failed',
          'statusMessage': 'Error checking payment status: $e'
        };
      }
    }

    return result;
  }
}

class LobbyLoadingAnimation extends StatelessWidget {
  const LobbyLoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    double sh = MediaQuery.of(context).size.height;
    double sw = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: 1*sh,
          width: 1*sw,
          padding: EdgeInsets.symmetric(vertical: 48, horizontal: 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DesignText(
                text: "Just a sec",
                maxLines: 3,
                fontSize: 28,
                fontWeight: FontWeight.w600,
                textAlign: TextAlign.center,
              ),
              Lottie.asset(
                'assets/animations/lobby.json',
                repeat: true,
                fit: BoxFit.cover,
                height: 0.4*sh,
                width: 0.9*sw,
              ),
              SizedBox(height: 24),
              DesignText(
                text: "We're Letting you in ...",
                maxLines: 3,
                fontSize: 24,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DottedDivider extends StatelessWidget {
  final double height;
  final double dashWidth;
  final double dashSpace;

  const DottedDivider({
    super.key,
    this.height = 1,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boxWidth = constraints.constrainWidth();
        final dashCount = (boxWidth / (dashWidth + dashSpace)).floor();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

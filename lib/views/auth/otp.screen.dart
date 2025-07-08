// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import '../../designs/colors.designs.dart';
// import '../../designs/widgets/text.widget.designs.dart';
// import '../../designs/widgets/button.widget.designs.dart';
// import '../../designs/widgets/space.widget.designs.dart';

// class OtpScreen extends StatefulWidget {
//   final String phoneNumber;
//   final String verificationId;
//   final Function(PhoneAuthCredential) onVerify;

//   const OtpScreen({
//     Key? key,
//     required this.phoneNumber,
//     required this.verificationId,
//     required this.onVerify,
//   }) : super(key: key);

//   @override
//   State<OtpScreen> createState() => _OtpScreenState();
// }

// class _OtpScreenState extends State<OtpScreen> {
//   final List<TextEditingController> _otpControllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(
//     6,
//     (index) => FocusNode(),
//   );

//   int _resendSeconds = 60;
//   bool _isResendActive = false;

//   @override
//   void initState() {
//     super.initState();
//     _startResendTimer();
//     for (int i = 0; i < 5; i++) {
//       _otpControllers[i].addListener(() {
//         if (_otpControllers[i].text.length == 1) {
//           _focusNodes[i + 1].requestFocus();
//         }
//       });
//     }
//   }

//   void _startResendTimer() {
//     Future.delayed(const Duration(seconds: 1), () {
//       if (mounted) {
//         setState(() {
//           if (_resendSeconds > 0) {
//             _resendSeconds--;
//             _startResendTimer();
//           } else {
//             _isResendActive = true;
//           }
//         });
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 24.w),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Space.h(height: 24.h),
//               GestureDetector(
//                 onTap: () => Get.back(),
//                 child: Icon(Icons.arrow_back_ios, size: 20.sp),
//               ),
//               Space.h(height: 32.h),
//               DesignText(
//                 text: "OTP VERIFICATION",
//                 fontSize: 28.sp,
//                 fontWeight: FontWeight.w700,
//                 color: const Color(0xFF333333),
//               ),
//               Space.h(height: 8.h),
//               DesignText(
//                 text:
//                     "Enter OTP sent to ${widget.phoneNumber.replaceRange(3, widget.phoneNumber.length - 2, '******')}",
//                 fontSize: 16.sp,
//                 color: Color(0xFF989898),
//               ),
//               Space.h(height: 48.h),
//               // Row(
//               //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               //   children: List.generate(
//               //     6,
//               //     (index) => Container(
//               //       width: 48.w,
//               //       height: 56.h,
//               //       decoration: BoxDecoration(
//               //         color: Color(0xFFF5F5F5),
//               //         borderRadius: BorderRadius.circular(12.r),
//               //         border: Border.all(
//               //           color: Color(0xFFE5E5E5),
//               //           width: 1,
//               //         ),
//               //       ),
//               //       child: TextField(
//               //         controller: _otpControllers[index],
//               //         focusNode: _focusNodes[index],
//               //         keyboardType: TextInputType.number,
//               //         textAlign: TextAlign.center,
//               //         maxLength: 1,
//               //         decoration: InputDecoration(
//               //           counterText: "",
//               //           border: InputBorder.none,
//               //         ),
//               //         style: TextStyle(
//               //           fontSize: 24.sp,
//               //           fontWeight: FontWeight.bold,
//               //         ),
//               //         onChanged: (value) {
//               //           if (value.isEmpty && index > 0) {
//               //             _otpControllers[index].clear();
//               //             _focusNodes[index - 1].requestFocus();
//               //           } else if (value.isNotEmpty) {
//               //             if (value.length > 1) {
//               //               _otpControllers[index].text = value[0];
//               //             }
//               //             if (index < 5) {
//               //               _focusNodes[index + 1].requestFocus();
//               //             }
//               //           }
//               //         },
//               //         onEditingComplete: () {
//               //           if (_otpControllers[index].text.isEmpty && index > 0) {
//               //             _focusNodes[index - 1].requestFocus();
//               //           }
//               //         },
//               //       ),
//               //     ),
//               //   ),
//               // ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: List.generate(
//                   6,
//                   (index) => Focus(
//                     onKeyEvent: (node, event) {
//                       // Handle backspace key
//                       if (event.logicalKey == LogicalKeyboardKey.backspace) {
//                         if (_otpControllers[index].text.isEmpty && index > 0) {
//                           _focusNodes[index - 1].requestFocus();
//                           _otpControllers[index - 1].selection = TextSelection(
//                             baseOffset: 0,
//                             extentOffset:
//                                 _otpControllers[index - 1].text.length,
//                           );
//                           return KeyEventResult.handled;
//                         }
//                       }
//                       return KeyEventResult.ignored;
//                     },
//                     child: Container(
//                       width: 48.w,
//                       height: 56.h,
//                       decoration: BoxDecoration(
//                         color: Color(0xFFF5F5F5),
//                         borderRadius: BorderRadius.circular(12.r),
//                         border: Border.all(
//                           color: Color(0xFFE5E5E5),
//                           width: 1,
//                         ),
//                       ),
//                       child: TextField(
//                         controller: _otpControllers[index],
//                         focusNode: _focusNodes[index],
//                         keyboardType: TextInputType.number,
//                         textAlign: TextAlign.center,
//                         maxLength: 1,
//                         decoration: InputDecoration(
//                           counterText: "",
//                           border: InputBorder.none,
//                         ),
//                         style: TextStyle(
//                           fontSize: 24.sp,
//                           fontWeight: FontWeight.bold,
//                         ),
//                         onChanged: (value) {
//                           if (value.length == 1) {
//                             if (index < 5) {
//                               _focusNodes[index + 1].requestFocus();
//                             }
//                           } else if (value.isEmpty && index > 0) {
//                             _focusNodes[index - 1].requestFocus();
//                           }
//                         },
//                         onTap: () {
//                           _otpControllers[index].clear();
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               Space.h(height: 24.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   DesignText(
//                     text: "Didn't receive OTP? ",
//                     fontSize: 14.sp,
//                     color: Color(0xFF989898),
//                   ),
//                   GestureDetector(
//                     onTap: _isResendActive
//                         ? () {
//                             setState(() {
//                               _resendSeconds = 60;
//                               _isResendActive = false;
//                             });
//                             _startResendTimer();
//                             // Add resend OTP logic here
//                           }
//                         : null,
//                     child: DesignText(
//                       text: _isResendActive
//                           ? "Resend OTP"
//                           : "Resend in $_resendSeconds seconds",
//                       fontSize: 14.sp,
//                       fontWeight: FontWeight.w600,
//                       color: _isResendActive
//                           ? DesignColors.accent
//                           : Color(0xFF989898),
//                     ),
//                   ),
//                 ],
//               ),
//               Spacer(),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 24.h),
//                 child: SizedBox(
//                   width: double.infinity,
//                   child: DesignButton(
//                     onPress: () {
//                       final otp = _otpControllers.map((c) => c.text).join();
//                       if (otp.length == 6) {
//                         final credential = PhoneAuthProvider.credential(
//                           verificationId: widget.verificationId,
//                           smsCode: otp,
//                         );
//                         widget.onVerify(credential);
//                       } else {
//                         Get.snackbar(
//                             "Error", "Please enter a valid 6-digit OTP");
//                       }
//                     },
//                     bgColor: DesignColors.accent,
//                     padding: EdgeInsets.symmetric(vertical: 16.h),
//                     child: DesignText(
//                       text: "CONTINUE",
//                       fontSize: 16.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     for (var controller in _otpControllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     super.dispose();
//   }
// }

//=====================================================================================================

import 'package:aroundu/designs/fonts.designs.dart';
import 'package:aroundu/designs/utils.designs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../designs/colors.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../utils/custome_snackbar.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final Function(String) onVerify;
  // Add a function for resend OTP
  final Function() onResendOtp;

  static final TextEditingController pinController = TextEditingController();

  static void setOtp(String? smsCode) {
    if (smsCode != null) {
      pinController.setText(smsCode);
    }
  }

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
    required this.onVerify,
    required this.onResendOtp, // Add this parameter
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinController = OtpScreen.pinController;
  final FocusNode _pinFocusNode = FocusNode();

  int _resendSeconds = 60;
  bool _isResendActive = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Clear the controller when the screen is initialized to ensure fresh input
    _pinController.clear();

    // Request focus to the pin input field when the screen loads
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _pinFocusNode.requestFocus();
    // });
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_resendSeconds > 0) {
            _resendSeconds--;
            _startResendTimer();
          } else {
            _isResendActive = true;
          }
        });
      }
    });
  }

  // Add method to handle resend OTP
  void _resendOtp() {
    if (_isResendActive) {
      setState(() {
        _resendSeconds = 60;
        _isResendActive = false;
      });
      _startResendTimer();

      // Call the resend OTP function from parent
      widget.onResendOtp();

      // Show a snackbar to inform the user
      Get.snackbar(
        "OTP Sent",
        "A new OTP has been sent to your phone number",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: DesignColors.accent.withOpacity(0.1),
        colorText: DesignColors.accent,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  // Common method to create PinTheme
  PinTheme _createPinTheme(double width, double height, double fontSize) {
    return PinTheme(
      width: width,
      height: height,
      textStyle: DesignFonts.poppins.copyWith(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: const Color.fromRGBO(70, 69, 66, 1),
      ),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(232, 235, 241, 0.37),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
  
  // Common method to create cursor
  Widget _createCursor(double width, double height) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: height,
        margin: EdgeInsets.only(bottom: height * 6),
        decoration: BoxDecoration(
          color: DesignColors.accent,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // Common method to build OTP input
  Widget _buildOtpInput({
    required double pinWidth,
    required double pinHeight,
    required double fontSize,
    required double separatorWidth,
  }) {
    final defaultPinTheme = _createPinTheme(pinWidth, pinHeight, fontSize);
    final cursor = _createCursor(pinWidth * 0.4, 2);
    
    return Pinput(
      length: 6,
      controller: _pinController,
      focusNode: _pinFocusNode,
      defaultPinTheme: defaultPinTheme,
      onTap: (){
         _pinFocusNode.requestFocus();
      },
      separatorBuilder: (index) => SizedBox(width: separatorWidth),
      focusedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              offset: Offset(0, 3),
              blurRadius: 16,
            ),
          ],
        ),
      ),
      submittedPinTheme: defaultPinTheme.copyWith(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(234, 239, 243, 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
      showCursor: true,
      cursor: cursor,
      onCompleted: (pin) {
        if (pin.length == 6) {
          widget.onVerify(pin);
        }
      },
    );
  }
  
  // Common method to build resend OTP row
  Widget _buildResendOtpRow({required double fontSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DesignText(
          text: "Didn't receive OTP? ",
          fontSize: fontSize ,
          color: const Color(0xFF989898),
        ),
        GestureDetector(
          onTap: _isResendActive ? _resendOtp : null,
          child: DesignText(
            text: _isResendActive
                ? "Resend OTP"
                : "Resend in $_resendSeconds seconds",
            fontSize: fontSize ,
            fontWeight: FontWeight.w600,
            color: _isResendActive
                ? DesignColors.accent
                : const Color(0xFF989898),
          ),
        ),
      ],
    );
  }
  
  // Common method to build continue button
  Widget _buildContinueButton({double? fontSize}) {
    return SizedBox(
      width: double.infinity,
      child: DesignButton(
        onPress: () {
          final otp = _pinController.text;
          if (otp.length == 6) {
            widget.onVerify(otp);
          } else {
            CustomSnackBar.show(
              context: context,
              message: "Please enter a valid 6-digit OTP",
              type: SnackBarType.error,
            );
          }
        },
        bgColor: DesignColors.accent,
        padding: EdgeInsets.symmetric(vertical: 16),
        child: DesignText(
          text: "CONTINUE",
          fontSize: fontSize ?? 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  // Phone layout - optimized for small screens
  Widget _buildPhoneLayout(BuildContext context) {
    return GestureDetector(
      onTap: () => _pinFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Space.h(height: 24),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Icon(Icons.arrow_back_ios, size: 20),
                    ),
                    Space.h(height: 32),
                    DesignText(
                      text: "OTP VERIFICATION",
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF333333),
                    ),
                    Space.h(height: 8),
                    DesignText(
                      text: "Enter OTP sent to ${widget.phoneNumber.replaceRange(3, widget.phoneNumber.length - 2, '******')}",
                      fontSize: 16,
                      color: const Color(0xFF989898),
                    ),
                    Space.h(height: 48),
                    // OTP input
                    Center(
                      child: _buildOtpInput(
                        pinWidth: 48,
                        pinHeight: 56,
                        fontSize: 20,
                        separatorWidth: 8,
                      ),
                    ),
                    Space.h(height: 24),
                    _buildResendOtpRow(fontSize: 14),
                    SizedBox(height: 80),
                    Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: _buildContinueButton(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Tablet layout - optimized for medium screens
  Widget _buildTabletLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () => _pinFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenHeight * 0.04,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Icon(Icons.arrow_back_ios, size: screenHeight * 0.025),
                        ),
                        Spacer(),
                      ],
                    ),
                    Space.h(height: screenHeight * 0.04),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left side - Form
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DesignText(
                                text: "OTP VERIFICATION",
                                fontSize: screenHeight * 0.04,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF333333),
                              ),
                              Space.h(height: screenHeight * 0.02),
                              DesignText(
                                text: "Enter OTP sent to ${widget.phoneNumber.replaceRange(3, widget.phoneNumber.length - 2, '******')}",
                                fontSize: screenHeight * 0.024,
                                color: Color(0xFF989898),
                              ),
                              Space.h(height: screenHeight * 0.06),
                              // OTP input
                              Center(
                                child: _buildOtpInput(
                                  pinWidth: 56,
                                  pinHeight: 64,
                                  fontSize: 22,
                                  separatorWidth: 12,
                                ),
                              ),
                              Space.h(height: screenHeight * 0.03),
                              _buildResendOtpRow(fontSize: 16),
                              Space.h(height: screenHeight * 0.08),
                              _buildContinueButton(fontSize: 16),
                            ],
                          ),
                        ),

                        // Right side - Image or illustration
                        Expanded(
                          flex: 1,
                          child: Center(
                            child: Container(
                              padding: EdgeInsets.all(24),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  'assets/images/onboarding_3.png',
                                  height: screenHeight * 0.5,
                                  fit: BoxFit.fitHeight,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Desktop layout - optimized for large screens
  Widget _buildDesktopLayout(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    
    return GestureDetector(
      onTap: () => _pinFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - 
                          MediaQuery.of(context).padding.top - 
                          MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 40),
                child: Row(
                  children: [
                    // Left side - Form with more padding and larger text
                    Expanded(
                      flex: 1,
                      child: Container(
                        padding: EdgeInsets.all(40),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: Icon(Icons.arrow_back_ios, size: 28),
                            ),
                            Space.h(height: 60),
                            DesignText(
                              text: "OTP VERIFICATION",
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                            ),
                            Space.h(height: 16),
                            DesignText(
                              text: "Enter OTP sent to ${widget.phoneNumber.replaceRange(3, widget.phoneNumber.length - 2, '******')}",
                              fontSize: 20,
                              color: Color(0xFF989898),
                            ),
                            Space.h(height: 80),
                            // OTP input
                            Center(
                              child: _buildOtpInput(
                                pinWidth: 70,
                                pinHeight: 80,
                                fontSize: 26,
                                separatorWidth: 20,
                              ),
                            ),
                            Space.h(height: 40),
                            Center(child: _buildResendOtpRow(fontSize: 18)),
                            Space.h(height: 100),
                            _buildContinueButton(fontSize: 18),
                          ],
                        ),
                      ),
                    ),

                    // Right side - Larger image or illustration with description
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.asset(
                                'assets/images/onboarding_4.png',
                                height: screenHeight * 0.5,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                            Space.h(height: 40),
                            DesignText(
                              text: "Secure Authentication",
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                              textAlign: TextAlign.center,
                            ),
                            Space.h(height: 16),
                            DesignText(
                              text: "We've sent a verification code to your phone to ensure your account security.",
                              fontSize: 18,
                              color: Color(0xFF989898),
                              textAlign: TextAlign.center,
                              maxLines: null,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBuilder(
      phoneLayout: _buildPhoneLayout(context),
      tabletLayout: _buildTabletLayout(context),
      desktopLayout: _buildDesktopLayout(context),
    );
  }

  @override
  void dispose() {
    _pinFocusNode.dispose();
    super.dispose();
  }
}

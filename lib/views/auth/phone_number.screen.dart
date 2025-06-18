import 'package:aroundu/designs/fonts.designs.dart';
import 'package:aroundu/designs/utils.designs.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'phone_number.controller.dart';
import '../../designs/colors.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';

class PhoneNumberScreen extends GetView<PhoneNumberController> {
  final Function(String) onContinue;

  PhoneNumberScreen({super.key, required this.onContinue}) {
    Get.put(PhoneNumberController());
  }

  Future<void> _launchURL(BuildContext context, String url) async {
    // Create a GlobalKey for the dialog
    final GlobalKey<State> launchUrlDialogKey = GlobalKey<State>();
    BuildContext? dialogContext;

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          key: launchUrlDialogKey,
          backgroundColor: Colors.transparent,
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [CircularProgressIndicator(color: DesignColors.accent)],
          ),
        );
      },
    );

    // Close dialog after a short delay to ensure it's dismissed
    Future.delayed(Duration(seconds: 2), () {
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }
    });

    try {
      bool launched = await launchUrl(
        Uri.parse(url),
        // mode: LaunchMode.externalApplication, // Force external browser
      );

      // Close the loading dialog immediately after launch attempt
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      if (!launched) {
        CustomSnackBar.show(
          context: context,
          message: "Could not launch $url",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      // Close the loading dialog
      if (dialogContext != null && Navigator.canPop(dialogContext!)) {
        Navigator.pop(dialogContext!);
      }

      CustomSnackBar.show(
        context: context,
        message: "Error launching $url",
        type: SnackBarType.error,
      );
    }
  }

  // Phone layout - optimized for small screens
  Widget _buildPhoneLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    Get.height -
                    MediaQuery.of(Get.context!).padding.top -
                    MediaQuery.of(Get.context!).padding.bottom,
              ),
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
                    text: "LOGIN",
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                  Space.h(height: 8),
                  DesignText(
                    text: "Enter your phone number to proceed",
                    fontSize: 16,
                    color: Color(0xFF989898),
                  ),
                  Space.h(height: 48),
                  DesignText(
                    text: "PHONE NUMBER",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF989898),
                  ),
                  Space.h(height: 16),
                  _buildPhoneNumberInput(),
                  SizedBox(height: 80),
                  _buildTermsAndContinueButton(context),
                  Space.h(height: 24),
                ],
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  Get.height -
                  MediaQuery.of(Get.context!).padding.top -
                  MediaQuery.of(Get.context!).padding.bottom,
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
                    children: [
                      // Left side - Form
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DesignText(
                              text: "LOGIN",
                              fontSize: screenHeight * 0.04,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF333333),
                            ),
                            Space.h(height: screenHeight * 0.02),
                            DesignText(
                              text: "Enter your phone number to proceed",
                              fontSize: screenHeight * 0.024,
                              color: Color(0xFF989898),
                            ),
                            Space.h(height: screenHeight * 0.1),
                            DesignText(
                              text: "PHONE NUMBER",
                              fontSize: screenHeight * 0.022,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF989898),
                            ),
                            Space.h(height: screenHeight * 0.024),
                            _buildPhoneNumberInput(),
                            Space.h(height: screenHeight * 0.1),
                            _buildTermsAndContinueButton(context, fontSize: 16),
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
                                'assets/images/onboarding_1.png',
                                height: Get.height * 0.6,
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
    );
  }

  // Desktop layout - optimized for large screens
  Widget _buildDesktopLayout(BuildContext context) {
     double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  Get.height -
                  MediaQuery.of(Get.context!).padding.top -
                  MediaQuery.of(Get.context!).padding.bottom,
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
                            text: "LOGIN",
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF333333),
                          ),
                          Space.h(height: 16),
                          DesignText(
                            text: "Enter your phone number to proceed",
                            fontSize: 20,
                            color: Color(0xFF989898),
                          ),
                          Space.h(height: 80),
                          DesignText(
                            text: "PHONE NUMBER",
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF989898),
                          ),
                          Space.h(height: 20),
                          _buildPhoneNumberInput(),
                          Space.h(height: 100),
                          _buildTermsAndContinueButton(context, fontSize: 18),
                        ],
                      ),
                    ),
                  ),

                  // Right side - Larger image or illustration
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        // color: DesignColors.accent.withOpacity(0.05),
                      ),
                      padding: EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'assets/images/onboarding_2.png',
                              height: screenHeight*0.6,
                              fit: BoxFit.fitHeight,
                            ),
                          ),
                          Space.h(height: 40),
                          DesignText(
                            text: "Your Plans, Your Rules",
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF333333),
                            textAlign: TextAlign.center,
                          ),
                          Space.h(height: 16),
                          DesignText(
                            text:
                                "Create a public lobby or keep it private—you decide who gets in.",
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
    );
  }

  // Common phone number input widget
  Widget _buildPhoneNumberInput() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: DesignColors.accent, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Obx(
            () => Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Image.network(
                    'https://upload.wikimedia.org/wikipedia/en/thumb/4/41/Flag_of_India.svg/20px-Flag_of_India.svg.png',
                    width: 24,
                    height: 16,
                  ),
                  Space.w(width: 8),
                  DesignText(
                    text: controller.countryCode.value,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  Icon(Icons.keyboard_arrow_down, size: 20),
                ],
              ),
            ),
          ),
          Space.w(width: 8),
          Expanded(
            child: TextField(
              onChanged: controller.updatePhoneNumber,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: "Enter mobile number",
                hintStyle: TextStyle(color: Color(0xFF989898), fontSize: 16),
              ),
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  // Common terms and continue button widget
  Widget _buildTermsAndContinueButton(
    BuildContext context, {
    double? fontSize,
  }) {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: DesignFonts.poppins.copyWith(
              fontSize: fontSize ?? 12,
              color: Color(0xFF989898),
            ),
            children: [
              TextSpan(text: "By clicking, I accept the "),
              TextSpan(
                text: "TnC",
                style: DesignFonts.poppins.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL(
                            context,
                            'https://www.aroundu.in/terms',
                          ),
              ),
              TextSpan(text: " & "),
              TextSpan(
                text: "Privacy Policy",
                style: DesignFonts.poppins.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
                recognizer:
                    TapGestureRecognizer()
                      ..onTap =
                          () => _launchURL(
                            context,
                            'https://www.aroundu.in/privacy',
                          ),
              ),
            ],
          ),
        ),
        Space.h(height: 16),
        Obx(
          () => SizedBox(
            width: double.infinity,
            child: DesignButton(
              onPress: () {
                if (controller.phoneNumber.value.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter a phone number',
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                  );
                  return;
                }
                controller.isLoading.value = true;
                onContinue(controller.getFullPhoneNumber());
              },
              isLoading: controller.isLoading.value,
              bgColor: DesignColors.accent,
              padding: EdgeInsets.symmetric(vertical: 16),
              child: DesignText(
                text: "CONTINUE",
                fontSize: fontSize ?? 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ScreenBuilder(
        phoneLayout: _buildPhoneLayout(context),
        tabletLayout: _buildTabletLayout(context),
        desktopLayout: _buildDesktopLayout(context),
      ),
    );
  }
}

import 'dart:async';
import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/fonts.designs.dart';
import 'package:aroundu/designs/icons.designs.dart';
import 'package:aroundu/designs/images.designs.dart';
import 'package:aroundu/designs/utils.designs.dart'; // Import DesignUtils
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/auth/auth.view.dart';
import 'package:aroundu/views/dashboard/dashboard.view.dart';
import 'package:aroundu/views/onboarding/view.onboarding.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SplashView extends StatelessWidget {
  SplashView({super.key});

  final authService = AuthService();

  Future<void> customWait(BuildContext context) async {
    kLogger.trace("Fetching User Info");
    // await Future.delayed(const Duration(seconds: 1));
    await GetStorage.init();

    final apiService = ApiService();
    // final ChatsController chatsController = Get.put(ChatsController());

    // Check if we're coming from a logout or app reinstall
    final prefs = GetStorage();
    final bool isLoggedOut = prefs.read('isLoggedOut') ?? false;
    final bool isFirstRun = prefs.read('isFirstRun') ?? true;

    // If this is first run after install/reinstall or explicit logout,
    // force sign out from Firebase and clear storage
    if (isFirstRun || isLoggedOut) {
      //|| isLoggedOut
      kLogger.trace("App reinstalled or user logged out explicitly");
      await _forceSignOut();

      kLogger.trace("User is not logged in! Going to `AuthView`");
      Get.off(() => const AuthView());
      return;
    }

    // Now check current user after handling reinstall/logout case
    final user = authService.currentUser;

    if (user != null) {
      try {
        final profile = await apiService.getUserProfileData();
        kLogger.trace("User is signed in using [GAuth] w/ uid ${user.uid}");
        kLogger.debug(profile);

        await prefs.write("userUID", profile["userId"]);

        if (profile["status"] == "ONBOARDED") {
          kLogger.trace(
            "User's profile is completed! Current status is [${profile["status"]}].",
          );

          // Ensure socket is connected before proceeding
          await Future.delayed(const Duration(milliseconds: 500));

          kLogger.trace("splash Going to `DashboardView`");
          Get.offAll(const DashboardView());
          return;
        }

        kLogger.trace(
          "User's profile is not completed! Going to `OnboardingView`",
        );

      

        Get.off(
        const OnboardingView(),
        arguments: [
        true,
        profile["status"] ?? "",
        user.displayName ?? "",
        "",
        "2004-02-10T18:30:00.000+00:00",
        "",
        <ProfileInterest>[],
        <UserInterest>[],
        <String>[],
        <Prompts>[],
        "MALE",
        ],
        );
        return;
      } catch (e) {
        // If we get API errors, force sign out as the token might be invalid
        kLogger.error("Error fetching user profile: $e");
        await _forceSignOut();
        Get.off(() => const AuthView());
        return;
      }
    }

    kLogger.trace("User is not logged in! Going to `AuthView`");
    Get.off(() => const AuthView());
  }

  // Force sign out from all providers
  Future<void> _forceSignOut() async {
    kLogger.trace("Performing force sign out");

    try {
      // Clear auth data using our custom AuthService
      await authService.clearAuthData();

      await GetStorage().remove("userUID");

      // Set logged out flag
      await GetStorage().write('isLoggedOut', true);
    } catch (e) {
      kLogger.error("Error during force sign out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: customWait(context),
        builder: (_, __) {
          return ScreenBuilder(
            phoneLayout: _buildPhoneLayout(context),
            tabletLayout: _buildTabletLayout(context),
            desktopLayout: _buildDesktopLayout(context),
          );
        },
      ),
    );
  }

  // Phone-specific layout
  Widget _buildPhoneLayout(BuildContext context) {
    final isLandscape = DesignUtils.isLandscape(context);

    // Phone-specific responsive values
    final double logoSize = DesignUtils.getOrientationValue(
      context,
      portrait: DesignUtils.toDeviceW(context, 60), // 60% of width in portrait
      landscape: DesignUtils.toDeviceH(
        context,
        40,
      ), // 40% of height in landscape
    ).clamp(150.0, 300.0); // Min 150, Max 300

    final double aroundUFontSize =
        isLandscape
            ? DesignUtils.getResponsiveFontSize(context, 36)
            : DesignUtils.getResponsiveFontSize(context, 44);

    final double spacing =
        isLandscape
            ? DesignUtils.getResponsiveSpacing(context, 48)
            : DesignUtils.getResponsiveSpacing(context, 96);

    return _buildSplashContent(
      context: context,
      logoSize: logoSize,
      aroundUFontSize: aroundUFontSize,
      spacing: spacing,
    );
  }

  // Tablet-specific layout
  Widget _buildTabletLayout(BuildContext context) {
    final isLandscape = DesignUtils.isLandscape(context);

    // Tablet-specific responsive values
    final double logoSize = DesignUtils.getOrientationValue(
      context,
      portrait: DesignUtils.toDeviceW(context, 45),
      landscape: DesignUtils.toDeviceH(context, 35),
    ).clamp(200.0, 350.0); // Min 200, Max 350

    final double aroundUFontSize = DesignUtils.getResponsiveFontSize(
      context,
      48,
    );

    final double spacing = DesignUtils.getResponsiveSpacing(context, 80);

    return _buildSplashContent(
      context: context,
      logoSize: logoSize,
      aroundUFontSize: aroundUFontSize,
      spacing: spacing,
    );
  }

  // Desktop-specific layout
  Widget _buildDesktopLayout(BuildContext context) {
    // Desktop-specific responsive values
    final double logoSize = DesignUtils.getOrientationValue(
      context,
      portrait: DesignUtils.toDeviceW(context, 30),
      landscape: DesignUtils.toDeviceH(context, 30),
    ).clamp(250.0, 400.0); // Min 250, Max 400

    final double aroundUFontSize = DesignUtils.getResponsiveFontSize(
      context,
      52,
    );

    final double spacing = DesignUtils.getResponsiveSpacing(context, 64);

    return _buildSplashContent(
      context: context,
      logoSize: logoSize,
      aroundUFontSize: aroundUFontSize,
      spacing: spacing,
    );
  }

  // Common splash content with customizable parameters
  Widget _buildSplashContent({
    required BuildContext context,
    required double logoSize,
    required double aroundUFontSize,
    required double spacing,
  }) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(DesignImages.splashBg.path, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: Center(
            child: SingleChildScrollView(
              padding: DesignUtils.getResponsivePadding(context),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DesignIcon.custom(
                    icon: DesignIcons.logo,
                    size: logoSize,
                    color: DesignColors.white,
                  ),
                  SizedBox(
                    height: DesignUtils.getResponsiveSpacing(context, 16),
                  ),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Around",
                          style: DesignFonts.poppins.copyWith(
                            fontSize: aroundUFontSize,
                            fontWeight: FontWeight.w500,
                            color: DesignColors.white,
                          ),
                        ),
                        TextSpan(
                          text: "U",
                          style: DesignFonts.poppins.copyWith(
                            color: DesignColors.white,
                            fontSize: aroundUFontSize,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

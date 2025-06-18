import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

///
/// Utils containing pre-defined constant values used in designs
///
class DesignUtils {
  // Responsive breakpoints
  static const double phoneBreakpoint = 600; // <600px = phone
  static const double tabletBreakpoint = 1024; // 600-1023px = tablet
  static const double desktopBreakpoint = 1440; // >=1024px = desktop/laptop

  // Additional breakpoints for more granular control
  static const double smallPhoneBreakpoint = 360; // For very small phones
  static const double largePhoneBreakpoint = 480; // For larger phones
  static const double smallTabletBreakpoint = 768; // For smaller tablets
  static const double largeDesktopBreakpoint = 1920; // For large monitors

  // Default design dimensions for different device types
  static const double kPhoneWidth = 360;
  static const double kPhoneHeight = 690;
  static const double kTabletWidth = 768;
  static const double kTabletHeight = 1024;
  static const double kDesktopWidth = 1280;
  static const double kDesktopHeight = 800;

  static double get kFigmaScreenWidth {
    // You may want to pass context here for more flexibility, but this version uses MediaQuery if available
    final width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    if (width < tabletBreakpoint) {
      return kPhoneWidth;
    } else if (width < desktopBreakpoint) {
      return kTabletWidth;
    } else {
      return kDesktopWidth;
    }
  }

  static double get kFigmaScreenHeight {
    final height = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.height /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    if (height < tabletBreakpoint) {
      return kPhoneHeight;
    } else if (height < desktopBreakpoint) {
      return kTabletHeight;
    } else {
      return kDesktopHeight;
    }
  }

  // Get screen width based on device type
  static double getScreenWidth(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.phone:
        return kPhoneWidth;
      case DeviceScreenType.tablet:
        return kTabletWidth;
      case DeviceScreenType.desktop:
        return kDesktopWidth;
    }
  }

  // Get screen height based on device type
  static double getScreenHeight(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.phone:
        return kPhoneHeight;
      case DeviceScreenType.tablet:
        return kTabletHeight;
      case DeviceScreenType.desktop:
        return kDesktopHeight;
    }
  }

 
 

  ///
  /// Padding for the scaffold widget used for every view
  ///
  static EdgeInsets scaffoldPadding = const EdgeInsets.symmetric(
    vertical: 20,
    horizontal: 20,
  );

  /// Returns responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.phone:
        return const EdgeInsets.symmetric(vertical: 16, horizontal: 16);
      case DeviceScreenType.tablet:
        return const EdgeInsets.symmetric(vertical: 20, horizontal: 24);
      case DeviceScreenType.desktop:
        return const EdgeInsets.symmetric(vertical: 24, horizontal: 32);
    }
  }

  /// Returns the current device type based on screen width
  static DeviceScreenType getDeviceType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < phoneBreakpoint) {
      return DeviceScreenType.phone;
    } else if (width < tabletBreakpoint) {
      return DeviceScreenType.tablet;
    } else {
      return DeviceScreenType.desktop;
    }
  }

  /// Returns a more specific device size category
  static DeviceSize getDeviceSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < smallPhoneBreakpoint) {
      return DeviceSize.extraSmallPhone;
    } else if (width < largePhoneBreakpoint) {
      return DeviceSize.smallPhone;
    } else if (width < phoneBreakpoint) {
      return DeviceSize.phone;
    } else if (width < smallTabletBreakpoint) {
      return DeviceSize.smallTablet;
    } else if (width < tabletBreakpoint) {
      return DeviceSize.tablet;
    } else if (width < desktopBreakpoint) {
      return DeviceSize.desktop;
    } else if (width < largeDesktopBreakpoint) {
      return DeviceSize.largeDesktop;
    } else {
      return DeviceSize.extraLargeDesktop;
    }
  }

  /// Returns a responsive font size based on device type
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.phone:
        return baseSize;
      case DeviceScreenType.tablet:
        return baseSize * 1.1;
      case DeviceScreenType.desktop:
        return baseSize * 1.2;
    }
  }

  /// Returns a responsive spacing value based on device type
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceScreenType.phone:
        return baseSpacing;
      case DeviceScreenType.tablet:
        return baseSpacing * 1.25;
      case DeviceScreenType.desktop:
        return baseSpacing * 1.5;
    }
  }

  ///
  /// Returns the height of the device screen adjusted by a percentage value.
  ///
  /// Calculates the height of the device screen multiplied by the given [percentage].
  ///
  /// Throws an assertion error if [percentage] is not within the valid range of
  /// 0 to 100.
  ///
  /// ### Example:
  /// ```
  /// double height = toDeviceH(context, 75);
  /// print('Height with 75% of the screen height: \$height');
  /// ```
  ///
  static double toDeviceH(BuildContext context, double percentage) {
    // assert if percentage is invalid
    assert(
      percentage >= 0 && percentage <= 100,
      'Percentage should be between 0 and 100 inclusive.',
    );

    return MediaQuery.sizeOf(context).height * (percentage / 100);
  }

  ///
  /// Returns the width of the device screen adjusted by a percentage value.
  ///
  /// Calculates the width of the device screen multiplied by the given [percentage].
  ///
  /// Throws an assertion error if [percentage] is not within the valid range of
  /// 0 to 100.
  ///
  /// ### Example:
  /// ```
  /// double width = toDeviceW(context, 75);
  /// print('Width with 75% of the screen width: \$width');
  /// ```
  ///
  static double toDeviceW(BuildContext context, double percentage) {
    // assert if percentage is invalid
    assert(
      percentage >= 0 && percentage <= 100,
      'Percentage should be between 0 and 100 inclusive.',
    );

    return MediaQuery.sizeOf(context).width * (percentage / 100);
  }

  /// Locks the app to portrait orientation only
  static Future<void> lockPortraitOrientation() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  /// Enables all orientations (useful for tablets and desktops)
  static Future<void> enableAllOrientations() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  /// Returns true if the device is in landscape orientation
  static bool isLandscape(BuildContext context) {
    return MediaQuery.orientationOf(context) == Orientation.landscape;
  }

  /// Returns a responsive value based on orientation
  static T getOrientationValue<T>(
    BuildContext context, {
    required T portrait,
    required T landscape,
  }) {
    return isLandscape(context) ? landscape : portrait;
  }
}

enum DeviceScreenType { phone, tablet, desktop }

/// More granular device size categories for finer control
enum DeviceSize {
  extraSmallPhone,
  smallPhone,
  phone,
  smallTablet,
  tablet,
  desktop,
  largeDesktop,
  extraLargeDesktop,
}

/// A new responsive screen builder that takes three different layouts for phone, tablet, and desktop
/// This approach gives more control over UI design for different screen sizes
class ScreenBuilder extends StatelessWidget {
  /// Widget to display on phone screens
  final Widget phoneLayout;

  /// Widget to display on tablet screens
  final Widget tabletLayout;

  /// Widget to display on desktop/laptop screens
  final Widget desktopLayout;

  /// Optional builder function for more complex scenarios
  final Widget Function(
    BuildContext context,
    DeviceScreenType deviceType,
    bool isLandscape,
  )?
  builder;

  const ScreenBuilder({
    super.key,
    required this.phoneLayout,
    required this.tabletLayout,
    required this.desktopLayout,
    this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = DesignUtils.getDeviceType(context);
    final isLandscape = DesignUtils.isLandscape(context);

    // If a custom builder is provided, use it
    if (builder != null) {
      return builder!(context, deviceType, isLandscape);
    }

    // Otherwise, use the appropriate layout based on device type
    switch (deviceType) {
      case DeviceScreenType.phone:
        return phoneLayout;
      case DeviceScreenType.tablet:
        return tabletLayout;
      case DeviceScreenType.desktop:
        return desktopLayout;
    }
  }
}

/// A simpler version that only handles phone and desktop layouts
/// Useful when tablet and desktop layouts are the same
class SimpleScreenBuilder extends StatelessWidget {
  /// Widget to display on phone screens
  final Widget mobileLayout;

  /// Widget to display on larger screens (tablet and desktop)
  final Widget desktopLayout;

  const SimpleScreenBuilder({
    super.key,
    required this.mobileLayout,
    required this.desktopLayout,
  });

  @override
  Widget build(BuildContext context) {
    final deviceType = DesignUtils.getDeviceType(context);

    if (deviceType == DeviceScreenType.phone) {
      return mobileLayout;
    } else {
      return desktopLayout;
    }
  }
}

/// A responsive layout builder that provides orientation-specific layouts
class OrientationScreenBuilder extends StatelessWidget {
  /// Widget to display in portrait orientation
  final Widget portraitLayout;

  /// Widget to display in landscape orientation
  final Widget landscapeLayout;

  const OrientationScreenBuilder({
    Key? key,
    required this.portraitLayout,
    required this.landscapeLayout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape = DesignUtils.isLandscape(context);

    return isLandscape ? landscapeLayout : portraitLayout;
  }
}

/// For backward compatibility with existing code
/// This will be deprecated in future versions
// class ResponsiveWrapper extends StatelessWidget {
//   final Widget Function(BuildContext context, ResponsiveInfo info) builder;

//   const ResponsiveWrapper({Key? key, required this.builder}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // Get all responsive information
//     final deviceType = DesignUtils.getDeviceType(context);
//     final deviceSize = DesignUtils.getDeviceSize(context);
//     final isLandscape = DesignUtils.isLandscape(context);
//     final responsivePadding = DesignUtils.getResponsivePadding(context);

//     // Create a ResponsiveInfo object with all the responsive data
//     final responsiveInfo = ResponsiveInfo(
//       deviceType: deviceType,
//       deviceSize: deviceSize,
//       isLandscape: isLandscape,
//       padding: responsivePadding,
//       screenWidth: MediaQuery.sizeOf(context).width,
//       screenHeight: MediaQuery.sizeOf(context).height,
//     );

//     // Call the builder with the context and responsive info
//     return builder(context, responsiveInfo);
//   }

//   /// Convenience method to get responsive font size
//   static double fontSize(BuildContext context, double baseSize) {
//     return DesignUtils.getResponsiveFontSize(context, baseSize);
//   }

//   /// Convenience method to get responsive spacing
//   static double spacing(BuildContext context, double baseSpacing) {
//     return DesignUtils.getResponsiveSpacing(context, baseSpacing);
//   }
// }

/// Class that holds all responsive information for easy access
// class ResponsiveInfo {
//   final DeviceScreenType deviceType;
//   final DeviceSize deviceSize;
//   final bool isLandscape;
//   final EdgeInsets padding;
//   final double screenWidth;
//   final double screenHeight;

//   const ResponsiveInfo({
//     required this.deviceType,
//     required this.deviceSize,
//     required this.isLandscape,
//     required this.padding,
//     required this.screenWidth,
//     required this.screenHeight,
//   });

//   /// Helper method to check if the device is a phone
//   bool get isPhone => deviceType == DeviceScreenType.phone;

//   /// Helper method to check if the device is a tablet
//   bool get isTablet => deviceType == DeviceScreenType.tablet;

//   /// Helper method to check if the device is a desktop
//   bool get isDesktop => deviceType == DeviceScreenType.desktop;

//   /// Helper method to get responsive value based on device type
//   T whenDeviceType<T>({
//     required T phone,
//     required T tablet,
//     required T desktop,
//   }) {
//     switch (deviceType) {
//       case DeviceScreenType.phone:
//         return phone;
//       case DeviceScreenType.tablet:
//         return tablet;
//       case DeviceScreenType.desktop:
//         return desktop;
//     }
//   }

//   /// Helper method to get responsive value based on orientation
//   T whenOrientation<T>({required T portrait, required T landscape}) {
//     return isLandscape ? landscape : portrait;
//   }

//   /// Helper method to get responsive value based on both device type and orientation
//   T responsiveValue<T>({
//     required T phonePortrait,
//     T? phoneLandscape,
//     T? tabletPortrait,
//     T? tabletLandscape,
//     T? desktopPortrait,
//     T? desktopLandscape,
//   }) {
//     if (deviceType == DeviceScreenType.phone) {
//       return isLandscape ? (phoneLandscape ?? phonePortrait) : phonePortrait;
//     } else if (deviceType == DeviceScreenType.tablet) {
//       return isLandscape
//           ? (tabletLandscape ??
//               phoneLandscape ??
//               tabletPortrait ??
//               phonePortrait)
//           : (tabletPortrait ?? phonePortrait);
//     } else {
//       return isLandscape
//           ? (desktopLandscape ??
//               tabletLandscape ??
//               phoneLandscape ??
//               desktopPortrait ??
//               tabletPortrait ??
//               phonePortrait)
//           : (desktopPortrait ?? tabletPortrait ?? phonePortrait);
//     }
//   }
// }

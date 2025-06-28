import 'package:aroundu/constants/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A service class that centralizes all routing functionality for the application.
///
/// This service provides methods for navigation, route configuration, and handling
/// web URL-based navigation. It uses GetX for navigation management.
class RouteService {
  /// Singleton instance
  static final RouteService _instance = RouteService._internal();

  /// Factory constructor to return the singleton instance
  factory RouteService() => _instance;

  /// Private constructor for singleton pattern
  RouteService._internal();

  /// Configures the application routes
  ///
  /// This method returns a list of [GetPage] objects that define all the routes
  /// in the application. It should be used in the GetMaterialApp's getPages parameter.
  List<GetPage> configureRoutes() {
    return AppRoutes.routes;
  }

  /// Initializes the route service
  ///
  /// This method should be called during app initialization to set up any
  /// route-related configurations.
  void init() {
    // Add any initialization logic here
  }

  /// Navigates to a named route
  ///
  /// @param routeName The name of the route to navigate to
  /// @param parameters Optional parameters to pass to the route
  /// @param preventDuplicates Whether to prevent duplicate routes in the stack
  void navigateTo(
    String routeName, {
    Map<String, String>? parameters,
    bool preventDuplicates = true,
  }) {
    Get.toNamed(
      routeName,
      parameters: parameters,
      preventDuplicates: preventDuplicates,
    );
  }

  /// Navigates to a named route and removes the current route from the stack
  ///
  /// @param routeName The name of the route to navigate to
  /// @param parameters Optional parameters to pass to the route
  void navigateOffTo(String routeName, {Map<String, String>? parameters}) {
    Get.offNamed(routeName, parameters: parameters);
  }

  /// Navigates to a named route and removes all previous routes from the stack
  /// 
  /// @param routeName The name of the route to navigate to
  /// @param parameters Optional parameters to pass to the route
  void navigateOffAllTo(String routeName, {Map<String, String>? parameters}) {
    Get.offAllNamed(routeName, parameters: parameters);
  }

  /// Goes back to the previous route
  void goBack() {
    Get.back();
  }

  /// Checks if the app can go back to a previous route
  bool canGoBack() {
    return Get.previousRoute.isNotEmpty;
  }

  /// Gets the current route name
  String getCurrentRoute() {
    return Get.currentRoute;
  }

  /// Gets the previous route name
  String getPreviousRoute() {
    return Get.previousRoute;
  }

  /// Creates a URL path for web navigation
  ///
  /// @param routeName The name of the route
  /// @param parameters Optional parameters to include in the URL
  /// @return A properly formatted URL path
  String createUrlPath(String routeName, {Map<String, dynamic>? parameters}) {
    String path = routeName;

    if (parameters != null && parameters.isNotEmpty) {
      // Handle dynamic segments in the route (e.g., '/profile/:id')
      for (var entry in parameters.entries) {
        final placeholder = ':${entry.key}';
        if (path.contains(placeholder)) {
          path = path.replaceAll(placeholder, entry.value.toString());
        }
      }

      // Add query parameters for any remaining parameters
      final remainingParams = parameters.entries.where(
        (entry) => !path.contains(':${entry.key}'),
      );

      if (remainingParams.isNotEmpty) {
        path += '?';
        path += remainingParams
            .map(
              (entry) =>
                  '${entry.key}=${Uri.encodeComponent(entry.value.toString())}',
            )
            .join('&');
      }
    }

    return path;
  }

  /// Parses URL parameters from the current route
  ///
  /// @return A map of parameter names to values
  Map<String, String> parseUrlParameters() {
    return Get.parameters as Map<String, String>;
  }

  /// Gets a specific parameter from the current route
  ///
  /// @param name The name of the parameter
  /// @return The parameter value or null if not found
  String? getParameter(String name) {
    return Get.parameters[name];
  }
}

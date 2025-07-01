import 'package:aroundu/constants/appRoutes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;

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

  /// Generates initial routes for the application
  ///
  /// This method is used with the onGenerateInitialRoutes parameter in GetMaterialApp
  /// to handle deep linking and initial route generation.
  /// @param initialRoute The initial route name
  /// @return A list of routes to be pushed to the navigator
  List<Route<dynamic>> generateInitialRoutes(String initialRoute) {
    // If it's a standard route, just return it
    if (AppRoutes.routes.any((route) => route.name == initialRoute)) {
      final matchedRoute = AppRoutes.routes.firstWhere(
        (route) => route.name == initialRoute,
      );
      return [
        GetPageRoute(
          page: matchedRoute.page,
          transition: matchedRoute.transition,
          settings: RouteSettings(name: initialRoute),
        ),
      ];
    }

    // For deep linking or custom route handling
    // Default to landing page if no match is found
    return [
      GetPageRoute(
        page: () => AppRoutes.routes.first.page(),
        settings: const RouteSettings(name: AppRoutes.landing),
      ),
    ];
  }

  /// Generates a route for the application
  ///
  /// This method is used with the onGenerateRoute parameter in GetMaterialApp
  /// to handle dynamic route generation for routes not defined in getPages.
  /// @param settings The route settings
  /// @return A route or null if no match is found
  Route<dynamic>? generateRoute(RouteSettings settings) {
    // Extract the route name
    final String name = settings.name ?? '';

    // Check if there's a direct match in our routes
    for (final route in AppRoutes.routes) {
      // For static routes (exact match)
      if (route.name == name) {
        return GetPageRoute(
          page: route.page,
          transition: route.transition,
          settings: settings,
        );
      }

      // For dynamic routes with parameters (e.g., '/profile/:id')
      if (route.name.contains(':')) {
        // Extract parameter names from the route pattern
        final paramNames = <String>[];
        final regexPattern = route.name.replaceAllMapped(RegExp(r':([^/]+)'), (
          match,
        ) {
          final paramName = match.group(1)!;
          paramNames.add(paramName);
          return '([^/]+)';
        });

        final routePattern = RegExp('^$regexPattern\$');

        if (routePattern.hasMatch(name)) {
          // Extract parameters from the URL
          final match = routePattern.firstMatch(name);
          final params = <String, String>{};
          if (match != null) {
            // Start from index 1 as group 0 is the entire match
            for (int i = 0; i < paramNames.length; i++) {
              params[paramNames[i]] = match.group(i + 1) ?? '';
            }
          }

          // Set the parameters for GetX to use
          Get.parameters = params;

          return GetPageRoute(
            page: route.page,
            transition: route.transition,
            settings: settings,
          );
        }
      }
    }

    // If no match is found, return null or a default route
    return GetPageRoute(
      page: () => AppRoutes.routes.first.page(),
      settings: const RouteSettings(name: AppRoutes.landing),
    );
  }

  /// Callback for route changes
  ///
  /// This method is called whenever a route change occurs in the application.
  /// It can be used for analytics, logging, or other route-related side effects.
  /// @param route The current route
  void handleRouteChange(Routing? routing) {
    // Process route changes when routing is null or not navigating back
    if (routing == null) {
      _processRouteChange();
    } else if (routing.isBack == false) {
      _processRouteChange();
    }
  }

  /// Helper method to process route changes
  void _processRouteChange() {
    final currentRoute = Get.currentRoute;

    // Log route changes for debugging
    print('Route changed to: $currentRoute');

    // Update browser history for web
    if (currentRoute != '/') {
      // You can add custom web-specific logic here
      // For example, updating page title based on route
      final routeName = currentRoute.split('/').last;
      final formattedTitle =
          routeName.isEmpty
              ? 'AroundU'
              : 'AroundU | ${routeName.substring(0, 1).toUpperCase()}${routeName.substring(1)}';

      // Update page title for SEO and user experience
      // This is web-only code
      updateWebPageTitle(formattedTitle);

      // Track page views with analytics
      trackPageView(currentRoute);
    }
  }

  /// Updates the web page title
  ///
  /// This is a helper method for web-specific functionality
  /// Since this is a web-only project, we can directly use dart:html
  void updateWebPageTitle(String title) {
    try {
      // Using package:web for web
      // This is the recommended approach instead of dart:html
      web.document.title = title;

      // Log for debugging
      print('Updated page title to: $title');
    } catch (e) {
      print('Error updating page title: $e');
    }
  }

  /// Tracks page views for analytics
  ///
  /// This method can be connected to various analytics services
  /// like Google Analytics, Firebase Analytics, etc.
  void trackPageView(String route) {
    // Log for debugging
    print('Tracking page view: $route');

    // Example implementation for Google Analytics
    try {
      // This would typically send data to your analytics service
      // For Google Analytics 4, you might use something like:
      // gtag('event', 'page_view', {
      //   'page_title': web.document.title,
      //   'page_location': web.window.location.href,
      //   'page_path': route
      // });

      // For Firebase Analytics:
      // FirebaseAnalytics.instance.logScreenView(
      //   screenName: route,
      // );
    } catch (e) {
      print('Error tracking page view: $e');
    }
  }
}

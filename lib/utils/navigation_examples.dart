import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/utils/route_service.dart';

/// This file contains examples of how to use the RouteService for navigation.
/// It is meant to be used as a reference and is not part of the actual application.

class NavigationExamples {
  // Get the singleton instance of RouteService
  final RouteService _routeService = RouteService();

  /// Example of navigating to a simple route
  void navigateToDashboard() {
    _routeService.navigateTo(AppRoutes.dashboard);
  }

  /// Example of navigating to a route with parameters
  void navigateToUserProfile(String userId) {
    _routeService.navigateTo(
      AppRoutes.otherProfile,
      parameters: {'userId': userId},
    );
  }

  /// Example of navigating to a route and removing the current route from the stack
  void navigateToNotificationsAndRemoveCurrent() {
    _routeService.navigateOffTo(AppRoutes.notifications);
  }

  /// Example of navigating to a route and removing all previous routes from the stack
  void navigateToDashboardAndClearStack() {
    _routeService.navigateOffAllTo(AppRoutes.dashboard);
  }

  /// Example of going back to the previous route
  void goBack() {
    if (_routeService.canGoBack()) {
      _routeService.goBack();
    }
  }

  /// Example of getting the current route
  String getCurrentRoute() {
    return _routeService.getCurrentRoute();
  }

  /// Example of creating a URL path for web navigation
  String createProfileUrlPath(String userId) {
    return _routeService.createUrlPath(
      AppRoutes.otherProfile,
      parameters: {'userId': userId},
    );
  }

  /// Example of parsing URL parameters
  Map<String, String> parseUrlParameters() {
    return _routeService.parseUrlParameters();
  }

  /// Example of getting a specific parameter from the URL
  String? getUserIdFromUrl() {
    return _routeService.getParameter('userId');
  }
}

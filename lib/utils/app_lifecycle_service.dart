
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a class to hold the lifecycle state
class LifecycleState {
  final AppLifecycleState? currentState;
  final String currentRoute;
  final Map<String, Function(AppLifecycleState)> screenCallbacks;

  LifecycleState({
    this.currentState,
    this.currentRoute = '',
    this.screenCallbacks = const {},
  });

  LifecycleState copyWith({
    AppLifecycleState? currentState,
    String? currentRoute,
    Map<String, Function(AppLifecycleState)>? screenCallbacks,
  }) {
    return LifecycleState(
      currentState: currentState ?? this.currentState,
      currentRoute: currentRoute ?? this.currentRoute,
      screenCallbacks: screenCallbacks ?? this.screenCallbacks,
    );
  }
}

// Create a StateNotifier to manage the lifecycle state
class AppLifecycleNotifier extends StateNotifier<LifecycleState>
    with WidgetsBindingObserver {
  final Ref ref;

  AppLifecycleNotifier(this.ref) : super(LifecycleState()) {
    WidgetsBinding.instance.addObserver(this);
    kLogger.trace("AppLifecycleService initialized");
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    kLogger.trace("AppLifecycleService closed");
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    state = state.copyWith(currentState: lifecycleState);
    kLogger.trace(
        "App Lifecycle State changed: $lifecycleState for route: ${state.currentRoute}");
    kLogger.info(state.screenCallbacks.toString());

    // Execute all registered callbacks
    state.screenCallbacks.forEach((routeName, callback) {
      kLogger.trace("Executing callback for route: $routeName");
      callback(lifecycleState);
    });

    if (lifecycleState == AppLifecycleState.paused) {
      // Now we can access the ref
      Future.microtask(() {
       

      });
    }
  }

  // Register a callback for a specific screen
  void registerCallback(
      String routeName, Function(AppLifecycleState) callback) {
    final updatedCallbacks =
        Map<String, Function(AppLifecycleState)>.from(state.screenCallbacks);
    updatedCallbacks[routeName] = callback;
    state = state.copyWith(screenCallbacks: updatedCallbacks);
    kLogger.trace("Registered lifecycle callback for route: $routeName");
  }

  // Unregister a callback when screen is disposed
  void unregisterCallback(String routeName) {
    final updatedCallbacks =
        Map<String, Function(AppLifecycleState)>.from(state.screenCallbacks);
    updatedCallbacks.remove(routeName);
    state = state.copyWith(screenCallbacks: updatedCallbacks);
    kLogger.trace("Unregistered lifecycle callback for route: $routeName");
  }

  // Update current route
  void setCurrentRoute(String routeName) {
    state = state.copyWith(currentRoute: routeName);
    kLogger.trace("Current route set to: $routeName");
  }
}

// Create a provider for the AppLifecycleNotifier
final appLifecycleProvider =
    StateNotifierProvider<AppLifecycleNotifier, LifecycleState>((ref) {
  return AppLifecycleNotifier(ref);
});

// Route observer to update current route
class RiverpodRouteObserver extends NavigatorObserver {
  final WidgetRef ref;

  RiverpodRouteObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    // Use a post-frame callback to ensure we're not modifying state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (route.settings.name != null) {
        ref
            .read(appLifecycleProvider.notifier)
            .setCurrentRoute(route.settings.name!);
      } else if (route.settings.name == null && route is MaterialPageRoute) {
        final widgetName = route.builder.toString().split('(')[0];
        ref.read(appLifecycleProvider.notifier).setCurrentRoute(widgetName);
      }
    });
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    // Use a post-frame callback to ensure we're not modifying state during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (previousRoute != null && previousRoute.settings.name != null) {
        ref
            .read(appLifecycleProvider.notifier)
            .setCurrentRoute(previousRoute.settings.name!);
      }
    });
  }
}

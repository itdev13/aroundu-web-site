import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/lobby/lobby.view.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

// Create a StateNotifier that manages an AsyncValue state
class LobbyDetailsNotifier extends StateNotifier<AsyncValue<LobbyDetails?>> {
  LobbyDetailsNotifier() : super(const AsyncValue.loading());

  Future<void> fetchLobbyDetails(String lobbyId) async {
    // Set loading state
    state = const AsyncValue.loading();

    final AuthService authService = AuthService();

    try {
      // Add optional delay for testing
      // await Future.delayed(Duration(seconds: 2), () {
      //   print("Delay completed at ${DateTime.now()}");
      // });
      final isauth =
          ((authService.getToken() != null &&
                  authService.getToken().isNotEmpty) &&
              (authService.getRefreshToken() != null &&
                  authService.getRefreshToken().isNotEmpty));
      kLogger.trace("is auth in lobby : $isauth");
      String endPoint = "match/lobby/api/v1/$lobbyId/detail";
      Response? response;
      if (isauth) {
        endPoint = "match/lobby/api/v1/$lobbyId/detail";
        response = await ApiService().get(endPoint);
      } else {
        endPoint = "match/lobby/public/$lobbyId/detail";
        response = await ApiService().get(endPoint);
      }
      

      if (response.data != null) {
        kLogger.debug('Lobby details fetched successfully');
        // Update state with data
        state = AsyncValue.data(LobbyDetails.fromJson(response.data));
      } else {
        kLogger.debug('Lobby data not found for ID: $lobbyId');
        // Update state with null data
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      kLogger.error('Error in fetching lobby details: $e \n $stack');
      authService.storeToken("");
      final container = ProviderContainer();
      container.read(isAuthProvider(lobbyId).notifier).state = false;
      container.dispose();
      state = const AsyncValue.loading();
      final response = await ApiService().get(
        "match/lobby/public/$lobbyId/detail",
      );
      if (response.data != null) {
        kLogger.debug('Lobby details fetched successfully');
        // Update state with data
        state = AsyncValue.data(LobbyDetails.fromJson(response.data));
      } else {
        kLogger.debug('Lobby data not found for ID: $lobbyId');
        // Update state with null data
        state = const AsyncValue.data(null);
        state = AsyncValue.error(e, stack);
      }
      // Update state with error
      if (response.statusCode != 200) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  // Method to manually reset to loading state
  void reset() {
    state = const AsyncValue.loading();
  }
}

// Create the provider
final lobbyDetailsProvider = StateNotifierProvider.family<
  LobbyDetailsNotifier,
  AsyncValue<LobbyDetails?>,
  String
>((ref, lobbyId) {
  final notifier = LobbyDetailsNotifier();
  // Automatically fetch data when the provider is first accessed
  notifier.fetchLobbyDetails(lobbyId);
  return notifier;
});

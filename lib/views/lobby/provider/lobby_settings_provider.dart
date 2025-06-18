
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// part 'lobby_settings_provider.g.dart';

// Define the state class for lobby settings
class LobbySettingsState {
  final bool isLoading;
  final String? error;
  final bool? success;
  final bool showLobbyMembers;
  final bool enableChat;

  LobbySettingsState({
    required this.isLoading,
    this.error,
    this.success,
    required this.showLobbyMembers,
    required this.enableChat,
  });

  // Create a copy of the state with updated values
  LobbySettingsState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
    bool? showLobbyMembers,
    bool? enableChat,
  }) {
    return LobbySettingsState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
      showLobbyMembers: showLobbyMembers ?? this.showLobbyMembers,
      enableChat: enableChat ?? this.enableChat,
    );
  }

  // Initial state factory
  factory LobbySettingsState.initial() {
    return LobbySettingsState(
      isLoading: false,
      error: null,
      success: null,
      showLobbyMembers: false,
      enableChat: false,
    );
  }
}

// StateNotifier for lobby settings
class LobbySettingsNotifier extends StateNotifier<LobbySettingsState> {
  LobbySettingsNotifier() : super(LobbySettingsState.initial());

  // Update settings via API call
  Future<bool> updateSettings(String lobbyId,
      {bool? showLobbyMembers, bool? enableChat}) async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null, success: null);

      // Prepare request body with current values and any updates
      final Map<String, dynamic> requestBody = {
        "showLobbyMembers": showLobbyMembers ?? state.showLobbyMembers,
        "enableChat": enableChat ?? state.enableChat,
      };

      // Make API call
      final response = await ApiService().put(
        "match/lobby/$lobbyId/settings",
        requestBody,
        (json) => json != null, // Return true if response is not null
      );

      final success = response ?? false;

      // Update state based on response
      state = state.copyWith(
        isLoading: false,
        success: success,
        error: success ? null : 'Failed to update lobby settings',
        // Update local state if successful
        showLobbyMembers: success
            ? (showLobbyMembers ?? state.showLobbyMembers)
            : state.showLobbyMembers,
        enableChat:
            success ? (enableChat ?? state.enableChat) : state.enableChat,
      );

      return success;
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
      kLogger.error('Error updating lobby settings: $e');
      return false;
    }
  }

  // Fetch current settings
  Future<void> fetchSettings(String lobbyId) async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // Make API call to get current settings
      final response = await ApiService().get(
        "match/lobby/$lobbyId/settings",
        (json) => json,
      );

      if (response != null) {
        // Update state with fetched settings
        state = state.copyWith(
          isLoading: false,
          showLobbyMembers: response['showLobbyMembers'] ?? false,
          enableChat: response['enableChat'] ?? false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to fetch lobby settings',
        );
      }
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      kLogger.error('Error fetching lobby settings: $e');
    }
  }
}

// Provider for the lobby settings
final lobbySettingsProvider = StateNotifierProvider.family<
    LobbySettingsNotifier, LobbySettingsState, String>(
  (ref, lobbyId) => LobbySettingsNotifier(),
);

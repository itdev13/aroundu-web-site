
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../utils/api_service/api_service.dart';

part 'past_lobby_provider.g.dart';

/// Provider to activate a lobby
@riverpod
Future<bool> activateLobby(Ref ref, String lobbyId) async {
  try {
    final response = await ApiService().put(
      "match/lobby/api/v1/$lobbyId/past",
      {}, // Empty body for this PUT request
      (json) => json != null, // Return true if response is not null
    );

    kLogger.debug('Lobby past response: $response');
    return response ?? false;
  } catch (e) {
    kLogger.error('Error making lobby past: $e');
    return false;
  }
}

// State class for the lobby activation
class LobbyPastState {
  final bool isLoading;
  final String? error;
  final bool? success;

  const LobbyPastState({
    this.isLoading = false,
    this.error,
    this.success,
  });

  LobbyPastState copyWith({
    bool? isLoading,
    String? error,
    bool? success,
  }) {
    return LobbyPastState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }
}

// Notifier class for the lobby activation
class LobbyPastNotifier extends StateNotifier<LobbyPastState> {
  LobbyPastNotifier() : super(const LobbyPastState());

  Future<bool> activateLobby(String lobbyId) async {
    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null, success: null);

      final response = await ApiService().put(
        "match/lobby/api/v1/$lobbyId/past",
        {}, // Empty body for this PUT request
        (json) => json != null, // Return true if response is not null
      );

      final success = response ?? false;

      // Update state based on response
      state = state.copyWith(
        isLoading: false,
        success: success,
        error: success ? null : 'Failed to activate lobby',
      );

      return success;
    } catch (e) {
      // Update state with error
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        success: false,
      );
      kLogger.error('Error activating lobby: $e');
      return false;
    }
  }
}

// Provider for the lobby activation state
final lobbyPastProvider = StateNotifierProvider.family<
    LobbyPastNotifier, LobbyPastState, String>(
  (ref, lobbyId) => LobbyPastNotifier(),
);

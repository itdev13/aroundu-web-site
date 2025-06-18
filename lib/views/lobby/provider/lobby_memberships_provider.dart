import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

// Provider for the lobby memberships with pagination
final lobbyMembershipsProvider = StateNotifierProvider.family<
    LobbyMembershipsNotifier, LobbyMembershipsState, String>(
  (ref, lobbyId) => LobbyMembershipsNotifier(lobbyId),
);

// State class to hold the lobby memberships data and loading state
class LobbyMembershipsState {
  final LobbyMembership? lobbyMembership;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool hasMoreData;
  final int currentSkip;
  final String searchText;

  LobbyMembershipsState({
    this.lobbyMembership,
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.hasMoreData = true,
    this.currentSkip = 0,
    this.searchText = '',
  });

  // Create a copy of the state with updated values
  LobbyMembershipsState copyWith({
    LobbyMembership? lobbyMembership,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? hasMoreData,
    int? currentSkip,
    String? searchText,
  }) {
    return LobbyMembershipsState(
      lobbyMembership: lobbyMembership ?? this.lobbyMembership,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentSkip: currentSkip ?? this.currentSkip,
      searchText: searchText ?? this.searchText,
    );
  }
}

class LobbyMembershipsNotifier extends StateNotifier<LobbyMembershipsState> {
  final String lobbyId;
  final ApiService _apiService = ApiService();
  final int limit = 20;

  LobbyMembershipsNotifier(this.lobbyId) : super(LobbyMembershipsState()) {
    // Initialize by loading the first batch of data
    fetchMemberships();
  }

  // Fetch memberships with pagination and search
  Future<void> fetchMemberships() async {
    if (state.isLoading || (!state.hasMoreData && state.currentSkip > 0)) {
      return;
    }

    state = state.copyWith(isLoading: true, hasError: false);

    try {
      String url =
          'match/lobby/api/v1/$lobbyId/memberShips?limit=$limit&skip=${state.currentSkip}';

      // Add search parameter if search text is not empty
      if (state.searchText.isNotEmpty) {
        url += '&searchText=${Uri.encodeComponent(state.searchText)}';
      }

      final response = await _apiService.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final LobbyMembership newMemberships = LobbyMembership.fromJson(data);

        // If we get an empty userInfos list and it's not the first page, we've reached the end
        final bool noMoreData =
            newMemberships.userInfos.isEmpty && state.currentSkip > 0;

        // If it's the first page, replace the data, otherwise merge with existing data
        if (state.currentSkip == 0) {
          state = state.copyWith(
            lobbyMembership: newMemberships,
            isLoading: false,
            hasMoreData: !noMoreData,
            currentSkip: state.currentSkip + limit,
          );
        } else {
          // Merge the new data with existing data
          final mergedUserInfos = [
            ...?state.lobbyMembership?.userInfos,
            ...newMemberships.userInfos,
          ];

          final mergedSquads = [
            ...?state.lobbyMembership?.squads,
            ...newMemberships.squads,
          ];

          final mergedMemberships = LobbyMembership(
            lobbyName:
                state.lobbyMembership?.lobbyName ?? newMemberships.lobbyName,
            lobbyId: state.lobbyMembership?.lobbyId ?? newMemberships.lobbyId,
            userInfos: mergedUserInfos,
            squads: mergedSquads,
          );

          state = state.copyWith(
            lobbyMembership: mergedMemberships,
            isLoading: false,
            hasMoreData: !noMoreData,
            currentSkip: state.currentSkip + limit,
          );
        }
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Failed to load memberships: ${response.statusMessage}',
        );
      }
    } catch (e, s) {
      kLogger.error('Error fetching lobby memberships: $e \n $s');
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Error fetching lobby memberships: $e',
      );
    }
  }

  // Load more data (pagination)
  Future<void> loadMore() async {
    if (!state.isLoading && state.hasMoreData) {
      await fetchMemberships();
    }
  }

  // Refresh the data (reset pagination and fetch from start)
  Future<void> refresh() async {
    state = state.copyWith(
      currentSkip: 0,
      hasMoreData: true,
    );
    await fetchMemberships();
  }

  // Update search text and refresh data
  Future<void> search(String query) async {
    state = state.copyWith(
      searchText: query,
      currentSkip: 0,
      hasMoreData: true,
    );
    await fetchMemberships();
  }

  // Reset the state
  void reset() {
    state = LobbyMembershipsState();
  }
}

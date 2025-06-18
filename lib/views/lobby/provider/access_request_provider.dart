// access_request_provider.dart
import 'package:aroundu/models/access_request.lobby.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



// Cache state notifier to handle the data and refresh logic
class AccessRequestsNotifier
    extends StateNotifier<AsyncValue<List<AccessRequest>>> {
  AccessRequestsNotifier() : super(const AsyncValue.loading());

  Future<void> fetchAccessRequests(String lobbyId) async {
    try {
      state = const AsyncValue.loading();
      final response =
          await ApiService().get("match/lobby/api/v1/$lobbyId/accessRequests");

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      // Ensure we're working with a List
      final List<dynamic> jsonList =
          response.data is List ? response.data : [response.data];

      // Convert each item to Map<String, dynamic>
      final List<AccessRequest> requests = jsonList
          .map((item) =>
              AccessRequest.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      state = AsyncValue.data(requests);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void refresh(String lobbyId) {
    fetchAccessRequests(lobbyId);
  }
}

// Provider that maintains the state
final accessRequestsNotifierProvider = StateNotifierProvider.family<
    AccessRequestsNotifier, AsyncValue<List<AccessRequest>>, String>(
  (ref, lobbyId) {
    final notifier = AccessRequestsNotifier();
    // Initial fetch
    notifier.fetchAccessRequests(lobbyId);
    return notifier;
  },
);

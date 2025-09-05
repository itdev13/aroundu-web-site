import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/selected_tickets_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model class for lock pricing response
class LockPricingResponse {
  final int? code;
  final String? status;
  final String? message;
  final double? total;

  LockPricingResponse({this.code, this.status, this.message, this.total});

  // Factory constructor to create a LockPricingResponse from JSON
  factory LockPricingResponse.fromJson(Map<String, dynamic> json) {
    return LockPricingResponse(
      code: json['code'],
      status: json['status'],
      message: json['message'],
      total: json['total']?.toDouble() ?? 0.0,
    );
  }

  // Method to convert LockPricingResponse to JSON
  Map<String, dynamic> toJson() {
    return {'code': code, 'status': status, 'message': message, 'total': total};
  }

  // Create a copy of LockPricingResponse with some fields updated
  LockPricingResponse copyWith({int? code, String? status, String? message, double? total}) {
    return LockPricingResponse(
      code: code ?? this.code,
      status: status ?? this.status,
      message: message ?? this.message,
      total: total ?? this.total,
    );
  }
}

// State class for the lock pricing provider
class LockPricingState {
  final LockPricingResponse? lockPricingData;
  final bool isLoading;
  final String? error;

  LockPricingState({this.lockPricingData, this.isLoading = false, this.error});

  // Create a copy of LockPricingState with some fields updated
  LockPricingState copyWith({LockPricingResponse? lockPricingData, bool? isLoading, String? error}) {
    return LockPricingState(
      lockPricingData: lockPricingData ?? this.lockPricingData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  // Initial state
  factory LockPricingState.initial() {
    return LockPricingState(lockPricingData: null, isLoading: false, error: null);
  }
}

// Notifier class for the lock pricing provider
class LockPricingNotifier extends StateNotifier<LockPricingState> {
  final ApiService _apiService;

  LockPricingNotifier(this._apiService) : super(LockPricingState.initial());

  // Lock pricing data from API
  Future<void> lockPricing(String lobbyId, int groupSize, List<SelectedTicket>? selectedTickets,{ String? userId,
    bool isPublic = false,
  }) async {

    try {
      // Set loading state
      state = state.copyWith(isLoading: true, error: null);

      // Prepare query parameters
      Map<String, dynamic> body = {};

      if (groupSize != null) {
        if (selectedTickets != null && selectedTickets.isNotEmpty) {
          body['groupSize'] = selectedTickets.fold<int>(0, (sum, ticket) => sum + ticket.slots).toString();
        } else {
          body['groupSize'] = groupSize.toString();
        }
      }
      if (selectedTickets != null && selectedTickets.isNotEmpty) {
        body['ticketOptionsDTOS'] = selectedTickets.map((e) => e.toJson()).toList();
      }
      if (userId != null && userId.isNotEmpty) {

        body['randomId'] = userId;
      }


      // Make API call
      Response response;
       if (isPublic) {
         response = await ApiService().post(
          'match/lobby/$lobbyId/pricing/lock',
          body: body,
          // queryParameters: queryParams,
        );
      } else {
         response = await _apiService.post(
          'match/lobby/$lobbyId/pricing/lock',
          body: body,
          // queryParameters: queryParams,
        );
      }
      

      // Parse response
      if (response.statusCode == 200) {
        final lockPricingResponse = LockPricingResponse.fromJson(response.data);
        state = state.copyWith(lockPricingData: lockPricingResponse, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to lock pricing data: ${response.statusMessage}');
      }
    } catch (e, s) {
      kLogger.error("Error locking pricing data: $e \n $s");
      state = state.copyWith(isLoading: false, error: 'Error locking pricing data: $e');
    }
  }

  // Reset lock pricing data
  void reset() {
    state = LockPricingState.initial();
  }
}

// Provider for the lock pricing state
final lockPricingProvider = StateNotifierProvider.family<LockPricingNotifier, LockPricingState, String>(
  (ref, lobbyId) => LockPricingNotifier(ApiService()),
);

// Provider to get the lock pricing data
final lockPricingDataProvider = Provider.family<LockPricingResponse?, String>(
  (ref, lobbyId) => ref.watch(lockPricingProvider(lobbyId)).lockPricingData,
);

// Provider to check if lock pricing is loading
final lockPricingLoadingProvider = Provider.family<bool, String>(
  (ref, lobbyId) => ref.watch(lockPricingProvider(lobbyId)).isLoading,
);

// Provider to get any lock pricing error
final lockPricingErrorProvider = Provider.family<String?, String>(
  (ref, lobbyId) => ref.watch(lockPricingProvider(lobbyId)).error,
);

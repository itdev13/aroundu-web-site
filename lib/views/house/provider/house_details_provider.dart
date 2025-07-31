import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart' show ApiService;
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HouseDetailsNotifier extends StateNotifier<AsyncValue<HouseDetailedModel?>> {
  HouseDetailsNotifier() : super(const AsyncValue.loading());

  Future<void> fetchHosueDetails(String houseId) async {
    // Set loading state
    state = const AsyncValue.loading();

    try {
      // Add optional delay for testing
      // await Future.delayed(Duration(seconds: 1), () {
      //   print("Delay completed at ${DateTime.now()}");
      // });

      final response = await ApiService().get(
        "match/house/public",
        queryParameters: {'houseId': houseId, 'pastLobbies': true, 'upcomingLobbies': true, 'skip': 0, 'limit': 20},
      );

      kLogger.debug('house api response: ${response.data['house']['userStatus']}');

      if (response.data != null) {
        kLogger.debug('House details fetched successfully');
        // Update state with data
        // response.data['house']['userStatus'] =
        //     response.data['house']['userStatus'] ?? 'ADMIN';

        state = AsyncValue.data(HouseDetailedModel.fromJson(response.data));
      } else {
        kLogger.debug('House data not found for ID: $houseId');
        // Update state with null data
        state = const AsyncValue.data(null);
      }
    } catch (e, stack) {
      kLogger.error('Error in fetching House details: $e \n $stack');
      // Update state with error
      state = AsyncValue.error(e, stack);
    }
  }

  // Method to manually reset to loading state
  void reset() {
    state = const AsyncValue.loading();
  }
}

// Create the provider
final houseDetailsProvider = StateNotifierProvider.family<HouseDetailsNotifier, AsyncValue<HouseDetailedModel?>, String>((
  ref,
  houseId,
) {
  final notifier = HouseDetailsNotifier();
  // Automatically fetch data when the provider is first accessed
  notifier.fetchHosueDetails(houseId);
  return notifier;
});

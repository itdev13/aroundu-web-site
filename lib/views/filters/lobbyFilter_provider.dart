import 'package:aroundu/models/category.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final selectedTabProvider = StateProvider<int>((ref) => 0);
final selectedLobbyFilterCategoryProvider =
    StateProvider<List<CategoryModel?>>((ref) => []);
final selectedLobbyFilterSubCategoryProvider =
    StateProvider<List<SubCategoryInfo?>>((ref) => []);
final filterDataProvider = StateNotifierProvider<FilterDataNotifier,
    Map<String, Map<String, dynamic>>>((ref) => FilterDataNotifier());
final selectedFiltersProvider =
    StateProvider<List<Map<String, dynamic>>>((ref) => []);

final selectedEventTypeProvider =
    StateProvider<String>((ref) => ''); // PUBLIC, PRIVATE, ALL
final selectedLocationFilterProvider =
    StateProvider<Map<String, dynamic>>((ref) => {});
final selectedDateFilterProvider =
    StateProvider<Map<String, dynamic>>((ref) => {});
final selectedTimeProvider =
    StateProvider<List<String>>((ref) => []); // MORNING, DAY, EVENING, NIGHT
final selectedAgeGroupProvider =
    StateProvider<Map<String, dynamic>>((ref) => {});
final selectedPriceRangeProvider =
    StateProvider<Map<String, dynamic>>((ref) => {});
final selectedFreeEventProvider = StateProvider<bool>((ref) => true);

final applyFilterProvider =
    FutureProvider.family<dynamic, Map<String, dynamic>>((ref, body) async {
  try {
    String url = 'match/search/api/v1/filter';
    final response =
        await ApiService().post(url, queryParameters: {}, body: body);

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e,s) {
    throw Exception('Error applying filters: $e \n $s');
  }
});

class FilterDataNotifier
    extends StateNotifier<Map<String, Map<String, dynamic>>> {
  static const maxRetryAttempts = 1;

  // Keep track of failed request attempts
  final _failedAttempts = <String, int>{};

  FilterDataNotifier() : super({});

  Future<void> fetchFiltersForSubCategories(
      List<SubCategoryInfo?> subCategories) async {
    if (subCategories.isEmpty) return;

    final apiService = ApiService();

    // Filter out subCategories that:
    // 1. Already have data in state
    // 2. Exceeded max retry attempts
    final eligibleSubCategories = subCategories.where((subCategory) {
      if (subCategory == null) return false;

      final id = subCategory.subCategoryId;
      if (state.containsKey(id)) return false;

      final attempts = _failedAttempts[id] ?? 0;
      return attempts < maxRetryAttempts;
    }).toList();

    if (eligibleSubCategories.isEmpty) return;

    final futures = eligibleSubCategories.map((subCategory) async {
      final id = subCategory!.subCategoryId;

      try {
        final response = await apiService.get(
          "match/api/v1/getFilters/$id",
        );

        // Clear failed attempts on success
        _failedAttempts.remove(id);

        return MapEntry(id, response.data);
      } catch (e) {
        print('Error fetching filters for $id: $e');

        // Increment failed attempts
        _failedAttempts[id] = (_failedAttempts[id] ?? 0) + 1;

        return null;
      }
    }).toList();

    final results = await Future.wait(futures);

    final newState = Map<String, Map<String, dynamic>>.from(state);
    for (final result in results) {
      if (result != null) {
        newState[result.key] = result.value;
      }
    }

    state = newState;
  }

  void clearFilters() {
    state = {};
    _failedAttempts.clear(); // Also clear failed attempts when clearing filters
  }
}

// class FilterDataNotifier
//     extends StateNotifier<Map<String, Map<String, dynamic>>> {
//   FilterDataNotifier() : super({});
//
//   Future<void> fetchFiltersForSubCategories(
//       List<SubCategoryInfo?> subCategories) async {
//     if (subCategories.isEmpty) return;
//
//     final apiService = ApiService();
//
//     // Create a list of futures for parallel execution
//     final futures = subCategories
//         .where((subCategory) =>
//             subCategory != null &&
//             !state.containsKey(subCategory.subCategoryId))
//         .map((subCategory) async {
//       try {
//         final response = await apiService.get(
//           "match/api/v1/getFilters/${subCategory!.subCategoryId}",
//         );
//
//         return MapEntry(subCategory.subCategoryId, response.data);
//       } catch (e) {
//         print('Error fetching filters for ${subCategory!.subCategoryId}: $e');
//         return null;
//       }
//     }).toList();
//
//     // Wait for all requests to complete
//     final results = await Future.wait(futures);
//
//     // Update state with new data
//     final newState = Map<String, Map<String, dynamic>>.from(state);
//     for (final result in results) {
//       if (result != null) {
//         newState[result.key] = result.value;
//       }
//     }
//
//     state = newState;
//   }
//
//   void clearFilters() {
//     state = {};
//   }
// }

import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aroundu/models/category.dart';



// Provider that takes initial interests
final addYourInterestProvider = StateNotifierProvider.autoDispose
    .family<AddYourInterestNotifier, AddYourInterestState, List<UserInterest>>(
        (ref, initialInterests) {
  // Get categories from categoryProvider
  final categories = ref.watch(categoryProvider);

  // Handle AsyncValue states
  return categories.when(
    data: (categoryList) => AddYourInterestNotifier(
      initialInterests,
      categoryList ?? [], // Provide empty list if null
    ),
    loading: () => AddYourInterestNotifier(
      initialInterests,
      [], // Empty list while loading
    ),
    error: (error, stackTrace) => AddYourInterestNotifier(
      initialInterests,
      [], // Empty list on error
    ),
  );
});

class AddYourInterestNotifier extends StateNotifier<AddYourInterestState> {
  final List<UserInterest> initialInterests;
  final List<CategoryModel> availableCategories;

  AddYourInterestNotifier(this.initialInterests, this.availableCategories)
      : super(
          AddYourInterestState(
            selectedCategories: {},
            selectedSubcategories: {},
            availableCategories: [],
            availableSubcategories: [],
            isLoading: availableCategories.isEmpty, // Set initial loading state
          ),
        ) {
    _initializeWithInterests();
  }

  void _initializeWithInterests() {
    // Skip initialization if categories are not yet loaded
    if (availableCategories.isEmpty) return;

    final selectedCategories = <CategoryModel>{};
    final selectedSubcategories = <SubCategoryInfo>{};
    final allSubcategories = <SubCategoryInfo>[];

    // First, populate all available subcategories from the category provider
    for (final category in availableCategories) {
      for (final subcategory in category.subCategoryInfoList) {
        allSubcategories.add(subcategory);
      }
    }

    // Then, mark selections based on userInterests
    for (final interest in initialInterests) {
      // Find matching category from available categories
      final matchingCategory = availableCategories.firstWhere(
        (category) => category.categoryId == interest.category.categoryId,
        orElse: () => availableCategories.first, // Fallback if not found
      );

      selectedCategories.add(matchingCategory);

      // Add matching subcategories to selected
      for (final subCategory in interest.subCategories) {
        final matchingSubcategory =
            matchingCategory.subCategoryInfoList.firstWhere(
          (sub) => sub.subCategoryId == subCategory.subCategoryId,
          orElse: () => matchingCategory.subCategoryInfoList.first, // Fallback
        );
        selectedSubcategories.add(matchingSubcategory);
      }
    }

    state = state.copyWith(
      availableCategories: availableCategories,
      selectedCategories: selectedCategories,
      availableSubcategories: allSubcategories,
      selectedSubcategories: selectedSubcategories,
      isLoading: false,
    );
  }

  // Reset to initial state
  void resetToInitial() {
    _initializeWithInterests();
  }

  // Modified clearSelections to optionally reset to initial state
  void clearSelections({bool resetToInitial = false}) {
    if (resetToInitial) {
      _initializeWithInterests();
    } else {
      state = state.copyWith(
        selectedCategories: {},
        selectedSubcategories: {},
      );
    }
  }

  // Rest of your existing methods remain the same
  void setLoading(bool value) {
    state = state.copyWith(isLoading: value);
  }

  Future<void> updateUserInterests() async {
    setLoading(true);
    try {
      final interestAttributes = state.selectedCategories.map((category) {
        final subCategoryIds = state.selectedSubcategories
            .where((sub) => category.subCategoryInfoList
                .map((subCat) => subCat.subCategoryId)
                .contains(sub.subCategoryId))
            .map((subCat) => subCat.subCategoryId)
            .toList();

        return {
          "categoryId": category.categoryId,
          "subCategoryIds": subCategoryIds,
        };
      }).toList();

      final body = {
        "interestAttributes": interestAttributes,
      };

      const url = "user/api/v1/updateUserInterests";
      final response = await ApiService().post(url, body: body);
      print("updateUserInterests: ${response.data}");
    } catch (e) {
      print("updateUserInterests Error: $e");
    } finally {
      setLoading(false);
    }
  }

  void addCategory(CategoryModel category) {
    if (!state.availableCategories
        .any((cat) => cat.categoryId == category.categoryId)) {
      state = state.copyWith(
        availableCategories: [...state.availableCategories, category],
      );
    }
  }

  void addSubcategory(SubCategoryInfo subcategory) {
    if (!state.availableSubcategories
        .any((sub) => sub.subCategoryId == subcategory.subCategoryId)) {
      state = state.copyWith(
        availableSubcategories: [...state.availableSubcategories, subcategory],
      );
    }
  }

  void toggleCategory(CategoryModel category) {
    final newSelectedCategories = {...state.selectedCategories};
    if (newSelectedCategories.contains(category)) {
      newSelectedCategories.remove(category);
    } else {
      newSelectedCategories.add(category);
    }
    state = state.copyWith(selectedCategories: newSelectedCategories);
  }

  void toggleSubcategory(SubCategoryInfo subcategory) {
    final newSelectedSubcategories = {...state.selectedSubcategories};
    if (newSelectedSubcategories.contains(subcategory)) {
      newSelectedSubcategories.remove(subcategory);
    } else {
      newSelectedSubcategories.add(subcategory);
    }
    state = state.copyWith(selectedSubcategories: newSelectedSubcategories);
  }
}

class AddYourInterestState {
  final Set<CategoryModel> selectedCategories;
  final Set<SubCategoryInfo> selectedSubcategories;
  final List<CategoryModel> availableCategories;
  final List<SubCategoryInfo> availableSubcategories;
  final bool isLoading; // New property

  AddYourInterestState({
    required this.selectedCategories,
    required this.selectedSubcategories,
    required this.availableCategories,
    required this.availableSubcategories,
    this.isLoading = false, // Default to false
  });

  AddYourInterestState copyWith({
    Set<CategoryModel>? selectedCategories,
    Set<SubCategoryInfo>? selectedSubcategories,
    List<CategoryModel>? availableCategories,
    List<SubCategoryInfo>? availableSubcategories,
    bool? isLoading,
  }) {
    return AddYourInterestState(
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedSubcategories:
          selectedSubcategories ?? this.selectedSubcategories,
      availableCategories: availableCategories ?? this.availableCategories,
      availableSubcategories:
          availableSubcategories ?? this.availableSubcategories,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

import 'dart:math';

import 'package:aroundu/designs/widgets/chip.widgets.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/range_slider.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/text_field.dart';
import 'package:aroundu/models/category.dart';
import 'package:aroundu/views/filters/lobbyFilterFields.dart';
import 'package:aroundu/views/filters/lobbyFilter_provider.dart';
import 'package:aroundu/views/location/location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../designs/colors.designs.dart';
import '../../designs/icons.designs.dart';
import 'lobbyFilterResult.view.dart';

class LobbyFilterView extends ConsumerStatefulWidget {
  const LobbyFilterView({super.key});

  @override
  ConsumerState<LobbyFilterView> createState() => _LobbyFilterViewState();
}

class _LobbyFilterViewState extends ConsumerState<LobbyFilterView> {
  final List<TabItem> tabItems = [
    TabItem(title: 'Category'),
    TabItem(title: 'Sub-Category'),
    TabItem(title: 'Filter by Preferences'),
    TabItem(title: 'Additional Preferences'),
  ];

  @override
  void dispose() {
    super.dispose();
    ref.read(filterDataProvider.notifier).clearFilters();
  }

  @override
  Widget build(BuildContext context) {
    final selectedTab = ref.watch(selectedTabProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Left sidebar with tabs
              Container(
                width: min( sw(0.3),200),
                color: const Color(0xFFFAF9F9),
                child: ListView.builder(
                  padding: EdgeInsets.only(top: sh(0.15)),
                  itemCount: tabItems.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        ref.read(selectedTabProvider.notifier).state = index;
                      },
                      child: Container(
                        padding: EdgeInsets.only(
                          top: 24,
                          right: 16,
                          left: 16,
                          bottom: 40,
                        ),
                        child: Center(
                          child: Text(
                            tabItems[index].title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            style: TextStyle(
                              fontSize: 12,
                              color: selectedTab == index
                                  ? const Color(0xFFEC4B5D)
                                  : const Color(0xFF444444),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Right content area
              Expanded(
                child: Container(
                  padding:
                      EdgeInsets.only(top: sh(0.15), left: 16, right: 16),
                  child: IndexedStack(
                    index: selectedTab,
                    children: const [
                      CategoryTabContent(),
                      SubCategoryTabContent(),
                      FilterPreferencesTabContent(),
                      AdditionalPreferencesTabContent(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Header
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: sh(0.15),
              padding: EdgeInsets.only(
                top: 40,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      ref
                          .read(selectedLobbyFilterCategoryProvider.notifier)
                          .state = [];
                      ref
                          .read(selectedLobbyFilterSubCategoryProvider.notifier)
                          .state = [];
                      ref.read(selectedTabProvider.notifier).state = 0;
                      ref.read(selectedFiltersProvider.notifier).state = [];

                      ref.read(selectedEventTypeProvider.notifier).state = '';
                      ref.read(selectedLocationFilterProvider.notifier).state =
                          {};
                      ref.read(selectedDateFilterProvider.notifier).state = {};
                      ref.read(selectedTimeProvider.notifier).state = [];
                      ref.read(selectedAgeGroupProvider.notifier).state = {};
                      ref.read(selectedFreeEventProvider.notifier).state =
                          false;

                      Get.back();
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Text(
                    "Filter",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      ref
                          .read(selectedLobbyFilterCategoryProvider.notifier)
                          .state = [];
                      ref
                          .read(selectedLobbyFilterSubCategoryProvider.notifier)
                          .state = [];
                      ref.read(selectedTabProvider.notifier).state = 0;
                      ref.read(selectedFiltersProvider.notifier).state = [];

                      ref.read(selectedEventTypeProvider.notifier).state = '';
                      ref.read(selectedLocationFilterProvider.notifier).state =
                          {};
                      ref.read(selectedDateFilterProvider.notifier).state = {};
                      ref.read(selectedTimeProvider.notifier).state = [];
                      ref.read(selectedAgeGroupProvider.notifier).state = {};
                      ref.read(selectedPriceRangeProvider.notifier).state = {};
                      ref.read(selectedFreeEventProvider.notifier).state =
                          false;
                    },
                    child: Text(
                      "Reset",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF3E79A1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Apply Filters Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () async {
                final selectedCategories =
                    ref.read(selectedLobbyFilterCategoryProvider);
                final selectedCategoryIds = selectedCategories
                    .where((category) =>
                        category != null && category.categoryId.isNotEmpty)
                    .map((category) => category!.categoryId)
                    .toList();

                final selectedSubCategories =
                    ref.read(selectedLobbyFilterSubCategoryProvider);
                final selectedSubCategoryIds = selectedSubCategories
                    .where((subCategory) =>
                        subCategory != null &&
                        subCategory.subCategoryId.isNotEmpty)
                    .map((subCategory) => subCategory!.subCategoryId)
                    .toList();

                final selectedEventType = ref.read(selectedEventTypeProvider);
                final selectedLocation =
                    ref.read(selectedLocationFilterProvider);
                final selectedDateRange = ref.read(selectedDateFilterProvider);
                final selectedTime = ref.read(selectedTimeProvider);
                final selectedAgeGroup = ref.read(selectedAgeGroupProvider);
                final selectedPriceRange = ref.read(selectedPriceRangeProvider);
                final selectedFreeEvent = ref.read(selectedFreeEventProvider);
                final selectedAdditionalPreferences =
                    ref.read(selectedFiltersProvider);

                // Build preferences map excluding empty values
                Map<String, dynamic> preferences = {};

                // Only add eventType if it's not empty (since it defaults to '')
                if (selectedEventType.isNotEmpty) {
                  preferences['eventType'] = selectedEventType;
                }

                // Only add maps if they're not empty
                if (selectedLocation.isNotEmpty) {
                  preferences['location'] = selectedLocation;
                }

                if (selectedDateRange.isNotEmpty) {
                  preferences['dateRange'] = selectedDateRange;
                }

                if (selectedTime.isNotEmpty) {
                  preferences['time'] = selectedTime;
                }

                if (selectedAgeGroup.isNotEmpty) {
                  preferences['ageRange'] = selectedAgeGroup;
                }

                if (selectedPriceRange.isNotEmpty && !selectedFreeEvent) {
                  preferences['priceRange'] = selectedPriceRange;
                }

                preferences['isFreeEvent'] = selectedFreeEvent; //paidEvent

                // Build the final body map
                Map<String, dynamic> body = {};

                body['categoryIds'] = selectedCategoryIds;
                body['subCategoryIds'] = selectedSubCategoryIds;
                body['preferences'] = preferences;
                body['additionalPreferences'] = selectedAdditionalPreferences;

                print(body);
                // Get.back(result: selectedFilters);

                Get.dialog(
                  const Center(
                    child: CircularProgressIndicator(
                      color: DesignColors.accent,
                    ),
                  ),
                  barrierDismissible: false,
                  name: 'loadingDialog', // Add name to help with dismissing
                );

                try {
                  // Use ref.read instead of watch and await the future
                  final response =
                      await ref.read(applyFilterProvider(body).future);

                  // Dismiss loading dialog
                  if (Get.isDialogOpen == true) {
                    Get.back();
                  }

                  // Process the response
                  final results = FilterResponse.fromJson(response);
                  Get.off(() => LobbyFilterResultView(results: results));
                } catch (error, stackTrace) {
                  // Dismiss loading dialog if it's open
                  if (Get.isDialogOpen == true) {
                    Get.back();
                  }

                  // Show error message
                  print("$error \n $stackTrace");
                  Get.snackbar(
                    'Error',
                    'Error applying filters',
                    backgroundColor: Colors.white,
                    colorText: Colors.black,
                    snackPosition: SnackPosition.BOTTOM,
                  );
                } finally {
                  ref.read(selectedLobbyFilterCategoryProvider.notifier).state =
                      [];
                  ref
                      .read(selectedLobbyFilterSubCategoryProvider.notifier)
                      .state = [];
                  ref.read(selectedTabProvider.notifier).state = 0;
                  ref.read(selectedFiltersProvider.notifier).state = [];

                  ref.read(selectedEventTypeProvider.notifier).state = '';
                  ref.read(selectedLocationFilterProvider.notifier).state = {};
                  ref.read(selectedDateFilterProvider.notifier).state = {};
                  ref.read(selectedTimeProvider.notifier).state = [];
                  ref.read(selectedAgeGroupProvider.notifier).state = {};
                  ref.read(selectedFreeEventProvider.notifier).state = false;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                minimumSize: Size(sw(1) - 32, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Apply Filters",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tab Item Model
class TabItem {
  final String title;

  TabItem({required this.title});
}

// Category Tab Content
class CategoryTabContent extends ConsumerWidget {
  const CategoryTabContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryProvider);
    final selectedCategory = ref.watch(selectedLobbyFilterCategoryProvider);
     double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;

    return SingleChildScrollView(
      child: category.when(
        data: (categoryList) {
          if (categoryList == null || categoryList.isEmpty) {
            return const Center(child: Text('No categories available.'));
          }
          return Padding(
            padding: EdgeInsets.only(top: 24, bottom: sh(0.2)),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 12.0,
              children: List.generate(categoryList.length, (index) {
                final currentCategory = categoryList[index];
                final isSelected = selectedCategory.contains(currentCategory);

                return DesignChip.medium(
                  onTap: () {
                    final notifier =
                        ref.read(selectedLobbyFilterCategoryProvider.notifier);
                    if (isSelected) {
                      notifier.state = List.from(notifier.state)
                        ..remove(currentCategory);
                    } else {
                      notifier.state = List.from(notifier.state)
                        ..add(currentCategory);
                    }
                  },
                  isSelected: isSelected,
                  title: currentCategory.name,
                );
              }),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading categories: ${error.toString()}'),
        ),
      ),
    );
  }
}

// Sub-Category Tab Content
class SubCategoryTabContent extends ConsumerWidget {
  const SubCategoryTabContent({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryProvider);
    final selectedCategory = ref.watch(selectedLobbyFilterCategoryProvider);
    final selectedSubCategory =
        ref.watch(selectedLobbyFilterSubCategoryProvider);
        double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;

    return SingleChildScrollView(
      child: category.when(
        data: (categoryList) {
          // Use selectedCategory if not empty, otherwise use all categories
          final List<SubCategoryInfo> subCategoryList;

          if (selectedCategory.isNotEmpty) {
            // Filter subcategories from selected categories only
            subCategoryList = selectedCategory
                .where((category) => category != null)
                .expand((category) => category!.subCategoryInfoList)
                .toList();
          } else {
            // Use all subcategories if no category is selected
            subCategoryList = categoryList
                    ?.expand((category) => category.subCategoryInfoList)
                    .toList() ??
                [];
          }

          if (subCategoryList.isEmpty) {
            return const Center(child: Text('No SubCategories available.'));
          }

          return Padding(
            padding: EdgeInsets.only(top: 24, bottom: sh(0.2)),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 12.0,
              children: List.generate(subCategoryList.length, (index) {
                final currentSubCategory = subCategoryList[index];
                final isSelected =
                    selectedSubCategory.contains(currentSubCategory);

                return DesignChip.medium(
                    onTap: () {
                      final notifier = ref.read(
                          selectedLobbyFilterSubCategoryProvider.notifier);
                      ref.read(selectedFiltersProvider.notifier).state = [];
                      if (isSelected) {
                        notifier.state = List.from(notifier.state)
                          ..remove(currentSubCategory);
                      } else {
                        notifier.state = List.from(notifier.state)
                          ..add(currentSubCategory);
                      }
                    },
                    isSelected: isSelected,
                    title: currentSubCategory.name);
              }),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error loading categories: ${error.toString()}'),
        ),
      ),
    );
  }
}

// Filter Preferences Tab Content
class FilterPreferencesTabContent extends ConsumerStatefulWidget {
  const FilterPreferencesTabContent({super.key});

  @override
  ConsumerState<FilterPreferencesTabContent> createState() =>
      _FilterPreferencesTabContentState();
}

class _FilterPreferencesTabContentState
    extends ConsumerState<FilterPreferencesTabContent> {
  @override
  Widget build(BuildContext context) {
    final selectedType = ref.watch(selectedEventTypeProvider);
    final selectedLocation = ref.watch(selectedLocationFilterProvider);
    final selectedDate = ref.watch(selectedDateFilterProvider);
    final selectedAgeGroup = ref.watch(selectedAgeGroupProvider);
    final selectedPriceRange = ref.watch(selectedPriceRangeProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 22),

          // Event Type

          DesignText(
            text: "Event Type ",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF323232),
          ),
          SizedBox(height: 16),
          Wrap(
            spacing: 8.0,
            runSpacing: 12.0,
            children: [
              DesignChip.medium(
                onTap: () {
                  if (selectedType == 'PUBLIC') {
                    ref.read(selectedEventTypeProvider.notifier).state = '';
                  } else {
                    ref.read(selectedEventTypeProvider.notifier).state =
                        'PUBLIC';
                  }
                },
                isSelected: selectedType == 'PUBLIC',
                title: "🌏 Public",
              ),
              DesignChip.medium(
                onTap: () {
                  if (selectedType == 'PRIVATE') {
                    ref.read(selectedEventTypeProvider.notifier).state = '';
                  } else {
                    ref.read(selectedEventTypeProvider.notifier).state =
                        'PRIVATE';
                  }
                },
                isSelected: selectedType == 'PRIVATE',
                title: "🔒 Private",
              ),
              DesignChip.medium(
                onTap: () {
                  if (selectedType == 'ALL') {
                    ref.read(selectedEventTypeProvider.notifier).state = '';
                  } else {
                    ref.read(selectedEventTypeProvider.notifier).state = 'ALL';
                  }
                },
                isSelected: selectedType == 'ALL',
                title: "🎛️ All",
              ),
            ],
          ),
          SizedBox(height: 34),

          /// Location

          DesignText(
            text: "Location",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF323232),
          ),
          SizedBox(height: 16),
          WrapperTextField(
            text: selectedLocation.isNotEmpty
                ? selectedLocation['structured_formatting']['main_text'] ?? ''
                : '',
            hintText: 'Add location',
            suffixOnPressed: () async {
              final currentLocation = ref.read(selectedLocationFilterProvider);

              if (currentLocation.isNotEmpty) {
                ref.read(selectedLocationFilterProvider.notifier).state = {};
              }

              // Proceed with location selection
              final location = await Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) {
                return const Location();
              }));

              if (location != null) {
                // Reset and add new location
                ref.read(selectedLocationFilterProvider.notifier).state = {};
                final locationJson = location.toJson();
                print('New location added: $locationJson');
                ref.read(selectedLocationFilterProvider.notifier).state =
                    locationJson;
              }
            },
          ),
          SizedBox(height: 34),

          /// Date range

          DesignText(
            text: "Date",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF323232),
          ),
          SizedBox(height: 16),
          InkWell(
            onTap: () async {
              // Check if dates are already selected
              if (selectedDate.isNotEmpty) {
                ref.read(selectedDateFilterProvider.notifier).state = {};
              }

              final DateTimeRange? picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                initialDateRange: selectedDate.isNotEmpty
                    ? DateTimeRange(
                        start: DateTime.fromMillisecondsSinceEpoch(
                            int.parse(selectedDate['startDate'])),
                        end: DateTime.fromMillisecondsSinceEpoch(
                            int.parse(selectedDate['endDate'])),
                      )
                    : null,
              );

              if (picked != null) {
                // Reset and add new dates
                ref.read(selectedDateFilterProvider.notifier).state = {
                  'startDate': picked.start.millisecondsSinceEpoch.toString(),
                  'endDate': picked.end.millisecondsSinceEpoch.toString(),
                };
                print("start : ${picked.start} \n end : ${picked.end}");
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: DesignColors.border,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DesignText(
                    text: selectedDate.isNotEmpty
                        ? '${_formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(selectedDate['startDate'])))} - ${_formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(selectedDate['endDate'])))}'
                        : 'Select Date Range',
                    fontSize: 14,
                    color: const Color(0xFF444444),
                    fontWeight: FontWeight.w300,
                  ),
                  Icon(Icons.date_range, size: 20),
                ],
              ),
            ),
          ),
          SizedBox(height: 34),

          /// Time

          DesignText(
            text: "Time",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF323232),
          ),
          SizedBox(
            height:sh(0.22),
            // padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Align(
              child: GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: Get.width>700? 4:2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2,
                children: [
                  _buildCard(
                    ref: ref,
                    icon: DesignIcons.morning,
                    title: 'Morning',
                    subtitle: '12am to 9am',
                    timeValue: 'MORNING',
                  ),
                  _buildCard(
                    ref: ref,
                    icon: DesignIcons.day,
                    title: 'Day',
                    subtitle: '9am to 4pm',
                    timeValue: 'DAY',
                  ),
                  _buildCard(
                    ref: ref,
                    icon: DesignIcons.evening,
                    title: 'Evening',
                    subtitle: '4pm to 9pm',
                    timeValue: 'EVENING',
                  ),
                  _buildCard(
                    ref: ref,
                    icon: DesignIcons.night,
                    title: 'Night',
                    subtitle: '9pm to 12am',
                    timeValue: 'NIGHT',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          /// Age group

          DesignText(
            text: "Age Group",
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF323232),
          ),
          WrapperRangeSlider(
            min: 1,
            max: 100,
            // Use stored values if they exist, otherwise use defaults
            selectedMin: selectedAgeGroup.isNotEmpty
                ? selectedAgeGroup['min'] as double
                : 1,
            selectedMax: selectedAgeGroup.isNotEmpty
                ? selectedAgeGroup['max'] as double
                : 100,
            handleChange: (min, max) {
              // Update the provider with new values
              ref.read(selectedAgeGroupProvider.notifier).state = {
                'min': min.roundToDouble(),
                'max': max.roundToDouble(),
              };
              print('Age range updated - Min: $min, Max: $max');
            },
          ),
          SizedBox(height: 34),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DesignText(
                text: "Only paid events",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF323232),
              ),
              Switch(
                value: !ref.watch(
                    selectedFreeEventProvider), // Watch the provider's state
                onChanged: (val) {
                  ref.read(selectedFreeEventProvider.notifier).state =
                      !val; // Update the state
                },
                activeColor: DesignColors.accent,
                inactiveTrackColor: Colors.grey[200],
                inactiveThumbColor: DesignColors.accent,
                // Remove borders and customize shape:
                trackOutlineColor: WidgetStateProperty.all(
                    Colors.transparent), // This removes the border
                trackOutlineWidth:
                    WidgetStateProperty.all(0), // Ensures no outline width
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                splashRadius: 0,
              ),
            ],
          ),
          SizedBox(height: 34),

          /// Price range

          if (!ref.watch(selectedFreeEventProvider)) ...[
            DesignText(
              text: "Price Range",
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF323232),
            ),
            WrapperRangeSlider(
              min: 0,
              max: 100000,
              selectedMin: selectedPriceRange.isNotEmpty
                  ? selectedPriceRange['min'] as double
                  : 0,
              selectedMax: selectedPriceRange.isNotEmpty
                  ? selectedPriceRange['max'] as double
                  : 100000,
              handleChange: (min, max) {
                // Update provider with new values
                ref.read(selectedPriceRangeProvider.notifier).state = {
                  'min': min.roundToDouble(),
                  'max': max.roundToDouble(),
                };
                print(
                    'Price range updated - Min: \$${min.toStringAsFixed(2)}, Max: \$${max.toStringAsFixed(2)}');
              },
            ),
            SizedBox(height: 34),
          ],

          // Add bottom padding for scrolling
          SizedBox(height: sh(0.1)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildCard({
    required WidgetRef ref,
    required DesignIcons icon,
    required String title,
    required String subtitle,
    required String timeValue, // Add this parameter
  }) {
    return Consumer(
      builder: (context, ref, child) {
        final selectedTime = ref.watch(selectedTimeProvider);
        final isSelected = selectedTime.contains(timeValue);

        return InkWell(
          onTap: () {
            final currentState =
                List<String>.from(ref.read(selectedTimeProvider));

            if (isSelected) {
              currentState.remove(timeValue);
            } else {
              currentState.add(timeValue);
            }

            ref.read(selectedTimeProvider.notifier).state = currentState;
          },
          splashColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? DesignColors.accent.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? DesignColors.accent : DesignColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DesignIcon.custom(
                  icon: icon,
                  size: 20,
                  color: isSelected
                      ? DesignColors.accent
                      : const Color(0xFF444444),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DesignText(
                      text: title,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? DesignColors.accent
                          : const Color(0xFF444444),
                    ),
                    DesignText(
                      text: subtitle,
                      fontSize: 9,
                      fontWeight: FontWeight.w300,
                      color: isSelected
                          ? DesignColors.accent
                          : const Color(0xFF444444),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Additional Preferences Tab Content

class AdditionalPreferencesTabContent extends ConsumerStatefulWidget {
  const AdditionalPreferencesTabContent({super.key});

  @override
  ConsumerState<AdditionalPreferencesTabContent> createState() =>
      _AdditionalPreferencesTabContentState();
}

class _AdditionalPreferencesTabContentState
    extends ConsumerState<AdditionalPreferencesTabContent> {
  @override
  void initState() {
    super.initState();
    // _fetchFiltersData();
  }

  void _fetchFiltersData() {
    final selectedSubCategories =
        ref.read(selectedLobbyFilterSubCategoryProvider);
    if (selectedSubCategories.isNotEmpty) {
      ref
          .read(filterDataProvider.notifier)
          .fetchFiltersForSubCategories(selectedSubCategories);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedSubCategories =
        ref.watch(selectedLobbyFilterSubCategoryProvider);
    final filterData = ref.watch(filterDataProvider);
    final selectedFilters = ref.watch(selectedFiltersProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;

    if (selectedSubCategories.isNotEmpty) {
      ref
          .read(filterDataProvider.notifier)
          .fetchFiltersForSubCategories(selectedSubCategories);
    }

    if (selectedSubCategories.isEmpty) {
      return Center(
        child: Text(
          'Please select a subcategory',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    if (selectedSubCategories.length > 1) {
      return Center(
        child: Text(
          'Please select only 1 subcategory',
          style: TextStyle(fontSize: 14),
        ),
      );
    }

    bool isLoading = selectedSubCategories.any((subCategory) =>
        subCategory != null &&
        !filterData.containsKey(subCategory.subCategoryId));

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 22),
          ...selectedSubCategories.map(
            (subCategory) {
              if (subCategory == null) return const SizedBox.shrink();
              final subCategoryData = filterData[subCategory.subCategoryId];

              if (subCategoryData == null) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (subCategoryData['advancedFilterInfoList'] != null) ...[
                    ...(subCategoryData['advancedFilterInfoList'] as List).map(
                      (filter) {
                        // Find existing filter
                        final existingFilter = selectedFilters.firstWhere(
                          (f) =>
                              f['title'] == filter['title'] &&
                              f['subCategoryId'] == subCategory.subCategoryId,
                          orElse: () => {},
                        );

                        // Get the value based on filter type
                        final selectedValue =
                            filter['filterType'] == 'CHECK_BOX'
                                ? existingFilter['options']
                                : existingFilter['options']?.isNotEmpty == true
                                    ? existingFilter['options'][0]
                                    : null;

                        return DynamicFilterField(
                          type: filter['filterType'],
                          title: filter['title'],
                          options: filter['options']?.cast<String>(),
                          value: selectedValue,
                          filterData: filter,
                          onChanged: (String key, dynamic value) {
                            final selectedOptions =
                                filter['filterType'] == 'CHECK_BOX'
                                    ? value
                                    : [value];

                            _updateFilters(
                              ref,
                              selectedFilters,
                              {
                                ...filter,
                                'options': selectedOptions,
                                'subCategoryId': subCategory.subCategoryId,
                              },
                            );
                          },
                        );
                      },
                    ).toList(),
                  ],
                  if (subCategoryData['otherFilterInfo'] != null) ...[
                    SizedBox(height: 16),

                    // Date Filter
                    if (subCategoryData['otherFilterInfo']['dateInfo'] != null)
                      DynamicFilterField(
                        type: 'DATE',
                        title: 'Date',
                        value: _getFilterValue(selectedFilters, 'dateInfo'),
                        filterData: subCategoryData['otherFilterInfo']
                            ['dateInfo'],
                        onChanged: (String key, dynamic value) {
                          _updateFilters(
                            ref,
                            selectedFilters,
                            {
                              'title': 'dateInfo',
                              'type': 'DATE',
                              'value': value,
                              'subCategoryId': subCategory.subCategoryId,
                            },
                          );
                        },
                      ),

                    // Date Range Filter
                    if (subCategoryData['otherFilterInfo']['dateRange'] != null)
                      DynamicFilterField(
                        type: 'DATE_RANGE',
                        title: 'Date Range',
                        value: _getFilterValue(selectedFilters, 'dateRange'),
                        filterData: subCategoryData['otherFilterInfo']
                            ['dateRange'],
                        onChanged: (String key, dynamic value) {
                          _updateFilters(
                            ref,
                            selectedFilters,
                            {
                              'title': 'dateRange',
                              'type': 'DATE_RANGE',
                              'value': value,
                              'subCategoryId': subCategory.subCategoryId,
                            },
                          );
                        },
                      ),

                    // Range Filter
                    if (subCategoryData['otherFilterInfo']['range'] != null)
                      DynamicFilterField(
                        type: 'SLIDER',
                        title: 'Range',
                        value: _getFilterValue(selectedFilters, 'range'),
                        filterData: subCategoryData['otherFilterInfo']['range'],
                        onChanged: (String key, dynamic value) {
                          _updateFilters(
                            ref,
                            selectedFilters,
                            {
                              'title': 'range',
                              'type': 'SLIDER',
                              'value': value,
                              'subCategoryId': subCategory.subCategoryId,
                            },
                          );
                        },
                      ),

                    // Location Filter
                    if (subCategoryData['otherFilterInfo']['locationInfo'] !=
                        null)
                      DynamicFilterField(
                        type: 'LOCATION',
                        title: 'Location',
                        value: _getFilterValue(selectedFilters, 'locationInfo'),
                        filterData: subCategoryData['otherFilterInfo']
                            ['locationInfo'],
                        onChanged: (String key, dynamic value) {
                          _updateFilters(
                            ref,
                            selectedFilters,
                            {
                              'title': 'locationInfo',
                              'type': 'LOCATION',
                              'value': value,
                              'subCategoryId': subCategory.subCategoryId,
                            },
                          );
                        },
                      ),

                    // Input Filter
                    if (subCategoryData['otherFilterInfo']['input'] != null)
                      DynamicFilterField(
                        type: 'INPUT',
                        title: subCategoryData['otherFilterInfo']['input']
                                ['title'] ??
                            'Input',
                        value: _getFilterValue(selectedFilters, 'input'),
                        filterData: subCategoryData['otherFilterInfo']['input'],
                        onChanged: (String key, dynamic value) {
                          _updateFilters(
                            ref,
                            selectedFilters,
                            {
                              'title': 'input',
                              'type': 'INPUT',
                              'value': value,
                              'subCategoryId': subCategory.subCategoryId,
                            },
                          );
                        },
                      ),

                    // Dropdown Filter
                    if (subCategoryData['otherFilterInfo']['dropdown'] != null)
                      DynamicFilterField(
                        type: 'DROP_DOWN_MENU',
                        title: subCategoryData['otherFilterInfo']['dropdown']
                                ['title'] ??
                            'Select Option',
                        options: (subCategoryData['otherFilterInfo']['dropdown']
                                ['options'] as List?)
                            ?.cast<String>(),
                        value: _getFilterValue(selectedFilters, 'dropdown'),
                        filterData: subCategoryData['otherFilterInfo']
                            ['dropdown'],
                        onChanged: (String key, dynamic value) {
                          _updateFilters(
                            ref,
                            selectedFilters,
                            {
                              'title': 'dropdown',
                              'type': 'DROP_DOWN_MENU',
                              'value': value,
                              'subCategoryId': subCategory.subCategoryId,
                            },
                          );
                        },
                      ),
                  ],
                  SizedBox(height: sh(0.1)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function to get filter value
  dynamic _getFilterValue(List<Map<String, dynamic>> filters, String title) {
    final filter = filters.firstWhere(
      (f) => f['title'] == title,
      orElse: () => {},
    );
    return filter['value'];
  }

  // Helper function to update filters
  void _updateFilters(
    WidgetRef ref,
    List<Map<String, dynamic>> currentFilters,
    Map<String, dynamic> newFilter,
  ) {
    final List<Map<String, dynamic>> updatedFilters = List.from(currentFilters);

    final existingIndex = updatedFilters.indexWhere((filter) =>
        filter['title'] == newFilter['title'] &&
        filter['subCategoryId'] == newFilter['subCategoryId']);

    if (existingIndex != -1) {
      updatedFilters[existingIndex] = newFilter;
    } else {
      updatedFilters.add(newFilter);
    }

    ref.read(selectedFiltersProvider.notifier).state = updatedFilters;
  }
}

import 'dart:math';

import 'package:aroundu/designs/widgets/category_list.dart';
import 'package:aroundu/models/category.dart';
import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/house/provider/houses_providers.dart';
import 'package:aroundu/views/house/provider/houses_providers_util.dart';
import 'package:aroundu/views/house/view_all_house_card.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers_util.dart';
import 'package:aroundu/views/lobby/widgets/view_all_explore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/icons.designs.dart';
import '../../designs/utils.designs.dart';
import '../../designs/widgets/chip.widgets.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/lobby_card.widgets.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import '../filters/lobbyFilter.view.dart';
import '../filters/lobbyFilterResult.view.dart';
import '../notifications/notifications.view.dart';
import '../search/search.view.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          HapticFeedback.lightImpact();
          try {
            ref.invalidate(categoryProvider);
            ref.invalidate(selectedCategoryProvider);
            ref.invalidate(selectedSubCategoryProvider);
            ref.invalidate(LobbyProviderUtil.getProvider(LobbyType.trending));
            ref.invalidate(
              LobbyProviderUtil.getProvider(LobbyType.recommendations),
            );
            ref.invalidate(HouseProviderUtil.getProvider(HouseType.trending));
            ref.invalidate(
              HouseProviderUtil.getProvider(HouseType.recommendations),
            );
          } catch (e) {
            CustomSnackBar.show(
              context: context,
              message: 'Failed to refresh page',
              type: SnackBarType.error,
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // const Space.h(height: 20),
              const SearchAndFilterInfo(),

              Space.h(height: 16),

              // const Categories(),

              ///
              /// Trending Lobbies
              ///
              const LobbiesList(
                lobbyType: LobbyType.trending,
                title: "Trending Lobbies",
              ),

              ///
              /// Trending house
              ///
              const HousesList(
                houseType: HouseType.trending,
                title: "Trending Houses",
              ),

              ///
              /// Top Picks / Recommended Lobbies
              ///
              const LobbiesList(
                lobbyType: LobbyType.recommendations,
                title: "Recommended Lobbies",
              ),

              ///
              /// Top Picks / Recommended houses
              ///
              const HousesList(
                houseType: HouseType.recommendations,
                title: "Recommended Houses",
              ),

              Space.h(height: 0.1 * Get.height),
            ],
          ),
        ),
      ),
    );
  }
}

// First, create a provider for selected category
final selectedCategoryProvider = StateProvider<CategoryModel?>((ref) => null);
final selectedSubCategoryProvider = StateProvider<SubCategoryInfo?>(
  (ref) => null,
);

class SearchAndFilterInfo extends ConsumerWidget {
  const SearchAndFilterInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final category = ref.watch(categoryProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 224,
          padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
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
          child: Column(
            children: [
              Space.h(height: 23),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              canRequestFocus: false,
                              onTap: () {
                                HapticFeedback.lightImpact();
                                Get.to(() => const SearchView());
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Search here....',
                                hintStyle: DesignFonts.poppins.merge(
                                  TextStyle(
                                    fontSize: 14,
                                    color: const Color(0xFF444444),
                                  ),
                                ),
                                contentPadding: EdgeInsets.zero,
                                isDense: true,
                              ),
                            ),
                          ),
                          Space.w(width: 10),
                          DesignIcon.icon(
                            icon: Icons.search,
                            color: const Color(0xFF444444),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Get.to(() => const LobbyFilterView());
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: DesignIcon.icon(
                        icon: Icons.tune,
                        color: const Color(0xFF444444),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Space.h(height: 16),
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  children: [
                    switch (category) {
                      AsyncData(:final List<CategoryModel> value) => Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 24),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedCategoryProvider.notifier)
                                    .state = null;
                                // Clear subcategory selection when "All" is selected
                                ref
                                    .read(selectedSubCategoryProvider.notifier)
                                    .state = null;
                              },
                              child: Container(
                                width: min(96, sw(0.18)),
                                height: 96,
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        selectedCategory == null
                                            ? const Color(0xFF3E79A1)
                                            : Colors.transparent,
                                    width: selectedCategory == null ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(16),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DesignIcon.custom(
                                      icon: DesignIcons.all,
                                      color:
                                          selectedCategory == null
                                              ? const Color(0xFF3E79A1)
                                              : const Color(0xFF989898),
                                      size: 18,
                                    ),
                                    Space.h(height: 4),
                                    DesignText(
                                      text: 'All',
                                      fontSize: 12,
                                      textAlign: TextAlign.center,
                                      color:
                                          selectedCategory == null
                                              ? const Color(0xFF3E79A1)
                                              : const Color(0xFF989898),
                                      maxLines: 2,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          ...List.generate(value.length, (index) {
                            final category = value[index];
                            final isSelected = selectedCategory == category;

                            return Padding(
                              padding: EdgeInsets.only(right: 18),
                              child: GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  ref
                                      .read(selectedCategoryProvider.notifier)
                                      .state = isSelected ? null : category;
                                  // Clear subcategory selection when changing categories
                                  ref
                                      .read(
                                        selectedSubCategoryProvider.notifier,
                                      )
                                      .state = null;
                                },
                                child: Container(
                                   width: min(96, sw(0.18)),
                                  height: 96,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? const Color(0xFF3E79A1)
                                              : Colors.transparent,
                                      width: isSelected ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(16),
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DesignText(
                                        text: category.iconUrl,
                                        color:
                                            isSelected
                                                ? const Color(0xFF3E79A1)
                                                : const Color(0xFF989898),
                                        fontSize: 12,
                                      ),
                                      DesignText(
                                        text: category.name,
                                        fontSize: 12,
                                        textAlign: TextAlign.center,
                                        color:
                                            isSelected
                                                ? const Color(0xFF3E79A1)
                                                : const Color(0xFF989898),
                                        maxLines: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      AsyncError() => const Text(
                        'Oops, something unexpected happened',
                      ),
                      _ => Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              height: 20,
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            Space.h(height: 20),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 20),
                              height: 80,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: 5,
                                itemBuilder:
                                    (context, index) => Container(
                                      margin: EdgeInsets.only(right: 10),
                                      width: 80,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                              ),
                            ),
                            Space.h(height: 16),
                            Container(height: 2, color: Colors.white),
                          ],
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
        // Show subcategories if a category is selected
        if (selectedCategory != null) ...[
          Space.h(height: 14),
          SizedBox(
            height: 40, // Fixed height for subcategory list
            child: switch (category) {
              AsyncData() => ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16),
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemCount: selectedCategory.subCategoryInfoList.length,
                separatorBuilder: (context, index) => SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final subCategory =
                      selectedCategory.subCategoryInfoList[index];
                  final isSelected = selectedSubCategory == subCategory;

                  return DesignChip.filled(
                    fontSize: 12,
                    title: subCategory.name,
                    borderColor: const Color(0xFFEAEFF2),
                    radius: 16,
                    filledColor:
                        isSelected ? const Color(0xFFEAEFF2) : Colors.white,
                    textColor:
                        isSelected
                            ? const Color(0xFF323232)
                            : const Color(0xFF989898),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      final notifier = ref.read(
                        selectedSubCategoryProvider.notifier,
                      );
                      if (isSelected) {
                        // notifier.state = selectedSubCategory
                        //     .where((item) =>
                        //         item?.subCategoryId != subCategory.subCategoryId)
                        //     .toList();
                        notifier.state = null;
                      } else {
                        // notifier.state = [...selectedSubCategory, subCategory];
                        notifier.state = subCategory;
                      }
                    },
                  );
                },
              ),
              AsyncError() => Center(
                child: DesignText(
                  text: 'Failed to load subcategories',
                  fontSize: 12,
                ),
              ),
              _ => Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder:
                      (context, index) => Container(
                        margin: EdgeInsets.only(right: 8),
                        width: 80,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                ),
              ),
            },
          ),
        ],
      ],
    );
  }
}

class LobbiesList extends ConsumerWidget {
  const LobbiesList({
    super.key,
    required this.lobbyType,
    required this.title,
    this.showViewAll = false,
  });
  final LobbyType lobbyType;
  final String title;
  final bool showViewAll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    final yourLobbies = ref.watch(
      LobbyProviderUtil.getProvider(
        lobbyType,
        categoryId: selectedCategory?.categoryId,
        subCategoryId: selectedSubCategory?.subCategoryId,
      ),
    );

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollController = ScrollController();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            switch (yourLobbies) {
              AsyncData(:final List<Lobby> value) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: DesignText(
                            text: title,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (value.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              HapticFeedback.selectionClick();
                              Get.to(
                                () => ViewAllLobbiesExplore(
                                  title: title,
                                  lobbies: value,
                                ),
                              );
                            },
                            child: DesignText(
                              text: "View All",
                              fontSize: 12,
                              color: const Color(0xFF3E79A1),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Space.h(height: 8),
                  value.isNotEmpty
                          ? SizedBox(
                            height: min(231, constraints.maxHeight * 0.6),
                            child: Stack(
                              children: [
                                ListView.builder(
                                  controller: scrollController,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: value.length,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final lobby = value[index];
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        right:
                                            index == value.length - 1
                                                ? sw(0.01)
                                                : 16,
                                        left: index == 0 ? sw(0.01) : 0,
                                        bottom: 8,
                                      ),
                                      child: ConstrainedBox(
                                        constraints: BoxConstraints(
                                          maxWidth: 450,
                                          // maxWidth: min(650, 750),
                                          minWidth: 200,
                                        ),
                                        child: DesignLobbyWidget(
                                          lobby: lobby,
                                          hasCoverImage:
                                              lobby.mediaUrls.isNotEmpty,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                Positioned(
                                  right: 0,
                                  bottom:
                                      (min(231, constraints.maxHeight * 0.6)) /
                                      2,
                                  child: GestureDetector(
                                    onTap: () {
                                      try {
                                        if (scrollController.position.pixels <
                                            scrollController
                                                .position
                                                .maxScrollExtent) {
                                          scrollController.animateTo(
                                            scrollController.position.pixels +
                                                min(650, 750),
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeOut,
                                          );
                                        }
                                      } catch (e, s) {
                                        print("$e \n $s");
                                      }
                                    },
                                    child: Container(
                                      width: min(sw(0.08), 40),
                                      height: min(sw(0.08), 40),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(124),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                Positioned(
                                  left: 0,
                                  bottom:
                                      (min(231, constraints.maxHeight * 0.6)) /
                                      2,
                                  child: GestureDetector(
                                    onTap: () {
                                      try {
                                        if (scrollController.position.pixels >
                                            0) {
                                          scrollController.animateTo(
                                            scrollController.position.pixels -
                                                min(650, 750),
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            curve: Curves.easeOut,
                                          );
                                        }
                                      } catch (e, s) {
                                        print("$e \n $s");
                                      }
                                    },
                                    child: Container(
                                      width: min(sw(0.08), 40),
                                      height: min(sw(0.08), 40),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(124),
                                        borderRadius: BorderRadius.circular(
                                          100,
                                        ),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                          : SizedBox(
                            height: sh(0.1),
                            child: Center(
                              child: DesignText(
                                text: "No lobbies to show",
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                    
                ],
              ),
              AsyncError() => SizedBox(
                width: sw(1),
                child: Center(
                  child: DesignText(
                    text: 'Oops, something unexpected happened',
                    fontSize: 12,
                  ),
                ),
              ),
              _ => SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder:
                      (context, index) => Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: const LobbyCardShimmer(),
                      ),
                ),
              ),
            },
            Space.h(height: 34),
          ],
        );
      },
    );
  }
}

class HousesList extends ConsumerWidget {
  const HousesList({
    super.key,
    required this.houseType,
    required this.title,
    this.showViewAll = false,
  });
  final HouseType houseType;
  final String title;
  final bool showViewAll;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedSubCategory = ref.watch(selectedSubCategoryProvider);
    final yourHouses = ref.watch(
      HouseProviderUtil.getProvider(
        houseType,
        categoryId: selectedCategory?.categoryId,
        subCategoryId: selectedSubCategory?.subCategoryId,
      ),
    );
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return LayoutBuilder(
      builder: (context, constraints) {
        final scrollController = ScrollController();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// Your Houses
            ///
            switch (yourHouses) {
              AsyncData(:final List<House> value) => Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: DesignText(
                          text: title,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (value.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.to(
                              () => ViewAllHousesExplore(
                                title: title,
                                houses: value,
                              ),
                            );
                          },
                          child: DesignText(
                            text: "View All",
                            fontSize: 12,
                            color: const Color(0xFF3E79A1),
                          ),
                        ),
                    ],
                  ),
                  Space.h(height: 8),
                  value.isNotEmpty
                      ? Stack(
                        children: [
                          SizedBox(
                            height: min(231, constraints.maxHeight * 0.6),
                            child: ListView.builder(
                              // scrollDirection: Axis.horizontal,
                              // options: CarouselOptions(
                              //   height: 0.24.sh,
                              //   viewportFraction: 0.8,
                              //   enlargeCenterPage: true,
                              //   enlargeFactor: 0,
                              // ),
                              controller: scrollController,
                              scrollDirection: Axis.horizontal,
                              itemCount: value.length,
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final house = value[index];
                                return Padding(
                                  padding: EdgeInsets.only(
                                    right:
                                        index == value.length - 1
                                            ? sw(0.01)
                                            : 16,
                                    left: index == 0 ? sw(0.01) : 0,
                                    bottom: 8,
                                  ),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      maxWidth: 450,
                                      // maxWidth: min(650, 750),
                                      minWidth: 200,
                                    ),
                                    child: ViewAllHouseCard(
                                      house: house,
                                      onHouseDeleted: () {},
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: (min(231, constraints.maxHeight * 0.6)) / 2,
                            child: GestureDetector(
                              onTap: () {
                                try {
                                  if (scrollController.position.pixels <
                                      scrollController
                                          .position
                                          .maxScrollExtent) {
                                    scrollController.animateTo(
                                      scrollController.position.pixels +
                                          min(650, 750),
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                } catch (e, s) {
                                  print("$e \n $s");
                                }
                              },
                              child: Container(
                                width: min(sw(0.08), 40),
                                height: min(sw(0.08), 40),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(124),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            left: 0,
                            bottom: (min(231, constraints.maxHeight * 0.6)) / 2,
                            child: GestureDetector(
                              onTap: () {
                                try {
                                  if (scrollController.position.pixels > 0) {
                                    scrollController.animateTo(
                                      scrollController.position.pixels -
                                          min(650, 750),
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                  }
                                } catch (e, s) {
                                  print("$e \n $s");
                                }
                              },
                              child: Container(
                                width: min(sw(0.08), 40),
                                height: min(sw(0.08), 40),
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(124),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                      : SizedBox(
                        height: sh(0.1),
                        child: Center(
                          child: DesignText(
                            text: "No houses to show",
                            fontSize: 16,
                          ),
                        ),
                      ),
                ],
              ),
              AsyncError() => SizedBox(
                width: sw(1),
                child: Center(
                  child: DesignText(
                    text: 'Oops, something unexpected happened',
                    fontSize: 12,
                  ),
                ),
              ),
              _ => SizedBox(
                height: 240,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder:
                      (context, index) => Padding(
                        padding: EdgeInsets.only(right: 16),
                        child: const LobbyCardShimmer(),
                      ),
                ),
              ),
            },
            Space.h(height: 34),
          ],
        );
      },
    );
  }
}

class LobbyCardShimmer extends StatelessWidget {
  const LobbyCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
       maxWidth: 450,
        // maxWidth: min(650, 750),
        minWidth: 200,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          height: 231,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 18,
                      width: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: 180,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          height: 14,
                          width: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Spacer(),
                        Container(
                          height: 14,
                          width: 60,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HouseCardShimmer extends StatelessWidget {
  const HouseCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
         maxWidth: 450,
        minWidth: 200,
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

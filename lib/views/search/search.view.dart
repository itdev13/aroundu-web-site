import 'dart:async';


import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/views/filters/lobbyFilterResult.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;

import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';

// Providers
final searchTextProvider = StateProvider<String>((ref) => '');
final showRecommendationsProvider = StateProvider<bool>((ref) => true);

// AsyncNotifier to handle API calls and state
class RecommendationsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    return [];
  }

  Future<void> fetchRecommendations(String query) async {
    // if (query.isEmpty) {
    //   state = const AsyncValue.data([]);
    //   return;
    // }

    state = const AsyncValue.loading();

    try {
      const url = "match/search/api/v1/auto-completions";
      final queryParameters = {'query': query};

      final response = await ApiService().get(
        url,
        queryParameters: queryParameters,
      );

      final List<String> recommendations = List<String>.from(response.data);
      print(recommendations);
      List<String> cleanData = recommendations.map((item) {
        return html_parser.parse(item).body!.text;
      }).toList();
      print(cleanData);

      state = AsyncValue.data(cleanData);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

 Future<void> performSearch(String searchText) async {
    try {
      const url = 'match/search';
      final body = {"title": searchText};

      final response = await ApiService().post(
        url,
        queryParameters: {},
        body: body,
      );

      // Clean the response data before parsing
      final cleanedData = _cleanResponseData(response.data);
      final results = FilterResponse.fromJson(cleanedData);

      Get.offNamed(AppRoutes.filterResult,arguments: {
        'results': results,
      });
    } catch (error, stack) {
      print('Error performing search: $error \n $stack');
    }
  }

  dynamic _cleanResponseData(dynamic data) {
    if (data is String) {
      // Remove replacement characters and clean the string
      return data.replaceAll('\uFFFD', '').replaceAll('�', '');
    } else if (data is Map) {
      // Recursively clean map values
      final cleaned = <String, dynamic>{};
      data.forEach((key, value) {
        cleaned[key] = _cleanResponseData(value);
      });
      return cleaned;
    } else if (data is List) {
      // Recursively clean list items
      return data.map((item) => _cleanResponseData(item)).toList();
    }
    return data;
  }

}

final recommendationsProvider =
    AsyncNotifierProvider<RecommendationsNotifier, List<String>>(
  () => RecommendationsNotifier(),
);

class SearchView extends ConsumerStatefulWidget {
  const SearchView({super.key});

  @override
  ConsumerState<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends ConsumerState<SearchView> {
  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      final text = _searchController.text;
      ref.read(searchTextProvider.notifier).state = text;
      ref.read(showRecommendationsProvider.notifier).state = text.isEmpty;

      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 600), () {
        ref.read(recommendationsProvider.notifier).fetchRecommendations(text);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchFocusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final showRecommendations = ref.watch(showRecommendationsProvider);
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // Enable automatic resizing
        body: Column(
          children: [
            // Fixed header section
            Container(
              padding: EdgeInsets.only(
                top: 56,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: DesignIcon.icon(
                      icon: Icons.arrow_back_ios_new_rounded,
                    ),
                  ),
                  Space.h(height: 16),
                  Container(
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
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onEditingComplete: () {
                              if (_searchController.text.isNotEmpty) {
                                ref
                                    .read(recommendationsProvider.notifier)
                                    .performSearch(_searchController.text);
                              }
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
                ],
              ),
            ),

            Space.h(height: 16),

            // Flexible content area that adjusts to available space
            Expanded(
              child: recommendationsAsync.when(
                data: (recommendations) {
                  if (recommendations.isEmpty) {
                    return Padding(
                      padding: EdgeInsets.all(16),
                      child: DesignText(
                        text: 'No result found',
                        color: DesignColors.accent,
                        fontSize: 14,
                      ),
                    );
                  }
                  return Container(
                    color: Colors.white,
                    padding: EdgeInsets.only(bottom: 16),
                    child: ListView.builder(
                      shrinkWrap:
                          false, // Remove shrinkWrap for better performance
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom > 0
                            ? 16 // Add small padding when keyboard is open
                            : 0,
                      ),
                      itemCount: recommendations.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            // Perform search when recommendation is tapped
                            ref
                                .read(recommendationsProvider.notifier)
                                .performSearch(recommendations[index]);
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                if (showRecommendations) ...[
                                  DesignIcon.icon(
                                    icon: Icons.history,
                                    color: Colors.grey,
                                    size: 20,
                                  ),
                                  Space.w(width: 8),
                                ],
                                Expanded(
                                  // Add Expanded to prevent text overflow
                                  child: Text(
                                    recommendations[index],
                                    style: DesignFonts.poppins.copyWith(
                                      fontSize: 14,
                                      color: const Color(0xFF444444),
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Handle long text
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      color: DesignColors.accent,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: EdgeInsets.all(16),
                  child: DesignText(
                    text: 'Error loading recommendations',
                    color: DesignColors.accent,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

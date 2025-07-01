import 'dart:async';
import 'dart:math';

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/widgets/chip.widgets.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/lobby_card.widgets.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/appDownloadCard.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/feedback/suggestion.dart';
import 'package:aroundu/views/filters/lobbyFilter.view.dart';
import 'package:aroundu/views/house/provider/houses_providers.dart';
import 'package:aroundu/views/house/provider/houses_providers_util.dart';
import 'package:aroundu/views/house/view_all_house_card.dart';
import 'package:aroundu/views/lobby/provider/add_your_interest_provider.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers_util.dart';
import 'package:aroundu/views/lobby/widgets/view_all_explore.dart';
import 'package:aroundu/views/notifications/notifications.view.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/search/search.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../dashboard/controller.dashboard.dart';
import '../dashboard/dashboard.view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HouseView extends ConsumerStatefulWidget {
  const HouseView({super.key});

  @override
  ConsumerState<HouseView> createState() => _HouseViewState();
}

class _HouseViewState extends ConsumerState<HouseView> {
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  List<House>? houses;
  bool isLiked = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // _fetchHouseData();
  }

  // Future<void> _fetchHouseData() async {
  //   try {
  //     final data = await fetchHouses();
  //     if (mounted) {
  //       setState(() {
  //         houses = data;
  //         print('House data fetched: $houses');
  //         isLoading = false;
  //       });
  //     }
  //   } catch (e) {
  //     print('Error fetching house data: $e');
  //     if (mounted) {
  //       setState(() {
  //         houses = [];
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        // appBar: const CustomAppBar(),
        body: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            try {
              await Get.delete<DashboardController>();
              await Get.delete<ProfileController>();
              Get.put(DashboardController());
              Get.put(ProfileController());
              // await ref
              //     .read(momentsWithParamsProvider((
              //       houseId: null,
              //       lobbyId: null,
              //       userId: null,
              //       followedMoments: true
              //     )).notifier)
              //     .fetchMoments();
              // await ref
              //     .read(announcementsProvider.notifier)
              //     .fetchAnnouncements();

              ref.invalidate(
                LobbyProviderUtil.getProvider(
                  ref.watch(checkOutLobbiesProvider),
                ),
              );

              ref.invalidate(HouseProviderUtil.getProvider(HouseType.followed));
              ref.invalidate(HouseProviderUtil.getProvider(HouseType.created));
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
                Container(
                  padding: EdgeInsets.only(
                    top: 48,
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
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              dashboardController.updateTabIndex(
                                4,
                              ); // Assuming 4 is the index for the profile section
                            },
                            child: Obx(
                              () => CircleAvatar(
                                radius: 24,
                                backgroundImage: NetworkImage(
                                  dashboardController.userProfilePicture.value,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () => DesignText(
                                  text: dashboardController.userName.value,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Obx(() {
                                if (dashboardController
                                    .userCity
                                    .value
                                    .isNotEmpty) {
                                  return Row(
                                    children: [
                                      DesignIcon.icon(
                                        icon: Icons.location_on,
                                        size: 12,
                                      ),
                                      DesignText(
                                        text:
                                            dashboardController.userCity.value,
                                        fontSize: 12,
                                      ),
                                    ],
                                  );
                                } else {
                                  return SizedBox.shrink();
                                }
                              }),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () {
                              FancyAppDownloadDialog.show(
                                context,
                                title: "Unlock Premium Features",
                                message:
                                    "Get the full AroundU experience with exclusive features, enhanced performance, and more!",
                                appStoreUrl:
                                    "https://apps.apple.com/in/app/aroundu/id6744299663",
                                playStoreUrl:
                                    "https://play.google.com/store/apps/details?id=com.polar.aroundu",
                                // cancelButtonText: "Maybe Later",
                                onCancel: () {
                                  print("User chose to skip download");
                                },
                              );
                              // HapticFeedback.selectionClick();
                              // Get.to(() => NotificationsView());
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: DesignColors.accent,
                                shape: BoxShape.circle,
                              ),
                              child: DesignIcon.icon(
                                icon: Icons.notifications_none_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
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
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      canRequestFocus: false,
                                      onTap: () {
                                        HapticFeedback.selectionClick();
                                        Get.toNamed(AppRoutes.search);
                                      },
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Search here....',
                                        hintStyle: DesignFonts.poppins.copyWith(
                                          color: DesignColors.primary
                                              .withOpacity(0.6),
                                          fontWeight: FontWeight.w400,
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
                              Get.toNamed(AppRoutes.filter);

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
                    ],
                  ),
                ),

                Space.h(height: 24),

                // const FeaturedMoments(),

                // const ShowAnnouncements(),
                const CheckOutLobbies(),
                Space.h(height: 34),

                // ReferBanner(
                //   title: 'Refer a Friend, Earn cash',
                //   subtitle: 'Invite a friend & earn ',
                //   rewardAmount: '₹200',
                //   buttonText: 'Refer a friend Now',
                //   onPressed: () {
                //     Get.to(() => ReferAndEarnScreen());
                //     // Your action here!
                //     // print('Refer button tapped!');
                //   },
                // ),
                const FollowedHouses(),
                Space.h(height: 34),

                const YourInterests(),
                Space.h(height: 34),

                const YourCreatedHouses(),
                Space.h(height: 34),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: SuggestionFormWidget(),
                ),
                Space.h(height: 0.2 * Get.height),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ViewedMomentsNotifier? _capturedMomentsNotifier;

// /// Featured Moments
// class FeaturedMoments extends ConsumerStatefulWidget {
//   const FeaturedMoments({super.key});

//   @override
//   ConsumerState<FeaturedMoments> createState() => _FeaturedMomentsState();
// }

// class _FeaturedMomentsState extends ConsumerState<FeaturedMoments> {
//   @override
//   void initState() {
//     super.initState();
//     // Capture the notifier reference in initState
//     _capturedMomentsNotifier = ref.read(viewedMomentsProvider.notifier);
//     Future.microtask(() => ref
//         .read(momentsWithParamsProvider((
//           houseId: null,
//           lobbyId: null,
//           userId: null,
//           followedMoments: true
//         )).notifier)
//         .fetchMoments());
//   }

//   @override
//   void dispose() {
//     print("Starting dispose featured moments");

//     // Use the captured notifier reference
//     final notifier = _capturedMomentsNotifier;

//     // Schedule execution with Timer but don't use ref
//     if (notifier != null) {
//       Timer(Duration(milliseconds: 100), () {
//         try {
//           notifier.sendViewedMomentsToApi();
//           print(
//               "Executed sendViewedMomentsToApi via Timer with captured notifier");
//         } catch (e) {
//           print("Error in Timer callback: $e");
//         }
//       });
//     }

//     // Call super.dispose()
//     super.dispose();

//     print("Super dispose called");
//   }

//   // Build shimmer loading effect for moments
//   Widget _buildShimmerLoading() {
//     return SizedBox(
//       width: double.infinity,
//       child: Padding(
//         padding: EdgeInsets.only(left: 16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             DesignText(
//               text: 'Featured Moments',
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w600,
//             ),
//             Space.h(height: 18.h),
//             SizedBox(
//               height: 0.112.sh,
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: ListView.builder(
//                   physics: const NeverScrollableScrollPhysics(),
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 5, // Show 5 shimmer items
//                   itemBuilder: (context, index) {
//                     return _buildMomentCircleShimmer();
//                   },
//                 ),
//               ),
//             ),
//             Space.h(height: 34.h),
//           ],
//         ),
//       ),
//     );
//   }

//   // Build shimmer effect for a single moment circle
//   Widget _buildMomentCircleShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey[300]!,
//       highlightColor: Colors.grey[100]!,
//       child: Container(
//         margin: EdgeInsets.only(right: 16.w),
//         height: 0.1.sh,
//         width: 0.2.sw,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(2),
//               decoration: const BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: Colors.white,
//               ),
//               child: Container(
//                 padding: const EdgeInsets.all(2),
//                 decoration: const BoxDecoration(
//                   color: Colors.white,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const CircleAvatar(
//                   radius: 32,
//                   backgroundColor: Colors.white,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 4),
//             Container(
//               height: 12.h,
//               width: 60.w,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(4.r),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final momentsState = ref.watch(momentsWithParamsProvider(
//         (houseId: null, lobbyId: null, userId: null, followedMoments: true)));

//     final viewedList = ref.watch(viewedMomentsProvider);

//     return momentsState.when(
//       loading: () => _buildShimmerLoading(), // Show shimmer loading effect
//       error: (error, stackTrace) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             DesignText(text: 'Something went wrong', fontSize: 12.sp),
//             ElevatedButton(
//               onPressed: () => ref
//                   .read(momentsWithParamsProvider((
//                     houseId: null,
//                     lobbyId: null,
//                     userId: null,
//                     followedMoments: true
//                   )).notifier)
//                   .fetchMoments(),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ), // Show nothing on error
//       data: (moments) {
//         if (moments.isEmpty) {
//           return const SizedBox.shrink(); // Show nothing when empty
//         }
//         print("Moments createdAt: ${moments.first.createdAt}");

//         return SizedBox(
//           width: double.infinity,
//           child: Padding(
//             padding: EdgeInsets.only(left: 16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 DesignText(
//                   text: 'Featured Moments',
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 Space.h(height: 18.h),
//                 SizedBox(
//                   height: 0.112.sh, //0.1.sh
//                   child: Align(
//                     alignment: Alignment.centerLeft,
//                     child: ListView.builder(
//                       physics: const BouncingScrollPhysics(),
//                       scrollDirection: Axis.horizontal,
//                       shrinkWrap: true,
//                       itemCount: moments.length,
//                       itemBuilder: (context, index) {
//                         final moment = moments[index];
//                         return MomentCircle(
//                           imageUrl: moment.media!.isNotEmpty
//                               ? moment.media!.first
//                               : "https://art.pixilart.com/sr2e207c7fa53aws3.png",
//                           username: moment.createdBy?.userName ?? "user name",
//                           isViewed: viewedList.contains(moment.id),
//                           onTap: () {
//                             // Get.to(() => MomentFullPageView(moments: moment));
//                             HapticFeedback.lightImpact();
//                             Get.to(() => CombinedMomentView(
//                                   currentPageIndex: index,
//                                   moments: moments,
//                                 ));
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 Space.h(height: 34.h), //14.h
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

// ViewedAnnouncementsNotifier? _capturedAnnouncementsNotifier;

// /// show Announcements
// class ShowAnnouncements extends ConsumerStatefulWidget {
//   const ShowAnnouncements({super.key});

//   @override
//   ConsumerState<ShowAnnouncements> createState() => _ShowAnnouncementsState();
// }

// class _ShowAnnouncementsState extends ConsumerState<ShowAnnouncements> {
//   @override
//   void initState() {
//     super.initState();
//     _capturedAnnouncementsNotifier =
//         ref.read(viewedAnnouncementsProvider.notifier);
//     Future.microtask(
//         () => ref.read(announcementsProvider.notifier).fetchAnnouncements());
//   }

//   @override
//   void dispose() {
//     print("Starting dispose featured announcements");

//     // Use the captured notifier reference
//     final notifier = _capturedAnnouncementsNotifier;

//     // Schedule execution with Timer but don't use ref
//     if (notifier != null) {
//       Timer(Duration(milliseconds: 100), () {
//         try {
//           notifier.sendViewedAnnouncementsToApi();
//           print(
//               "Executed sendViewedAnnouncementsToApi via Timer with captured notifier");
//         } catch (e) {
//           print("Error in Timer callback: $e");
//         }
//       });
//     }

//     // Call super.dispose()
//     super.dispose();

//     print("Super dispose called");
//   }

//   // Build shimmer loading effect for announcements
//   Widget _buildAnnouncementsShimmer() {
//     return Container(
//       width: double.infinity,
//       margin: EdgeInsets.only(bottom: 16.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w),
//             child: Row(
//               children: [
//                 Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Row(
//                     children: [
//                       Container(
//                         width: 20.sp,
//                         height: 20.sp,
//                         decoration: const BoxDecoration(
//                           color: Colors.white,
//                           shape: BoxShape.circle,
//                         ),
//                       ),
//                       SizedBox(width: 8.w),
//                       Container(
//                         height: 16.sp,
//                         width: 120.w,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(4.r),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Space.h(height: 16.h),
//           SizedBox(
//             height: 120.h,
//             child: ListView.builder(
//               physics: const NeverScrollableScrollPhysics(),
//               scrollDirection: Axis.horizontal,
//               itemCount: 3, // Show 3 shimmer items
//               padding: EdgeInsets.only(left: 16.w),
//               itemBuilder: (context, index) {
//                 return Shimmer.fromColors(
//                   baseColor: Colors.grey[300]!,
//                   highlightColor: Colors.grey[100]!,
//                   child: Container(
//                     margin: EdgeInsets.only(right: 16.w),
//                     width: 250.w,
//                     height: 120.h,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Space.h(height: 24.h),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final announcementsState = ref.watch(announcementsProvider);

//     return announcementsState.when(
//       loading: () => _buildAnnouncementsShimmer(),
//       error: (error, stackTrace) => Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline_rounded,
//               color: Colors.red[400],
//               size: 32.sp,
//             ),
//             Space.h(height: 8.h),
//             DesignText(
//               text: 'Failed to load announcements',
//               fontSize: 12.sp,
//               textAlign: TextAlign.center,
//             ),
//             Space.h(height: 8.h),
//             ElevatedButton(
//               onPressed: () =>
//                   ref.read(announcementsProvider.notifier).fetchAnnouncements(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: DesignColors.accent,
//                 foregroundColor: Colors.white,
//                 padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//               ),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ),
//       data: (announcements) {
//         if (announcements.isEmpty) {
//           return const SizedBox.shrink();
//         }

//         return Container(
//           width: double.infinity,
//           margin: EdgeInsets.only(bottom: 16.h),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 16.w),
//                 child: Row(
//                   children: [
//                     Row(
//                       children: [
//                         Icon(
//                           Icons.campaign_rounded,
//                           size: 20.sp,
//                           color: ColorsPalette.redColor,
//                         ),
//                         SizedBox(width: 8.w),
//                         DesignText(
//                           text: 'Announcements',
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     // TextButton.icon(
//                     //   onPressed: () {
//                     //     // Navigate to all announcements view
//                     //   },
//                     //   icon: Icon(
//                     //     Icons.arrow_forward_rounded,
//                     //     size: 16.sp,
//                     //     color: const Color(0xFF3E79A1),
//                     //   ),
//                     //   label: DesignText(
//                     //     text: "View All",
//                     //     fontSize: 12.sp,
//                     //     color: const Color(0xFF3E79A1),
//                     //   ),
//                     //   style: TextButton.styleFrom(
//                     //     padding: EdgeInsets.symmetric(horizontal: 8.w),
//                     //     minimumSize: Size.zero,
//                     //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),
//               Space.h(height: 16.h),
//               SizedBox(
//                 height: 120.h, // Reduced height for better proportion
//                 child: ListView.builder(
//                   physics: const BouncingScrollPhysics(),
//                   scrollDirection: Axis.horizontal,
//                   itemCount: announcements.length,
//                   padding: EdgeInsets.only(left: 16.w),
//                   itemBuilder: (context, index) {
//                     final announcement = announcements[index];
//                     return GestureDetector(
//                       onTap: () {
//                         HapticFeedback.lightImpact();
//                         if (announcement != null) {
//                           Get.to(() => CombinedAnnouncementView(
//                                 announcements: announcements,
//                                 currentPageIndex: index,
//                               ));
//                         }
//                       },
//                       child: AnnouncementCardSmallView(
//                         headline: announcement.title ?? "No Title",
//                         imageUrl: announcement.media != null &&
//                                 announcement.media!.isNotEmpty
//                             ? announcement.media!.first
//                             : "https://via.placeholder.com/150",
//                         houseName: announcement.houseDetail?.name ?? "No House",
//                         stackImageUrl: announcement.houseDetail?.profilePhoto ??
//                             "https://via.placeholder.com/150",
//                         description:
//                             announcement.description ?? "No Description",
//                         announcement: announcement,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Space.h(height: 24.h),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }

final checkOutLobbiesProvider = StateProvider<LobbyType>(
  (ref) => LobbyType.myLobbies,
);

/// CheckOutLobbies
class CheckOutLobbies extends ConsumerStatefulWidget {
  const CheckOutLobbies({super.key});

  @override
  ConsumerState<CheckOutLobbies> createState() => _CheckOutLobbiesState();
}

class _CheckOutLobbiesState extends ConsumerState<CheckOutLobbies> {
  // Build shimmer loading effect for lobbies
  Widget _buildLobbiesShimmer() {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 16,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Space.h(height: 16),
                Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Row(
                    children: [
                      Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Space.w(width: 8),
                      Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Space.w(width: 8),
                      Container(
                        height: 24,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                Space.h(height: 16),
              ],
            ),
          ),
          SizedBox(
            height: 231,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 3, // Show 3 shimmer items
              padding: EdgeInsets.symmetric(horizontal: 12),
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == 2 ? 12 : 16,
                    bottom: 8,
                  ),
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      width: 0.75 * Get.width,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lobbyType = ref.watch(checkOutLobbiesProvider);
    final yourLobbies = ref.watch(LobbyProviderUtil.getProvider(lobbyType));
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DesignText(
                  text: 'Check out Lobbies',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                Space.h(height: 16),
                Row(
                  children: [
                    DesignChip.medium(
                      title: "My lobbies",
                      isSelected: (lobbyType == LobbyType.myLobbies),
                      fontSize: 10,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (lobbyType != LobbyType.myLobbies) {
                          ref.read(checkOutLobbiesProvider.notifier).state =
                              LobbyType.myLobbies;
                        }
                      },
                    ),
                    Space.w(width: 8),
                    DesignChip.medium(
                      title: "Joined",
                      isSelected: (lobbyType == LobbyType.joined),
                      fontSize: 10,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (lobbyType == LobbyType.joined) {
                          ref.read(checkOutLobbiesProvider.notifier).state =
                              LobbyType.myLobbies;
                        } else {
                          ref.read(checkOutLobbiesProvider.notifier).state =
                              LobbyType.joined;
                        }
                      },
                    ),
                    Space.w(width: 8),
                    DesignChip.medium(
                      title: "Saved",
                      isSelected: (lobbyType == LobbyType.saved),
                      fontSize: 10,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (lobbyType == LobbyType.saved) {
                          ref.read(checkOutLobbiesProvider.notifier).state =
                              LobbyType.myLobbies;
                        } else {
                          ref.read(checkOutLobbiesProvider.notifier).state =
                              LobbyType.saved;
                        }
                      },
                    ),
                  ],
                ),
                Space.h(height: 16),
              ],
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final scrollController = ScrollController();
              return switch (yourLobbies) {
                AsyncData(:final List<Lobby> value) =>
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
                                      hasCoverImage: lobby.mediaUrls.isNotEmpty,
                                    ),
                                  ),
                                );
                              },
                            ),

                            Positioned(
                              right: 0,
                              bottom:
                                  (min(231, constraints.maxHeight * 0.6)) / 2,
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
                              bottom:
                                  (min(231, constraints.maxHeight * 0.6)) / 2,
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
                        ),
                      )
                      : GestureDetector(
                        onTap: () => dashboardController.updateTabIndex(1),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 40, bottom: 32),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCFCFC),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  DesignText(
                                    text: 'View suggestions',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF3E79A1),
                                  ),
                                  Space.h(height: 8),
                                  DesignText(
                                    text: 'Get suggestion for lobbies',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  Space.h(height: 2),
                                  DesignText(
                                    text:
                                        'We can suggest you lobbies based on interests ',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff989898),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                AsyncError() => Center(
                  child: DesignText(
                    text: 'Oops, something unexpected happened',
                    fontSize: 12,
                  ),
                ),
                _ => _buildLobbiesShimmer(),
              };
            },
          ),
        ],
      ),
    );
  }
}

/// FollowedHouses
class FollowedHouses extends ConsumerStatefulWidget {
  const FollowedHouses({super.key});

  @override
  ConsumerState<FollowedHouses> createState() => _FollowedHousesState();
}

class _FollowedHousesState extends ConsumerState<FollowedHouses> {
  // Build shimmer loading effect for followed houses
  Widget _buildFollowedHousesShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: 18,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
        Space.h(height: 16),
        SizedBox(
          height: 231,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Show 3 shimmer items
            padding: EdgeInsets.symmetric(horizontal: 12),
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 12 : 16,
                  bottom: 8,
                ),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 0.75 * Get.width,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final DashboardController dashboardController =
        Get.find<DashboardController>();
    final yourHouses = ref.watch(
      HouseProviderUtil.getProvider(HouseType.followed),
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
                          text: "Followed Houses",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (value.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.toNamed(
                              AppRoutes.viewAllHouses,
                              arguments: {
                                'title': "Followed Houses",
                                'houses': value,
                              },
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
                  Space.h(height: 16),
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
                      : Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        child: GestureDetector(
                          onTap: () => dashboardController.updateTabIndex(1),
                          child: Center(
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.only(top: 48, bottom: 40),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCFCFC),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    spreadRadius: 1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Space.h(height: 56.h),
                                  DesignText(
                                    text: 'Discover houses',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF3E79A1),
                                  ),
                                  Space.h(height: 2),
                                  DesignText(
                                    text: 'You have not joined any houses',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xff989898),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),
              AsyncError() => SizedBox(
                width: 1,
                child: Center(
                  child: DesignText(
                    text: 'Oops, something unexpected happened',
                    fontSize: 12,
                  ),
                ),
              ),
              _ => _buildFollowedHousesShimmer(),
            },
            // Space.h(height: 34.h),
          ],
        );
      },
    );
  }
}

/// YourInterests
class YourInterests extends ConsumerStatefulWidget {
  const YourInterests({super.key});

  @override
  ConsumerState<YourInterests> createState() => _YourInterestsState();
}

class _YourInterestsState extends ConsumerState<YourInterests> {
  // Build shimmer loading effect for interests
  Widget _buildInterestsShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 16,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        Space.h(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            8,
            (index) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 32,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // final ProfileController profileController = Get.find<ProfileController>();
    final ProfileController profileController = Get.put(ProfileController());
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 12),
      child: Obx(() {
        if (profileController.isLoading.value) {
          return _buildInterestsShimmer();
        }
        ProfileModel? profile = profileController.profileData.value;
        if (profile == null) {
          // If no data is found, show shimmer effect as fallback UI
          return _buildInterestsShimmer();
        }

        // Fetch and store all subcategories
        List<SubCategoryWithColor> allSubCategories =
            profile.userInterests
                .expand(
                  (interest) => interest.subCategories.map(
                    (subCategory) => SubCategoryWithColor(
                      subCategory,
                      interest.category.bgColor ??
                          "EAEFF2", // Default color if bgColor is null
                    ),
                  ),
                )
                .toList();

        // Limit to 8 subcategories for display
        List<SubCategoryWithColor> displayedSubCategories =
            allSubCategories.take(8).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DesignText(
                  text: 'Your interests',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                // if (allSubCategories.length > 8)
                //   GestureDetector(
                //     onTap: () {
                //       HapticFeedback.selectionClick();
                //       //TODO: uncomment this

                //       // Get.to(
                //       //   () => ViewAllUserInterestsPage(
                //       //     userInterests: profile.userInterests,
                //       //   ),
                //       // );
                //     },
                //     child: DesignText(
                //       text: 'View all',
                //       fontSize: 12,
                //       color: const Color(0xFF3E79A1),
                //     ),
                //   ),
              ],
            ),
            Space.h(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Display up to 8 subcategories as chips
                ...displayedSubCategories.map((data) {
                  Color bgColor = const Color(0xFFEAEFF2);
                  return DesignChip.filled(
                    fontSize: 14,
                    title: data.subCategory.name,
                    borderColor: bgColor,
                    filledColor: bgColor,
                  );
                }),

                // "+ Add" option for adding interests
                DesignChip.medium(
                  fontSize: 14,
                  title: "+ Add",
                  borderColor: const Color(0xFF3E79A1),
                  textColor: const Color(0xFF3E79A1),
                  onTap: () {
                    // HapticFeedback.selectionClick();
                    FancyAppDownloadDialog.show(
                      context,
                      title: "Unlock Premium Features",
                      message:
                          "Get the full AroundU experience with exclusive features, enhanced performance, and more!",
                      appStoreUrl:
                          "https://apps.apple.com/in/app/aroundu/id6744299663",
                      playStoreUrl:
                          "https://play.google.com/store/apps/details?id=com.polar.aroundu",
                      // cancelButtonText: "Maybe Later",
                      onCancel: () {
                        print("User chose to skip download");
                      },
                    );
                    //TODO: uncomment this

                    // Get.to(
                    //   () =>
                    //       AddYourInterest(userInterests: profile.userInterests),
                    // );
                  },
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}

/// YourCreatedHouses
class YourCreatedHouses extends ConsumerStatefulWidget {
  const YourCreatedHouses({super.key});

  @override
  ConsumerState<YourCreatedHouses> createState() => _YourCreatedHousesState();
}

class _YourCreatedHousesState extends ConsumerState<YourCreatedHouses> {
  // Build shimmer loading effect for created houses
  Widget _buildCreatedHousesShimmer() {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 16,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                height: 20,
                width: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Space.h(height: 16),
        SizedBox(
          height: sh(0.3),
          width: 1,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 3, // Show 3 shimmer items
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Padding(
                padding: EdgeInsets.only(right: 8),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Use the provider to fetch created houses
    final yourHouses = ref.watch(
      HouseProviderUtil.getProvider(HouseType.created),
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
                          text: "Followed Houses",
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      if (value.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Get.toNamed(
                              AppRoutes.viewAllHouses,
                              arguments: {
                                'title': "Followed Houses",
                                'houses': value,
                              },
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
                  Space.h(height: 16),
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
                      : Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 12,
                        ),
                        child: Center(
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(top: 48, bottom: 40),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCFCFC),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 1,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Space.h(height: 56.h),
                                DesignText(
                                  text: 'Houses not found',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF3E79A1),
                                ),
                                Space.h(height: 2),
                                DesignText(
                                  text: 'You have not created any houses',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xff989898),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
              AsyncError() => SizedBox(
                width: 1,
                child: Center(
                  child: DesignText(
                    text: 'Oops, something unexpected happened',
                    fontSize: 12,
                  ),
                ),
              ),
              _ => _buildCreatedHousesShimmer(),
            },
            // Space.h(height: 34.h),
          ],
        );
      },
    );
  }
}

class AddYourInterest extends ConsumerWidget {
  const AddYourInterest({super.key, required this.userInterests});
  final List<UserInterest> userInterests;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use provider.family to pass userInterests directly
    final state = ref.watch(addYourInterestProvider(userInterests));
    final notifier = ref.read(addYourInterestProvider(userInterests).notifier);
    // final category = ref.watch(categoryProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 24,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC4B5D),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed:
              state.isLoading
                  ? null
                  : () async {
                    await notifier.updateUserInterests();

                    if (!state.isLoading) {
                      Navigator.pop(context);
                    }
                  },
          child:
              state.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : DesignText(
                    text: "Save",
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: DesignText(
                      text: 'Cancel',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF3E79A1),
                    ),
                  ),
                ],
              ),
              Space.h(height: 40),
              DesignText(
                text: 'Which category best describes you?',
                fontSize: 20,
                fontWeight: FontWeight.w500,
                maxLines: 2,
              ),
              Space.h(height: 2),
              DesignText(
                text: 'It will help us to find perfect Recommendations for you',
                fontSize: 12,
                color: const Color(0xff444444),
                maxLines: 2,
              ),
              Space.h(height: 20),

              // Selected Interests Section
              if (state.selectedSubcategories.isNotEmpty) ...[
                DesignText(
                  text: "Selected Interests",
                  fontSize: 14,
                  color: DesignColors.secondary,
                ),
                Space.h(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children:
                      state.selectedSubcategories.map((subCategory) {
                        return DesignChip.medium(
                          title: "${subCategory.iconUrl} ${subCategory.name}",
                          isSelected: true,
                          showCloseAction: true,
                          onTap: () {
                            notifier.toggleSubcategory(subCategory);
                          },
                        );
                      }).toList(),
                ),
                Space.h(height: 16),
              ],

              // Categories Section
              DesignText(
                text: "Categories",
                fontSize: 14,
                color: DesignColors.secondary,
              ),
              Space.h(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    state.availableCategories.map((category) {
                      final isSelected = state.selectedCategories.contains(
                        category,
                      );
                      return DesignChip.medium(
                        title: "${category.iconUrl} ${category.name}",
                        isSelected: isSelected,
                        onTap: () {
                          notifier.toggleCategory(category);

                          // Toggle all subcategories under this category
                          for (final subCategory
                              in category.subCategoryInfoList) {
                            notifier.toggleSubcategory(subCategory);
                          }
                        },
                      );
                    }).toList(),
              ),

              // Subcategories Section
              ...state.availableCategories.map((category) {
                if (category.subCategoryInfoList.isEmpty) {
                  return const SizedBox();
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Space.h(height: 16),
                    DesignText(
                      text: "${category.name} Subcategories",
                      fontSize: 14,
                      color: DesignColors.secondary,
                    ),
                    Space.h(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children:
                          category.subCategoryInfoList.map((subCat) {
                            final isSelected = state.selectedSubcategories
                                .contains(subCat);
                            return DesignChip.medium(
                              title: "${subCat.iconUrl} ${subCat.name}",
                              isSelected: isSelected,
                              onTap: () {
                                notifier.toggleSubcategory(subCat);
                              },
                            );
                          }).toList(),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class MomentCircle extends ConsumerWidget {
  final String imageUrl;
  final String username;
  final bool isViewed;
  final VoidCallback onTap;

  const MomentCircle({
    super.key,
    required this.imageUrl,
    required this.username,
    this.isViewed = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 16), //w
        height: 0.1 * screenHeight,
        width: 0.2 * screenWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(2), // r
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    isViewed
                        ? null
                        : const LinearGradient(
                          colors: [
                            Color(0xFFE1306C),
                            Color(0xFFFD1D1D),
                            Color(0xFFF56040),
                          ],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
              ),
              child: Container(
                padding: const EdgeInsets.all(2), //r
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 32, //r
                  backgroundImage: NetworkImage(imageUrl),
                ),
              ),
            ),
            const SizedBox(height: 4),
            DesignText(
              text: username,
              fontSize: 12,
              maxLines: 1,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class SubCategoryWithColor {
  final SubCategory subCategory;
  final String? bgColor;

  SubCategoryWithColor(this.subCategory, this.bgColor);
}

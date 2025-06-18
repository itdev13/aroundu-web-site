import 'dart:math';

import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/category.chip.dart';
import 'package:aroundu/designs/widgets/chip.widgets.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/utils/api_service/api_service.dart' as apiService;
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/lobby/provider/save_lobby_provider.dart';
import 'package:aroundu/views/lobby/widgets/rich_text_display.dart';
import 'package:aroundu/views/profile/controllers/controller.groups.profiledart.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/profile/public_profile/controller.public.profile.dart';
import 'package:aroundu/views/temp/tempHoseDetailsView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';

import '../../designs/colors.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../models/lobby.dart';

final isHouseSavedProvider = StateProvider.family<bool, String>(
  (ref, houseId) => false,
);

class ViewAllHouseCard extends ConsumerStatefulWidget {
  final House house;
  final Function onHouseDeleted;

  const ViewAllHouseCard({
    super.key,
    required this.house,
    required this.onHouseDeleted,
  });

  @override
  ConsumerState<ViewAllHouseCard> createState() => _ViewAllHouseCardState();
}

class _ViewAllHouseCardState extends ConsumerState<ViewAllHouseCard> {
  final groupController = Get.put(GroupController());
  final profileController = Get.put(ProfileController());
  final publicProfileController = Get.put(PublicProfileController());
  // final ChatsController chatController = Get.put(ChatsController());
  // final ChatsController chatController = Get.isRegistered<ChatsController>()
  //     ? Get.find<ChatsController>()
  //     : Get.put(ChatsController());
  bool isFollowing = false;
  Color getRandomColor() {
    final random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  Future<void> _onHouseLikeTap() async {
    final houseId = widget.house.id ?? "";
    // Call the provider to toggle the bookmark and pass current isSaved value
    await ref.read(
      toggleBookmarkProvider(
        itemId: houseId,
        isSaved: (ref.read(isHouseSavedProvider(houseId))),
        entityType: "HOUSE",
      ).future,
    );

    // After API call, toggle the local isSaved state
    ref.read(isHouseSavedProvider(houseId).notifier).state =
        !ref.read(isHouseSavedProvider(houseId));
  }

  @override
  void initState() {
    final houseId = widget.house.id ?? "";
    Future.microtask(() {
      ref.read(isHouseSavedProvider(houseId).notifier).state =
          widget.house.isSaved ?? false;
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final houseId = widget.house.id ?? "";
    final isSaved = ref.watch(isHouseSavedProvider(houseId));
    List<UserSummary> userSummaries =
        (widget.house.userSummaries != null)
            ? widget.house.userSummaries!.take(4).toList()
            : [];
    List<Color> userSummariesBgColors = [
      Color(0xFFC3E9F7),
      Color(0xFFCACDFF),
      Color(0xFFF7D7A9),
      Color(0xFFD3F0BE),
    ];
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return GestureDetector(
      onTap: () async {
        // Show loading dialog
        // showDialog(
        //   context: context,
        //   barrierDismissible: false,
        //   builder: (BuildContext context) {
        //     return AlertDialog(
        //       backgroundColor: Colors.transparent,
        //       content: Center(
        //         child: CircularProgressIndicator(
        //           color: DesignColors.accent,
        //         ),
        //       ),
        //     );
        //   },
        // );

        // try {
        // final houseDetails = await _getHouseDetailedData(houseId: houseId);

        // Always close the dialog regardless of the result
        // if (Navigator.canPop(context)) {
        //   Navigator.of(context, rootNavigator: true).pop();
        // }

        // if (houseDetails != null) {
        HapticFeedback.selectionClick();
        Get.to(() => HouseDetailsView());
        //TODO : add this house detail page

        // await Get.to(
        //   () => HouseDetailPage(
        //     // house: houseDetails,
        //     houseId: houseId,
        //   ),
        // );
        // } else {
        //   Fluttertoast.showToast(msg: "House Not Found !!!");
        // }
        // } catch (e, stack) {
        //   // Ensure dialog is closed in case of error
        //   if (Navigator.canPop(context)) {
        //     Navigator.of(context, rootNavigator: true).pop();
        //   }

        //   print("Error fetching house details: $e \n $stack");
        //   Fluttertoast.showToast(msg: "Error loading house details");
        // }
      },
      child: Card(
        shadowColor: ColorsPalette.lightGrayColor,
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SizedBox(
          width: sw(0.9),
          // height: 0.235.sh,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    child:
                        (widget.house.photos?.isNotEmpty ?? false)
                            ? Image.network(
                              widget.house.photos!.first,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              height: 138,
                              loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child; // The image is fully loaded.
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return Container(
                                  color: Colors.grey,
                                  width: double.infinity,
                                  height: 138,
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                );
                              },
                            )
                            : Container(
                              width: double.infinity,
                              height: 138,
                              color: Colors.grey,
                              child: const Center(
                                child: Text(
                                  'No Image Available',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: CustomChip(
                      textColor: Colors.white,
                      // borderColor: Colors.transparent,
                      // textColor: Colors.white,
                      text:
                          (widget.house.subCategories!.isNotEmpty)
                              ? widget.house.subCategories?.first.name ??
                                  'No Name'
                              : 'No Name',
                      color: const Color.fromARGB(103, 217, 217, 217),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Row(
                      children: [
                        // //house share
                        // GestureDetector(
                        //   onTap: () async {
                        //     await groupController.fetchGroups();
                        //     await profileController.getFriends();
                        //     await shareHouseBottomSheet(context);
                        //   },
                        //   child: Container(
                        //     padding: const EdgeInsets.all(8),
                        //     decoration: BoxDecoration(
                        //       color: Colors.black.withOpacity(0.4),
                        //       shape: BoxShape.circle,
                        //     ),
                        //     child: const Icon(
                        //       Icons.share,
                        //       color: Colors.white,
                        //       size: 18,
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(width: 8),
                        //house like
                        GestureDetector(
                          onTap: () async {
                            await _onHouseLikeTap();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSaved ? Icons.favorite : Icons.favorite_border,
                              color:
                                  isSaved ? DesignColors.accent : Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (userSummaries.isNotEmpty)
                    Positioned(
                      bottom: 5,
                      right: 0,
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: SizedBox(
                              // color: Colors.red.shade300,
                              width:
                                  (userSummaries.length == 1)
                                      ? 24
                                      : (userSummaries.length == 2)
                                      ? 44
                                      : (userSummaries.length == 3)
                                      ? 60
                                      : 78,
                              height: 28,
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                clipBehavior: Clip.none,
                                children: [
                                  for (int i = 0; i < userSummaries.length; i++)
                                    Positioned(
                                      left: i * 16,
                                      child: CircleAvatar(
                                        radius: 14,
                                        backgroundColor:
                                            userSummariesBgColors[i],
                                        // backgroundColor: Colors.grey[300],
                                        child:
                                            i == 3
                                                ? DesignText(
                                                  text:
                                                      "+${widget.house.followerCount! - 3}",
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(
                                                    0xFF323232,
                                                  ),
                                                )
                                                : ClipOval(
                                                  child: Image.network(
                                                    userSummaries[i]
                                                        .profilePictureUrl,
                                                    fit: BoxFit.cover,
                                                    width: 28,
                                                    height: 28,
                                                    errorBuilder:
                                                        (
                                                          context,
                                                          error,
                                                          stackTrace,
                                                        ) => Icon(
                                                          Icons.person,
                                                          size: 16,
                                                          color: const Color(
                                                            0xFF323232,
                                                          ),
                                                        ),
                                                    loadingBuilder:
                                                        (
                                                          context,
                                                          child,
                                                          loadingProgress,
                                                        ) =>
                                                            loadingProgress ==
                                                                    null
                                                                ? child
                                                                : const Center(
                                                                  child: CircularProgressIndicator(
                                                                    color:
                                                                        DesignColors
                                                                            .accent,
                                                                  ),
                                                                ),
                                                  ),
                                                ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DesignText(
                                  text: widget.house.name ?? "No Title",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF444444),
                                ),
                              ),
                            ],
                          ),
                          RichTextDisplay(
                            controller: TextEditingController(
                              text:
                                  widget.house.description ?? "No Description",
                            ),
                            hintText: '',
                            maxHeight: 24,
                            fontSize: 10,
                          ),
                          Row(
                            children: [
                              // Expanded(
                              //   child: DesignText(
                              //     text: widget.house.description ??
                              //         "No Description",
                              //     fontSize: 10,
                              //     fontWeight: FontWeight.w400,
                              //     maxLines: (userSummaries.isNotEmpty) ? 1 : 2,
                              //     color: Color(0xFF323232),
                              //   ),
                              // ),
                            ],
                          ),
                        ],
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

import 'dart:math';

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/views/lobby/provider/save_lobby_provider.dart';
import 'package:aroundu/views/profile/controllers/controller.groups.profiledart.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/profile/public_profile/controller.public.profile.dart';
import 'package:aroundu/views/profile/user_profile_followed_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../colors.designs.dart';
import '../icons.designs.dart';
import 'chip.widgets.designs.dart';
import 'icon.widget.designs.dart';
import 'space.widget.designs.dart';
import 'text.widget.designs.dart';

class DesignLobbyWidget extends ConsumerStatefulWidget {
  final bool hasJoined;
  final Lobby lobby;
  final bool hasCoverImage;

  const DesignLobbyWidget({
    super.key,
    required this.lobby,
    this.hasJoined = false,
    this.hasCoverImage = false,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DesignLobbyWidgetState();
}

class _DesignLobbyWidgetState extends ConsumerState<DesignLobbyWidget> {
  late bool isSaved;

  final groupController = Get.put(GroupController());
  final profileController = Get.put(ProfileController());
  final publicProfileController = Get.put(PublicProfileController());
  // final ChatsController chatController = Get.isRegistered<ChatsController>()
  //     ? Get.find<ChatsController>()
  //     : Get.put(ChatsController());

  @override
  void initState() {
    super.initState();
    // Set the initial state based on the lobby's saved status
    isSaved = widget.lobby.isSaved;
  }

  // Function to handle bookmark toggle on tap
  Future<void> _onBookmarkTap() async {
    // Call the provider to toggle the bookmark and pass current isSaved value
    await ref.read(
      toggleBookmarkProvider(
        itemId: widget.lobby.id,
        isSaved: isSaved,
        entityType: "LOBBY",
      ).future,
    );

    // After API call, toggle the local isSaved state
    setState(() {
      isSaved = !isSaved;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lobby = widget.lobby;
    List<UserSummary> userSummaries =
        (lobby.userSummaries != null)
            ? lobby.userSummaries!.take(4).toList()
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
        HapticFeedback.selectionClick();
        await Navigator.pushNamed(
          context,
          AppRoutes.lobby.replaceAll(':lobbyId', lobby.id),
        );
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: DesignText(
                text: "Lobby Information",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              content: Wrap(
                spacing: 24.0, // Horizontal space between items
                runSpacing: 12, // Vertical space between rows
                children:
                    (() {
                      final sortedItems = List.from(lobby.compactItems);
                      return sortedItems.map((item) {
                        if (item.content != "") {
                          return SizedBox(
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: DesignText(
                                text: "${item.iconUrl ?? '🔄'} ${item.content}",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }).toList();
                    })(), // Immediately invoked function to return the sorted children
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: DesignText(
                    text: "Close",
                    fontSize: 14,
                    color: const Color(0xFF3E79A1),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        width: sw(0.9), // Use 90% of the screen width for the whole container
        height: sh(0.248), // 235
        decoration: BoxDecoration(
          // color: lobby.colorScheme.bg,
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2), // Very light shadow
              spreadRadius: 0,
              blurRadius: 4,
              offset: const Offset(0, 2), // Slight shadow below
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  child: Image.network(
                    (widget.hasCoverImage)
                        // ? (widget.lobby.mediaUrls.first != "1")
                        ? widget.lobby.mediaUrls.first
                        // : "https://media.istockphoto.com/id/1329350253/vector/image-vector-simple-mountain-landscape-photo-adding-photos-to-the-album.jpg?s=612x612&w=0&k=20&c=3iXykf5ZQI2eBo0DaQ7W-e_8E5rhFEammFqO9XCisnI="
                        : "https://media.istockphoto.com/id/1329350253/vector/image-vector-simple-mountain-landscape-photo-adding-photos-to-the-album.jpg?s=612x612&w=0&k=20&c=3iXykf5ZQI2eBo0DaQ7W-e_8E5rhFEammFqO9XCisnI=",
                    fit: BoxFit.cover,
                    width: sw(0.9),
                    height: 136,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: sw(0.9),
                        height: 136,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_rounded,
                            color: Colors.grey,
                            size: 40,
                          ),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: sw(0.9),
                        height: 136,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),

                // top row on card - category, share, save
                Positioned(
                  top: (lobby.hasOffer) ? 0 : 8,
                  left: (lobby.hasOffer) ? 0 : 8,
                  right: 8,
                  child: SizedBox(
                    width: sw(0.9),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (lobby.hasOffer) ...[
                          Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Image.asset(
                                "assets/images/offer.png",
                                height: 56,
                                width: 44,
                              ),
                              Positioned(
                                top: 10,
                                left: 2,
                                right: 2,
                                child: DesignText(
                                  text: "Offers inside",
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  textAlign: TextAlign.center,
                                  color: Colors.white,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                        ],
                        DesignChip.filled(
                          title:
                              (lobby.filter.subCategoryName.length <= 20)
                                  ? lobby.filter.subCategoryName
                                  : '${lobby.filter.subCategoryName.substring(0, 20)}...',
                          borderColor: lobby.colorScheme.border,
                          filledColor: lobby.colorScheme.bg,
                          fontSize: 10,
                        ),
                        const SizedBox(width: 4),
                        DesignChip.filled(
                          title: "${widget.lobby.membersRequired} slots left",
                          textColor:
                              widget.lobby.activity == 'HIGH'
                                  ? const Color(0xFFEC4B5D)
                                  : Colors.green,
                          borderColor:
                              widget.lobby.activity == 'HIGH'
                                  ? const Color(0xFFEC4B5D)
                                  : Colors.green,
                          filledColor: const Color(0xFFEAEFF2),
                          fontSize: 10,
                          trailingIcon:
                              widget.lobby.activity == 'HIGH'
                                  ? DesignIcon.custom(
                                    icon: DesignIcons.rocket,
                                    size: 12,
                                    color: const Color(0xFFEC4B5D),
                                  )
                                  : null,
                        ),
                        const Spacer(),
                        // InkWell(
                        //   onTap: () async {
                        //     await ShareUtility.showShareBottomSheet(
                        //       context: context,
                        //       entityType: EntityType.lobby,
                        //       entity: lobby,
                        //     );

                        //     // await groupController.fetchGroups();
                        //     // await profileController.getFriends();
                        //     // await shareLobbyBottomSheet(context);
                        //   },
                        //   child: CircleAvatar(
                        //     radius: 14,
                        //     backgroundColor: const Color(0x4DFAF9F9),
                        //     child: DesignIcon.icon(
                        //       icon: Icons.share,
                        //       size: 18,
                        //       color: Colors.white,
                        //     ),
                        //   ),
                        // ),
                        // const Space.w(width: 12),
                        InkWell(
                          onTap: _onBookmarkTap, // Toggle bookmark on tap
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: const Color(0x4DFAF9F9),
                            child: DesignIcon.icon(
                              icon:
                                  isSaved
                                      ? FontAwesomeIcons.solidBookmark
                                      : FontAwesomeIcons.bookmark,
                              size: 16,
                              color:
                                  isSaved ? DesignColors.accent : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // bottom row on card - price, profile picture
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: SizedBox(
                    width: sw(0.9),
                    child: Row(
                      children: [
                        DesignChip.filled(
                          filledColor: Colors.white,
                          fontSize: 12,
                          title:
                              widget.lobby.priceDetails?.price == 0.0
                                  ? "Free"
                                  : "${widget.lobby.priceDetails?.price}",
                          textColor: const Color(0xFF3E79A1),
                        ),
                        Space.w(width: 8),
                        // if (widget.lobby.userStatus == "ADMIN")
                        //   GestureDetector(
                        //     onTap: () {
                        //       // Navigate to the crop screen on tap
                        //       Get.to(() => ImageCropScreen(
                        //             imageUrl: widget.lobby.mediaUrls.first,
                        //             lobby: lobby,
                        //           ));
                        //     },
                        //     child: CircleAvatar(
                        //       backgroundColor: Colors.white70,
                        //       radius: 14,
                        //       child: Icon(
                        //         Icons.edit,
                        //         size: 16,
                        //       ),
                        //     ),
                        //   ),
                        const Spacer(),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: SizedBox(
                            // color: Colors.red.shade300,
                            width:
                                (userSummaries.length == 1)
                                    ? 12
                                    : (userSummaries.length == 2)
                                    ? 28
                                    : (userSummaries.length == 3)
                                    ? 44 //48
                                    : 60,
                            height: 24,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                for (int i = 0; i < userSummaries.length; i++)
                                  Positioned(
                                    left: i * 14,
                                    child: CircleAvatar(
                                      radius: 12,
                                      // backgroundColor: const Color(0xFFEAEFF2),
                                      backgroundColor: userSummariesBgColors[i],
                                      child:
                                          i == 3
                                              ? DesignText(
                                                text:
                                                    "+${lobby.currentMembers - 3}",
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                                color: const Color(0xFF323232),
                                              )
                                              : ClipOval(
                                                child: Image.network(
                                                  userSummaries[i]
                                                      .profilePictureUrl,
                                                  fit: BoxFit.cover,
                                                  width: 24,
                                                  height: 24,
                                                  errorBuilder:
                                                      (
                                                        context,
                                                        error,
                                                        stackTrace,
                                                      ) => Icon(
                                                        Icons.person,
                                                        size: 14,
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
                        // GestureDetector(
                        //   onTap: () async {
                        //     if (lobby.adminSummary.userId != "") {
                        //       Get.to(
                        //         () => PublicProfileView(
                        //           userId: lobby.adminSummary.userId,
                        //           // isFriend: lobby.adminSummary.isFriend,
                        //           // isRequestSent: lobby.adminSummary.requestSent,
                        //           // isRequestReceived:
                        //           //     lobby.adminSummary.requestReceived,
                        //         ),
                        //       );
                        //     }
                        //   },
                        //   child: CircleAvatar(
                        //     backgroundColor: Colors.white,
                        //     radius: 15,
                        //     child: Image.network(
                        //       lobby.adminSummary.profilePicture,
                        //       fit: BoxFit.cover,
                        //       errorBuilder: (context, error, stackTrace) {
                        //         return Icon(
                        //           Icons.person,
                        //           size: 14.sp,
                        //         );
                        //       },
                        //       loadingBuilder:
                        //           (context, child, loadingProgress) {
                        //         if (loadingProgress == null) return child;
                        //         return const Center(
                        //           child: CircularProgressIndicator(
                        //             strokeWidth: 2,
                        //           ),
                        //         );
                        //       },
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // The column that contains the rest of the content
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(top: 4, bottom: 4, left: 8, right: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: DesignText(
                            text: lobby.title,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            maxLines: 1,
                          ),
                        ),
                        Row(
                          children: [
                            Space.w(width: 8),
                            DesignText(
                              text:
                                  lobby.lobbyType == "PRIVATE"
                                      ? "Private"
                                      : "Public",
                              color: const Color(0xFF444444),
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                            ),
                            Space.w(width: 4),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String infoText =
                                        lobby.lobbyType == "PRIVATE"
                                            ? "This is a private lobby. You need to request access from the admin. Once approved, complete the payment (if required) to join."
                                            : "This is a public lobby. You can join and participate instantly.";
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: DesignText(
                                        text:
                                            "${lobby.lobbyType.capitalize!} Lobby Information",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      content: DesignText(
                                        text: infoText,
                                        fontSize: 14,
                                        color: const Color(0xFF444444),
                                        maxLines: 10,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: DesignText(
                                            text: "Close",
                                            fontSize: 14,
                                            color: const Color(0xFF3E79A1),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: DesignIcon.icon(
                                icon: Icons.info_outline_rounded,
                                size: 14,
                                color: const Color(0xFF3E79A1),
                              ),
                            ),
                            Space.w(width: 8),
                          ],
                        ),
                      ],
                    ),
                    Space.h(height: sh(0.005)),

                    // Adjust the Wrap to fit two items per row without overflowing
                    Row(
                      children: [
                        widget.lobby.houseDetail != null
                            ? CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              radius: 18,
                              child:
                                  widget
                                          .lobby
                                          .houseDetail!
                                          .profilePhoto
                                          .isNotEmpty
                                      ? ClipOval(
                                        child: Image.network(
                                          widget
                                              .lobby
                                              .houseDetail!
                                              .profilePhoto,
                                          fit: BoxFit.cover,
                                          width: 36,
                                          height: 36,
                                          errorBuilder: (
                                            context,
                                            error,
                                            stackTrace,
                                          ) {
                                            return Icon(
                                              Icons.groups_rounded,
                                              size: 18,
                                            );
                                          },
                                          loadingBuilder: (
                                            context,
                                            child,
                                            loadingProgress,
                                          ) {
                                            if (loadingProgress == null)
                                              return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: DesignColors.accent,
                                                value:
                                                    loadingProgress
                                                                .expectedTotalBytes !=
                                                            null
                                                        ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                        : null,
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                      : Icon(Icons.groups_rounded, size: 18),
                            )
                            : GestureDetector(
                              onTap: () async {
                                final uid =
                                    await GetStorage().read("userUID") ?? '';
                                if (lobby.adminSummary.userId != "") {
                                  Get.toNamed(AppRoutes.myProfile);
                                  //TODO : add profilescreen

                                  // Get.to(
                                  //   () =>
                                  //       (lobby.adminSummary.userId == uid)
                                  //           ? ProfileDetailsFollowedScreen()
                                  //           : ProfileDetailsScreen(
                                  //             userId: lobby.adminSummary.userId,
                                  //           ),
                                  // );
                                }
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 18,
                                child:
                                    lobby
                                            .adminSummary
                                            .profilePictureUrl
                                            .isNotEmpty
                                        ? ClipOval(
                                          child: Image.network(
                                            lobby
                                                .adminSummary
                                                .profilePictureUrl,
                                            fit: BoxFit.cover,
                                            width: 36,
                                            height: 36,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Icon(
                                                Icons.person,
                                                size: 18,
                                                color: const Color(0xFF323232),
                                              );
                                            },
                                            loadingBuilder: (
                                              context,
                                              child,
                                              loadingProgress,
                                            ) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: DesignColors.accent,
                                                  value:
                                                      loadingProgress
                                                                  .expectedTotalBytes !=
                                                              null
                                                          ? loadingProgress
                                                                  .cumulativeBytesLoaded /
                                                              loadingProgress
                                                                  .expectedTotalBytes!
                                                          : null,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                        : Icon(
                                          Icons.person,
                                          size: 18,
                                          color: const Color(0xFF323232),
                                        ),
                              ),
                            ),
                        Space.w(width: 18),
                        Expanded(
                          child: Wrap(
                            spacing: 0.0, // Horizontal space between items
                            runSpacing: 4, // Vertical space between rows
                            children:
                                (() {
                                  // Create a new list from compactItems
                                  final sortedItems = List.from(
                                    lobby.compactItems,
                                  );
                                  // kLogger.trace("$sortedItems");

                                  // Return the sorted and mapped children
                                  return sortedItems.map((item) {
                                    if (item.content != "") {
                                      return SizedBox(
                                        width: min(120, sw(0.2)),
                                        // width:sw(0.1),
                                        // width: 0.35.sw,
                                        child: InfoItemWithIconForCompactView(
                                          iconUrl: item.iconUrl,
                                          text: item.content,
                                        ),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }).toList();
                                })(), // Immediately invoked function to return the sorted children
                          ),
                        ),
                      ],
                    ),

                    // Space.h(height: 0.01.sh),
                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   children: [
                    //     DesignButton(
                    //       onPress: _onJoinOrRequest,
                    //       title: () {
                    //         switch (lobby.userStatus) {
                    //           case "ADMIN":
                    //             return "View"; // Show "View Lobby" for admin
                    //           case "MEMBER":
                    //             return "View"; // Show "View Lobby" for member
                    //           case "VISITOR":
                    //             return lobby.isPrivate
                    //                 ? "Request"
                    //                 : "Join"; // Show based on whether the visitor has joined or not
                    //           default:
                    //             return "Join Lobby"; // Default case if userStatus is unexpected
                    //         }
                    //       }(),
                    //       bgColor: lobby.colorScheme.border,
                    //       titleSize: 14,
                    //       padding: EdgeInsets.symmetric(
                    //         horizontal: 24.w,
                    //         vertical: 0,
                    //       ),
                    //     ),
                    //     if (lobby.isPrivate) ...[
                    //       const Spacer(),
                    //       Row(
                    //         // MEMBER VISI
                    //         children: [
                    //           DesignIcon.custom(
                    //             icon: DesignIcons.peoples,
                    //             size: 18.sp,
                    //           ),
                    //           const SizedBox(width: 4),
                    //           DesignText(
                    //             text:
                    //                 "${lobby.filter.otherFilterInfo.currentCount?.value}",
                    //             fontSize: 11.sp,
                    //             fontWeight: FontWeight.w500,
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<dynamic> shareLobbyBottomSheet(BuildContext context) {
  //    double screenWidth = MediaQuery.of(context).size.width;
  //   double screenHeight = MediaQuery.of(context).size.height;

  //   double sw(double size) => screenWidth * size;

  //   double sh(double size) => screenHeight * size;
  //   return showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (context) {
  //       Set<String> conversationIds = {};
  //       final TextEditingController messageController = TextEditingController();

  //       return StatefulBuilder(
  //         builder: (BuildContext context, StateSetter setState) {
  //           return GestureDetector(
  //             onTap: () => FocusScope.of(context).unfocus(),
  //             child: Container(
  //               height: sh(0.8),
  //               decoration: BoxDecoration(
  //                 color: Colors.white,
  //                 borderRadius: BorderRadius.only(
  //                   topLeft: Radius.circular(20),
  //                   topRight: Radius.circular(20),
  //                 ),
  //                 boxShadow: [
  //                   BoxShadow(
  //                     color: Colors.black.withOpacity(0.1),
  //                     blurRadius: 10,
  //                     spreadRadius: 0,
  //                   ),
  //                 ],
  //               ),
  //               child: Column(
  //                 children: [
  //                   // Handle bar for dragging
  //                   Container(
  //                     margin: EdgeInsets.only(top: 10),
  //                     width: 40,
  //                     height: 5,
  //                     decoration: BoxDecoration(
  //                       color: Colors.grey[300],
  //                       borderRadius: BorderRadius.circular(10),
  //                     ),
  //                   ),

  //                   // Header with lobby info
  //                   Padding(
  //                     padding: EdgeInsets.all(16),
  //                     child: Row(
  //                       children: [
  //                         ClipRRect(
  //                           borderRadius: BorderRadius.circular(8),
  //                           child: Image.network(
  //                             widget.lobby.mediaUrls.first,
  //                             width: 60,
  //                             height: 60,
  //                             fit: BoxFit.cover,
  //                             errorBuilder: (context, error, stackTrace) =>
  //                                 Container(
  //                               width: 60,
  //                               height: 60,
  //                               color: Colors.grey[200],
  //                               child: Icon(Icons.image_not_supported,
  //                                   size: 24),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(width: 12),
  //                         Expanded(
  //                           child: Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               DesignText(
  //                                 text: "Share Lobby",
  //                                 fontSize: 18,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                               SizedBox(height: 4),
  //                               DesignText(
  //                                 text: widget.lobby.title,
  //                                 fontSize: 14,
  //                                 fontWeight: FontWeight.w400,
  //                                 color: Colors.grey[700],
  //                               ),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   Divider(height: 1),

  //                   // Message input section
  //                   Padding(
  //                     padding: EdgeInsets.all(16),
  //                     child: Column(
  //                       crossAxisAlignment: CrossAxisAlignment.start,
  //                       children: [
  //                         DesignText(
  //                           text: "Add a message",
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.w500,
  //                           color: DesignColors.secondary,
  //                         ),
  //                         SizedBox(height: 8),
  //                         Container(
  //                           decoration: BoxDecoration(
  //                             borderRadius: BorderRadius.circular(12),
  //                             border: Border.all(color: Colors.grey[300]!),
  //                           ),
  //                           child: TextField(
  //                             controller: messageController,
  //                             maxLines: 3,
  //                             decoration: InputDecoration(
  //                               hintText: "Hey, check out this lobby!",
  //                               hintStyle: TextStyle(
  //                                 color: Colors.grey[400],
  //                                 fontSize: 14,
  //                               ),
  //                               contentPadding: EdgeInsets.all(12),
  //                               border: InputBorder.none,
  //                             ),
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   ),

  //                   // Tab bar for Friends and Squads
  //                   Expanded(
  //                     child: DefaultTabController(
  //                       length: 2,
  //                       child: Column(
  //                         children: [
  //                           TabBar(
  //                             tabs: [
  //                               Tab(
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Icon(Icons.person, size: 16),
  //                                     SizedBox(width: 6),
  //                                     Text('Friends'),
  //                                   ],
  //                                 ),
  //                               ),
  //                               Tab(
  //                                 child: Row(
  //                                   mainAxisAlignment: MainAxisAlignment.center,
  //                                   children: [
  //                                     Icon(Icons.group, size: 16),
  //                                     SizedBox(width: 6),
  //                                     Text('Squads'),
  //                                   ],
  //                                 ),
  //                               ),
  //                             ],
  //                             labelColor: DesignColors.accent,
  //                             unselectedLabelColor: Colors.grey,
  //                             indicatorColor: DesignColors.accent,
  //                             indicatorWeight: 3,
  //                           ),
  //                           Expanded(
  //                             child: TabBarView(
  //                               children: [
  //                                 // Friends Tab
  //                                 Obx(() {
  //                                   if (profileController
  //                                       .isSearchingFriends.value) {
  //                                     return const Center(
  //                                       child: CircularProgressIndicator(),
  //                                     );
  //                                   }

  //                                   if (profileController.friendsList.isEmpty) {
  //                                     return Center(
  //                                       child: Column(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.center,
  //                                         children: [
  //                                           Icon(
  //                                             Icons.people_outline,
  //                                             size: 48,
  //                                             color: Colors.grey[400],
  //                                           ),
  //                                           SizedBox(height: 16),
  //                                           DesignText(
  //                                             text: "No friends yet",
  //                                             fontSize: 16,
  //                                             color: Colors.grey[600],
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     );
  //                                   }

  //                                   return Padding(
  //                                     padding: EdgeInsets.all(16),
  //                                     child: GridView.builder(
  //                                       gridDelegate:
  //                                           SliverGridDelegateWithFixedCrossAxisCount(
  //                                         crossAxisCount: 3,
  //                                         childAspectRatio: 0.75,
  //                                         crossAxisSpacing: 12,
  //                                         mainAxisSpacing: 12,
  //                                       ),
  //                                       itemCount: profileController
  //                                           .friendsList.length,
  //                                       itemBuilder: (context, index) {
  //                                         final friend = profileController
  //                                             .friendsList[index];
  //                                         final isSelected = conversationIds
  //                                             .contains(friend.conversationId);

  //                                         return GestureDetector(
  //                                           onTap: () {
  //                                             setState(() {
  //                                               if (isSelected) {
  //                                                 conversationIds.remove(
  //                                                     friend.conversationId);
  //                                               } else {
  //                                                 conversationIds.add(
  //                                                     friend.conversationId);
  //                                               }
  //                                             });
  //                                           },
  //                                           child: Container(
  //                                             decoration: BoxDecoration(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(12),
  //                                               border: Border.all(
  //                                                 color: isSelected
  //                                                     ? DesignColors.accent
  //                                                     : Colors.grey[300]!,
  //                                                 width: isSelected ? 2 : 1,
  //                                               ),
  //                                               color: isSelected
  //                                                   ? DesignColors.accent
  //                                                       .withOpacity(0.1)
  //                                                   : Colors.white,
  //                                             ),
  //                                             child: Column(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment.center,
  //                                               children: [
  //                                                 Stack(
  //                                                   alignment:
  //                                                       Alignment.bottomRight,
  //                                                   children: [
  //                                                     Container(
  //                                                       padding:
  //                                                           EdgeInsets.all(2),
  //                                                       decoration:
  //                                                           BoxDecoration(
  //                                                         shape:
  //                                                             BoxShape.circle,
  //                                                         border: Border.all(
  //                                                           color: isSelected
  //                                                               ? DesignColors
  //                                                                   .accent
  //                                                               : Colors
  //                                                                   .transparent,
  //                                                           width: 2,
  //                                                         ),
  //                                                       ),
  //                                                       child: CircleAvatar(
  //                                                         radius: 30,
  //                                                         backgroundImage: friend
  //                                                                         .profilePictureUrl !=
  //                                                                     null &&
  //                                                                 friend
  //                                                                     .profilePictureUrl!
  //                                                                     .isNotEmpty
  //                                                             ? NetworkImage(friend
  //                                                                 .profilePictureUrl!)
  //                                                             : null,
  //                                                         child: friend.profilePictureUrl ==
  //                                                                     null ||
  //                                                                 friend
  //                                                                     .profilePictureUrl!
  //                                                                     .isEmpty
  //                                                             ? Icon(
  //                                                                 Icons.person,
  //                                                                 size: 30)
  //                                                             : null,
  //                                                       ),
  //                                                     ),
  //                                                     if (isSelected)
  //                                                       Container(
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           color: DesignColors
  //                                                               .accent,
  //                                                           shape:
  //                                                               BoxShape.circle,
  //                                                           border: Border.all(
  //                                                             color:
  //                                                                 Colors.white,
  //                                                             width: 2,
  //                                                           ),
  //                                                         ),
  //                                                         child: Icon(
  //                                                           Icons.check,
  //                                                           color: Colors.white,
  //                                                           size: 16,
  //                                                         ),
  //                                                       ),
  //                                                   ],
  //                                                 ),
  //                                                 SizedBox(height: 8),
  //                                                 Padding(
  //                                                   padding:
  //                                                       EdgeInsets.symmetric(
  //                                                           horizontal: 4),
  //                                                   child: Text(
  //                                                     friend.name,
  //                                                     style: TextStyle(
  //                                                       fontSize: 12,
  //                                                       fontWeight: isSelected
  //                                                           ? FontWeight.w600
  //                                                           : FontWeight.normal,
  //                                                       color: isSelected
  //                                                           ? DesignColors
  //                                                               .accent
  //                                                           : Colors.black,
  //                                                     ),
  //                                                     textAlign:
  //                                                         TextAlign.center,
  //                                                     maxLines: 1,
  //                                                     overflow:
  //                                                         TextOverflow.ellipsis,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                   );
  //                                 }),

  //                                 // Squads Tab with similar improvements
  //                                 Obx(() {
  //                                   if (groupController.isLoading.value) {
  //                                     return const Center(
  //                                       child: CircularProgressIndicator(),
  //                                     );
  //                                   }

  //                                   if (groupController.groups.isEmpty) {
  //                                     return Center(
  //                                       child: Column(
  //                                         mainAxisAlignment:
  //                                             MainAxisAlignment.center,
  //                                         children: [
  //                                           Icon(
  //                                             Icons.group_off,
  //                                             size: 48,
  //                                             color: Colors.grey[400],
  //                                           ),
  //                                           SizedBox(height: 16),
  //                                           DesignText(
  //                                             text: "No squads yet",
  //                                             fontSize: 16,
  //                                             color: Colors.grey[600],
  //                                           ),
  //                                         ],
  //                                       ),
  //                                     );
  //                                   }

  //                                   return Padding(
  //                                     padding: EdgeInsets.all(16),
  //                                     child: GridView.builder(
  //                                       gridDelegate:
  //                                           SliverGridDelegateWithFixedCrossAxisCount(
  //                                         crossAxisCount: 3,
  //                                         childAspectRatio: 0.75,
  //                                         crossAxisSpacing: 12,
  //                                         mainAxisSpacing: 12,
  //                                       ),
  //                                       itemCount:
  //                                           groupController.groups.length,
  //                                       itemBuilder: (context, index) {
  //                                         final group =
  //                                             groupController.groups[index];
  //                                         final isSelected = conversationIds
  //                                             .contains(group.groupId);

  //                                         return GestureDetector(
  //                                           onTap: () {
  //                                             setState(() {
  //                                               if (isSelected) {
  //                                                 conversationIds
  //                                                     .remove(group.groupId);
  //                                               } else {
  //                                                 conversationIds
  //                                                     .add(group.groupId);
  //                                               }
  //                                             });
  //                                           },
  //                                           child: Container(
  //                                             decoration: BoxDecoration(
  //                                               borderRadius:
  //                                                   BorderRadius.circular(12),
  //                                               border: Border.all(
  //                                                 color: isSelected
  //                                                     ? DesignColors.accent
  //                                                     : Colors.grey[300]!,
  //                                                 width: isSelected ? 2 : 1,
  //                                               ),
  //                                               color: isSelected
  //                                                   ? DesignColors.accent
  //                                                       .withOpacity(0.1)
  //                                                   : Colors.white,
  //                                             ),
  //                                             child: Column(
  //                                               mainAxisAlignment:
  //                                                   MainAxisAlignment.center,
  //                                               children: [
  //                                                 Stack(
  //                                                   alignment:
  //                                                       Alignment.bottomRight,
  //                                                   children: [
  //                                                     Container(
  //                                                       padding:
  //                                                           EdgeInsets.all(2),
  //                                                       decoration:
  //                                                           BoxDecoration(
  //                                                         shape:
  //                                                             BoxShape.circle,
  //                                                         border: Border.all(
  //                                                           color: isSelected
  //                                                               ? DesignColors
  //                                                                   .accent
  //                                                               : Colors
  //                                                                   .transparent,
  //                                                           width: 2,
  //                                                         ),
  //                                                       ),
  //                                                       child: CircleAvatar(
  //                                                         radius: 30,
  //                                                         backgroundImage: group
  //                                                                         .profilePicture !=
  //                                                                     null &&
  //                                                                 group
  //                                                                     .profilePicture!
  //                                                                     .isNotEmpty
  //                                                             ? NetworkImage(group
  //                                                                 .profilePicture!)
  //                                                             : null,
  //                                                         child: group.profilePicture ==
  //                                                                     null ||
  //                                                                 group
  //                                                                     .profilePicture!
  //                                                                     .isEmpty
  //                                                             ? Icon(
  //                                                                 Icons.group,
  //                                                                 size: 30)
  //                                                             : null,
  //                                                       ),
  //                                                     ),
  //                                                     if (isSelected)
  //                                                       Container(
  //                                                         decoration:
  //                                                             BoxDecoration(
  //                                                           color: DesignColors
  //                                                               .accent,
  //                                                           shape:
  //                                                               BoxShape.circle,
  //                                                           border: Border.all(
  //                                                             color:
  //                                                                 Colors.white,
  //                                                             width: 2,
  //                                                           ),
  //                                                         ),
  //                                                         child: Icon(
  //                                                           Icons.check,
  //                                                           color: Colors.white,
  //                                                           size: 16,
  //                                                         ),
  //                                                       ),
  //                                                   ],
  //                                                 ),
  //                                                 SizedBox(height: 8),
  //                                                 Padding(
  //                                                   padding:
  //                                                       EdgeInsets.symmetric(
  //                                                           horizontal: 4),
  //                                                   child: Text(
  //                                                     group.groupName,
  //                                                     style: TextStyle(
  //                                                       fontSize: 12,
  //                                                       fontWeight: isSelected
  //                                                           ? FontWeight.w600
  //                                                           : FontWeight.normal,
  //                                                       color: isSelected
  //                                                           ? DesignColors
  //                                                               .accent
  //                                                           : Colors.black,
  //                                                     ),
  //                                                     textAlign:
  //                                                         TextAlign.center,
  //                                                     maxLines: 1,
  //                                                     overflow:
  //                                                         TextOverflow.ellipsis,
  //                                                   ),
  //                                                 ),
  //                                               ],
  //                                             ),
  //                                           ),
  //                                         );
  //                                       },
  //                                     ),
  //                                   );
  //                                 }),
  //                               ],
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),

  //                   // Bottom action buttons
  //                   Container(
  //                     padding: EdgeInsets.all(16),
  //                     decoration: BoxDecoration(
  //                       color: Colors.white,
  //                       boxShadow: [
  //                         BoxShadow(
  //                           color: Colors.black.withOpacity(0.05),
  //                           blurRadius: 5,
  //                           offset: Offset(0, -3),
  //                         ),
  //                       ],
  //                     ),
  //                     child: Column(
  //                       mainAxisSize: MainAxisSize.min,
  //                       children: [
  //                         // External share button
  //                         GestureDetector(
  //                           onTap: () async {
  //                             // Create a shareable link for the lobby
  //                             final String shareableLink =
  //                                 "https://aroundu.com/lobby/${widget.lobby.id}";
  //                             // Use the share package to open the native share dialog
  //                             await Share.share(
  //                               'Check out this lobby: ${widget.lobby.title}\n$shareableLink',
  //                               subject: 'Join me on AroundU!',
  //                             );
  //                           },
  //                           child: Container(
  //                             margin: EdgeInsets.only(bottom: 16),
  //                             padding: EdgeInsets.symmetric(vertical: 12),
  //                             decoration: BoxDecoration(
  //                               color: Colors.grey[100],
  //                               borderRadius: BorderRadius.circular(12),
  //                               border: Border.all(color: Colors.grey[300]!),
  //                             ),
  //                             child: Row(
  //                               mainAxisAlignment: MainAxisAlignment.center,
  //                               children: [
  //                                 Icon(
  //                                   Icons.share,
  //                                   size: 20,
  //                                   color: Colors.grey[800],
  //                                 ),
  //                                 SizedBox(width: 8),
  //                                 Text(
  //                                   'Share via...',
  //                                   style: TextStyle(
  //                                     fontSize: 14,
  //                                     fontWeight: FontWeight.w500,
  //                                     color: Colors.grey[800],
  //                                   ),
  //                                 ),
  //                               ],
  //                             ),
  //                           ),
  //                         ),

  //                         Row(
  //                           children: [
  //                             Expanded(
  //                               child: DesignButton(
  //                                 onPress: () => Navigator.pop(context),
  //                                 padding: EdgeInsets.symmetric(vertical: 12),
  //                                 title: 'Cancel',
  //                                 titleSize: 14,
  //                                 bgColor: Colors.grey.shade300,
  //                                 titleColor: Colors.grey[700],
  //                               ),
  //                             ),
  //                             SizedBox(width: 12),
  //                             Expanded(
  //                               child: Consumer(
  //                                 builder: (context, ref, child) {
  //                                   return DesignButton(
  //                                     onPress: conversationIds.isEmpty
  //                                         ? () {
  //                                             CustomSnackBar.show(
  //                                                 context: context,
  //                                                 message:
  //                                                     'Please select at least one recipient',
  //                                                 type: SnackBarType.warning,
  //                                               );
  //                                           }
  //                                         : () async {
  //                                             final messageText =
  //                                                 messageController.text.trim();
  //                                             if (conversationIds.isEmpty) {
  //                                               ScaffoldMessenger.of(context)
  //                                                   .showSnackBar(
  //                                                 SnackBar(
  //                                                   content: Text(
  //                                                       'Please select at least one recipient'),
  //                                                   behavior: SnackBarBehavior
  //                                                       .floating,
  //                                                 ),
  //                                               );
  //                                               return;
  //                                             }

  //                                             // Show loading indicator
  //                                             showDialog(
  //                                               context: context,
  //                                               barrierDismissible: false,
  //                                               builder: (context) => Center(
  //                                                 child:
  //                                                     CircularProgressIndicator(),
  //                                               ),
  //                                             );

  //                                             try {
  //                                               await chatController
  //                                                   .sendBulkMessages(
  //                                                 message: messageText.isEmpty
  //                                                     ? "Check out this lobby: ${widget.lobby.title}"
  //                                                     : messageText,
  //                                                 id: widget.lobby.id,
  //                                                 from: chatController
  //                                                     .currentUserId.value,
  //                                                 attachments: [],
  //                                                 conversationIds:
  //                                                     conversationIds.toList(),
  //                                                 type: "LOBBY",
  //                                               );

  //                                               // Close loading dialog
  //                                               Navigator.pop(context);
  //                                               // Close bottom sheet
  //                                               Navigator.pop(context);

  //                                               // Show success message
  //                                               ScaffoldMessenger.of(context)
  //                                                   .showSnackBar(
  //                                                 SnackBar(
  //                                                   content: Text(
  //                                                       'Lobby shared successfully!'),
  //                                                   behavior: SnackBarBehavior
  //                                                       .floating,
  //                                                   backgroundColor:
  //                                                       Colors.green,
  //                                                 ),
  //                                               );
  //                                             } catch (e) {
  //                                               // Close loading dialog
  //                                               Navigator.pop(context);

  //                                               // Show error message
  //                                               ScaffoldMessenger.of(context)
  //                                                   .showSnackBar(
  //                                                 SnackBar(
  //                                                   content: Text(
  //                                                       'Failed to share: ${e.toString()}'),
  //                                                   behavior: SnackBarBehavior
  //                                                       .floating,
  //                                                   backgroundColor: Colors.red,
  //                                                 ),
  //                                               );
  //                                             }
  //                                           },
  //                                     padding:
  //                                         EdgeInsets.symmetric(vertical: 12),
  //                                     title: 'Share',
  //                                     titleSize: 14,
  //                                   );
  //                                 },
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ],
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}

class InfoItemWithIconForCompactView extends StatelessWidget {
  final String? iconUrl;
  final String text;
  final VoidCallback? onTap;

  const InfoItemWithIconForCompactView({
    super.key,
    this.iconUrl,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    final convertedIcon =
        iconUrl != null ? DesignIcons.getIconFromString(iconUrl!) : null;

    return SizedBox(
      width: sw(0.225),
      child: Padding(
        padding: EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: onTap,
          child:
              convertedIcon != null
                  ? Row(
                    children: [
                      DesignIcon.custom(
                        icon: convertedIcon,
                        color: DesignColors.accent,
                        size: 10,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DesignText(
                          text: text,
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF444444),
                        ),
                      ),
                    ],
                  )
                  : DesignText(
                    text: iconUrl != null ? "$iconUrl  $text" : text,
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF444444),
                  ),
        ),
      ),
    );
  }
}

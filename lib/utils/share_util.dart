import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/announcement.model.dart';
import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/profile/controllers/controller.groups.profiledart.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Enum to define different entity types for sharing
enum EntityType { profile, lobby, house, moment, announcement }

/// A utility class for sharing different entities in the app
class ShareUtility {
  // Private constructor to prevent instantiation
  ShareUtility._();

  /// Main method to show share bottom sheet for any entity
  static Future<void> showShareBottomSheet({
    required BuildContext context,
    required EntityType entityType,
    required dynamic entity,
  }) async {
    try {
      // Ensure controllers are initialized
      // final chatController = Get.find<ChatsController>();
      // final profileController = Get.find<ProfileController>();
      // final groupController = Get.find<GroupController>();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [CircularProgressIndicator(color: DesignColors.accent)],
            ),
          );
        },
      );

      // Fetch necessary data before showing the sheet
      // await groupController.fetchGroups();
      // await profileController.getFriends();
      Navigator.pop(context);
      // Show the bottom sheet
      await _showShareBottomSheet(
        context: context,
        entityType: entityType,
        entity: entity,
        // chatController: chatController,
      );
    } catch (e) {
      if (context.mounted) {
        CustomSnackBar.show(
          context: context,
          message: "Error preparing share options: $e",
          type: SnackBarType.error,
        );
      }
    }
  }

  /// Private method to show the actual bottom sheet
  static Future<void> _showShareBottomSheet({
    required BuildContext context,
    required EntityType entityType,
    required dynamic entity,
    // required ChatsController chatController,
  }) async {
    // Get entity details based on type
    final EntityDetails details = _getEntityDetails(entityType, entity);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        double sw = MediaQuery.of(context).size.width;
        double sh = MediaQuery.of(context).size.height;
        Set<String> conversationIds = {};
        final TextEditingController messageController = TextEditingController();
        messageController.text = details.defaultMessage;

        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Container(
                height: 0.4 * sh,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Handle bar for dragging
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),

                    // Header with entity info - Updated to match lobby_card style
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Entity image with proper styling
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              details.isCircular ? 30 : 8,
                            ),
                            child:
                                details.imageUrl.isNotEmpty
                                    ? Image.network(
                                      details.imageUrl,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                width: 60,
                                                height: 60,
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  details.icon,
                                                  size: 24,
                                                ),
                                              ),
                                    )
                                    : Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey[200],
                                      child: Icon(details.icon, size: 24),
                                    ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Share ${details.entityTypeName}",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  details.subtitle,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[700],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(height: 1),

                    // Share options - Keep existing functionality
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildShareOption(
                            icon: Icons.copy,
                            color: Colors.blue,
                            label: "Copy Link",
                            onTap: () async {
                              await Clipboard.setData(
                                ClipboardData(
                                  text:
                                      '${details.defaultMessage} \n ${details.shareLink}',
                                ),
                              );
                              if (context.mounted) {
                                Navigator.pop(context);
                                CustomSnackBar.show(
                                  context: context,
                                  message: "Link copied to clipboard",
                                  type: SnackBarType.success,
                                );
                              }
                            },
                          ),

                          // _buildShareOption(
                          //   icon: FontAwesomeIcons.whatsapp,
                          //   color: Colors.green,
                          //   label: "WhatsApp",
                          //   onTap: () async {
                          //     final whatsappUrl =
                          //         "whatsapp://send?text=${Uri.encodeComponent(details.defaultMessage + ' ' + details.shareLink)}";

                          //     try {
                          //       final uri = Uri.parse(whatsappUrl);
                          //       if (await canLaunchUrl(uri)) {
                          //         final launched = await launchUrl(uri);
                          //         if (!launched) {
                          //           throw 'Could not launch WhatsApp';
                          //         }
                          //       } else {
                          //         throw 'WhatsApp not installed';
                          //       }
                          //     } catch (e) {
                          //       if (context.mounted) {
                          //         CustomSnackBar.show(
                          //           context: context,
                          //           message:
                          //               "WhatsApp is not installed or could not be opened",
                          //           type: SnackBarType.warning,
                          //         );
                          //       }
                          //     }
                          //   },
                          // ),
                          _buildShareOption(
                            icon: Icons.share,
                            color: Colors.purple,
                            label: "More",
                            onTap: () async {
                              await Share.share(
                                '${details.defaultMessage} \n ${details.shareLink}',
                                subject: "AroundU ${details.entityTypeName}",
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // Divider(height: 1),

                    // AroundU share options
                    // Expanded(
                    //   child: DefaultTabController(
                    //     length: 2,
                    //     child: Column(
                    //       children: [
                    //         TabBar(
                    //           tabs: [
                    //             Tab(text: "Friends"),
                    //             Tab(text: "Groups"),
                    //           ],
                    //           labelColor: DesignColors.accent,
                    //           unselectedLabelColor: Colors.grey,
                    //           indicatorColor: DesignColors.accent,
                    //         ),
                    //         Expanded(
                    //           child: TabBarView(
                    //             children: [
                    //               // Friends Tab
                    //               _buildFriendsShareList(
                    //                 context,
                    //                 conversationIds,
                    //                 setState,
                    //               ),

                    //               // Groups Tab
                    //               _buildGroupsShareList(
                    //                 context,
                    //                 conversationIds,
                    //                 setState,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    // Message input and send button
                    // if (conversationIds.isNotEmpty)
                    //   Container(
                    //     padding: EdgeInsets.all(16),
                    //     decoration: BoxDecoration(
                    //       color: Colors.white,
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.black.withOpacity(0.05),
                    //           blurRadius: 5,
                    //           offset: const Offset(0, -1),
                    //         ),
                    //       ],
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Expanded(
                    //           child: DesignTextField(
                    //             controller: messageController,
                    //             hintText: "Add a message...",
                    //             maxLines: 3,
                    //             minLines: 1,
                    //           ),
                    //         ),
                    //         SizedBox(width: 12),
                    //         InkWell(
                    //           onTap: () async {
                    //             if (conversationIds.isEmpty) {
                    //               CustomSnackBar.show(
                    //                 context: context,
                    //                 message:
                    //                     "Please select at least one recipient",
                    //                 type: SnackBarType.warning,
                    //               );
                    //               return;
                    //             }

                    //             final message = messageController.text.trim();

                    //             try {
                    //               await chatController.sendBulkMessages(
                    //                 message: message.isEmpty
                    //                     ? details.defaultMessage
                    //                     : message,
                    //                 id: details.entityId,
                    //                 from: chatController.currentUserId.value,
                    //                 attachments: [],
                    //                 conversationIds: conversationIds.toList(),
                    //                 type: details.entityTypeForApi,
                    //               );

                    //               if (context.mounted) {
                    //                 CustomSnackBar.show(
                    //                   context: context,
                    //                   message:
                    //                       "${details.entityTypeName} shared successfully!",
                    //                   type: SnackBarType.success,
                    //                 );
                    //                 Navigator.pop(context);
                    //               }
                    //             } catch (e) {
                    //               if (context.mounted) {
                    //                 CustomSnackBar.show(
                    //                   context: context,
                    //                   message:
                    //                       "Error sharing ${details.entityTypeName.toLowerCase()}: $e",
                    //                   type: SnackBarType.error,
                    //                 );
                    //               }
                    //             }
                    //           },
                    //           child: Container(
                    //             padding: EdgeInsets.all(12),
                    //             decoration: BoxDecoration(
                    //               color: DesignColors.accent,
                    //               shape: BoxShape.circle,
                    //             ),
                    //             child: Icon(
                    //               Icons.send,
                    //               color: Colors.white,
                    //               size: 20,
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Build a share option button
  static Widget _buildShareOption({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      // borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80,
        padding: EdgeInsets.symmetric(vertical: 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Build the friends list for sharing
  static Widget _buildFriendsShareList(
    BuildContext context,
    Set<String> conversationIds,
    StateSetter setState,
  ) {
    final profileController = Get.put(ProfileController());

    return Obx(() {
      final friends = profileController.friendsList;

      if (friends.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                "No friends yet",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: friends.length,
        itemBuilder: (context, index) {
          final friend = friends[index];
          final conversationId = friend.conversationId ?? "";
          final isSelected = conversationIds.contains(conversationId);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  friend!.profilePictureUrl!.isNotEmpty
                      ? NetworkImage(friend.profilePictureUrl ?? "")
                      : null,
              child:
                  friend.profilePictureUrl!.isEmpty
                      ? Icon(Icons.person, size: 20, color: Colors.grey)
                      : null,
            ),
            title: Text(
              friend.name,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "@${friend.userName}",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Checkbox(
              value: isSelected,
              activeColor: DesignColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    conversationIds.add(conversationId);
                  } else {
                    conversationIds.remove(conversationId);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  conversationIds.remove(conversationId);
                } else {
                  conversationIds.add(conversationId);
                }
              });
            },
          );
        },
      );
    });
  }

  /// Build the groups list for sharing
  static Widget _buildGroupsShareList(
    BuildContext context,
    Set<String> conversationIds,
    StateSetter setState,
  ) {
    
    final groupController = Get.put(GroupController());

    return Obx(() {
      final groups = groupController.groups;

      if (groups.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                "No groups yet",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          final conversationId = group.groupId ?? "";
          final isSelected = conversationIds.contains(conversationId);

          return ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  group.profilePicture!.isNotEmpty
                      ? NetworkImage(group.profilePicture ?? "")
                      : null,
              child:
                  group.profilePicture!.isEmpty
                      ? Icon(Icons.group, size: 20, color: Colors.grey)
                      : null,
            ),
            title: Text(
              group.groupName,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              "${group.participants.length} members",
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Checkbox(
              value: isSelected,
              activeColor: DesignColors.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    conversationIds.add(conversationId);
                  } else {
                    conversationIds.remove(conversationId);
                  }
                });
              },
            ),
            onTap: () {
              setState(() {
                if (isSelected) {
                  conversationIds.remove(conversationId);
                } else {
                  conversationIds.add(conversationId);
                }
              });
            },
          );
        },
      );
    });
  }

  /// Get entity details based on type
  static EntityDetails _getEntityDetails(EntityType type, dynamic entity) {
    switch (type) {
      case EntityType.profile:
        final profile = entity as ProfileModel;
        return EntityDetails(
          entityId: profile.userId,
          entityTypeName: "Profile",
          entityTypeForApi: "USER",
          title: "Share ${profile.name}'s Profile",
          subtitle: "@${profile.userName}",
          imageUrl: profile.profilePictureUrl,
          icon: Icons.person,
          isCircular: true,
          shareLink: "www.aroundu.in/otherProfile/${profile.userId}",
          defaultMessage:
              "Check out ${profile.name}'s profile on AroundU. Looks interesting",
        );

      case EntityType.lobby:
        final lobby = entity as Lobby;
        return EntityDetails(
          entityId: lobby.id,
          entityTypeName: "Lobby",
          entityTypeForApi: "LOBBY",
          title: "Share Lobby: ${lobby.title}",
          subtitle: "${lobby.currentMembers}/${lobby.totalMembers} members",
          imageUrl: lobby.mediaUrls.isNotEmpty ? lobby.mediaUrls.first : "",
          icon: Icons.group,
          isCircular: false,
          shareLink: "www.aroundu.in/lobby/${lobby.id}",
          defaultMessage:
              "If you're around, this is where the vibe’s brewing 🌪️. Check out this ${lobby.title} lobby on AroundU",
        );

      case EntityType.house:
        final house = entity as House;
        return EntityDetails(
          entityId: house.id ?? "",
          entityTypeName: "House",
          entityTypeForApi: "HOUSE",
          title: "Share House: ${house.name ?? 'House'}",
          subtitle: "${house.followerCount ?? 0} followers",
          imageUrl: house.profilePhoto ?? "",
          icon: Icons.home,
          isCircular: false,
          shareLink: "www.aroundu.in/house/${house.id}",
          defaultMessage:
              "Found a corner of the internet that actually gets me. Check out ${house.name ?? "this"} house on AroundU",
        );

      case EntityType.moment:
        final moment = entity;
        return EntityDetails(
          entityId: moment.id ?? "",
          entityTypeName: "Moment",
          entityTypeForApi: "MOMENT",
          title: "Share Moment",
          subtitle: moment.title ?? "Shared Moment",
          imageUrl:
              moment.media != null && moment.media!.isNotEmpty
                  ? moment.media!.first
                  : "",
          icon: Icons.photo,
          isCircular: false,
          shareLink: "www.aroundu.in/moment/${moment.id}",
          defaultMessage:
              "Some moments speak louder than captions. Check out this moment on AroundU",
        );

      case EntityType.announcement:
        final announcement = entity as GetAnnouncementModel;
        return EntityDetails(
          entityId: announcement.id ?? "",
          entityTypeName: "Announcement",
          entityTypeForApi: "ANNOUNCEMENT",
          title: "Share Announcement",
          subtitle: announcement.title ?? "Announcement",
          imageUrl:
              announcement.media != null && announcement.media!.isNotEmpty
                  ? announcement.media!.first
                  : "",
          icon: Icons.campaign,
          isCircular: false,
          shareLink:
              "${ApiConstants.arounduBaseUrl}/announcement/${announcement.id}",
          defaultMessage: "Check out this announcement on AroundU!",
        );
    }
  }
}

/// Class to hold entity details for sharing
class EntityDetails {
  final String entityId;
  final String entityTypeName;
  final String entityTypeForApi;
  final String title;
  final String subtitle;
  final String imageUrl;
  final IconData icon;
  final bool isCircular;
  final String shareLink;
  final String defaultMessage;

  EntityDetails({
    required this.entityId,
    required this.entityTypeName,
    required this.entityTypeForApi,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.icon,
    required this.isCircular,
    required this.shareLink,
    required this.defaultMessage,
  });
}

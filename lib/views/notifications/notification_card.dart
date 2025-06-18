import 'package:aroundu/models/notifications.model.dart';
import 'package:aroundu/views/notifications/notification_action_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../designs/widgets/text.widget.designs.dart';
import '../../designs/colors.designs.dart';

class NotificationCard extends ConsumerStatefulWidget {
  const NotificationCard({super.key, required this.notification});
  final NotificationBaseModel notification;

  @override
  ConsumerState<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends ConsumerState<NotificationCard> {
  bool _isButtonsDisabled = false;

  // // Helper methods to get redirection paths
  // String getLeftPath() {
  //   return widget.notification.redirectionPaths
  //           .where((path) => path.direction == RedirectionDirection.LEFT)
  //           .firstOrNull
  //           ?.path ??
  //       '';
  // }

  // String getRightPath() {
  //   return widget.notification.redirectionPaths
  //           .where((path) => path.direction == RedirectionDirection.RIGHT)
  //           .firstOrNull
  //           ?.path ??
  //       '';
  // }

  // String getCenterPath() {
  //   return widget.notification.redirectionPaths
  //           .where((path) => path.direction == RedirectionDirection.CENTER)
  //           .firstOrNull
  //           ?.path ??
  //       '';
  // }

  // Format date to a user-friendly string
  String formatDate(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    // If less than a minute
    if (difference.inSeconds < 60) {
      return 'Just now';
    }
    // If less than an hour
    else if (difference.inMinutes < 60) {
      final int minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    }
    // If less than a day
    else if (difference.inHours < 24) {
      final int hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    }
    // If less than a week
    else if (difference.inDays < 7) {
      final int days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    }
    // If in the same year
    else if (dateTime.year == now.year) {
      return DateFormat('MMM d').format(dateTime); // e.g., "Jun 15"
    }
    // Otherwise show full date
    else {
      return DateFormat('MMM d, yyyy').format(dateTime); // e.g., "Jun 15, 2023"
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.notification.layoutType) {
      case "PFP_TEXT": //done
        return _buildPfpTextLayout(); // done
      case "ICON_TEXT": //done
        return _buildIconTextLayout(); // done
      case "MULTI_PFP_TEXT": // done
        return _buildMultiPfpTextLayout(); //done
      case "MULTI_PFP_TEXT_IMAGE": //done
        return _buildMultiPfpTextImageLayout(); //done
      case "PFP_ENTITY_TEXT_BUTTONS": //done
        return _buildPfpEntityTextButtonsLayout(); // done
      case "MULTI_PFP_ENTITY_TEXT_BUTTONS": //done
        return _buildMultiPfpEntityTextButtonsLayout(); // done
      case "PFP_TEXT_BUTTONS": //done
        return _buildPfpTextButtonsLayout(); //done
      case "ENTITY_TEXT_IMAGE": // done
        return _buildEntityTextImageLayout(); //done
      case "MULTI_PFP_TEXT_BUTTONS":
        return _buildMultiPfpTextButtonsLayout(); //done
      default:
        return _buildDefaultLayout();
    }
  }

  Widget _buildActionButtons() {
    if (widget.notification.buttons == null ||
        widget.notification.buttons!.isEmpty) {
      return SizedBox.shrink();
    }

    // Get the action state for this specific notification
    final actionState = ref.watch(
      notificationActionProvider(widget.notification.id),
    );

    // If the action is completed, don't show buttons
    if (actionState.isCompleted) {
      return SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(width: 4),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEC4B5D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          onPressed:
              actionState.isLoading
                  ? null
                  : () async {
                    final notifier = ref.read(
                      notificationActionProvider(
                        widget.notification.id,
                      ).notifier,
                    );
                    await notifier.performAction(
                      context: context,
                      id: widget.notification.id,
                      action: widget.notification.buttons![0].key,
                    );
                  },
          child:
              actionState.isLoading
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : DesignText(
                    text: widget.notification.buttons![0].title,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
        ),
        SizedBox(width: 4),
        if (widget.notification.buttons!.length >= 2)
          OutlinedButton(
            onPressed:
                actionState.isLoading
                    ? null
                    : () async {
                      final notifier = ref.read(
                        notificationActionProvider(
                          widget.notification.id,
                        ).notifier,
                      );
                      await notifier.performAction(
                        context: context,
                        id: widget.notification.id,
                        action: widget.notification.buttons![1].key,
                      );
                    },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF3E79A1)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            child:
                actionState.isLoading
                    ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3E79A1),
                        ),
                      ),
                    )
                    : Text(
                      widget.notification.buttons![1].title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3E79A1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
          ),
      ],
    );
  }

  // Profile picture with text layout
  Widget _buildPfpTextLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            //PFP
            GestureDetector(
              onTap: () {
                // final leftPath = getLeftPath();
                // if (leftPath.isNotEmpty) {
                //   Get.toNamed(leftPath);
                // }
              },
              child: Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFFD3D1D2),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    (widget.notification.users.isNotEmpty)
                        ? widget.notification.users.first.profilePicture
                        : "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFAF9F9),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: const Color(0xFFD3D1D2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            //Text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Icon with text layout
  Widget _buildIconTextLayout() {
    return GestureDetector(
      onTap: () {
        // final path = getCenterPath();
        // if (path.isNotEmpty) {
        //   Get.toNamed(path);
        // } else {
        //   final alterPath = getRightPath();
        //   if (alterPath.isNotEmpty) {
        //     Get.toNamed(alterPath);
        //   } else {
        //     final backupPath = getLeftPath();
        //     if (backupPath.isNotEmpty) {
        //       Get.toNamed(backupPath);
        //     }
        //   }
        // }
      },
      child: Card(
        color: Colors.white,
        elevation: 0.8,
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              //icon
              Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFFD3D1D2),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    widget.notification.icon ?? "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFAF9F9),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 24,
                          color: DesignColors.accent,
                        ),
                      );
                    },
                  ),
                ),
              ),

              //text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
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

  // Multiple profile pictures with text layout
  Widget _buildMultiPfpTextLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            //Multi PFP
            GestureDetector(
              onTap: () {
                // if (widget.notification.users.length == 1) {
                //   final leftPath = getLeftPath();
                //   if (leftPath.isNotEmpty) {
                //     Get.toNamed(leftPath);
                //   }
                // } else{
                //   final path = getCenterPath();
                //   if (path.isNotEmpty) {
                //     Get.toNamed(path);
                //   }
                // }
              },
              child: Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    // Show profile pictures based on number of users
                    if (widget.notification.users.isNotEmpty)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          height:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          width:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD3D1D2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.notification.users[0].profilePicture,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFAF9F9),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: const Color(0xFFD3D1D2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Second user profile picture (if available)
                    if (widget.notification.users.length >= 2)
                      Positioned(
                        right: 0,
                        bottom:
                            (widget.notification.users.length >= 3) ? null : 0,
                        top: (widget.notification.users.length >= 3) ? 0 : null,
                        child: Container(
                          height:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          width:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD3D1D2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.notification.users[1].profilePicture,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFAF9F9),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: const Color(0xFFD3D1D2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Third user profile picture or +X indicator
                    if (widget.notification.users.length >= 3)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color:
                                  widget.notification.users.length > 3
                                      ? DesignColors.accent.withValues(
                                        alpha: 0.8,
                                      )
                                      : const Color(0xFFFAF9F9),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFD3D1D2),
                                width: 0.5,
                              ),
                            ),
                            child:
                                widget.notification.users.length > 3
                                    ? Center(
                                      child: DesignText(
                                        text:
                                            "+${widget.notification.users.length - 2}",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        widget
                                            .notification
                                            .users[2]
                                            .profilePicture,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: const Color(0xFFFAF9F9),
                                            child: Icon(
                                              Icons.person,
                                              size: 16,
                                              color: const Color(0xFFD3D1D2),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                          ),
                        ),
                      ),

                    // If no users, show default icon
                    if (widget.notification.users.isEmpty)
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F9),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFD3D1D2),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: const Color(0xFFD3D1D2),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Multiple profile pictures with text and image layout
  Widget _buildMultiPfpTextImageLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            //Multi PFP
            GestureDetector(
              onTap: () {
                // if (widget.notification.users.length == 1) {
                //   final leftPath = getLeftPath();
                //   if (leftPath.isNotEmpty) {
                //     Get.toNamed(leftPath);
                //   }
                // } else{
                //   final path = getCenterPath();
                //   if (path.isNotEmpty) {
                //     Get.toNamed(path);
                //   }
                // }
              },
              child: Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    // Show profile pictures based on number of users
                    if (widget.notification.users.isNotEmpty)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          height:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          width:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD3D1D2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.notification.users[0].profilePicture,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFAF9F9),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: const Color(0xFFD3D1D2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Second user profile picture (if available)
                    if (widget.notification.users.length >= 2)
                      Positioned(
                        right: 0,
                        bottom:
                            (widget.notification.users.length >= 3) ? null : 0,
                        top: (widget.notification.users.length >= 3) ? 0 : null,
                        child: Container(
                          height:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          width:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD3D1D2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.notification.users[1].profilePicture,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFAF9F9),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: const Color(0xFFD3D1D2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Third user profile picture or +X indicator
                    if (widget.notification.users.length >= 3)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color:
                                  widget.notification.users.length > 3
                                      ? DesignColors.accent.withValues(
                                        alpha: 0.8,
                                      )
                                      : const Color(0xFFFAF9F9),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFD3D1D2),
                                width: 0.5,
                              ),
                            ),
                            child:
                                widget.notification.users.length > 3
                                    ? Center(
                                      child: DesignText(
                                        text:
                                            "+${widget.notification.users.length - 2}",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        widget
                                            .notification
                                            .users[2]
                                            .profilePicture,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: const Color(0xFFFAF9F9),
                                            child: Icon(
                                              Icons.person,
                                              size: 16,
                                              color: const Color(0xFFD3D1D2),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                          ),
                        ),
                      ),

                    // If no users, show default icon
                    if (widget.notification.users.isEmpty)
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F9),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFD3D1D2),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: const Color(0xFFD3D1D2),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),

            //EntityImage
            GestureDetector(
              onTap: () {
                // final path = getRightPath();
                // if (path.isNotEmpty) {
                //   Get.toNamed(path);
                // }
              },
              child: Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.notification.entity.entityImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, color: Colors.grey);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Profile picture with entity text and buttons layout
  Widget _buildPfpEntityTextButtonsLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //Entity Image
            GestureDetector(
              onTap: () {
                // final path = getLeftPath();
                // if (path.isNotEmpty) {
                //   Get.toNamed(path);
                // }
              },
              child: Container(
                height: 64,
                width: 64,
                margin: EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.notification.entity.entityImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, color: Color(0xFFEC4B5D));
                    },
                  ),
                ),
              ),
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   } else {
                  //     final backupPath = getLeftPath();
                  //     if (backupPath.isNotEmpty) {
                  //       Get.toNamed(backupPath);
                  //     }
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Multiple profile pictures with entity text and buttons layout
  Widget _buildMultiPfpEntityTextButtonsLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                //Entity Image
                GestureDetector(
                  onTap: () {
                    // final path = getCenterPath();
                    // if (path.isNotEmpty) {
                    //   Get.toNamed(path);
                    // }
                  },
                  child: Container(
                    height: 64,
                    width: 64,
                    margin: EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF9F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.notification.entity.entityImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.image, color: Color(0xFFEC4B5D));
                        },
                      ),
                    ),
                  ),
                ),

                //user PFP
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: GestureDetector(
                    onTap: () {
                      // final path = getLeftPath();
                      // if (path.isNotEmpty) {
                      //   Get.toNamed(path);
                      // }
                    },
                    child: Container(
                      height: 28,
                      width: 28,
                      margin: EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF9F9),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: const Color(0xFFD3D1D2),
                          width: 0.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          (widget.notification.users.isNotEmpty)
                              ? widget.notification.users.first.profilePicture
                              : "",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              color: Color(0xFFEC4B5D),
                              size: 16,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // // print("path: $path");
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Profile picture with text and buttons layout
  Widget _buildPfpTextButtonsLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            //user PFP
            GestureDetector(
              onTap: () {
                // final path = getLeftPath();
                // if (path.isNotEmpty) {
                //   Get.toNamed(path);
                // }
              },
              child: Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFFD3D1D2),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    (widget.notification.users.isNotEmpty)
                        ? widget.notification.users.first.profilePicture
                        : "",
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFAF9F9),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: const Color(0xFFD3D1D2),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Entity with text and image layout
  Widget _buildEntityTextImageLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //entity image
            GestureDetector(
              onTap: () {
                // final path = getLeftPath();
                // if (path.isNotEmpty) {
                //   Get.toNamed(path);
                // }
              },
              child: Container(
                height: 64,
                width: 64,
                margin: EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.notification.entity.entityImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, color: Color(0xFFEC4B5D));
                    },
                  ),
                ),
              ),
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Multiple profile pictures with text and buttons layout
  Widget _buildMultiPfpTextButtonsLayout() {
    return Card(
      color: Colors.white,
      elevation: 0.8,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Row(
          children: [
            //multi PFP
            GestureDetector(
              onTap: () {
                // if (widget.notification.users.length == 1) {
                //   final path = getLeftPath();
                //   if (path.isNotEmpty) {
                //     Get.toNamed(path);
                //   }
                // } else{
                //   final path = getCenterPath();
                //   if (path.isNotEmpty) {
                //     Get.toNamed(path);
                //   }
                // }
              },
              child: Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                child: Stack(
                  children: [
                    // Show profile pictures based on number of users
                    if (widget.notification.users.isNotEmpty)
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          height:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          width:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD3D1D2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.notification.users[0].profilePicture,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFAF9F9),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: const Color(0xFFD3D1D2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Second user profile picture (if available)
                    if (widget.notification.users.length >= 2)
                      Positioned(
                        right: 0,
                        bottom:
                            (widget.notification.users.length >= 3) ? null : 0,
                        top: (widget.notification.users.length >= 3) ? 0 : null,
                        child: Container(
                          height:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          width:
                              (widget.notification.users.length >= 2) ? 36 : 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF9F9),
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              color: const Color(0xFFD3D1D2),
                              width: 0.5,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.network(
                              widget.notification.users[1].profilePicture,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFFAF9F9),
                                  child: Icon(
                                    Icons.person,
                                    size: 16,
                                    color: const Color(0xFFD3D1D2),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                    // Third user profile picture or +X indicator
                    if (widget.notification.users.length >= 3)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            height: 36,
                            width: 36,
                            decoration: BoxDecoration(
                              color:
                                  widget.notification.users.length > 3
                                      ? DesignColors.accent.withValues(
                                        alpha: 0.8,
                                      )
                                      : const Color(0xFFFAF9F9),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: const Color(0xFFD3D1D2),
                                width: 0.5,
                              ),
                            ),
                            child:
                                widget.notification.users.length > 3
                                    ? Center(
                                      child: DesignText(
                                        text:
                                            "+${widget.notification.users.length - 2}",
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    )
                                    : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.network(
                                        widget
                                            .notification
                                            .users[2]
                                            .profilePicture,
                                        fit: BoxFit.cover,
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          return Container(
                                            color: const Color(0xFFFAF9F9),
                                            child: Icon(
                                              Icons.person,
                                              size: 16,
                                              color: const Color(0xFFD3D1D2),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                          ),
                        ),
                      ),

                    // If no users, show default icon
                    if (widget.notification.users.isEmpty)
                      Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF9F9),
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: const Color(0xFFD3D1D2),
                            width: 0.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 24,
                          color: const Color(0xFFD3D1D2),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            //text
            Expanded(
              child: GestureDetector(
                onTap: () {
                  // final path = getCenterPath();
                  // if (path.isNotEmpty) {
                  //   Get.toNamed(path);
                  // } else {
                  //   final alterPath = getRightPath();
                  //   if (alterPath.isNotEmpty) {
                  //     Get.toNamed(alterPath);
                  //   }
                  // }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
                    ),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // Default layout for unknown types
  Widget _buildDefaultLayout() {
    return GestureDetector(
      onTap: () {
        // final path = getCenterPath();
        // if (path.isNotEmpty) {
        //   Get.toNamed(path);
        // } else {
        //   final alterPath = getLeftPath();
        //   if (alterPath.isNotEmpty) {
        //     Get.toNamed(alterPath);
        //   } else {
        //     final path = getRightPath();
        //     if (path.isNotEmpty) {
        //       Get.toNamed(path);
        //     }
        //   }
        // }
      },
      child: Card(
        color: Colors.white,
        elevation: 0.8,
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                height: 48,
                width: 48,
                margin: EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF9F9),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: const Color(0xFFD3D1D2),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    (widget.notification.users.isNotEmpty)
                        ? widget.notification.users.first.profilePicture
                        : widget.notification.entity.entityImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFFFAF9F9),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          size: 24,
                          color: DesignColors.accent,
                        ),
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text: formatDate(widget.notification.createdDate),
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF989898),
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: widget.notification.title,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF444444),
                    ),
                    DesignText(
                      text: widget.notification.body,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      maxLines: 3,
                      color: Color(0xFF444444),
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

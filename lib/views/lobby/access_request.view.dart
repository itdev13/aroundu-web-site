import 'dart:async';

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/access.req.expanded.view.dart';
import 'package:aroundu/views/lobby/form_page.dart';
import 'package:aroundu/views/lobby/provider/access_request_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../designs/colors.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';

final permissionAccessRequestProvider = FutureProvider.autoDispose.family<
  Map<String, dynamic>,
  Map<String, dynamic>
>((ref, body) async {
  try {
    // Construct URL with ID
    String url =
        'match/lobby/api/v1/accept-access-requests'; // Replace with your endpoint

    // Make GET request (or POST if required)
    final response = await ApiService().post(
      url,
      queryParameters: {},
      body: body, // Add query params if needed
    );

    if (response.statusCode == 200) {
      return response.data as Map<String, dynamic>;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e, stack) {
    throw Exception('Error fetching getAccessRequest : $e  \n $stack');
  }
});

final selectAllProvider = StateProvider.autoDispose<bool>((ref) => false);
final selectedRequestsProvider = StateProvider.autoDispose<Set<String>>(
  (ref) => {},
);

class AccessRequestsView extends ConsumerWidget {
  // final LobbyDetails lobbyDetail;
  final String lobbyId;
  final String? pageTitle;

  const AccessRequestsView({super.key, required this.lobbyId, this.pageTitle});

  // Helper method to build consistent stat items
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF3E79A1)),
            SizedBox(width: 4),
            DesignText(
              text: label,
              fontSize: 10,
              fontWeight: FontWeight.w400,
              color: Colors.black54,
            ),
          ],
        ),
        SizedBox(height: 2),
        DesignText(
          text: value,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final lobby = lobbyDetail.lobby;
    final accessRequestsAsync = ref.watch(
      accessRequestsNotifierProvider(lobbyId),
    );
    final isSelectAll = ref.watch(selectAllProvider);
    final selectedRequests = ref.watch(selectedRequestsProvider);

    // Add refresh capability
    Future<void> onRefresh() async {
      ref
          .read(accessRequestsNotifierProvider(lobbyId).notifier)
          .refresh(lobbyId);
    }

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Scaffold(
      appBar: AppBar(
        title: DesignText(
          text: pageTitle ?? "",
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        actions: [
          accessRequestsAsync.when(
            data:
                (accessRequests) =>
                    accessRequests.isEmpty
                        ? IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: onRefresh,
                        )
                        : IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.5),
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  elevation: 4,
                                  title: Row(
                                    children: [
                                      Icon(
                                        Icons.download_outlined,
                                        color: DesignColors.accent,
                                        size: 20,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "Download Response Data",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Text(
                                    "This will download response data for all attendees in excel sheet format.",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                      height: 1.4,
                                    ),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  contentPadding: EdgeInsets.fromLTRB(
                                    24,
                                    16,
                                    24,
                                    0,
                                  ),
                                  actionsPadding: EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    8,
                                  ),
                                  actions: [
                                    Row(
                                      children: [
                                        // Cancel button - takes up half the space
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: TextButton(
                                              onPressed: () {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Close dialog without action
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    Colors.grey.shade100,
                                                foregroundColor: Colors.black87,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                              ),
                                              child: Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),

                                        // Download button - takes up half the space
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4,
                                            ),
                                            child: TextButton(
                                              onPressed: () async {
                                                Navigator.of(
                                                  context,
                                                ).pop(); // Close dialog
                                                await _handleFileDownload(
                                                  context,
                                                  lobbyId,
                                                );
                                              },
                                              style: TextButton.styleFrom(
                                                backgroundColor:
                                                    DesignColors.accent,
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                padding: EdgeInsets.symmetric(
                                                  vertical: 12,
                                                ),
                                              ),
                                              child: Text(
                                                "Download",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
            error:
                (error, stackTrace) => IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                ),
            loading:
                () => IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: onRefresh,
                ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: onRefresh,
        child: accessRequestsAsync.when(
          data:
              (accessRequests) =>
                  accessRequests.isEmpty
                      ? const Center(child: Text('No access requests'))
                      : Column(
                        children: [
                          if (accessRequests.first.accessRequests.isNotEmpty &&
                              accessRequests
                                      .first
                                      .accessRequests
                                      .first
                                      .lobbyType ==
                                  'PRIVATE')
                            Padding(
                              padding: EdgeInsets.all(16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Checkbox(
                                    value: isSelectAll,
                                    onChanged: (bool? value) {
                                      ref
                                          .read(selectAllProvider.notifier)
                                          .state = value ?? false;
                                      if (value ?? false) {
                                        // Select all requests
                                        final allIds =
                                            accessRequests
                                                .expand(
                                                  (request) =>
                                                      request.accessRequests,
                                                )
                                                .map(
                                                  (request) =>
                                                      request.accessRequestId,
                                                )
                                                .toSet();
                                        ref
                                            .read(
                                              selectedRequestsProvider.notifier,
                                            )
                                            .state = allIds;
                                      } else {
                                        // Deselect all
                                        ref
                                            .read(
                                              selectedRequestsProvider.notifier,
                                            )
                                            .state = {};
                                      }
                                    },
                                  ),
                                  DesignText(
                                    text: "Select all",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: accessRequests.length,
                              itemBuilder: (context, index) {
                                final accessRequest = accessRequests[index];
                                final requests = accessRequest.accessRequests;

                                return Column(
                                  children: List.generate(requests.length, (i) {
                                    final request = requests[i];
                                    final isGroup = request.groupData != null;
                                    final isSelected = selectedRequests
                                        .contains(request.accessRequestId);
                                    return GestureDetector(
                                      onTap:
                                          () => Get.toNamed(
                                            AppRoutes.detailAccessRequest,
                                            arguments: {
                                              'request': request,
                                              'lobbyId': lobbyId,
                                              'isGroup': isGroup,
                                            },
                                          ),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 0,
                                          bottom: 16,
                                        ),
                                        child: Container(
                                          //  margin: EdgeInsets.only(top: 12),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF5F7F9),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            border: Border.all(
                                              color: Colors.grey.withOpacity(
                                                0.15,
                                              ),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  // Profile Picture
                                                  CircleAvatar(
                                                    radius: 24,
                                                    backgroundColor:
                                                        const Color(0xFFEAEFF2),
                                                    child: ClipOval(
                                                      child: Image.network(
                                                        request.profilePictureUrl ??
                                                            "",
                                                        fit: BoxFit.cover,
                                                        width: 48,
                                                        height: 48,
                                                        errorBuilder:
                                                            (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) => Icon(
                                                              Icons.person,
                                                              size: 24,
                                                              color:
                                                                  Colors.grey,
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
                                                                            DesignColors.accent,
                                                                      ),
                                                                    ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 12,
                                                  ), // Space between profile picture and text
                                                  // Name and Request Text
                                                  isGroup
                                                      ? Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            DesignText(
                                                              text:
                                                                  request
                                                                      .groupData!
                                                                      .userInfos
                                                                      .first
                                                                      .name,
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                            DesignText(
                                                              text:
                                                                  "Group of ${(request.groupData!.userInfos.length)}",
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w300,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                      : Expanded(
                                                        child: RichText(
                                                          maxLines: 2,
                                                          overflow:
                                                              TextOverflow
                                                                  .ellipsis, // Handle overflow
                                                          text: TextSpan(
                                                            children: [
                                                              TextSpan(
                                                                text:
                                                                    request
                                                                        .name, // Name part
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500, // w500 for name
                                                                  fontFamily:
                                                                      'Poppins', // Apply Poppins font
                                                                  color:
                                                                      Colors
                                                                          .black, // Set your desired color
                                                                ),
                                                              ),
                                                              TextSpan(
                                                                text:
                                                                    request.lobbyType ==
                                                                            'PRIVATE'
                                                                        ? " requested to join lobby"
                                                                        : " joined lobby", // Rest of the text
                                                                style: TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w300, // w300 for the rest
                                                                  fontFamily:
                                                                      'Poppins', // Apply Poppins font
                                                                  color:
                                                                      Colors
                                                                          .black, // Set your desired color
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                  SizedBox(
                                                    width: 12,
                                                  ), // Space between text and buttons
                                                  // Buttons
                                                  isSelectAll
                                                      ? Checkbox(
                                                        value: isSelected,
                                                        onChanged: (
                                                          bool? value,
                                                        ) {
                                                          final currentSelected =
                                                              ref.read(
                                                                selectedRequestsProvider,
                                                              );
                                                          if (value ?? false) {
                                                            ref
                                                                .read(
                                                                  selectedRequestsProvider
                                                                      .notifier,
                                                                )
                                                                .state = {
                                                              ...currentSelected,
                                                              request
                                                                  .accessRequestId,
                                                            };
                                                          } else {
                                                            currentSelected.remove(
                                                              request
                                                                  .accessRequestId,
                                                            );
                                                            ref
                                                                .read(
                                                                  selectedRequestsProvider
                                                                      .notifier,
                                                                )
                                                                .state = {
                                                              ...currentSelected,
                                                            };
                                                          }
                                                        },
                                                      )
                                                      : request.lobbyType ==
                                                          'PRIVATE'
                                                      ? Row(
                                                        mainAxisSize:
                                                            MainAxisSize
                                                                .min, // Prevent buttons from expanding
                                                        children: [
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  const Color(
                                                                    0xFFEC4B5D,
                                                                  ),
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 8,
                                                                  ), // Button padding
                                                            ),
                                                            onPressed: () async {
                                                              final body = {
                                                                "lobbyId":
                                                                    lobbyId,
                                                                "requestAccessDTOList": [
                                                                  {
                                                                    "responses":
                                                                        "",
                                                                    "accessRequestId":
                                                                        request
                                                                            .accessRequestId,
                                                                    "isAccepted":
                                                                        true,
                                                                  },
                                                                ],
                                                              };
                                                              final res =
                                                                  await ref.read(
                                                                    permissionAccessRequestProvider(
                                                                      body,
                                                                    ).future,
                                                                  );
                                                              if (res['status'] ==
                                                                  'SUCCESS') {
                                                                CustomSnackBar.show(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      "${res['status']} ${res['message']}",
                                                                  type:
                                                                      SnackBarType
                                                                          .success,
                                                                );
                                                              } else {
                                                                CustomSnackBar.show(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      "${res['status']} ${res['message']}",
                                                                  type:
                                                                      SnackBarType
                                                                          .error,
                                                                );
                                                              }

                                                              ref
                                                                  .read(
                                                                    accessRequestsNotifierProvider(
                                                                      lobbyId,
                                                                    ).notifier,
                                                                  )
                                                                  .refresh(
                                                                    lobbyId,
                                                                  );
                                                            },
                                                            child: DesignText(
                                                              text: "Confirm",
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 8,
                                                          ), // Space between buttons
                                                          ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.white,
                                                              side: const BorderSide(
                                                                width:
                                                                    1.0, // 1px border width
                                                                color: Color(
                                                                  0xFF3E79A1,
                                                                ), // Border color
                                                              ),
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical: 8,
                                                                  ), // Button padding
                                                            ),
                                                            onPressed: () async {
                                                              await showCustomBottomSheet(
                                                                context,
                                                              );
                                                              final body = {
                                                                "lobbyId":
                                                                    lobbyId,
                                                                "requestAccessDTOList": [
                                                                  {
                                                                    "responses":
                                                                        ref
                                                                            .read(
                                                                              textControllerProvider,
                                                                            )
                                                                            .text,
                                                                    "accessRequestId":
                                                                        request
                                                                            .accessRequestId,
                                                                    "isAccepted":
                                                                        false,
                                                                  },
                                                                ],
                                                              };
                                                              final res =
                                                                  await ref.read(
                                                                    permissionAccessRequestProvider(
                                                                      body,
                                                                    ).future,
                                                                  );
                                                              if (res['status'] ==
                                                                  'SUCCESS') {
                                                                CustomSnackBar.show(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      "${res['status']} ${res['message']}",
                                                                  type:
                                                                      SnackBarType
                                                                          .success,
                                                                );
                                                              } else {
                                                                CustomSnackBar.show(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      "${res['status']} ${res['message']}",
                                                                  type:
                                                                      SnackBarType
                                                                          .error,
                                                                );
                                                              }
                                                              ref
                                                                  .read(
                                                                    accessRequestsNotifierProvider(
                                                                      lobbyId,
                                                                    ).notifier,
                                                                  )
                                                                  .refresh(
                                                                    lobbyId,
                                                                  );
                                                            },
                                                            child: DesignText(
                                                              text: "Delete",
                                                              fontSize: 12,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  const Color(
                                                                    0xFF3E79A1,
                                                                  ),
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                      : ElevatedButton(
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Colors.white,
                                                          side: const BorderSide(
                                                            width:
                                                                1.0, // 1px border width
                                                            color: Color(
                                                              0xFF3E79A1,
                                                            ), // Border color
                                                          ),
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 8,
                                                              ), // Button padding
                                                        ),
                                                        onPressed: () {
                                                          Get.toNamed(
                                                            AppRoutes
                                                                .detailAccessRequest,
                                                            arguments: {
                                                              'request':
                                                                  request,
                                                              'lobbyId':
                                                                  lobbyId,
                                                              'isGroup':
                                                                  isGroup,
                                                            },
                                                          );
                                                        },
                                                        child: DesignText(
                                                          text: "View",
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: const Color(
                                                            0xFF3E79A1,
                                                          ),
                                                        ),
                                                      ),
                                                ],
                                              ),
                                              Space.h(height: 8),
                                              // Improved attendance stats section with better layout
                                              if (request
                                                          .attendanceStats
                                                          .totalRsvps >=
                                                      0 ||
                                                  request
                                                          .attendanceStats
                                                          .totalAttended >=
                                                      0)
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    // Title
                                                    DesignText(
                                                      text: "Attendance",
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: const Color(
                                                        0xFF3E79A1,
                                                      ),
                                                    ),

                                                    // Stats
                                                    Row(
                                                      children: [
                                                        // RSVP Stats
                                                        _buildStatItem(
                                                          Icons.event_available,
                                                          "RSVPs",
                                                          "${request.attendanceStats.totalRsvps}",
                                                        ),

                                                        // Divider
                                                        Container(
                                                          height: 24,
                                                          width: 1,
                                                          margin:
                                                              EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                              ),
                                                          color: Colors.grey
                                                              .withOpacity(0.3),
                                                        ),

                                                        // Attended Stats
                                                        _buildStatItem(
                                                          Icons
                                                              .check_circle_outline,
                                                          "Attended",
                                                          "${request.attendanceStats.totalAttended}",
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) {
            print("Access request error : $error \n $stack");
            return Center(child: Text('Error: ${error.toString()}'));
          },
        ),
      ),
      bottomNavigationBar:
          isSelectAll
              ? Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  width: sw(1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4B5D),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ), // Button padding
                        ),
                        onPressed: () async {
                          final selectedIds = ref.read(
                            selectedRequestsProvider,
                          );

                          final body = {
                            "lobbyId": lobbyId,
                            "requestAccessDTOList":
                                selectedIds
                                    .map(
                                      (id) => {
                                        "responses": "", // Empty for confirm
                                        "accessRequestId": id,
                                        "isAccepted": true,
                                      },
                                    )
                                    .toList(),
                          };
                          final res = await ref.read(
                            permissionAccessRequestProvider(body).future,
                          );
                          if (res['status'] == 'SUCCESS') {
                            CustomSnackBar.show(
                              context: context,
                              message: "${res['status']} ${res['message']}",
                              type: SnackBarType.success,
                            );
                          } else {
                            CustomSnackBar.show(
                              context: context,
                              message: "${res['status']} ${res['message']}",
                              type: SnackBarType.error,
                            );
                          }
                          ref
                              .read(
                                accessRequestsNotifierProvider(
                                  lobbyId,
                                ).notifier,
                              )
                              .refresh(lobbyId);
                        },
                        child: DesignText(
                          text: "Accept all",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8), // Space between buttons
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(
                            width: 1.0, // 1px border width
                            color: Color(0xFF3E79A1), // Border color
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ), // Button padding
                        ),
                        onPressed: () async {
                          await showCustomBottomSheet(context);
                          final selectedIds = ref.read(
                            selectedRequestsProvider,
                          );

                          final body = {
                            "lobbyId": lobbyId,
                            "requestAccessDTOList":
                                selectedIds
                                    .map(
                                      (id) => {
                                        "responses":
                                            ref
                                                .read(textControllerProvider)
                                                .text, // Empty for confirm
                                        "accessRequestId": id,
                                        "isAccepted": false,
                                      },
                                    )
                                    .toList(),
                          };
                          final res = await ref.read(
                            permissionAccessRequestProvider(body).future,
                          );
                          if (res['status'] == 'SUCCESS') {
                            CustomSnackBar.show(
                              context: context,
                              message: "${res['status']} ${res['message']}",
                              type: SnackBarType.success,
                            );
                          } else {
                            CustomSnackBar.show(
                              context: context,
                              message: "${res['status']} ${res['message']}",
                              type: SnackBarType.error,
                            );
                          }
                          ref
                              .read(
                                accessRequestsNotifierProvider(
                                  lobbyId,
                                ).notifier,
                              )
                              .refresh(lobbyId);
                        },
                        child: DesignText(
                          text: "Deny all ",
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF3E79A1),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : null,
    );
  }

  Future<void> _handleFileDownload(BuildContext context, String lobbyId) async {
    // Show loading indicator
    BuildContext? dialogContext;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        dialogContext = ctx;
        return const Center(
          child: CircularProgressIndicator(color: DesignColors.accent),
        );
      },
    );

    try {
      // Call the download API
      final response = await ApiService().get(
        'match/lobby/$lobbyId/download/access',
      );

      // Close the loading dialog using the stored dialog context
      if (dialogContext != null) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (e) {
          // Ignore errors when closing dialog
        }
      }

      if (response.statusCode == 200) {
        // The response contains a file URL
        final fileUrl = response.data as String;

        // Use a short delay to ensure the previous dialog is fully dismissed
        await Future.delayed(const Duration(milliseconds: 100));

        // Show the FileOptionsDialog as a separate route

        Get.toNamed(
          AppRoutes.downloadAccessRequestData,
          arguments: {"fileUrl": fileUrl},
        );
      } else {
        throw Exception('Failed to download: ${response.statusCode}');
      }
    } catch (e, s) {
      // Close the loading dialog using the stored dialog context
      if (dialogContext != null) {
        try {
          Navigator.of(dialogContext!).pop();
        } catch (e) {
          // Ignore errors when closing dialog
        }
      }

      kLogger.error("error : ", error: e, stackTrace: s);

      // Use a safe way to show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download file: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}

// Method to launch URL in browser
void _launchUrlInBrowser(String url, BuildContext context) async {
  try {
    // Import 'package:url_launcher/url_launcher.dart' at the top of the file
    // Add sheet parameter to URL to ensure second sheet opens
    final Uri uri = Uri.parse(url);
    // Create a new URI with the sheet parameter if it doesn't exist
    final modifiedUrl =
        uri.toString().contains('sheet=')
            ? uri
            : Uri.parse('$url${url.contains('?') ? '&' : '?'}sheet=2');

    if (await canLaunchUrl(modifiedUrl)) {
      await launchUrl(modifiedUrl, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not launch $modifiedUrl');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error opening URL: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Method to download file directly
void _downloadFile(String url, BuildContext context) async {
  try {
    // Import 'package:dio/dio.dart' and 'package:path_provider/path_provider.dart' at the top
    final dio = Dio();
    final directory = await getExternalStorageDirectory();

    if (directory != null) {
      // Extract filename from URL or use a default name
      final fileName =
          url.split('/').last.isNotEmpty
              ? url.split('/').last
              : 'access_requests.xlsx';

      final savePath = '${directory.path}/$fileName';

      // Show download progress
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Downloading...'),
            content: LinearProgressIndicator(),
          );
        },
      );

      // Add sheet parameter to URL to ensure all sheets are accessible
      final downloadUrl =
          url.contains('sheet=')
              ? url
              : '$url${url.contains('?') ? '&' : '?'}sheet=all';

      await dio.download(
        downloadUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Update progress if needed
          }
        },
      );

      // Dismiss progress dialog
      Navigator.pop(context);

      // Show success message with instructions for multiple sheets
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('File Downloaded'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('File saved to: $savePath'),
                SizedBox(height: 8),
                Text(
                  'Note: This Excel file contains multiple sheets. You can access all sheets when opening the file in Excel.',
                  style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      throw Exception('Could not access storage directory');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error downloading file: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Method to copy URL to clipboard
void _copyUrlToClipboard(String url, BuildContext context) {
  try {
    // Import 'package:flutter/services.dart' at the top
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('URL copied to clipboard'),
        backgroundColor: DesignColors.accent,
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error copying URL: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

class RequestView extends StatefulWidget {
  const RequestView({super.key, required this.form});
  final FormModel form;
  @override
  State<RequestView> createState() => _RequestViewState();
}

class _RequestViewState extends State<RequestView> {
  @override
  Widget build(BuildContext context) {
    return PreviewFormScreen(form: widget.form);
  }
}

final textControllerProvider = StateProvider.autoDispose((ref) {
  return TextEditingController();
});

// Provider for character count
final characterCountProvider = StateProvider.autoDispose((ref) {
  return 0;
});

class CustomBottomSheet extends ConsumerWidget {
  const CustomBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = ref.watch(textControllerProvider);
    final characterCount = ref.watch(characterCountProvider);
    textController.clear();
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DesignText(
            text: 'Add note (Optional)',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 8),
          Stack(
            children: [
              TextField(
                controller: textController,
                maxLength: 400,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText:
                      'Eg. "This lobby is fully booked", "Host is no longer accepting access request"',
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                  counterText: '', // Hide the default counter
                ),
                onChanged: (value) {
                  ref.read(characterCountProvider.notifier).state =
                      value.length;
                },
              ),
              Positioned(
                right: 12,
                bottom: 12,
                child: Text(
                  '$characterCount/400',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          DesignText(
            text: 'This message will be visible to the requester',
            color: Colors.grey[600],
            fontSize: 12,
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: DesignText(text: 'Deny all', fontSize: 14),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => Navigator.pop(context, textController.text),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: DesignText(text: 'Confirm all', fontSize: 14),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Function to show bottom sheet
Future<void> showCustomBottomSheet(BuildContext context) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const CustomBottomSheet(),
  );
}

// Separate widget for file options dialog
class FileOptionsDialog extends StatelessWidget {
  final String fileUrl;

  const FileOptionsDialog({Key? key, required this.fileUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps from closing the dialog
            child: Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DesignText(
                      text: "File Ready",
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    SizedBox(height: 12),
                    DesignText(
                      text: "Choose what you want to do with the file:",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    DesignButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: "Open in Browser",
                      onPress: () {
                        Navigator.of(context).pop();
                        _launchUrlInBrowser(fileUrl, context);
                      },
                      titleColor: Colors.white,
                    ),
                    SizedBox(height: 12),
                    DesignButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: "Download File",
                      onPress: () {
                        Navigator.of(context).pop();
                        _downloadFile(fileUrl, context);
                      },
                      titleColor: Colors.white,
                    ),
                    SizedBox(height: 12),
                    DesignButton(
                      padding: EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: "Copy URL",
                      onPress: () {
                        Navigator.of(context).pop();
                        _copyUrlToClipboard(fileUrl, context);
                      },
                      titleColor: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for handling file operations
  void _launchUrlInBrowser(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not launch URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _downloadFile(String url, BuildContext context) async {
    // Implementation for downloading file
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not download file'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _copyUrlToClipboard(String url, BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL copied to clipboard'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

Future<void> _handleFileDownload(BuildContext context, String lobbyId) async {
  // Show loading indicator
  BuildContext? dialogContext;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      dialogContext = ctx;
      return const Center(
        child: CircularProgressIndicator(color: DesignColors.accent),
      );
    },
  );

  try {
    // Call the download API
    final response = await ApiService().get(
      'match/lobby/$lobbyId/download/access',
    );

    // Close the loading dialog using the stored dialog context
    if (dialogContext != null) {
      try {
        Navigator.of(dialogContext!).pop();
      } catch (e) {
        // Ignore errors when closing dialog
      }
    }

    if (response.statusCode == 200) {
      // The response contains a file URL
      final fileUrl = response.data as String;

      // Use a short delay to ensure the previous dialog is fully dismissed
      await Future.delayed(const Duration(milliseconds: 100));

      // Show the FileOptionsDialog as a separate route
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => FileOptionsDialog(fileUrl: fileUrl),
            fullscreenDialog: true,
          ),
        );
      }
    } else {
      throw Exception('Failed to download: ${response.statusCode}');
    }
  } catch (e, s) {
    // Close the loading dialog using the stored dialog context
    if (dialogContext != null) {
      try {
        Navigator.of(dialogContext!).pop();
      } catch (e) {
        // Ignore errors when closing dialog
      }
    }

    kLogger.error("error : ", error: e, stackTrace: s);

    // Use a safe way to show error message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download file: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/access_request_details.lobby.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/access_request_user.lobby.view.dart';
import 'package:aroundu/views/lobby/form_page.dart';
import 'package:aroundu/views/lobby/lobby.view.dart';
import 'package:aroundu/views/profile/controllers/controller.groups.profiledart.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/profile/user_profile_followed_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

final getAccessRequestProvider = FutureProvider.autoDispose.family<
  AccessRequestDetails,
  String
>((ref, id) async {
  try {
    // Construct URL with ID
    String url =
        'match/lobby/api/v1/accessRequest/$id'; // Replace with your endpoint

    // Make GET request (or POST if required)
    final response = await ApiService().get(
      url,
      queryParameters: {}, // Add query params if needed
    );

    if (response.statusCode == 200) {
      return AccessRequestDetails.fromJson(
        response.data as Map<String, dynamic>,
      );
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (e, stack) {
    throw Exception('Error fetching getAccessRequest $id: $e  \n $stack');
  }
});

final attendingAccessRequestProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, Map<String, dynamic>>((ref, params) async {
      try {
        final response = await ApiService().post(
          'match/lobby/api/v1/request-access',
          body: params,
        );

        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: response.data['message']);
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception(
            'Failed to submit access request: ${response.statusCode}',
          );
        }
      } catch (e, stack) {
        throw Exception('Error submitting access request: $e\n$stack');
      }
    });

final finalizeAccessRequestProvider = FutureProvider.autoDispose
    .family<Map<String, dynamic>, String>((ref, accessReqId) async {
      try {
        final response = await ApiService().post(
          'match/lobby/api/v1/finalize-request-access/$accessReqId',
          body: {},
        );

        if (response.statusCode == 200) {
          return response.data as Map<String, dynamic>;
        } else {
          throw Exception(
            'Failed to submit access request: ${response.statusCode}',
          );
        }
      } catch (e, stack) {
        throw Exception('Error submitting access request: $e\n$stack');
      }
    });

class SharedAccessRequestCardExtendedView extends ConsumerWidget {
  const SharedAccessRequestCardExtendedView({
    super.key,
    required this.accessReqId,
  });
  final String accessReqId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessRequestAsync = ref.watch(getAccessRequestProvider(accessReqId));
    return accessRequestAsync.when(
      loading:
          () => const Scaffold(
            body: Center(child: Center(child: CircularProgressIndicator())),
          ),
      error:
          (error, stack) =>
              const Scaffold(body: Center(child: Text('Something went wrong'))),
      data:
          (accessRequest) => Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                ),
                onPressed: () => Get.back(),
              ),
              title: const DesignText(
                text: "Lobby Invitation",
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Lobby Information
                    GestureDetector(
                      onTap:
                          () => Get.toNamed(
                            AppRoutes.lobby.replaceAll(
                              ':lobbyId',
                              accessRequest.lobbyId,
                            ),
                          ),
                      child: Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    child:
                                        accessRequest.mediaUrl.isNotEmpty
                                            ? Image.network(
                                              accessRequest.mediaUrl,
                                              height: 100,
                                              width: 100,
                                              fit: BoxFit.cover,
                                              loadingBuilder: (
                                                context,
                                                child,
                                                loadingProgress,
                                              ) {
                                                if (loadingProgress == null) {
                                                  return child;
                                                }
                                                return Container(
                                                  height: 100,
                                                  width: 100,
                                                  color: Colors.grey[200],
                                                  child: Center(
                                                    child: CircularProgressIndicator(
                                                      value:
                                                          loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                      strokeWidth: 2,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                );
                                              },
                                              errorBuilder: (
                                                context,
                                                error,
                                                stackTrace,
                                              ) {
                                                return Container(
                                                  height: 100,
                                                  width: 100,
                                                  color: Colors.grey[100],
                                                  child: const Center(
                                                    child: Icon(
                                                      Icons.groups_rounded,
                                                      size: 40,
                                                      color: Color(0xFFEC4B5D),
                                                    ),
                                                  ),
                                                );
                                              },
                                            )
                                            : Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.grey[100],
                                              child: const Center(
                                                child: Icon(
                                                  Icons.groups_rounded,
                                                  size: 40,
                                                  color: Color(0xFFEC4B5D),
                                                ),
                                              ),
                                            ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          DesignText(
                                            text: accessRequest.lobbyName,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black,
                                          ),
                                          const SizedBox(height: 2),
                                          DesignText(
                                            text: accessRequest.lobbyType,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black54,
                                          ),
                                          // const SizedBox(height: 26),
                                          // Row(
                                          //   children: [
                                          //     const Icon(Icons.calendar_today,
                                          //         size: 14, color: Colors.red),
                                          //     const SizedBox(width: 8),
                                          //     Expanded(
                                          //       child: DesignText(
                                          //         text: '${accessRequest.lobby?.startTime ?? 'TBD'} - ${accessRequest.lobby?.endTime ?? 'TBD'}',
                                          //         fontSize: 10,
                                          //         fontWeight: FontWeight.w400,
                                          //         color: Colors.black54,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                          // const SizedBox(height: 8),
                                          // Row(
                                          //   children: [
                                          //     const Icon(Icons.location_on,
                                          //         size: 14, color: Colors.red),
                                          //     const SizedBox(width: 8),
                                          //     Expanded(
                                          //       child: DesignText(
                                          //         text: accessRequest.lobby?.location ?? 'Location TBD',
                                          //         fontSize: 10,
                                          //         fontWeight: FontWeight.w400,
                                          //         color: Colors.black54,
                                          //       ),
                                          //     ),
                                          //   ],
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: DesignColors.accent,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: DesignText(
                            text:
                                'This person has invited you to join a private lobby. Please note that this is a group request - either everyone gets in, or no one does.',
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 10,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const DesignText(
                      text: 'You are invited by',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),

                    // Show additional admins from userInfos
                    ...accessRequest.groupData.userInfos
                        .where(
                          (user) =>
                              user.isAdmin &&
                              user.userId != accessRequest.lobbyAdmin?.userId,
                        )
                        .map(
                          (admin) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final uid =
                                    await GetStorage().read("userUID") ?? '';

                                //TODO: add profile page
                                if (admin.userId != "") {
                                  Get.toNamed(AppRoutes.myProfile);
                                  // Get.to(
                                  // () =>
                                  // (admin.userId == uid)
                                  //     ?
                                  // ProfileDetailsFollowedScreen(),
                                  // : ProfileDetailsScreen(
                                  //     userId: admin.userId,
                                  //   ),
                                  // );
                                }
                              },
                              child: Card(
                                color: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage:
                                        admin.profilePictureUrl.isNotEmpty
                                            ? NetworkImage(
                                              admin.profilePictureUrl,
                                            )
                                            : null,
                                    backgroundColor: Colors.grey[200],
                                    child:
                                        admin.profilePictureUrl.isEmpty
                                            ? const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            )
                                            : null,
                                  ),
                                  title: DesignText(
                                    text: admin.name,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                  ),
                                  subtitle: DesignText(
                                    text: admin.userName,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.black54,
                                  ),
                                  // trailing:  Chip(
                                  //   label: DesignText(
                                  //     text: 'Admin',
                                  //     fontSize: 10,
                                  //     fontWeight: FontWeight.w500,
                                  //     color: Colors.white,
                                  //   ),
                                  //   backgroundColor: Color(0xFFEC4B5D),
                                  //   padding: EdgeInsets.symmetric(
                                  //       horizontal: 8, vertical: 0),
                                  //   shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(24),
                                  //   ),
                                  // ),
                                ),
                              ),
                            ),
                          ),
                        ),

                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const DesignText(
                          text: 'Who else are attending',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        if ((accessRequest.isAdmin) &&
                            accessRequest.isFinalised == false)
                          GestureDetector(
                            onTap: () async {
                              final groupController =
                                  GroupController().initialized
                                      ? Get.find<GroupController>()
                                      : Get.put(GroupController());
                              final profileController =
                                  ProfileController().initialized
                                      ? Get.find<ProfileController>()
                                      : Get.put(ProfileController());
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.transparent,
                                    content: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        CircularProgressIndicator(
                                          color: DesignColors.accent,
                                          strokeWidth: 2,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );

                              await groupController.fetchGroups();
                              await profileController.getFriends();

                              Get.toNamed(
                                AppRoutes.lobbyAccessRequestShare,
                                arguments: {
                                  'friends': profileController.friendsList,
                                  'squads': groupController.groups,
                                  'lobbyId': accessRequest.lobbyId,
                                  'lobbyHasForm': accessRequest.hasForm,
                                  'lobbyIsPrivate':
                                      accessRequest.lobbyType == 'PRIVATE',
                                  'requestText': "",
                                  // 'selectedTickets': widget.selectedTickets,

                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: DesignColors.accent.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: DesignText(
                                text: '+ Add',
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: DesignColors.accent,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Card(
                      color: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const DesignText(
                                  text: 'Total no. of attendee',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54,
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: DesignColors.accent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: DesignText(
                                    text:
                                        '${accessRequest.groupData.userInfos.length - 1}',
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: DesignColors.accent,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Colors.grey, thickness: 0.4),
                            const SizedBox(height: 16),
                            Column(
                              children:
                                  accessRequest.groupData.userInfos
                                          .where((user) => !user.isAdmin)
                                          .isNotEmpty
                                      ? accessRequest.groupData.userInfos
                                          .where((user) => !user.isAdmin)
                                          .map((attendee) {
                                            return GestureDetector(
                                              onTap: () async {
                                                final uid =
                                                    await GetStorage().read(
                                                      "userUID",
                                                    ) ??
                                                    '';
                                                if (attendee.userId != "") {
                                                  //TODO: add profile

                                                  Get.toNamed(
                                                    AppRoutes.myProfile,
                                                  );
                                                  // Get.to(
                                                  // () =>
                                                  // (attendee.userId == uid)
                                                  //     ?
                                                  // ProfileDetailsFollowedScreen(),
                                                  // : ProfileDetailsScreen(
                                                  //     userId: attendee.userId,
                                                  //   ),
                                                  // );
                                                }
                                              },
                                              child: ListTile(
                                                leading: CircleAvatar(
                                                  backgroundImage:
                                                      attendee
                                                              .profilePictureUrl
                                                              .isNotEmpty
                                                          ? NetworkImage(
                                                            attendee
                                                                .profilePictureUrl,
                                                          )
                                                          : null,
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  child:
                                                      attendee
                                                              .profilePictureUrl
                                                              .isEmpty
                                                          ? const Icon(
                                                            Icons.person,
                                                            color: Colors.grey,
                                                          )
                                                          : null,
                                                ),
                                                title: DesignText(
                                                  text: attendee.name,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                                subtitle: DesignText(
                                                  text: attendee.userName,
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black54,
                                                ),
                                                trailing: const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 24,
                                                ),
                                              ),
                                            );
                                          })
                                          .toList()
                                      : [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 24,
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.people_outline_rounded,
                                                size: 48,
                                                color: Colors.grey[400],
                                              ),
                                              const SizedBox(height: 12),
                                              DesignText(
                                                text: "No attendees yet",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[600],
                                              ),
                                              const SizedBox(height: 4),
                                              const DesignText(
                                                text:
                                                    "Be the first to join this lobby!",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.grey,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 24),
                        SizedBox(width: 8),
                        Expanded(
                          child: DesignText(
                            text:
                                'The person invited you to join this lobby will be paying the lobby charges for all the attendees.',
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                            fontSize: 10,
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16.0),
              child: Builder(
                builder: (context) {
                  final uid = GetStorage().read("userUID") ?? '';

                  // Check if user is admin in the group data
                  final isUserAdmin = accessRequest.groupData.userInfos.any(
                    (user) => user.userId == uid && user.isAdmin,
                  );

                  // Check if user is a member (non-admin) in the group data
                  final isUserMember = accessRequest.groupData.userInfos.any(
                    (user) => user.userId == uid && !user.isAdmin,
                  );

                  // Case 1: User is admin - Show finalize request button
                  if ((isUserAdmin || accessRequest.isAdmin) &&
                      accessRequest.isFinalised == false) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  await ref.read(
                                    finalizeAccessRequestProvider(
                                      accessReqId,
                                    ).future,
                                  );
                                  Get.back();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEC4B5D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const DesignText(
                                  text: 'Finalize Request',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  } else if (accessRequest.isFinalised) {
                    return SizedBox.shrink();
                  }
                  // Case 2: User is a member (non-admin) - Show "Are you attending" with both buttons
                  else if (isUserMember) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DesignText(
                          text: 'Are you attending this lobby?',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () async {
                                  await ref.read(
                                    attendingAccessRequestProvider({
                                      'groupId':
                                          accessRequest.groupData.groupId,
                                      // 'form': accessRequest.form,
                                      'lobbyId': accessRequest.lobbyId,
                                      'exitRequest': true,
                                    }).future,
                                  );
                                  Get.back();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFF3E79A1),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(148),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const DesignText(
                                  text: 'Not Attending',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF3E79A1),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        ),
                      ],
                    );
                  }
                  // Case 3: User is not in the list - Show only the attending button
                  else {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const DesignText(
                          text: 'Are you attending this lobby?',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (accessRequest.hasForm) {
                                    Get.offNamed(
                                      AppRoutes.accessRequestFormFillView,
                                      arguments: {
                                        'lobbyId': accessRequest.lobbyId,
                                        'groupId':
                                            accessRequest.groupData.groupId,
                                        'isPrivate':
                                            accessRequest.lobbyType ==
                                            'PRIVATE',
                                      },
                                    );
                                  } else {
                                    await ref.read(
                                      attendingAccessRequestProvider({
                                        'groupId':
                                            accessRequest.groupData.groupId,
                                        // 'form': accessRequest.form,
                                        'lobbyId': accessRequest.lobbyId,
                                      }).future,
                                    );
                                    Get.back();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFEC4B5D),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(48),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const DesignText(
                                  text: 'Attending',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
    );
  }
}

class AccessRequestFormFillView extends ConsumerStatefulWidget {
  const AccessRequestFormFillView({
    super.key,
    required this.lobbyId,
    required this.groupId,
    required this.isPrivate,
  });
  final String lobbyId;
  final String groupId;
  final bool isPrivate;

  @override
  ConsumerState<AccessRequestFormFillView> createState() =>
      _AccessRequestFormFillViewState();
}

class _AccessRequestFormFillViewState
    extends ConsumerState<AccessRequestFormFillView> {
  final TextEditingController requestedTextEditingController =
      TextEditingController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formStateProvider(widget.lobbyId).notifier).reloadFormData([]);
    });
    super.initState();
  }

  @override
  void dispose() {
    // Dispose controller directly
    requestedTextEditingController.dispose();

    super.dispose();
  }

  void resetState() {
    print('resetState called');
    if (mounted) {
      print('resetState called in mounted');
      ref.read(requestTextProvider.notifier).state = '';
      ref.invalidate(lobbyFormAutofillProvider((lobbyId:widget.lobbyId, selectedTicketIds: [])));
      ref.read(formStateProvider(widget.lobbyId).notifier).resetForm();
      ref.invalidate(formStateProvider(widget.lobbyId));
    }
  }

  void submitRequest(BuildContext context) async {
    final requestText = ref.read(requestedText);
    final formNotifier = ref.read(formStateProvider(widget.lobbyId).notifier);

    // Check if the message is empty when required
    if (requestText.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Message cannot be empty",
        type: SnackBarType.error,
      );
      return;
    }

    // Check if all mandatory questions have been answered
    final missingQuestion = formNotifier.getMandatoryQuestionWithoutAnswer();
    if (missingQuestion != null) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: DesignText(
                text: "Incomplete Form",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              content: DesignText(
                text:
                    "Please answer the mandatory question:\n '' $missingQuestion ''",
                fontSize: 12,
                fontWeight: FontWeight.w400,
                maxLines: 10,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: DesignText(
                    text: "OK",
                    fontSize: 12,
                    color: DesignColors.accent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
      );
      return;
    }

    try {
      // Get final list of questions with their answers
      final finalQuestions = formNotifier.getQuestionsWithAnswers();

      // Convert to JSON for submission
      final formModel = FormModel(
        title: ref.read(formStateProvider(widget.lobbyId)).title,
        questions: finalQuestions,
      );

      kLogger.trace(formModel.toJson().toString());

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.transparent,
            content: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: DesignColors.accent,
                  strokeWidth: 2,
                ),
              ],
            ),
          );
        },
      );

      final res = await ref.read(
        attendingAccessRequestProvider({
          'groupId': widget.groupId,
          'form': formModel.toJson(),
          'lobbyId': widget.lobbyId,
        }).future,
      );

      // Close loading dialog
      Navigator.pop(context);

      kLogger.trace("attendingAccessRequestProvider : $res");

      // Reset state and navigate
      resetState();

      Get.back();
    } catch (e, s) {
      // Handle submission errors
      kLogger.error("error :", error: e, stackTrace: s);
      Get.snackbar(
        "Error",
        "Failed to submit form: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        resetState();
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: true,
            title: DesignText(
              text: 'Fill Form',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            leading: IconButton(
              onPressed: () {
                resetState();
                Get.back();
              },
              icon: DesignIcon.icon(
                icon: Icons.arrow_back_ios_new_rounded,
                size: 18,
              ),
            ),
            actions: [
              Padding(
                padding: EdgeInsets.all(16),
                child: InkWell(
                  onTap: resetState,
                  child: DesignText(
                    text: 'Clear',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF3E79A1),
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: GestureDetector(
            onTap: () => submitRequest(context),
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 24,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                child: Container(
                  width: 0.1 * sw,
                  height: 0.06 * sh,
                  color: Colors.red,
                  child: Center(
                    child: DesignText(
                      text: "Attending",
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Space(height: 34),
                  _buildFormContent(
                    lobbyId: widget.lobbyId,
                    isPrivate: widget.isPrivate,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent({required String lobbyId, required bool isPrivate}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Request message section
        if (isPrivate) ...[
          Card(
            shadowColor: Color(0x143E79A1),
            elevation: 6,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 18,
                top: 12,
                left: 12,
                right: 12,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DesignText(
                      text: "Add note for the host ",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                  Space.h(height: 12),

                  // TextField to enter request text
                  DesignTextField(
                    controller: requestedTextEditingController,
                    hintText: "Enter Request Message",
                    maxLines: 5,
                    fontSize: 12,
                    onChanged: (value) {
                      ref.read(requestedText.notifier).state = value!;
                    },
                    borderRadius: 24,
                  ),
                ],
              ),
            ),
          ),
          Space.h(height: 34),
        ],

        // Form section
        DesignText(
          text: "Fill the survey form",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF323232),
        ),
        Space.h(height: 12),
        DesignText(
          text:
              "Your answer to this survey from will be visible to the lobby host",
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Color(0xFF444444),
          maxLines: 2,
        ),
        Space.h(height: 34),

        _buildFormQuestions(lobbyId),
      ],
    );
  }

  Widget _buildFormQuestions(String lobbyId) {
    final formState = ref.watch(formStateProvider(lobbyId));
    final formNotifier = ref.watch(formStateProvider(lobbyId).notifier);
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form title
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: DesignText(
        //     text: formState.title,
        //     fontSize: 16,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),

        // Form questions
        Padding(
          // constraints: BoxConstraints(maxHeight: 0.6.sh),
          padding: EdgeInsets.only(bottom: 0.1 * sh),
          child:
              formState.questions.isEmpty
                  ? FutureBuilder(
                    future: Future.delayed(const Duration(seconds: 2)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEC4B5D),
                          ),
                        );
                      } else {
                        return Center(
                          child: DesignText(
                            text: "No questions found",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF323232),
                          ),
                        );
                      }
                    },
                  )
                  : Column(
                    children: List.generate(formState.questions.length, (
                      index,
                    ) {
                      final question = formState.questions[index];

                      // Text question
                      if (question.questionType == 'text') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Answer",
                                    fontSize: 12,
                                    onChanged: (val) => formNotifier.updateAnswer(question.id, val!),
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Number question
                      else if (question.questionType == 'number') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter a number",
                                    fontSize: 12,
                                    inputType: TextInputType.number,
                                    onEditingComplete: () {
                                      if (controller.text != null) {
                                        if (controller.text.isEmpty || RegExp(r'^\d+$').hasMatch(controller.text)) {
                                          formNotifier.updateAnswer(question.id, controller.text);
                                        } else {
                                          // Revert to previous valid value
                                          controller.text = question.answer;
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );
                                          // Show error message
                                          Fluttertoast.showToast(
                                            msg: "Please enter digits only",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      }
                                    },
                                    onChanged: (val) {
                                      // Validate: only allow digits
                                      if (val != null) {
                                        if (val.isEmpty || RegExp(r'^\d+$').hasMatch(val)) {
                                          formNotifier.updateAnswer(question.id, val);
                                        } else {
                                          // Revert to previous valid value
                                          controller.text = question.answer;
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );
                                          // Show error message
                                          // Fluttertoast.showToast(
                                          //   msg: "Please enter digits only",
                                          //   toastLength: Toast.LENGTH_SHORT,
                                          //   gravity: ToastGravity.BOTTOM,
                                          //   backgroundColor: Colors.red,
                                          //   textColor: Colors.white,
                                          // );
                                        }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Email question
                      else if (question.questionType == 'email') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter your email",
                                    fontSize: 12,
                                    inputType: TextInputType.emailAddress,
                                    onEditingComplete: () {
                                      if (controller.text.isNotEmpty &&
                                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(controller.text)) {
                                        // Show warning but don't revert the text
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid email address",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        // Update the answer regardless of validation
                                        formNotifier.updateAnswer(question.id, val);

                                        // Validate email format if not empty
                                        if (val.isNotEmpty &&
                                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                          // Show warning but don't revert the text
                                          // Fluttertoast.showToast(
                                          //   msg: "Please enter a valid email address",
                                          //   toastLength: Toast.LENGTH_SHORT,
                                          //   gravity: ToastGravity.BOTTOM,
                                          //   backgroundColor: Colors.orange,
                                          //   textColor: Colors.white,
                                          // );
                                        }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Date question
                      else if (question.questionType == 'date') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            controller.text.isNotEmpty
                                                ? DateTime.parse(controller.text)
                                                : DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: DesignColors.accent,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Color(0xFF262933),
                                              ),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: DesignColors.accent,
                                                  textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (picked != null) {
                                        // Format date as ISO string for storage
                                        final formattedDate = picked.toIso8601String();
                                        controller.text = formattedDate;
                                        formNotifier.updateAnswer(question.id, formattedDate);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: DesignColors.border),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            controller.text.isNotEmpty ? _formatDate(controller.text) : "Select a date",
                                            style: TextStyle(
                                              color: controller.text.isNotEmpty ? Colors.black : Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // File question
                      else if (question.questionType == 'file') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 8),
                                  Text(
                                    "Accepts PDF, PNG, JPG, MP4 files (Max 50MB)",
                                    style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Poppins'),
                                  ),
                                  Space.h(height: 12),
                                  InkWell(
                                    onTap: () async {
                                      try {
                                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'mp4'],
                                          withData: true, // Required for web
                                        );

                                        if (result != null && result.files.single.bytes != null) {
                                          // Get file data for web
                                          final file = result.files.single;
                                          final bytes = file.bytes!;
                                          final filename = file.name;

                                          // Check file size (50MB = 50 * 1024 * 1024 bytes)
                                          if (bytes.length > 50 * 1024 * 1024) {
                                            Fluttertoast.showToast(
                                              msg: "File size exceeds 50MB limit",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }

                                          // Show loading indicator
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.transparent,
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(color: DesignColors.accent),
                                                    SizedBox(height: 16),
                                                    Text("Uploading file...", style: TextStyle(color: Colors.white)),
                                                  ],
                                                ),
                                              );
                                            },
                                          );

                                          // Upload file
                                          try {
                                            final uploadBody = {
                                              'userId': await GetStorage().read("userUID") ?? '',
                                              'lobbyId': lobbyId,
                                              'questionId': question.id,
                                            };

                                            final result = await FileUploadService().uploadBytes(
                                              "user/upload/api/v1/file",
                                              bytes,
                                              filename,
                                              uploadBody,
                                            );

                                            // Close loading dialog
                                            Navigator.pop(context);

                                            if (result.statusCode == 200) {
                                              String fileUrl = result.data['imageUrl'];
                                              controller.text = fileUrl;
                                              formNotifier.updateAnswer(question.id, fileUrl);

                                              Fluttertoast.showToast(
                                                msg: "File uploaded successfully",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: "Failed to upload file",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                              );
                                            }
                                          } catch (e) {
                                            // Close loading dialog
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                              msg: "Error uploading file: $e",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                          }
                                        }
                                      } catch (e, s) {
                                        kLogger.error("Error selecting file:", error: e, stackTrace: s);
                                        Fluttertoast.showToast(
                                          msg: "Error selecting file: $e",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: DesignColors.border),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child:
                                          controller.text.isEmpty
                                              ? Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 5,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.cloud_upload_outlined,
                                                      color: Colors.grey.shade600,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        "Upload File",
                                                        style: TextStyle(
                                                          color: Colors.grey.shade700,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(Icons.add, color: Colors.grey.shade600, size: 20),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              : Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.topRight,
                                                    children: [
                                                      if (_isImageFile(controller.text))
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            controller.text,
                                                            height: 120,
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error, stackTrace) =>
                                                                    Icon(Icons.image, size: 50, color: Colors.grey),
                                                          ),
                                                        )
                                                      else if (_isPdfFile(controller.text))
                                                        Icon(Icons.picture_as_pdf, size: 50, color: Colors.red)
                                                      else if (_isVideoFile(controller.text))
                                                        Icon(Icons.video_file, size: 50, color: Colors.blue),
                                                      IconButton(
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          minimumSize: Size(32, 32),
                                                          maximumSize: Size(32, 32),
                                                        ),
                                                        icon: Icon(Icons.close, color: Colors.black, size: 16),
                                                        onPressed: () {
                                                          controller.clear();
                                                          formNotifier.updateAnswer(question.id, '');
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    _getFileNameFromUrl(controller.text),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // URL question
                      else if (question.questionType == 'url') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter URL",
                                    fontSize: 12,
                                    inputType: TextInputType.url,
                                    onEditingComplete: () {
                                      kLogger.trace(isValidUrl(controller.text).toString());
                                      // Validate URL format if not empty
                                      if (controller.text.isNotEmpty && !isValidUrl(controller.text)) {
                                        // Show warning but don't revert the text
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid URL",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        // Update the answer regardless of validation
                                        formNotifier.updateAnswer(question.id, val);

                                        // Validate URL format if not empty
                                        // if (val.isNotEmpty && !_isValidUrl(val)) {
                                        //   // Show warning but don't revert the text
                                        //   Fluttertoast.showToast(
                                        //     msg: "Please enter a valid URL",
                                        //     toastLength: Toast.LENGTH_SHORT,
                                        //     gravity: ToastGravity.BOTTOM,
                                        //     backgroundColor: Colors.orange,
                                        //     textColor: Colors.white,
                                        //   );
                                        // }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Multiple choice question
                      else if (question.questionType == 'multiple-choice') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  ...question.options.map((option) {
                                    return CheckboxListTile(
                                      title: DesignText(
                                        text: option,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF444444),
                                      ),
                                      value: question.answer == option,
                                      onChanged: (val) {
                                        if (val != null && val) {
                                          formNotifier.updateAnswer(question.id, option);
                                        }
                                      },
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                      activeColor: const Color(0xFFEC4B5D),
                                      checkColor: Colors.white,
                                      controlAffinity: ListTileControlAffinity.leading,
                                      dense: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Default fallback for unsupported question types
                      return Container();
                    }),
                  ),
        ),
      ],
    );
  }
    // Helper method to format date for display
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoString; // Return original string if parsing fails
    }
  }

  // Helper method to extract file name from URL
  String _getFileNameFromUrl(String url) {
    try {
      return url.split('/').last;
    } catch (e) {
      return url; // Return original URL if extraction fails
    }
  }

  bool isValidUrl(String url) {
    if (url.isEmpty || url.trim().isEmpty) return false;

    String cleanUrl = url.trim();

    // Basic sanity checks
    if (cleanUrl.length < 3 ||
        cleanUrl.contains(' ') ||
        cleanUrl.contains('\n') ||
        cleanUrl.contains('\t') ||
        cleanUrl.contains('\r')) {
      return false;
    }

    // Remove protocol if present to check the domain part
    String domainPart = cleanUrl;
    bool hasProtocol = false;

    if (cleanUrl.startsWith('http://')) {
      domainPart = cleanUrl.substring(7);
      hasProtocol = true;
    } else if (cleanUrl.startsWith('https://')) {
      domainPart = cleanUrl.substring(8);
      hasProtocol = true;
    }

    // Remove path, query, and fragment to isolate domain
    domainPart = domainPart.split('/')[0].split('?')[0].split('#')[0];

    // Handle port
    String domain = domainPart.split(':')[0];

    // Domain must not be empty after all parsing
    if (domain.isEmpty) return false;

    // Validate the domain structure BEFORE trying Uri.parse
    if (!_isValidDomainStructure(domain)) {
      return false;
    }

    // Now try to parse with https if no protocol
    String urlToParse = hasProtocol ? cleanUrl : 'https://$cleanUrl';

    // Additional attempt with www if needed
    if (!hasProtocol && !cleanUrl.startsWith('www.') && !_isIpAddress(domain)) {
      String urlWithWww = 'https://www.$cleanUrl';
      Uri? uriWithWww = Uri.tryParse(urlWithWww);
      if (uriWithWww != null && _isValidParsedUri(uriWithWww)) {
        return true;
      }
    }

    Uri? uri = Uri.tryParse(urlToParse);
    return uri != null && _isValidParsedUri(uri);
  }

  bool _isValidDomainStructure(String domain) {
    if (domain.isEmpty || domain.length > 253) return false;

    // Handle localhost
    if (domain == 'localhost') return true;

    // Check if it's an IP address
    if (_isIpAddress(domain)) {
      return _isValidIpAddress(domain);
    }

    // For domain names, must contain at least one dot
    if (!domain.contains('.')) return false;

    // Cannot start or end with dot or hyphen
    if (domain.startsWith('.') || domain.endsWith('.') || domain.startsWith('-') || domain.endsWith('-')) {
      return false;
    }

    // Cannot contain consecutive dots
    if (domain.contains('..')) return false;

    // Split into labels and validate each
    final labels = domain.split('.');
    if (labels.length < 2) return false;

    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      if (!_isValidDomainLabel(label, i == labels.length - 1)) {
        return false;
      }
    }

    return true;
  }

  bool _isValidDomainLabel(String label, bool isTLD) {
    if (label.isEmpty || label.length > 63) return false;

    // Cannot start or end with hyphen
    if (label.startsWith('-') || label.endsWith('-')) return false;

    // Must contain only alphanumeric characters and hyphens
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(label)) return false;

    // If it's a TLD (last label), additional validation
    if (isTLD) {
      // TLD must be at least 2 characters
      if (label.length < 2) return false;

      // TLD should contain at least one letter
      if (!RegExp(r'[a-zA-Z]').hasMatch(label)) return false;

      // Common valid TLD patterns - reject obvious random strings
      if (!_isValidTLD(label)) return false;
    } else {
      // Non-TLD labels cannot be all hyphens or have weird patterns
      if (RegExp(r'^-+$').hasMatch(label)) return false;
    }

    return true;
  }

  bool _isValidTLD(String tld) {
    // Convert to lowercase for checking
    String lowerTLD = tld.toLowerCase();

    // List of definitely invalid TLDs (random letter combinations)
    final obviouslyInvalid = {
      'aa',
      'bb',
      'cc',
      'dd',
      'ee',
      'ff',
      'gg',
      'hh',
      'ii',
      'jj',
      'kk',
      'll',
      'mm',
      'nn',
      'oo',
      'pp',
      'qq',
      'rr',
      'ss',
      'tt',
      'uu',
      'vv',
      'ww',
      'xx',
      'yy',
      'zz',
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'fff',
      'ggg',
      'hhh',
      'iii',
      'jjj',
      'kkk',
      'lll',
      'mmm',
      'nnn',
      'ooo',
      'ppp',
      'qqq',
      'rrr',
      'sss',
      'ttt',
      'uuu',
      'vvv',
      'www',
      'xxx',
      'yyy',
      'zzz',
    };

    if (obviouslyInvalid.contains(lowerTLD)) return false;

    // Check for common valid TLD patterns
    // Real TLDs usually have meaningful patterns
    final commonValidTLDs = {
      'com',
      'org',
      'net',
      'gov',
      'edu',
      'mil',
      'int',
      'co',
      'io',
      'ai',
      'me',
      'uk',
      'us',
      'ca',
      'au',
      'de',
      'fr',
      'jp',
      'cn',
      'in',
      'br',
      'mx',
      'ru',
      'info',
      'biz',
      'name',
      'pro',
      'aero',
      'asia',
      'cat',
      'coop',
      'jobs',
      'mobi',
      'museum',
      'post',
      'tel',
      'travel',
      'xxx',
      'app',
      'dev',
      'tech',
      'online',
      'site',
      'website',
      'store',
      'blog',
      'news',
      'today',
      'world',
    };

    // If it's a common valid TLD, accept it
    if (commonValidTLDs.contains(lowerTLD)) return true;

    // For other TLDs, check if they look reasonable
    // Real TLDs typically:
    // 1. Are not random character sequences
    // 2. Have vowels and consonants mixed reasonably
    // 3. Don't have repeating patterns

    // Check for reasonable letter distribution
    if (lowerTLD.length >= 3) {
      // Count vowels
      int vowels = 0;
      for (int i = 0; i < lowerTLD.length; i++) {
        if ('aeiou'.contains(lowerTLD[i])) vowels++;
      }

      // Should have at least one vowel for longer TLDs
      if (vowels == 0 && lowerTLD.length > 3) return false;

      // Check for excessive repetition
      if (RegExp(r'(.)\1{2,}').hasMatch(lowerTLD)) return false;
    }

    // If it passes basic checks and isn't obviously invalid, accept it
    return true;
  }

  bool _isIpAddress(String host) {
    // IPv4 pattern
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      return true;
    }

    // Basic IPv6 pattern (simplified)
    if (host.contains(':') && RegExp(r'^[0-9a-fA-F:]+$').hasMatch(host)) {
      return true;
    }

    return false;
  }

  bool _isValidIpAddress(String host) {
    // IPv4 validation
    final ipv4Pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    final match = ipv4Pattern.firstMatch(host);

    if (match != null) {
      for (int i = 1; i <= 4; i++) {
        final octet = int.tryParse(match.group(i)!);
        if (octet == null || octet < 0 || octet > 255) {
          return false;
        }
      }
      return true;
    }

    // IPv6 basic validation
    if (host.contains(':')) {
      final parts = host.split(':');
      if (parts.length > 8) return false;

      for (final part in parts) {
        if (part.isNotEmpty && (part.length > 4 || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(part))) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  bool _isValidParsedUri(Uri uri) {
    // Must be http or https
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    // Must have a valid host
    if (uri.host.isEmpty) return false;

    // Final validation of the host
    return _isValidDomainStructure(uri.host);
  }

  // Helper functions to check file types
  bool _isImageFile(String url) {
    final ext = url.toLowerCase().split('.').last;
    return ['png', 'jpg', 'jpeg'].contains(ext);
  }

  bool _isPdfFile(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isVideoFile(String url) {
    return url.toLowerCase().endsWith('.mp4');
  }
}

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/colors.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/access_request_details.lobby.model.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/access_request_user.lobby.view.dart';
import 'package:aroundu/views/lobby/form_page.dart';
import 'package:aroundu/views/lobby/lobby.view.dart';
import 'package:aroundu/views/profile/controllers/controller.groups.profiledart.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/profile/user_profile_followed_view.dart';
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
      ref.read(formStateProvider(widget.lobbyId).notifier).reloadFormData();
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
      ref.invalidate(lobbyFormAutofillProvider(widget.lobbyId));
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
                        final controller = formNotifier
                            .getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(
                                bottom: 18,
                                top: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText),
                                        if (question.isMandatory)
                                          TextSpan(
                                            text: '   *',
                                            style: TextStyle(
                                              color: Color(0xFFEC4B5D),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Answer",
                                    // maxLines: 5,
                                    fontSize: 12,
                                    onChanged:
                                        (val) => formNotifier.updateAnswer(
                                          question.id,
                                          val!,
                                        ),
                                    borderRadius: 16,
                                  ),
                                  // const SizedBox(height: 8),
                                  // TextFormField(
                                  //   controller: controller,
                                  //   decoration: const InputDecoration(
                                  //     labelText: "Answer",
                                  //     border: OutlineInputBorder(),
                                  //   ),
                                  //   onChanged: (val) => formNotifier.updateAnswer(
                                  //       question.id, val,),
                                  // ),
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
                              padding: EdgeInsets.only(
                                bottom: 18,
                                top: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText),
                                        if (question.isMandatory)
                                          TextSpan(
                                            text: '   *',
                                            style: TextStyle(
                                              color: Color(0xFFEC4B5D),
                                            ),
                                          ),
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
                                          formNotifier.updateAnswer(
                                            question.id,
                                            option,
                                          );
                                        }
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 0,
                                          ),
                                      activeColor: const Color(0xFFEC4B5D),
                                      checkColor: Colors.white,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
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
}

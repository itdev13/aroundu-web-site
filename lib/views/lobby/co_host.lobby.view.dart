import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';

// import '../../core/services/api.service.dart';
import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import '../profile/service.profile.dart';

class CoHostSelectionView extends StatefulWidget {
  const CoHostSelectionView({super.key, required this.lobbyDetails});

  final LobbyDetails lobbyDetails;

  @override
  State<CoHostSelectionView> createState() => _CoHostSelectionViewState();
}

class _CoHostSelectionViewState extends State<CoHostSelectionView> {
  // Using both controllers
  final profileController = Get.put(ProfileController());

  final memberController = Get.put(MemberSelectionController());

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.getUserProfileData();
      profileController.getFriends();
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: _buildBottomButton(),
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Obx(() {
                if (memberController.selectedMembers.isNotEmpty) {
                  return _buildSelectedMembers();
                } else {
                  return const SizedBox.shrink();
                }
              }),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: _buildMainContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding:
          EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
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
              InkWell(
                onTap: () {
                  Get.back();
                  profileController.clearState();
                },
                child: DesignIcon.icon(
                  icon: Icons.arrow_back_ios_new_rounded,
                ),
              ),
              Expanded(
                child: Center(
                  child: DesignText(
                    text: 'Select Members (Max 4)',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Obx(() => DesignText(
                    text: '${memberController.selectedMembers.length}/4',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DesignColors.accent,
                  )),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAEFF2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: profileController.userSearchController,
                    onChanged: (value) {
                      profileController.searchUsers(value);
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search friends...',
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
                SizedBox(width: 10),
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
    );
  }

  Widget _buildSelectedMembers() {
    return Container(
      height: 140,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DesignText(
            text: 'Selected Members',
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 8),
          Expanded(
            child: Obx(
              () => ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: memberController.selectedMembers.length,
                separatorBuilder: (_, __) => SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final member = memberController.selectedMembers[index];
                  return Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundImage: member.profilePictureUrl != null &&
                                    member.profilePictureUrl!.isNotEmpty
                                ? NetworkImage(member.profilePictureUrl!)
                                : null,
                            child: member.profilePictureUrl == null ||
                                    member.profilePictureUrl!.isEmpty
                                ? DesignIcon.icon(
                                    icon: member.gender == "MALE"
                                        ? FontAwesomeIcons.person
                                        : FontAwesomeIcons.personDress,
                                    size: 24,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: -5,
                            top: -5,
                            child: InkWell(
                              onTap: () =>
                                  memberController.removeMember(member),
                              child: Container(
                                padding: EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      DesignText(
                        text: member.name.split(' ')[0],
                        fontSize: 12,
                        maxLines: 1,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Obx(() {
      if (profileController.isSearchLoading.value) {
        return _buildSearchResults();
      }

      return Obx(() => profileController.friendsList.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
              padding: EdgeInsets.symmetric(vertical: 8),
              itemCount: profileController.friendsList.length,
              separatorBuilder: (context, index) => SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = profileController.friendsList[index];
                final isSelected = memberController.isUserSelected(user);

                return _buildUserListItem(
                  user: user,
                  trailing: DesignButton(
                    onPress: () => memberController.toggleMemberSelection(user),
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    bgColor: isSelected ? Colors.red : DesignColors.accent,
                    title: isSelected ? "Remove" : "Select",
                    titleSize: 11,
                  ),
                );
              },
            ));
    });
  }

  Widget _buildSearchResults() {
    return FutureBuilder<List<SearchUserModel>>(
      future: profileController.service
          .getSearchUser(profileController.searchQuery.value),
      builder: (context, snapshot) {
        if (snapshot.data == null ||
            profileController.isSearching.value == true) {
          return const Center(
            child: CircularProgressIndicator(
              color: DesignColors.accent,
            ),
          );
        }

        if ((snapshot.data?.length ?? 0) == 0) {
          return Center(
            child: DesignText(
              text: "User Not Found",
              fontSize: 24,
              fontWeight: FontWeight.w500,
              maxLines: 3,
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.symmetric(vertical: 8),
          itemCount: snapshot.data?.length ?? 0,
          separatorBuilder: (context, index) => SizedBox(height: 12),
          itemBuilder: (context, index) {
            final user = snapshot.data![index];
            final isSelected = memberController.isUserSelected(user);

            return _buildUserListItem(
              user: user,
              trailing: DesignButton(
                onPress: () => memberController.toggleMemberSelection(user),
                padding: EdgeInsets.symmetric(horizontal: 12),
                bgColor: isSelected ? Colors.red : DesignColors.accent,
                title: isSelected ? "Remove" : "Select",
                titleSize: 11,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.all(24),
      child: Obx(
        () => DesignButton(
          onPress: memberController.selectedMembers.isEmpty
              ? () {
                  print("nothing");
                }
              : () async {
                  // Return selected members
                  try {
                    final response = await ApiService().put(
                      "match/lobby/api/v1/${widget.lobbyDetails.lobby.id}/admins",
                      {
                        "lobbyId": widget.lobbyDetails.lobby.id,
                        "adminRequests": memberController.selectedMembersIds,
                      },
                      (json) => json,
                    );
                    Fluttertoast.showToast(msg: response['status']);
                    if (response['status'] == "SUCCESS") {
                      kLogger.debug('Invited admins successfully');
                      Fluttertoast.showToast(msg: "Co-Host added successfully");
                    } else {
                      kLogger.error('Failed to Invite admins');
                      Fluttertoast.showToast(
                          msg: "failed to add Co-Host try again later");
                    }
                  } catch (e, stack) {
                    kLogger.error('Error in admins co host: $e \n $stack');
                    Fluttertoast.showToast(msg: "something went wrong");
                  }
                  Get.back();
                },
          title: "Done",
          titleSize: 16,
          padding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class MemberSelectionController extends GetxController {
  final selectedMembers = <dynamic>[].obs;
  final selectedMembersIds = <String>[].obs;

  bool isUserSelected(dynamic user) {
    return selectedMembers.any((member) => member.userId == user.userId);
  }

  void toggleMemberSelection(dynamic user) {
    if (isUserSelected(user)) {
      removeMember(user);
    } else if (selectedMembers.length < 4) {
      selectedMembers.add(user);
      selectedMembersIds.add(user.userId);
    } else {
      Get.snackbar(
        'Maximum Limit Reached',
        'You can only select up to 4 members',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void removeMember(dynamic user) {
    selectedMembers.removeWhere((member) => member.userId == user.userId);
    selectedMembersIds.remove(user.userId);
  }
}

Widget _buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DesignText(
          text: "😢",
          fontSize: 32,
          fontWeight: FontWeight.w500,
        ),
        DesignText(
          text: "It looks a little quiet here...",
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: DesignColors.secondary,
        ),
        DesignText(
          text: "Start by searching for friends!",
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: DesignColors.secondary,
        ),
      ],
    ),
  );
}

Widget _buildUserListItem({
  required dynamic user,
  required Widget trailing,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundImage: user.profilePictureUrl != null &&
                      user.profilePictureUrl!.isNotEmpty
                  ? NetworkImage(user.profilePictureUrl!)
                  : null,
              child: user.profilePictureUrl == null ||
                      user.profilePictureUrl!.isEmpty
                  ? DesignIcon.icon(
                      icon: user.gender == "MALE"
                          ? FontAwesomeIcons.person
                          : FontAwesomeIcons.personDress,
                      size: 32,
                    )
                  : null,
            ),
            SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DesignText(
                    text: user.name,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  DesignText(
                    text: "@${user.userName}",
                    fontSize: 14,
                    color: DesignColors.secondary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      trailing,
    ],
  );
}

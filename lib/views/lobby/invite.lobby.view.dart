import 'dart:async';

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/views/lobby/external_attendees.view.dart';
import 'package:aroundu/views/lobby/provider/manage_members_lobby_provider.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../models/lobby.dart';
import 'package:aroundu/views/profile/service.profile.dart';

// Provider to manage selected users
final selectedUsersProvider =
    StateNotifierProvider<SelectedUsersNotifier, List<SearchUserModel>>((ref) {
      return SelectedUsersNotifier();
    });

class SelectedUsersNotifier extends StateNotifier<List<SearchUserModel>> {
  SelectedUsersNotifier() : super([]);

  void toggleUser(SearchUserModel user) {
    if (isSelected(user.userId)) {
      state = state.where((item) => item.userId != user.userId).toList();
    } else {
      state = [...state, user];
    }
  }

  bool isSelected(String userId) {
    return state.any((user) => user.userId == userId);
  }

  void clearAll() {
    state = [];
  }

  List<String> getSelectedUserIds() {
    return state.map((user) => user.userId).toList();
  }
}

class InviteFriendsView extends ConsumerStatefulWidget {
  const InviteFriendsView({super.key, required this.lobby});

  final Lobby lobby;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InvitePeopleViewState();
}

class _InvitePeopleViewState extends ConsumerState<InviteFriendsView> {
  final controller = Get.put(ProfileController());
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    // Clear search results when screen opens
    controller.searchResults.clear();
    controller.userSearchController.clear();
    Future.microtask(() => ref.read(selectedUsersProvider.notifier).clearAll());
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _debounceSearch(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      controller.searchUsers(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedUsers = ref.watch(selectedUsersProvider);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(bottom: 24),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            width: sw(1),
            child: DesignButton(
              onPress: () {
                final selectedUserIds =
                    ref
                        .read(selectedUsersProvider.notifier)
                        .getSelectedUserIds();
                ref.read(
                  invitePeopleInLobbyProvider(
                    lobbyId: widget.lobby.id,
                    friendsIds: selectedUserIds,
                    squadMembersIds:
                        [], // No squad members in new implementation
                  ).future,
                );
                Get.back();
              },
              title: "Invite",
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.only(top: 48, left: 8, right: 16, bottom: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: DesignIcon.icon(
                          icon: Icons.arrow_back_ios_new_rounded,
                          size: 18,
                        ),
                      ),
                      DesignText(
                        text: "Invite Users",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      GestureDetector(
                        onTap: () {
                          ref.read(selectedUsersProvider.notifier).clearAll();
                        },
                        child: DesignText(
                          text: "Clear",
                          fontSize: 14,
                          color: DesignColors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Search field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    margin: EdgeInsets.only(left: 8),
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFEAEFF2)),
                    ),
                    child: Row(
                      children: [
                        DesignIcon.icon(
                          icon: Icons.search,
                          color: const Color(0xFF989898),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: controller.userSearchController,
                            onChanged: _debounceSearch,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Search users...',
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
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Selected users horizontal list
            if (selectedUsers.isNotEmpty)
              Container(
                // height: 0.13.sh,
                // color: Colors.red,
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 16, top: 4, bottom: 8),
                      child: DesignText(
                        text: "Selected (${selectedUsers.length})",
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      height: sh(0.08),
                      // color: Colors.red,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: selectedUsers.length,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        itemBuilder: (context, index) {
                          final user = selectedUsers[index];
                          return Container(
                            width: 70,
                            margin: EdgeInsets.only(right: 8),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage:
                                          user.profilePictureUrl != null &&
                                                  user
                                                      .profilePictureUrl!
                                                      .isNotEmpty
                                              ? NetworkImage(
                                                user.profilePictureUrl!,
                                              )
                                              : null,
                                      child:
                                          user.profilePictureUrl == null ||
                                                  user
                                                      .profilePictureUrl!
                                                      .isEmpty
                                              ? DesignIcon.icon(
                                                icon: Icons.person_rounded,
                                                size: 24,
                                              )
                                              : null,
                                    ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(
                                                selectedUsersProvider.notifier,
                                              )
                                              .toggleUser(user);
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          padding: EdgeInsets.all(2),
                                          child: Icon(
                                            Icons.close,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4),
                                Text(
                                  user.name.length > 8
                                      ? '${user.name.substring(0, 8)}...'
                                      : user.name,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            // Search results
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Obx(() {
                  final searchResults = controller.searchResults;

                  if (controller.isSearching.value) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (searchResults.isEmpty &&
                      controller.userSearchController.text.isNotEmpty) {
                    return Center(child: Text("No users found"));
                  }

                  if (searchResults.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 48, color: Colors.grey),
                          SizedBox(height: 16),
                          DesignText(
                            text: "Search for users to invite",
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: searchResults.length,
                    physics: BouncingScrollPhysics(),
                    // shrinkWrap: true,
                    // separatorBuilder: (context, index) => Divider(),
                    itemBuilder: (context, index) {
                      final user = searchResults[index];
                      final isSelected = ref
                          .watch(selectedUsersProvider.notifier)
                          .isSelected(user.userId);

                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 4),
                        onTap: () {
                          ref
                              .read(selectedUsersProvider.notifier)
                              .toggleUser(user);
                        },
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage:
                              user.profilePictureUrl != null &&
                                      user.profilePictureUrl!.isNotEmpty
                                  ? NetworkImage(user.profilePictureUrl!)
                                  : null,
                          child:
                              user.profilePictureUrl == null ||
                                      user.profilePictureUrl!.isEmpty
                                  ? DesignIcon.icon(
                                    icon: Icons.person_rounded,
                                    size: 24,
                                  )
                                  : null,
                        ),
                        title: DesignText(
                          text: user.name,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        subtitle: DesignText(
                          text: user.userName,
                          fontSize: 12,
                          color: DesignColors.secondary,
                        ),
                        trailing: CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            ref
                                .read(selectedUsersProvider.notifier)
                                .toggleUser(user);
                          },
                          child: Icon(
                            isSelected
                                ? CupertinoIcons.check_mark_circled_solid
                                : CupertinoIcons.circle,
                            color:
                                isSelected
                                    ? DesignColors.accent
                                    : CupertinoColors.inactiveGray,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InviteExternalMembers extends ConsumerStatefulWidget {
  const InviteExternalMembers({super.key, required this.lobby});
  final Lobby lobby;

  @override
  ConsumerState<InviteExternalMembers> createState() =>
      _InviteExternalMembersState();
}

class _InviteExternalMembersState extends ConsumerState<InviteExternalMembers> {
  @override
  void initState() {
    super.initState();
    // Initialize the provider when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(externalAttendeesProvider(widget.lobby.id).notifier)
          .fetchExternalAttendees();
    });
  }

  @override
  Widget build(BuildContext context) {
    final externalAttendeesState = ref.watch(
      externalAttendeesProvider(widget.lobby.id),
    );
double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: DesignText(
            text: 'External Attendees',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Excel upload card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 2,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    width: sw(0.9),
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DesignButton(
                          onPress: () async {
                            await Get.toNamed(
                              AppRoutes.inviteExternalAttendees,
                              arguments: {
                                'lobbyId': widget.lobby.id,
                              },
                            );
                            ref
                                .read(
                                  externalAttendeesProvider(
                                    widget.lobby.id,
                                  ).notifier,
                                )
                                .fetchExternalAttendees();
                          },
                          padding: EdgeInsets.all(10),
                          child: DesignText(
                            text: 'Add External Attendees',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        DesignText(
                          text:
                              'Upload an Excel file with attendee details or you can also add attendees manually through app.',
                          textAlign: TextAlign.center,
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                          maxLines: null,
                          overflow: TextOverflow.visible,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // List header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    DesignText(
                      text: 'Invited Attendees',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    Spacer(),
                    if (externalAttendeesState.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DesignColors.accent,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // List of invited people
              Expanded(
                child:
                    externalAttendeesState.isLoading &&
                            externalAttendeesState.attendees.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : externalAttendeesState.hasError
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DesignText(
                                text: 'Error loading attendees',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                              SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  ref
                                      .read(
                                        externalAttendeesProvider(
                                          widget.lobby.id,
                                        ).notifier,
                                      )
                                      .fetchExternalAttendees();
                                },
                                child: Text('Retry'),
                              ),
                            ],
                          ),
                        )
                        : externalAttendeesState.attendees.isEmpty
                        ? Center(child: Text('No external attendees yet'))
                        : RefreshIndicator(
                          onRefresh: () async {
                            await ref
                                .read(
                                  externalAttendeesProvider(
                                    widget.lobby.id,
                                  ).notifier,
                                )
                                .fetchExternalAttendees();
                          },
                          color: Color(0xFFEC4B5D),
                          child: ListView.builder(
                            itemCount: externalAttendeesState.attendees.length,
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            itemBuilder: (context, index) {
                              final attendee =
                                  externalAttendeesState.attendees[index];
                              return Card(
                                margin: EdgeInsets.only(bottom: 12.0),
                                color: Colors.white,
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone_android,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          DesignText(
                                            text: attendee.mobile,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                          Spacer(),
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                attendee.status,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: DesignText(
                                              text: attendee.status,
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.event_seat,
                                            size: 18,
                                            color: Colors.grey,
                                          ),
                                          SizedBox(width: 8),
                                          DesignText(
                                            text: 'Slots: ${attendee.slots}',
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                            // fontWeight: FontWeight.w400,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'INVITED':
        return Color(0xFF3E79A1);
      case 'ONBOARDED':
        return Colors.green;
      case 'DECLINED':
        return DesignColors.accent;
      default:
        return Colors.grey;
    }
  }
}

// External Attendee Model
class ExternalAttendee {
  final String id;
  final int createdDate;
  final int lastModifiedDate;
  final String mobile;
  final String lobbyId;
  final String invitedBy;
  final String status;
  final int? updatedAt;
  final int slots;

  ExternalAttendee({
    required this.id,
    required this.createdDate,
    required this.lastModifiedDate,
    required this.mobile,
    required this.lobbyId,
    required this.invitedBy,
    required this.status,
    this.updatedAt,
    required this.slots,
  });

  factory ExternalAttendee.fromJson(Map<String, dynamic> json) {
    return ExternalAttendee(
      id: json['id'] as String,
      createdDate: json['createdDate'] as int,
      lastModifiedDate: json['lastModifiedDate'] as int,
      mobile: json['mobile'] as String,
      lobbyId: json['lobbyId'] as String,
      invitedBy: json['invitedBy'] as String,
      status: json['status'] as String,
      updatedAt: json['updatedAt'] as int?,
      slots: json['slots'] as int,
    );
  }
}

// External Attendees State
class ExternalAttendeesState {
  final List<ExternalAttendee> attendees;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;

  ExternalAttendeesState({
    this.attendees = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
  });

  ExternalAttendeesState copyWith({
    List<ExternalAttendee>? attendees,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
  }) {
    return ExternalAttendeesState(
      attendees: attendees ?? this.attendees,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// External Attendees Provider
class ExternalAttendeesNotifier extends StateNotifier<ExternalAttendeesState> {
  final String lobbyId;
  final ApiService _apiService = ApiService();

  ExternalAttendeesNotifier(this.lobbyId) : super(ExternalAttendeesState());

  Future<void> fetchExternalAttendees() async {
    try {
      state = state.copyWith(isLoading: true, hasError: false);

      final response = await _apiService.get(
        'match/lobby/external-attendee/$lobbyId',
        (json) => json,
      );

      if (response != null) {
        final List<ExternalAttendee> attendees =
            (response as List)
                .map((item) => ExternalAttendee.fromJson(item))
                .toList();

        state = state.copyWith(attendees: attendees, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          hasError: true,
          errorMessage: 'Failed to load external attendees',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
      );
    }
  }
}

// Provider definition
final externalAttendeesProvider = StateNotifierProvider.family<
  ExternalAttendeesNotifier,
  ExternalAttendeesState,
  String
>((ref, lobbyId) => ExternalAttendeesNotifier(lobbyId));

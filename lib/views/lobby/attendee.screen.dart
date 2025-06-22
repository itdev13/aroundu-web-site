import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/views/lobby/provider/lobby_details_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_memberships_provider.dart';
import 'package:aroundu/views/lobby/provider/manage_members_lobby_provider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'dart:async';

import '../../designs/colors.designs.dart';
import 'lobby.view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';



final removeAttendeeEnableProvider = StateProvider<bool>((ref) => false);

// Provider for search query
final searchQueryProvider = StateProvider<String>((ref) => '');

class RatingCubit extends Cubit<int?> {
  RatingCubit() : super(null); // Initially, no selection
Future<Response?> updateUserRatingApi(String userId, String action) async {
    try {
      print("$userId $action");
      const postRequestUrl = "user/api/v1/updateUserRating";
      final response = await ApiService().post(
        postRequestUrl,
        body: {
          'ratingRequestList': [
            {"userId": userId, "rating": action},
          ],
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print("User Rating Updated Successfully: ${response.data}");
        return response;
      } else {
        print("Error in updating rating: ${response.statusCode}");
        return response;
      }
    } catch (e) {
      print("API Error: $e");
      rethrow;
    }
  }
  Future<void> updateRating(int index, String ratingType, String userId) async {
    emit(null); // Optional: Show loading state

    // Call API with parameters
    // final momentsService = MomentsService();
    final success = await updateUserRatingApi(userId, ratingType);

    if (success != null && success.statusCode == 200) {
      emit(index); // Update UI only if API succeeds
    }
  }
}

final removeAttendeeIdListProvider =
    StateProvider<List<String>>((ref) => <String>[]);

class AttendeeScreen extends ConsumerWidget {
  const AttendeeScreen({super.key, required this.lobbyDetails});
  final LobbyDetails lobbyDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isRemoveAttendeeEnable = ref.watch(removeAttendeeEnableProvider);
    final selectedMembersList = ref.watch(removeAttendeeIdListProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    // Debounce timer for search
    Timer? _debounce;

    // Watch the lobby memberships provider
    final membershipsState =
        ref.watch(lobbyMembershipsProvider(lobbyDetails.lobby.id));
    final membershipsNotifier =
        ref.read(lobbyMembershipsProvider(lobbyDetails.lobby.id).notifier);

    // Function to handle search with debounce
    void _onSearchChanged(String query) {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        ref.read(searchQueryProvider.notifier).state = query;
        membershipsNotifier.search(query);
      });
    }

    // Initialize the controller for the scrollable list
    final scrollController = ScrollController();

    // Add scroll listener for pagination
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!scrollController.hasListeners) {
        scrollController.addListener(() {
          if (scrollController.position.pixels >=
                  scrollController.position.maxScrollExtent - 200 &&
              !membershipsState.isLoading &&
              membershipsState.hasMoreData) {
            membershipsNotifier.loadMore();
          }
        });
      }
    });
double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const DesignText(
          text: 'Attendee',
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            ref.read(removeAttendeeIdListProvider).clear();
            ref.read(removeAttendeeEnableProvider.notifier).state = false;
            Get.back();
          },
        ),
        actions: [
          if (lobbyDetails.lobby.userStatus == 'ADMIN')
            TextButton(
              onPressed: () {
                if (isRemoveAttendeeEnable) {
                  ref.read(removeAttendeeEnableProvider.notifier).state = false;
                } else {
                  ref.read(removeAttendeeEnableProvider.notifier).state = true;
                }
                ref.read(removeAttendeeIdListProvider).clear();
              },
              child: DesignText(
                text: (isRemoveAttendeeEnable) ? "Selected" : "Select",
                fontSize: 16,
                color: DesignColors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          // Add refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              membershipsNotifier.refresh();
            },
          ),
        ],
      ),
      bottomNavigationBar: isRemoveAttendeeEnable
          ? SizedBox(
              width: sw(1),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DesignText(
                      text:
                          "${selectedMembersList.length} ${(selectedMembersList.length == 1) ? "person is" : "people are"} selected",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF323232),
                      maxLines: 1,
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      width: sw(1),
                      child: DesignButton(
                        onPress: () async {
                          final removeMembersList =
                              ref.read(removeAttendeeIdListProvider);

                          if (removeMembersList.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "Please select members to remove",
                            );
                          } else {
                            // Show confirmation dialog
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  title: const DesignText(
                                    text: 'Remove Members',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  content: const DesignText(
                                    text:
                                        'If refunds are enabled, members can cancel and get a refund up to 2 days before the lobby starts. Removing a member will also trigger a refund.',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    maxLines: 10,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const DesignText(
                                        text: 'Go Back',
                                        fontSize: 14,
                                        color: DesignColors.accent,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const DesignText(
                                        text: 'Proceed',
                                        fontSize: 14,
                                        color: DesignColors.accent,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (result == true) {
                              await ref.read(removeLobbyMemberProvider(
                                lobbyId: lobbyDetails.lobby.id,
                                membersToRemove: removeMembersList,
                              ).future);
                              ref.read(removeAttendeeIdListProvider).clear();
                              ref
                                  .read(lobbyDetailsProvider(
                                          lobbyDetails.lobby.id)
                                      .notifier)
                                  .reset();
                              await ref
                                  .read(lobbyDetailsProvider(
                                          lobbyDetails.lobby.id)
                                      .notifier)
                                  .fetchLobbyDetails(lobbyDetails.lobby.id);
                              Get.back();
                            }
                          }
                        },
                        padding: EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        child: DesignText(
                          text: "Remove Members",
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => membershipsNotifier.refresh(),
        child: membershipsState.isLoading &&
                membershipsState.lobbyMembership == null
            ? const Center(child: CircularProgressIndicator())
            : membershipsState.hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DesignText(
                          text: membershipsState.errorMessage ??
                              'An error occurred',
                          fontSize: 16,
                          color: Colors.red,
                        ),
                        SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => membershipsNotifier.refresh(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search attendees...',
                              prefixIcon: const Icon(Icons.search,
                                  color: DesignColors.accent),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear,
                                          color: DesignColors.accent),
                                      onPressed: () {
                                        ref
                                            .read(searchQueryProvider.notifier)
                                            .state = '';
                                        membershipsNotifier.search('');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 15),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        ),
                      ),

                      // Attendees List
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Column(
                              children: [
                                // Responsive Grid of Attendee Cards
                                if (membershipsState.lobbyMembership != null)
                                  GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: membershipsState
                                        .lobbyMembership!.userInfos.length,
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          screenSize.width < 600 ? 2 : 3,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 0.9,
                                    ),
                                    itemBuilder: (context, index) {
                                      return AttendeeCard(
                                        userInfo: membershipsState
                                            .lobbyMembership!.userInfos[index],
                                        lobbyStatus:
                                            lobbyDetails.lobby.lobbyStatus,
                                        ratingGiven:
                                            lobbyDetails.lobby.ratingGiven,
                                      );
                                    },
                                  ),

                                // Loading indicator at the bottom when loading more
                                if (membershipsState.isLoading &&
                                    membershipsState.lobbyMembership != null)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  ),

                                // Message when no search results
                                if (membershipsState.lobbyMembership != null &&
                                    membershipsState
                                        .lobbyMembership!.userInfos.isEmpty &&
                                    membershipsState.searchText.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: Column(
                                        children: [
                                          Icon(Icons.search_off,
                                              size: 48,
                                              color: Colors.grey[400]),
                                          SizedBox(height: 16),
                                          DesignText(
                                            text:
                                                'No attendees found matching "${membershipsState.searchText}"',
                                            fontSize: 16,
                                            color: Colors.grey[600],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                // Message when no more data
                                else if (!membershipsState.hasMoreData &&
                                    membershipsState.currentSkip > 0)
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Center(
                                      child: DesignText(
                                        text: 'No more attendees to load',
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                // Admin Card Section (aligned at bottom)
                                if (membershipsState.lobbyMembership != null)
                                  ...List.generate(
                                      membershipsState.lobbyMembership!.squads
                                          .length, (index) {
                                    final squad = membershipsState
                                        .lobbyMembership!.squads[index];
                                    final memberSmallList =
                                        squad.participants.take(3).toList();
                                    return SizedBox(
                                      width: screenSize.width > 600
                                          ? 500
                                          : screenSize.width * 0.9,
                                      child: AdminCard(
                                        profileImageUrl: "",
                                        adminTag: 'Admin',
                                        name: squad.groupName,
                                        id: '',
                                        attendees: [
                                          ...List.generate(
                                              memberSmallList.length, (index) {
                                            final participant =
                                                memberSmallList[index];
                                            return (index == 2)
                                                ? Attendee(
                                                    id: participant.userId,
                                                    name: "",
                                                    imageUrl: "",
                                                    showNumber: true,
                                                    remainingCount:
                                                        membershipsState
                                                                .lobbyMembership!
                                                                .squads
                                                                .length -
                                                            2)
                                                : Attendee(
                                                    id: participant.userId,
                                                    name: participant.name,
                                                    imageUrl: participant
                                                        .profilePictureUrl,
                                                  );
                                          }),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

// Individual Attendee Card
class AttendeeCard extends ConsumerWidget {
  const AttendeeCard({
    super.key,
    required this.userInfo,
    required this.lobbyStatus,
    required this.ratingGiven,
  });

  final UserInfo userInfo;
  final String lobbyStatus;
  final bool ratingGiven;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isRemoveAttendeeEnable = ref.watch(removeAttendeeEnableProvider);
    final selectedMembersList = ref.watch(removeAttendeeIdListProvider);
    final List<String> ratingTypes = ["THUMBS_DOWN", "OK", "THUMBS_UP"];

    // Calculate responsive dimensions
    final double cardPadding = screenSize.width * 0.02;
    final double avatarRadius = screenSize.width < 600 ? 32 : 40;
    final double checkboxSize = screenSize.width < 600 ? 20 : 24;

    return InkWell(
      onTap: () async {
        final uid = await GetStorage().read("userUID") ?? '';
        // TODO : add profile screen

        // Get.to(() => (uid == userInfo.userId)
        //     ? ProfileDetailsFollowedScreen()
        //     : ProfileDetailsScreen(userId: userInfo.userId));
      },
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isRemoveAttendeeEnable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: checkboxSize,
                    width: checkboxSize,
                    child: Checkbox(
                      value: selectedMembersList.contains(userInfo.userId),
                      onChanged: (value) {
                        if (selectedMembersList.contains(userInfo.userId)) {
                          ref
                              .read(removeAttendeeIdListProvider.notifier)
                              .state = List.from(selectedMembersList)
                            ..remove(userInfo.userId);
                        } else {
                          ref
                              .read(removeAttendeeIdListProvider.notifier)
                              .state = List.from(selectedMembersList)
                            ..add(userInfo.userId);
                        }
                      },
                      activeColor: DesignColors.accent,
                    ),
                  ),
                ),
              Flexible(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: avatarRadius,
                      backgroundColor: const Color(0xFFEAEFF2),
                      child: ClipOval(
                        child: Image.network(
                          userInfo.profilePictureUrl ?? "",
                          fit: BoxFit.cover,
                          width: avatarRadius * 2,
                          height: avatarRadius * 2,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: avatarRadius,
                              color: Colors.grey,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: DesignColors.accent),
                            );
                          },
                        ),
                      ),
                    ),
                    if (userInfo.checkedIn)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: avatarRadius * 0.3,
                          backgroundColor: Colors.green,
                          child: Icon(
                            Icons.check,
                            size: avatarRadius * 0.4,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              DesignText(
                text: userInfo.name,
                fontWeight: FontWeight.w400,
                fontSize: screenSize.width < 600 ? 12 : 14,
              ),
              SizedBox(height: 4),
              DesignText(
                text: userInfo.userName,
                fontSize: screenSize.width < 600 ? 10 : 12,
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
              ),
              if (userInfo.slots != null) ...[
                SizedBox(height: 4),
                DesignText(
                  text: "${userInfo.slots ?? 0}",
                  fontSize: screenSize.width < 600 ? 10 : 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey[600],
                ),
              ],
              if ((lobbyStatus == 'PAST' || lobbyStatus == 'CLOSED') &&
                  !ratingGiven) ...[
                SizedBox(height: 6),
                BlocProvider(
                  create: (context) => RatingCubit(),
                  child: BlocBuilder<RatingCubit, int?>(
                    builder: (context, selectedIndex) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (index) {
                          final isSelected = selectedIndex == index;
                          final List<Widget> items = [
                            const Icon(Icons.thumb_down_alt_outlined),
                            const Text('OK',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Icon(Icons.thumb_up_alt_outlined),
                          ];

                          return GestureDetector(
                            onTap: () {
                              context.read<RatingCubit>().updateRating(
                                  index, ratingTypes[index], userInfo.userId);
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: isSelected
                                    ? ColorsPalette.redColor
                                    : const Color(0xFFEAEFF2),
                                child: items[index],
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Admin Card with Attendees List
class AdminCard extends ConsumerWidget {
  final String profileImageUrl;
  final String adminTag;
  final String name;
  final String id;
  final List<Attendee> attendees;

  const AdminCard({
    Key? key,
    required this.profileImageUrl,
    required this.adminTag,
    required this.name,
    required this.id,
    required this.attendees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = MediaQuery.of(context).size;
    final isRemoveAttendeeEnable = ref.watch(removeAttendeeEnableProvider);
    final selectedMembersList = ref.watch(removeAttendeeIdListProvider);
    bool areAllAttendeesSelected = attendees
        .every((attendee) => selectedMembersList.contains(attendee.id));

    // Calculate responsive dimensions
    final cardPadding = screenSize.width * 0.03;
    final double checkboxSize = screenSize.width < 600 ? 20 : 24;
    final spacing = screenSize.width * 0.02;

    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isRemoveAttendeeEnable)
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  height: checkboxSize,
                  width: checkboxSize,
                  child: Checkbox(
                    value: areAllAttendeesSelected,
                    onChanged: (value) {
                      final validAttendees =
                          attendees.map((attendee) => attendee.id).toList();

                      if (areAllAttendeesSelected) {
                        ref
                            .read(removeAttendeeIdListProvider.notifier)
                            .state = List.from(selectedMembersList)
                          ..removeWhere((id) => validAttendees.contains(id));
                      } else {
                        ref.read(removeAttendeeIdListProvider.notifier).state =
                            List.from(selectedMembersList)
                              ..addAll(validAttendees);
                      }
                    },
                    activeColor: DesignColors.accent,
                  ),
                ),
              ),
            SizedBox(width: spacing),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ProfileWithBadge(
                  profileImageUrl: profileImageUrl,
                  badgeText: adminTag,
                ),
                SizedBox(height: spacing),
                DesignText(
                  text: name,
                  fontWeight: FontWeight.w600,
                  fontSize: screenSize.width < 600 ? 10 : 12,
                ),
                SizedBox(height: spacing * 0.5),
                DesignText(
                  text: id,
                  fontWeight: FontWeight.w300,
                  color: Colors.grey,
                  fontSize: screenSize.width < 600 ? 8 : 10,
                ),
              ],
            ),
            SizedBox(width: screenSize.width * 0.05),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: spacing),
                  Column(
                    children: attendees
                        .map((attendee) => Padding(
                              padding: EdgeInsets.only(bottom: spacing),
                              child: AttendeeRow(
                                name: attendee.name,
                                imageUrl: attendee.imageUrl,
                                showNumber: attendee.showNumber,
                                remainingCount: attendee.remainingCount,
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Admin Profile with Badge
class ProfileWithBadge extends StatelessWidget {
  final String profileImageUrl;
  final String badgeText;

  const ProfileWithBadge({
    super.key,
    required this.profileImageUrl,
    required this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: const Color(0xFFEAEFF2),
              child: ClipOval(
                child: Image.network(
                  profileImageUrl, // Provide the URL
                  fit: BoxFit.cover,
                  width: 80,
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback widget in case of an error
                    return Icon(
                      Icons.person, // Default icon
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) {
                      return child;
                    } else {
                      // Show a loading indicator while the image loads
                      return const Center(
                        child: CircularProgressIndicator(
                            color: DesignColors.accent),
                      );
                    }
                  },
                ),
              ),
            ),
            const Positioned(
              bottom: 4,
              right: 4,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: Colors.green,
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 65,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 10,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Row for Individual Attendees
class AttendeeRow extends StatelessWidget {
  final String name;
  final String imageUrl;
  final bool showNumber;
  final int remainingCount;

  const AttendeeRow({
    super.key,
    required this.name,
    required this.imageUrl,
    this.showNumber = false,
    this.remainingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return showNumber
        ? Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEAEFF2),
                child: DesignText(text: "+ $remainingCount", fontSize: 14),
              ),
              const SizedBox(width: 8),
              const DesignText(
                text: "more ...",
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ],
          )
        : Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFFEAEFF2),
                child: ClipOval(
                  child: Image.network(
                    imageUrl, // Provide the URL
                    fit: BoxFit.cover,
                    width: 40,
                    height: 40,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback widget in case of an error
                      return Icon(
                        Icons.person, // Default icon
                        size: 20,
                        color: Colors.grey,
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        // Show a loading indicator while the image loads
                        return const Center(
                          child: CircularProgressIndicator(
                              color: DesignColors.accent),
                        );
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              DesignText(
                text: name,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ],
          );
  }
}

// Attendee Model
class Attendee {
  final String id;
  final String name;
  final String imageUrl;
  final bool showNumber;
  final int remainingCount;
  const Attendee({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.showNumber = false,
    this.remainingCount = 0,
  });
}

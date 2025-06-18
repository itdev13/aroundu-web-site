
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/views/profile/service.profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';



class ProfileController extends GetxController {
  final service = ProfileService();
  
  // Profile data
  final profileData = Rx<ProfileModel?>(null);
  final otherProfileData = Rx<ProfileModel?>(null);
  
  // Loading states
  final isLoading = true.obs;
  final isSearchLoading = false.obs;
  final isSearching = false.obs;
  final isSearchingFriends = false.obs;
  final isSearchingRequests = false.obs;
  
  // Friend request states
  final RxMap<String, bool> isRequestSentMap = <String, bool>{}.obs;
  
  // UI states
  final buttonTitle = 'sent'.obs;
  final searchQuery = ''.obs;
  final RxList<UserFriendsModel> friendsList = <UserFriendsModel>[].obs;
  final RxList<UserFriendsModel> friendRequests = <UserFriendsModel>[].obs;
  final RxList<SearchUserModel> searchResults = <SearchUserModel>[].obs;

  // Tab indices
  final tabIndex = 0.obs;
  final inviteTabIndex = 0.obs;

  // Error state
  final hasError = false.obs;
  final errorMessage = ''.obs;

  // Search controller
  final TextEditingController userSearchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    initializeData();
  }

  @override
  void dispose() {
    userSearchController.dispose();
    super.dispose();
  }

  // Initialize all data at once
  Future<void> initializeData() async {
    try {
      await Future.wait([
        getUserProfileData(),
        getFriends(),
        getFriendRequests(),
      ]);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load data: $e';
    }
  }

  void clearState() {
    isSearchLoading.value = false;
    isSearching.value = false;
    isSearchingFriends.value = false;
    isSearchingRequests.value = false;
    isRequestSentMap.value = <String, bool>{};
    buttonTitle.value = 'sent';
    searchQuery.value = '';
    friendsList.value = <UserFriendsModel>[];
    friendRequests.value = <UserFriendsModel>[];
    searchResults.value = <SearchUserModel>[];
    tabIndex.value = 0;
    inviteTabIndex.value = 0;
    userSearchController.clear();
    hasError.value = false;
    errorMessage.value = '';
  }

  Future<void> getUserProfileData() async {
    try {
      isLoading.value = true;
      profileData.value = await service.getUserDetailedData();
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = 'Error fetching user data: $e';
      print("Error fetching user data: $e \n $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getUserOtherProfileData(String userId) async {
    try {
      isLoading.value = true;
      otherProfileData.value = await service.getOtherUserDetailedData(userId);
    } catch (e, stackTrace) {
      hasError.value = true;
      errorMessage.value = 'Error fetching other user data: $e';
      print("Error fetching user data: $e \n $stackTrace");
    } finally {
      isLoading.value = false;
    }
  }

  void setTabIndex(int index) {
    tabIndex.value = index;
  }

  void setInviteTabIndex(int index) {
    inviteTabIndex.value = index;
  }

  Future<void> searchUsers(String query) async {
    try {
      searchQuery.value = query;
      if (searchQuery.value.isEmpty) {
        isSearchLoading.value = false;
        isSearching.value = false;
        searchResults.clear();
        return;
      }
      
      isSearchLoading.value = true;
      isSearching.value = true;
      
      final results = await service.getSearchUser(searchQuery.value);
      searchResults.value = results;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Error searching users: $e';
    } finally {
      isSearching.value = false;
    }
  }

  Future<void> changeButtonState(String userId) async {
    try {
      await service.addFriend(userId);
      isRequestSentMap[userId] = true;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to send friend request: $e';
    }
  }

  Future<List<UserFriendsModel>> getFriends() async {
    try {
      isSearchingFriends.value = true;
      final friends = await service.getUsersFriends();
      friendsList.value = friends;
      return friends;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load friends: $e';
      return [];
    } finally {
      isSearchingFriends.value = false;
    }
  }

  Future<dynamic> removeFriendFromList(String userId) async {
    try {
      var res = await service.removeFriend(userId);
      friendsList.removeWhere((friend) => friend.userId == userId);
      return res;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to remove friend: $e';
      return null;
    }
  }

  Future<List<UserFriendsModel>> getFriendRequests() async {
    try {
      isSearchingRequests.value = true;
      final requests = await service.getUsersFriendRequests();
      friendRequests.value = requests;
      return requests;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load friend requests: $e';
      return [];
    } finally {
      isSearchingRequests.value = false;
    }
  }

  Future<void> acceptFriendRequests(String userId) async {
    try {
      await service.acceptFriendRequest(userId);
      friendRequests.removeWhere((friend) => friend.userId == userId);
      // Refresh friends list after accepting
      await getFriends();
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to accept friend request: $e';
    }
  }

  Future<void> removeFriendRequest(String userId) async {
    try {
      await service.removeFriendRequest(userId);
      friendRequests.removeWhere((friend) => friend.userId == userId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to remove friend request: $e';
    }
  }

  Future<void> selectFiles(String userId) async {
    try {
      await service.uploadSelectedFile(userId);
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to upload file: $e';
    }
  }
}

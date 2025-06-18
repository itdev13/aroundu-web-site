// group_controller.dart
import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/views/profile/services/service.groups.profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

class GroupController extends GetxController {
  var isLoading = true.obs;
  final RxList<GroupModel> groups = <GroupModel>[].obs;
  var searchUsersList = <SearchUserModel>[].obs;
  var searchGroupsList = <GroupModel>[].obs;
  var usersFriendList = <UserFriendsModel>[].obs;
  var selectedParticipants = <UserFriendsModel>[].obs;
  final searchQuery = ''.obs;
  final searchGroupQuery = ''.obs;
  var groupName = ''.obs;
  var groupDescription = ''.obs;
  var isNextButtonEnabled = false.obs;
  var isCreateGroupLoading = false.obs;
  final isSearchQueryNotEmpty = false.obs;
  final isSearchGroupQueryNotEmpty = false.obs;
  final isSearchLoading = false.obs;
  final isGroupSearchLoading = false.obs;

  final TextEditingController userSearchController = TextEditingController();
  final TextEditingController groupSearchController = TextEditingController();
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController groupDescriptionController =
      TextEditingController();

  // Instance of GroupService
  final GroupService service = GroupService();

  @override
  void onInit() {
    fetchGroups();
    fetchFriends();
    super.onInit();
  }

  // Function to fetch the list of groups
  Future<void> fetchGroups() async {
    try {
      isLoading(true);
      var groupData = await service.fetchGroups();
      print(groupData);
      if (groupData.isNotEmpty) {
        groups.value = groupData;
      }
    } finally {
      isLoading(false);
    }
  }

  void searchFriends(String name) async {
    searchQuery.value = name;
    if (searchQuery.value.isEmpty) isSearchQueryNotEmpty.value = false;
    if (searchQuery.value != "") {
      isSearchQueryNotEmpty.value = true;
      isSearchLoading.value = true;
      searchUsersList.clear();
      final res = await service.searchFriends(searchQuery.value);
      searchUsersList.value = res;
      isSearchLoading.value = false;
    } else {
      isSearchLoading.value = false;
      isSearchQueryNotEmpty.value = false;
    }
  }

  void searchGroups(String groupName) async {
    searchGroupQuery.value = groupName;
    if (searchGroupQuery.value.isEmpty) {
      isSearchGroupQueryNotEmpty.value = false;
    }
    if (searchGroupQuery.value != "") {
      isSearchGroupQueryNotEmpty.value = true;
      isGroupSearchLoading.value = true;
      searchGroupsList.clear();
      searchGroupsList.value = groups.where((group) {
        return group.groupName.toLowerCase().contains(groupName.toLowerCase());
      }).toList();
      isGroupSearchLoading.value = false;
    } else {
      isGroupSearchLoading.value = false;
      isSearchGroupQueryNotEmpty.value = false;
    }
  }

  Future<void> fetchFriends() async {
    try {
      usersFriendList.clear();
      final res = await service.fetchFriends();
      usersFriendList.value = res;
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch friends: $e");
    }
  }

  void selectParticipant(UserFriendsModel user) {
    if (selectedParticipants.contains(user)) {
      selectedParticipants.remove(user);
    } else {
      selectedParticipants.add(user);
    }
    isNextButtonEnabled.value = selectedParticipants.isNotEmpty;
  }

  void updateGroupName(String name) {
    groupName.value = name;
  }

  void updateGroupDescription(String description) {
    groupDescription.value = description;
  }

  // Add these new variables
  final Rx<File?> selectedImage = Rx<File?>(null);
  final FileUploadService fileUploadService = FileUploadService();
  
  // Add this method to pick image
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }
  
  // Modify createGroup method to handle image upload
  Future<void> createGroup(BuildContext context) async {
    if (groupName.value.isEmpty || selectedParticipants.isEmpty) return;
    
    isLoading.value = true;
    String profilePictureUrl = "";
    
    try {
      // Upload image if selected
      if (selectedImage.value != null) {
        final uploadBody = {
          'type': 'GROUP_PROFILE'
        };
        
        final response = await fileUploadService.upload(
         ApiConstants.uploadFile,
          selectedImage.value!,
          uploadBody
        );
        
        if (response.statusCode == 200) {
          profilePictureUrl = response.data['imageUrl'] ?? "";
        }
      }
      
      // Create the list of selected participant IDs
      List<String> participantIds = selectedParticipants.map((user) => user.userId).toList();
      
      // Call the service to create the group
      await service.createGroup(
        groupName.value,
        participantIds,
        groupDescription.value,
        profilePictureUrl
      );
      
      CustomSnackBar.show(context: context, message:  'Squad created successfully!', type: SnackBarType.success);
    
      
    } catch (e,s) {
      CustomSnackBar.show(
          context: context,
          message: 'Failed to create Squad!',
          type: SnackBarType.error);
      Get.snackbar('Error', 'Failed to create squad: $e \n $s');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Add this to clear state
  @override
  void onClose() {
    selectedImage.value = null;
    super.onClose();
  }
}

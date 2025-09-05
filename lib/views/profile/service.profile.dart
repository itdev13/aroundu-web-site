import 'dart:io';
import 'dart:typed_data';

import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';



class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  ProfileService._internal();
  factory ProfileService() {
    return _instance;
  }

  final apiService = ApiService();

  final List<SearchUserModel> searchUsersList = [];
  final List<UserFriendsModel> usersFriendList = [];
  final List<UserFriendsModel> usersFriendRequestList = [];

  Future<ProfileModel?> getUserDetailedData() async {
    final res = await apiService.get(
      "user/api/v1/getUserDetailedView",
    );
    return ProfileModel.fromJson(res.data);
  }

  Future<ProfileModel?> getOtherUserDetailedData(String userId) async {
    final res = await apiService.get(
      "user/api/v1/getUserDetailedView?userId=$userId",
    );
    return ProfileModel.fromJson(res.data);
  }

  Future<List<SearchUserModel>> getSearchUser(String name) async {
    // if (searchUsersList.isNotEmpty) return searchUsersList;
    searchUsersList.clear();
    await Future.delayed(const Duration(seconds: 1));
    final res = await apiService.get(
      "user/friend/api/v1/userSearch?userText=$name",
    );
    searchUsersList.clear();
    for (var item in res.data) {
      searchUsersList.add(SearchUserModel.fromJson(item));
    }

    return searchUsersList;
  }

  Future<List<UserFriendsModel>> getUsersFriends() async {
    usersFriendList.clear();
    await Future.delayed(const Duration(seconds: 1));
    final res = await apiService.get(
      "user/friend/api/v1/show?type=FRIEND",
    );
    usersFriendList.clear();
    for (var item in res.data) {
      usersFriendList.add(UserFriendsModel.fromJson(item));
    }

    return usersFriendList;
  }

  Future<List<UserFriendsModel>> getUsersFriendRequests() async {
    usersFriendRequestList.clear();
    await Future.delayed(const Duration(seconds: 1));
    final res = await apiService.get(
      "user/friend/api/v1/showRequestReceived",
    );
    usersFriendRequestList.clear();
    for (var item in res.data) {
      usersFriendRequestList.add(UserFriendsModel.fromJson(item));
    }

    return usersFriendRequestList;
  }

  Future<dynamic> removeFriendRequest(String userId) async {
    //TODO: Add request to remove friend request
  }

  Future<File?> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType
          .image, // Change this to FileType.any if you want both images and videos
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      // Convert the selected file path to a File object
      return File(result.files.single.path!);
    } else {
      // User canceled the picker or no file was selected
      return null;
    }
  }

  Future<void> uploadSelectedFile(String userId) async {
    // Pick the file using the pickFile function
    File? selectedFile =
        await pickFile(); // Assuming you have the pickFile() function from before

    // Check if a file was selected
    if (selectedFile != null) {
      try {
        // Prepare the upload body (customize as per your API requirements)
        final uploadBody = {
          'userId': userId,
          'someOtherData': 'Chat Attachment',
        };

        // Upload the selected file
        final result = await FileUploadService().upload(
          "user/upload/api/v1/file", // Your file upload API endpoint URL
          selectedFile, // File to upload
          uploadBody, // Extra data you need to send with the request
        );

        // Handle the result of the upload
        if (result.statusCode == 200) {
          // Assuming the file URL is returned in `imageUrl`
          String fileUrl = result.data['imageUrl'];
          print(fileUrl);
          // Make a POST request to the new API endpoint with the file URL in the body
          final postResult = await apiService.post(
            "user/api/v1/updateProfileMedia?type=PROFILE_PIC&url=$fileUrl",
            body: {},
          );

          // Check the response of the POST request
          if (postResult.statusCode == 200) {
            // Handle successful posting of the URL
            print("File URL successfully posted to the new API");
          } else {
            throw Exception('Failed to post file URL to the new API');
          }
        } else {
          throw Exception('Failed to upload ${selectedFile.path}');
        }
      } catch (e) {
        // Show an error message if the upload or POST fails
        Get.snackbar('Upload/Post Failed', 'Error: $e');
      }
    } else {
      // No file was selected
      Get.snackbar('No File Selected', 'Please select a file to upload.');
    }
  }

  // Web-compatible file upload method
  Future<String?> uploadFileBytes(Uint8List bytes, String filename, String userId) async {
    try {
      final uploadBody = {
        'userId': userId,
        'someOtherData': 'Chat Attachment',
      };

      final result = await FileUploadService().uploadBytes(
        "user/upload/api/v1/file",
        bytes,
        filename,
        uploadBody,
      );

      if (result.statusCode == 200) {
        String fileUrl = result.data['imageUrl'];
        
        // Make a POST request to the new API endpoint with the file URL in the body
        final postResult = await apiService.post(
          "user/api/v1/updateProfileMedia?type=PROFILE_PIC&url=$fileUrl",
          body: {},
        );

        if (postResult.statusCode == 200) {
          return fileUrl;
        } else {
          throw Exception('Failed to post file URL to the new API');
        }
      } else {
        throw Exception('Failed to upload $filename');
      }
    } catch (e) {
      Get.snackbar('Upload Failed', 'Error: $e');
      return null;
    }
  }

  Future<dynamic> acceptFriendRequest(String userId) async {
    final res = await apiService.post(
      "user/friend/api/v1/acceptRequest/$userId",
      body: {},
    );
    return res.data;
  }

  Future<dynamic> removeFriend(String userId) async {
    final res = await apiService.post(
      "user/friend/api/v1/remove/$userId",
      body: {},
    );
    return res.data;
  }

  Future<dynamic> addFriend(String userId) async {
    final res = await apiService.post(
      "user/friend/api/v1/sendRequest/$userId",
      body: {},
    );
    return res.data;
  }
}

class UserFriendsModel {
  final String? profilePictureUrl;
  final String userId;
  final String userName;
  final String name;
  final String email;
  final String gender;
  final String conversationId;

  UserFriendsModel({
    this.profilePictureUrl,
    required this.userId,
    required this.userName,
    required this.name,
    required this.email,
    required this.gender,
    required this.conversationId,
  });

  factory UserFriendsModel.fromJson(Map<String, dynamic> json) {
    return UserFriendsModel(
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      conversationId: json['conversationId'] ?? '',
    );
  }
}

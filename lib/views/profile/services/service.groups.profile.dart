// group_service.dart
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:get/get.dart';

class GroupService extends GetxService {
  final apiService = ApiService();

  Future<List<GroupModel>> fetchGroups() async {
    final res = await apiService.get(
      "user/group/api/v1/show?type=SQUAD",
    );
    List<GroupModel> groups = (res.data as List)
        .map((item) => GroupModel.fromJson(item as Map<String, dynamic>))
        .toList();
    return groups;
  }

  Future<List<SearchUserModel>> searchFriends(String name) async {
    try {
      final res =
          await apiService.get("user/friend/api/v1/userSearch?userText=$name");
      List<SearchUserModel> searchUsersList = [];

      for (var item in res.data) {
        searchUsersList.add(SearchUserModel.fromJson(item));
      }
      return searchUsersList;
    } catch (error) {
      throw Exception("Error searching users: $error");
    }
  }

  Future<List<UserFriendsModel>> fetchFriends() async {
    try {
      final res = await apiService.get("user/friend/api/v1/show?type=FRIEND");
      List<UserFriendsModel> usersFriendList = [];

      for (var item in res.data) {
        usersFriendList.add(UserFriendsModel.fromJson(item));
      }
      return usersFriendList;
    } catch (error) {
      throw Exception("Error fetching friends: $error");
    }
  }

  Future<Map<String, dynamic>> createGroup(
      String groupName, List<String> friends, String description,
      [String profilePictureUrl = ""]) async {
    final body = {
      "name": groupName,
      "friends": friends,
      "description": description,
      "profilePicture": profilePictureUrl
    };

    try {
      final response = await apiService.post(
        "user/group/api/v1/create",
        body: body,
      );
      return response.data;
    } catch (error) {
      throw Exception("Error creating Squad: $error");
    }
  }

  Future<Map<String, dynamic>> updateGroup({
    required String groupId,
    String? name,
    String? description,
    String? profilePicture,
    List<String>? friends,
    List<String>? admins,
  }) async {
    Map<String, dynamic> body = {
      "groupId": groupId,
    };

    // Only add fields that are being updated
    if (name != null) body["name"] = name;
    if (description != null) body["description"] = description;
    if (profilePicture != null) body["profilePicture"] = profilePicture;
    if (friends != null) body["friends"] = friends;
    if (admins != null) body["admins"] = admins;

    try {
      final response = await apiService.put(
        "user/group",
        body: body,
      );
      return response.data;
    } catch (error, s) {
      throw Exception("Error updating Squad: $error \n $s");
    }
  }

  Future<Map<String, dynamic>> leaveGroup(String groupId) async {
    try {
      final response = await apiService.put(
        "user/group/api/v1/exit",
        body: {},
        queryParameters: {"groupId": groupId},
      ); 
      return response.data;
    } catch (error) {
      throw Exception("Error leaving group: $error");
    }
  }
}

class GroupModel {
  final String groupId;
  final String groupName;
  final String? description;
  final String? profilePicture;
  final List<ParticipantModel> participants;

  GroupModel({
    required this.groupId,
    required this.groupName,
    this.profilePicture,
    this.description,
    required this.participants,
  });

  // Factory constructor to create an instance from JSON
  factory GroupModel.fromJson(Map<String, dynamic> json) {
    return GroupModel(
      groupId: json['groupId'] ?? '',
      groupName: json['groupName'] ?? '',
      profilePicture: json['profilePicture'] ?? '',
      description: json['description'] ?? '',
      participants: ((json['participants'] as List?) ?? [])
          .map((participant) => ParticipantModel.fromJson(participant as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ParticipantModel {
  final String userId;
  final String userName;
  final String name;
  final String email;
  final bool isAdmin;
  final String gender;
  final String profilePictureUrl;

  ParticipantModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.email,
    this.isAdmin = false,
    required this.gender,
    required this.profilePictureUrl,
  });

  // Factory constructor to create an instance from JSON
  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
        userId: json['userId'] ?? '',
        userName: json['userName'] ?? '',
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        isAdmin: json['isAdmin'] ?? false,
        profilePictureUrl: json['profilePictureUrl'] ?? '',
        gender:
            json['gender'] ?? "MALE" // default value if isAdmin is not provided
        );
  }
}

class SearchUserModel {
  final String userId;
  final String userName;
  final String name;
  final String email;
  final bool isFriend;
  final bool requestSent;
  final bool requestReceived;

  SearchUserModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.email,
    required this.isFriend,
    required this.requestSent,
    required this.requestReceived,
  });

  UserFriendsModel toUserFriendsModel() {
    return UserFriendsModel(
      userId: userId,
      userName: userName,
      name: name,
      email: email,
    );
  }

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isFriend: json['isFriend'] ?? false,
      requestSent: json['requestSent'] ?? false,
      requestReceived: json['requestReceived'] ?? false,
    );
  }
}

class UserFriendsModel {
  final String userId;
  final String userName;
  final String name;
  final String email;

  UserFriendsModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.email,
  });

  // Override == to compare based on userId
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserFriendsModel && other.userId == userId;
  }

  // Override hashCode to use userId
  @override
  int get hashCode => userId.hashCode;

  factory UserFriendsModel.fromJson(Map<String, dynamic> json) {
    return UserFriendsModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

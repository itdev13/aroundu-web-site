import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/views/profile/services/service.groups.profile.dart';

import '../../models/lobby.dart';

class LobbyDetails {
  final Lobby lobby;
  // final LobbyMembership lobbyMembership;
  final Category category;
  final SubCategory subCategory;
  final String conversationId;

  LobbyDetails({
    required this.lobby,
    // required this.lobbyMembership,
    required this.category,
    required this.subCategory,
    required this.conversationId,
  });

  factory LobbyDetails.fromJson(Map<String, dynamic> json) {
    return LobbyDetails(
      lobby: Lobby.fromJson(json['lobby']),
      // lobbyMembership: LobbyMembership.fromJson(json['lobbyMemberShip']),
      category: Category.fromJson(json['category']),
      subCategory: SubCategory.fromJson(json['subCategory']),
      conversationId: json['conversationId'] ?? '',
    );
  }
}

class LobbyMembership {
  final String lobbyName;
  final String lobbyId;
  final List<UserInfo> userInfos;
  final List<GroupModel> squads;

  LobbyMembership({
    required this.lobbyName,
    required this.lobbyId,
    required this.userInfos,
    required this.squads,
  });

  factory LobbyMembership.fromJson(Map<String, dynamic> json) {
    return LobbyMembership(
      lobbyName: json['lobbyName'],
      lobbyId: json['lobbyId'],
      userInfos: (json['userInfos'] as List)
          .map((item) => UserInfo.fromJson(item))
          .toList(),
      squads: (json['groupData'] as List)
          .map((item) => GroupModel.fromJson(item))
          .toList(),
    );
  }
}

class UserInfo {
  final String userName;
  final String name;
  final String userId;
  final String? profilePictureUrl;
  final bool isAdmin;
  final FormModel? form;
  final bool checkedIn;
  final int? slots;

  UserInfo({
    required this.userName,
    required this.name,
    required this.userId,
    this.profilePictureUrl,
    required this.isAdmin,
    this.form,
    required this.checkedIn,
    this.slots,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      userId: json['userId'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? "",
      isAdmin: json['isAdmin'] ?? false,
      form: json['form'] != null ? FormModel.fromJson(json['form']) : null,
      checkedIn: json['checkedIn'] ?? false,
      slots: json['slots'],
    );
  }
}

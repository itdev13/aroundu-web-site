import '../../models/lobby.dart';

class AccessRequestDetails {
  final String userName;
  final String name;
  final String status;
  final String groupLabel;
  final String squadName;
  final String profilePictureUrl;
  final FormModel? form;
  final String text;
  final String lobbyType;
  final GroupData groupData;
  final String lobbyId;
  final String lobbyName;
  final bool isAdmin;
  final LobbyAdmin? lobbyAdmin;
  final LocationInfo? lobbyLocation;
  final String lobbyDescription;
  final String lobbyDate;
  final String mediaUrl;
  final bool hasForm;
  final bool isFinalised;

  AccessRequestDetails({
    String? userName,
    String? name,
    required String? status,
    String? groupLabel,
    String? squadName,
    String? profilePictureUrl,
    this.form,
    String? text,
    required String? lobbyType,
    required GroupData? groupData,
    required String? lobbyId,
    required String? lobbyName,
    required bool? isAdmin,
    required String? lobbyDescription,
    required String? lobbyDate,
    this.lobbyLocation,
    this.lobbyAdmin,
    required String? mediaUrl,
    required bool? hasForm,
    required bool? isFinalised,
  })  : userName = userName ?? '',
        name = name ?? '',
        status = status ?? '',
        groupLabel = groupLabel ?? '',
        squadName = squadName ?? '',
        profilePictureUrl = profilePictureUrl ?? '',
        text = text ?? '',
        lobbyType = lobbyType ?? '',
        groupData = groupData ?? GroupData.empty(),
        lobbyId = lobbyId ?? '',
        lobbyName = lobbyName ?? '',
        lobbyDescription = lobbyDescription ?? '',
        lobbyDate = lobbyDate ?? '',
        isAdmin = isAdmin ?? false,
        mediaUrl = mediaUrl?? '',
        hasForm = hasForm?? false,
        isFinalised = isFinalised?? false;

  factory AccessRequestDetails.fromJson(Map<String, dynamic> json) {
    return AccessRequestDetails(
      userName: json['userName'] as String?,
      name: json['name'] as String?,
      status: json['status'] as String?,
      groupLabel: json['groupLabel'] as String?,
      squadName: json['squadName'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      form: json['form'] != null ? FormModel.fromJson(json['form']) : null,
      text: json['text'] as String?,
      lobbyType: json['lobbyType'] as String?,
      groupData: json['groupData'] != null
          ? GroupData.fromJson(json['groupData'] as Map<String, dynamic>)
          : GroupData.empty(),
      lobbyId: json['lobbyId'] as String?,
      lobbyName: json['lobbyName'] as String?,
      isAdmin: json['isAdmin'] as bool?,
      lobbyDescription: json['lobbyDescription'] as String?,
      lobbyDate: json['lobbyDate'] as String?,
      lobbyLocation: json['lobbyLocation'] != null
          ? LocationInfo.fromJson(json['lobbyLocation'])
          : null,
      lobbyAdmin: json['lobbyAdmin'] != null
          ? LobbyAdmin.fromJson(json['lobbyAdmin'])
          : LobbyAdmin.empty(),
      mediaUrl: json['mediaUrl'] as String?,
      hasForm: json['hasForm'] as bool?,
      isFinalised: json['isFinalised'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'name': name,
      'status': status,
      'groupLabel': groupLabel,
      'squadName': squadName,
      'profilePictureUrl': profilePictureUrl,
      'form': form?.toJson(),
      'text': text,
      'lobbyType': lobbyType,
      'groupData': groupData.toJson(),
      'lobbyId': lobbyId,
      'lobbyName': lobbyName,
      'lobbyDescription': lobbyDescription,
      'lobbyDate': lobbyDate,
      'lobbyLocation': lobbyLocation?.toJson(),
      'isAdmin': isAdmin,
      'lobbyAdmin': lobbyAdmin?.toJson(),
      'mediaUrl': mediaUrl,
      'hasForm': hasForm,
      'isFinalised': isFinalised,
    };
  }
}

class GroupData {
  final List<UserInfo> userInfos;
  final String text;
  final String status;
  final String lobbyType;
  final String groupId;

  GroupData({
    List<UserInfo>? userInfos,
    String? text,
    String? status,
    String? lobbyType,
    String? groupId,
  })  : userInfos = userInfos ?? [],
        text = text ?? '',
        status = status ?? '',
        lobbyType = lobbyType ?? '',
        groupId = groupId ?? '';

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      userInfos: (json['userInfos'] as List?)
          ?.map((e) => UserInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      text: json['text'] as String?,
      status: json['status'] as String?,
      lobbyType: json['lobbyType'] as String?,
      groupId: json['groupId'] as String?,
    );
  }

  static GroupData empty() => GroupData();

  Map<String, dynamic> toJson() {
    return {
      'userInfos': userInfos.map((user) => user.toJson()).toList(),
      'text': text,
      'status': status,
      'lobbyType': lobbyType,
      'groupId': groupId,
    };
  }
}

class UserInfo {
  final String userName;
  final String name;
  final String profilePictureUrl;
  final bool isAdmin;
  final String userId;
  final FormModel? form;
  final bool checkedIn;

  UserInfo({
    String? userName,
    String? name,
    String? profilePictureUrl,
    bool? isAdmin,
    bool? checkedIn,
    String? userId,
    this.form,
  })  : userName = userName ?? '',
        name = name ?? '',
        profilePictureUrl = profilePictureUrl ?? '',
        isAdmin = isAdmin ?? false,
        checkedIn = checkedIn ?? false,
        userId = userId ?? '';

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userName: json['userName'] as String?,
      name: json['name'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      isAdmin: json['isAdmin'] as bool?,
      userId: json['userId'] as String?,
      form: json['form'] != null ? FormModel.fromJson(json['form']) : null,
      checkedIn: json['checkedIn'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'isAdmin': isAdmin,
      'userId': userId,
      'form': form,
      'checkedIn': checkedIn,
    };
  }
}

class LobbyAdmin {
  final String userId;
  final String userName;
  final String name;
  final String profilePicture;

  LobbyAdmin({
    String? userId,
    String? userName,
    String? name,
    String? profilePicture,
  })  : userId = userId ?? '',
        userName = userName ?? '',
        name = name ?? '',
        profilePicture = profilePicture ?? '';

  factory LobbyAdmin.fromJson(Map<String, dynamic> json) {
    return LobbyAdmin(
      userId: json['userId'] as String?,
      userName: json['userName'] as String?,
      name: json['name'] as String?,
      profilePicture: json['profilePicture'] as String?,
    );
  }

  static LobbyAdmin empty() => LobbyAdmin();

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'name': name,
      'profilePicture': profilePicture,
    };
  }
}

import 'package:aroundu/models/lobby.dart';

class AccessRequest {
  final String lobbyName;
  final String lobbyId;
  final String lobbyStatus;
  final bool lobbyAdmin;
  List<Request> accessRequests;

  AccessRequest({
    required this.lobbyName,
    required this.lobbyId,
    required this.lobbyStatus,
    required this.lobbyAdmin,
    required this.accessRequests,
  });

  factory AccessRequest.fromJson(Map<String, dynamic> json) {
    return AccessRequest(
      lobbyName: json['lobbyName'] ?? '',
      lobbyId: json['lobbyId'] ?? '',
      lobbyStatus: json['lobbyStatus'] ?? '',
      lobbyAdmin: json['lobbyAdmin'] ?? false,
      accessRequests: (json['accessRequests'] != null)
          ? (json['accessRequests'] as List)
              .map((item) => Request.fromJson(item))
              .toList()
          : [],
    );
  }
}

class Request {
  final String accessRequestId;
  final String userName;
  final String name;
  final String status;
  final String? profilePictureUrl;
  final FormModel? form;
  final List<FormModel>? forms;
  final String? text;
  final String? lobbyType;
  final GroupData? groupData;
  final String lobbyId;
  final String lobbyName;
  final bool isAdmin;
  final AdminSummary lobbyAdmin;
  final String lobbyDescription;
  final LocationInfo? lobbyLocation;
  final String lobbyDate;
  final AttendanceStats attendanceStats; // Added attendance stats field

  Request({
    required this.accessRequestId,
    required this.userName,
    required this.name,
    required this.status,
    this.profilePictureUrl,
    this.form,
    this.forms,
    this.text,
    this.lobbyType,
    this.groupData,
    required this.lobbyId,
    required this.lobbyName,
    required this.isAdmin,
    required this.lobbyAdmin,
    required this.lobbyDescription,
    this.lobbyLocation,
    required this.lobbyDate,
    required this.attendanceStats, // Added to constructor
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      accessRequestId: json['accessRequestId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      form: json['form'] != null ? FormModel.fromJson(json['form']) : null,
      forms: json['forms']!= null
         ? (json['forms'] as List)
             .map((item) => FormModel.fromJson(item))
             .toList()
          : null,
      text: json['text'] ?? '',
      lobbyType: json['lobbyType'] ?? '',
      groupData: json['groupData'] != null
          ? GroupData.fromJson(json['groupData'])
          : null,
      lobbyId: json['lobbyId'] ?? '',
      lobbyName: json['lobbyName'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      lobbyAdmin: json['lobbyAdmin'] != null
          ? AdminSummary.fromJson(json['lobbyAdmin'])
          : const AdminSummary(
              userId: "", name: "", profilePictureUrl: "", userName: ""),
      lobbyDescription: json['lobbyDescription'] ?? '',
      lobbyLocation: json['lobbyLocation'] != null
          ? LocationInfo.fromJson(json['lobbyLocation'])
          : null,
      lobbyDate: json['lobbyDate'] ?? '',
      attendanceStats: json['attendanceStats'] != null
          ? AttendanceStats.fromJson(json['attendanceStats'])
          : AttendanceStats.empty(), // Parse attendance stats from JSON
    );
  }
}

// New class for attendance statistics
class AttendanceStats {
  final int totalRsvps;
  final int totalAttended;

  AttendanceStats({
    required this.totalRsvps,
    required this.totalAttended,
  });

  factory AttendanceStats.fromJson(Map<String, dynamic> json) {
    return AttendanceStats(
      totalRsvps: json['totalRsvps'] ?? 0,
      totalAttended: json['totalAttended'] ?? 0,
    );
  }
  static AttendanceStats empty() {
    return AttendanceStats(
      totalRsvps: 0,
      totalAttended: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRsvps': totalRsvps,
      'totalAttended': totalAttended,
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
    required this.userInfos,
    required this.text,
    required this.status,
    required this.lobbyType,
    required this.groupId,
  });

  factory GroupData.fromJson(Map<String, dynamic> json) {
    return GroupData(
      userInfos: (json['userInfos'] as List)
          .map((item) => UserInfo.fromJson(item))
          .toList(),
      text: json['text'] ?? '',
      status: json['status'] ?? '',
      lobbyType: json['lobbyType'] ?? '',
      groupId: json['groupId'] ?? '',
    );
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
    required this.userName,
    required this.name,
    required this.profilePictureUrl,
    required this.isAdmin,
    required this.userId,
    this.form,
    required this.checkedIn,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      userId: json['userId'] ?? '',
      form: json['form'] != null ? FormModel.fromJson(json['form']) : null,
      checkedIn: json['checkedIn'] ?? false,
    );
  }
}

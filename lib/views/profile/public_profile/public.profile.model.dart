

import 'package:aroundu/models/profile.model.dart';

class PublicProfileModel {
  String userId;
  String userName;
  String name;
  String? profilePictureUrl;
  String email;
  bool isFriend;
  bool requestSent;
  bool requestReceived;
  String gender;
  String? conversationId;
  Location? location;
  bool active;
  bool panVerified;
  bool accountVerified;

  // String dob;
  // Address? addresses;
  // String bio;
  // bool verified;
  // List<String> hashTags;
  // List<ProfileInterest> profileInterests;
  // List<UserInterest> userInterests;
  // final List<Prompts> prompts;

  PublicProfileModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.profilePictureUrl,
    required this.email,
    required this.isFriend,
    required this.requestSent,
    required this.requestReceived,
    required this.gender,
    required this.conversationId,
    required this.location,
    required this.active,
    required this.panVerified,
    required this.accountVerified,
    // required this.dob,
    // this.addresses,
    // required this.bio,
    // required this.verified,
    // required this.hashTags,
    // required this.profileInterests,
    // required this.userInterests,
    // required this.prompts,
  });

  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicProfileModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      email: json['email'] ?? '',
      isFriend: json['isFriend'] ?? false,
      requestSent: json['requestSent'] ?? false,
      requestReceived: json['requestReceived'] ?? false,
      gender: json['gender'] ?? '',
      conversationId: json['conversationId'] ?? '',
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      active: json['active'] ?? false,
      panVerified: json['panVerified'] ?? false,
      accountVerified: json['accountVerified'] ?? false,

      // addresses: json['addresses'] != null
      //     ? Address.fromJson(json['addresses'])
      //     : null,
      // bio: json['bio'],
      // verified: json['verified'],
      // hashTags:
      //     (json['hashTags'] as List?)?.map((e) => e as String).toList() ?? [],
      // profileInterests: (json['profileInterests'] as List?)
      //         ?.map((i) => ProfileInterest.fromJson(i))
      //         .toList() ??
      //     [],
      // userInterests: (json['userInterests'] as List?)
      //         ?.map((i) => UserInterest.fromJson(i))
      //         .toList() ??
      //     [],
      // prompts: (json['prompts'] as List?)
      //         ?.map((i) => Prompts.fromJson(i))
      //         .toList() ??
      //     [],
    );
  }
}

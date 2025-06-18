
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/models/profile.model.dart';


class HouseDetailedModel {
  House? house;
  List<dynamic>? upcomingLobbies;
  List<dynamic>? pastLobbies;
  List<dynamic>? followers;
  List<dynamic>? announcements;
  List<dynamic>? moments;

  HouseDetailedModel({
    this.house,
    this.upcomingLobbies,
    this.pastLobbies,
    this.followers,
    this.announcements,
    this.moments,
  });

  HouseDetailedModel.fromJson(Map<String, dynamic> json) {
    house = json['house'] != null ? House.fromJson(json['house']) : null;
    upcomingLobbies = json['upcomingLobbies'];
    pastLobbies = json['pastLobbies'];
    followers = json['followers'];
    announcements = json['announcements'];
    moments = json['moments'];
  }

  // Map<String, dynamic> toJson() {
  //   final Map<String, dynamic> data = <String, dynamic>{};
  //   if (house != null) {
  //     data['house'] = house!.toJson();
  //   }
  //   data['upcomingLobbies'] = upcomingLobbies;
  //   data['pastLobbies'] = pastLobbies;
  //   data['followers'] = followers;
  //   data['announcements'] = announcements;
  //   data['moments'] = moments;
  //   return data;
  // }
}

class House {
  String? id;
  String? name;
  String? description;
  LocationInfo? locationInfo;
  List<String>? photos;
  String? profilePhoto;
  CreatedBy? createdBy;
  int? followerCount;
  List<Category>? categories;
  List<SubCategory>? subCategories;
  int? createdDate;
  int? lastModifiedDate;
  bool? isSaved;
  String? userStatus;
  bool? accountVerified;
  bool? panVerified;
  bool? gstVerified;
  List<UserSummary>? userSummaries;
  List<SocialMediaLink> socialMediaLinks = [];
  String? pinnedAnnouncementId;
  bool? showHostDetails;

  House({
    this.id,
    this.name,
    this.description,
    this.locationInfo,
    this.photos,
    this.profilePhoto,
    this.createdBy,
    this.followerCount,
    this.categories,
    this.subCategories,
    this.createdDate,
    this.lastModifiedDate,
    this.isSaved,
    this.showHostDetails,
    this.userStatus,
    this.accountVerified,
    this.panVerified,
    this.gstVerified,
    this.userSummaries,
    this.pinnedAnnouncementId,
    required this.socialMediaLinks,
  });

  House.fromJson(Map<String, dynamic> json) : socialMediaLinks = [] {
    id = json['id'];
    // announcementId = json['announcementId'];
    pinnedAnnouncementId = json['pinnedAnnouncementId'];
    name = json['name'];
    description = json['description'];
    locationInfo =
        json['locationInfo'] != null
            ? LocationInfo.fromJson(json['locationInfo'])
            : null;
    photos = json['photos']?.cast<String>();
    profilePhoto = json['profilePhoto'];
    createdBy =
        json['createdBy'] != null
            ? CreatedBy.fromJson(json['createdBy'])
            : null;
    followerCount = json['followerCount'];
    if (json['categories'] != null) {
      categories = <Category>[];
      json['categories'].forEach((v) {
        categories!.add(Category.fromJson(v));
      });
    }
    if (json['subCategories'] != null) {
      subCategories = <SubCategory>[];
      json['subCategories'].forEach((v) {
        subCategories!.add(SubCategory.fromJson(v));
      });
    }
    createdDate = json['createdDate'];
    lastModifiedDate = json['lastModifiedDate'];
    isSaved = json['isSaved'];
    userStatus = json['userStatus'];
    showHostDetails = json['showHostDetails'] ?? true;
    accountVerified = json['accountVerified'];
    panVerified = json['panVerified'];
    gstVerified = json['gstVerified'];
    socialMediaLinks =
        (json['socialMediaLinks'] as List?)
            ?.map((e) => SocialMediaLink.fromJson(e))
            .toList() ??
        [];
    if (json['userSummaries'] != null) {
      userSummaries = <UserSummary>[];
      json['userSummaries'].forEach((v) {
        userSummaries!.add(UserSummary.fromJson(v));
      });
    }
  }
}

class LocationInfo {
  List<LocationResponses>? locationResponses;
  List<GoogleSearchResponse>? googleSearchResponses;

  LocationInfo({this.locationResponses, this.googleSearchResponses});

  LocationInfo.fromJson(Map<String, dynamic> json) {
    if (json['locationResponses'] != null) {
      locationResponses = <LocationResponses>[];
      json['locationResponses'].forEach((v) {
        locationResponses!.add(LocationResponses.fromJson(v));
      });
    }
    if (json['googleSearchResponses'] != null) {
      googleSearchResponses = <GoogleSearchResponse>[];
      json['googleSearchResponses'].forEach((v) {
        googleSearchResponses!.add(GoogleSearchResponse.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (locationResponses != null) {
      data['locationResponses'] =
          locationResponses!.map((v) => v.toJson()).toList();
    }
    if (googleSearchResponses != null) {
      data['googleSearchResponses'] =
          googleSearchResponses!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LocationResponses {
  ExactLocation? exactLocation;
  ExactLocation? approxLocation;
  String? areaName;
  String? formattedAddress;

  LocationResponses({
    this.exactLocation,
    this.approxLocation,
    this.areaName,
    this.formattedAddress,
  });

  LocationResponses.fromJson(Map<String, dynamic> json) {
    exactLocation =
        json['exactLocation'] != null
            ? ExactLocation.fromJson(json['exactLocation'])
            : null;
    approxLocation =
        json['approxLocation'] != null
            ? ExactLocation.fromJson(json['approxLocation'])
            : null;
    areaName = json['areaName'];
    formattedAddress = json['formattedAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (exactLocation != null) {
      data['exactLocation'] = exactLocation!.toJson();
    }
    if (approxLocation != null) {
      data['approxLocation'] = approxLocation!.toJson();
    }
    data['areaName'] = areaName;
    data['formattedAddress'] = formattedAddress;
    return data;
  }
}

class Locations {
  double? lat;
  double? lon;

  Locations({this.lat, this.lon});

  Locations.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lon = json['lon'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }
}

class ExactLocation {
  double? lat;
  double? lng;

  ExactLocation({this.lat, this.lng});

  ExactLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lng'] = lng;
    return data;
  }
}

// class GoogleSearchResponses {
//   String? description;
//   String? placeId;
//   StructuredFormatting? structuredFormatting;

//   GoogleSearchResponses({
//     this.description,
//     this.placeId,
//     this.structuredFormatting,
//   });

//   GoogleSearchResponses.fromJson(Map<String, dynamic> json) {
//     description = json['description'];
//     placeId = json['place_id'];
//     structuredFormatting = json['structured_formatting'] != null
//         ? StructuredFormatting.fromJson(json['structured_formatting'])
//         : null;
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['description'] = description;
//     data['place_id'] = placeId;
//     if (structuredFormatting != null) {
//       data['structured_formatting'] = structuredFormatting!.toJson();
//     }
//     return data;
//   }
// }

// class StructuredFormatting {
//   String? mainText;
//   String? secondaryText;

//   StructuredFormatting({this.mainText, this.secondaryText});

//   StructuredFormatting.fromJson(Map<String, dynamic> json) {
//     mainText = json['main_text'];
//     secondaryText = json['secondary_text'];
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = <String, dynamic>{};
//     data['main_text'] = mainText;
//     data['secondary_text'] = secondaryText;
//     return data;
//   }
// }

class CreatedBy {
  String? userId;
  String? userName;
  String? name;
  String? gender;
  String? profilePictureUrl;
  bool? isFriend;
  bool? requestSent;
  bool? requestReceived;
  Locations? location;
  bool? active;

  CreatedBy({
    this.userId,
    this.userName,
    this.name,
    this.gender,
    this.profilePictureUrl,
    this.isFriend,
    this.requestSent,
    this.requestReceived,
    this.location,
    this.active,
  });

  CreatedBy.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    name = json['name'];
    gender = json['gender'];
    profilePictureUrl = json['profilePictureUrl'];
    isFriend = json['isFriend'];
    requestSent = json['requestSent'];
    requestReceived = json['requestReceived'];
    location =
        json['Location'] != null ? Locations.fromJson(json['Location']) : null;
    active = json['active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    data['name'] = name;
    data['gender'] = gender;
    data['profilePictureUrl'] = profilePictureUrl;
    data['isFriend'] = isFriend;
    data['requestSent'] = requestSent;
    data['requestReceived'] = requestReceived;
    if (location != null) {
      data['Location'] = location!.toJson();
    }
    data['active'] = active;
    return data;
  }
}

class SocialMediaLink {
  final String type;
  final String url;

  SocialMediaLink({required this.type, required this.url});

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) {
    return SocialMediaLink(type: json['type'] ?? '', url: json['url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'url': url};
  }
}

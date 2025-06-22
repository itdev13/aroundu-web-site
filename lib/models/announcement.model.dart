class GetAnnouncementModel {
  String? id;
  int? createdDate;
  int? lastModifiedDate;
  String? title;
  String? description;
  List<String>? media;
  String? houseId;
  CreatedBy? createdBy;
  HouseDetail? houseDetail;

  GetAnnouncementModel({
    this.id,
    this.createdDate,
    this.lastModifiedDate,
    this.title,
    this.description,
    this.media,
    this.houseId,
    this.createdBy,
    this.houseDetail,
  });

  GetAnnouncementModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdDate = json['createdDate'];
    lastModifiedDate = json['lastModifiedDate'];
    title = json['title'] ?? '';
    description = json['description'] ?? '';
    media = json['media'] != null ? List<String>.from(json['media']) : [];
    houseId = json['houseId'] ?? '';
    createdBy = json['createdBy'] != null
        ? CreatedBy.fromJson(json['createdBy'])
        : null;
    houseDetail = json['houseDetail'] != null
        ? HouseDetail.fromJson(json['houseDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdDate'] = createdDate;
    data['lastModifiedDate'] = lastModifiedDate;
    data['title'] = title;
    data['description'] = description;
    data['media'] = media;
    data['houseId'] = houseId;
    if (createdBy != null) {
      data['createdBy'] = createdBy!.toJson();
    }
    if (houseDetail != null) {
      data['houseDetail'] = houseDetail!.toJson();
    }
    return data;
  }
}

class CreatedBy {
  String? userId;
  String? userName;
  String? name;
  String? email;
  String? gender;
  String? deviceToken;
  Location? location;
  bool? active;
  bool? accountVerified;
  int? aura;
  double? rating;
  bool? isFriend;
  bool? requestSent;
  bool? requestReceived;
  String? profilePictureUrl;

  CreatedBy({
    this.userId,
    this.userName,
    this.name,
    this.email,
    this.gender,
    this.deviceToken,
    this.location,
    this.active,
    this.accountVerified,
    this.aura,
    this.rating,
    this.isFriend,
    this.requestSent,
    this.requestReceived,
    this.profilePictureUrl,
  });

  CreatedBy.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    userName = json['userName'];
    name = json['name'];
    email = json['email'];
    gender = json['gender'];
    deviceToken = json['deviceToken'];
    location =
        json['Location'] != null ? Location.fromJson(json['Location']) : null;
    active = json['active'];
    accountVerified = json['accountVerified'];
    aura = json['aura'];
    rating = json['rating'] != null ? json['rating'].toDouble() : 0.0;
    isFriend = json['isFriend'];
    requestSent = json['requestSent'];
    requestReceived = json['requestReceived'];
    profilePictureUrl = json['profilePictureUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['userName'] = userName;
    data['name'] = name;
    data['email'] = email;
    data['gender'] = gender;
    data['deviceToken'] = deviceToken;
    if (location != null) {
      data['Location'] = location!.toJson();
    }
    data['active'] = active;
    data['accountVerified'] = accountVerified;
    data['aura'] = aura;
    data['rating'] = rating;
    data['isFriend'] = isFriend;
    data['requestSent'] = requestSent;
    data['requestReceived'] = requestReceived;
    data['profilePictureUrl'] = profilePictureUrl;
    return data;
  }
}

class Location {
  double? lat;
  double? lon;

  Location({this.lat, this.lon});

  Location.fromJson(Map<String, dynamic> json) {
    lat = json['lat'] != null ? json['lat'].toDouble() : null;
    lon = json['lon'] != null ? json['lon'].toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat;
    data['lon'] = lon;
    return data;
  }
}

class HouseDetail {
  String? houseId;
  String? name;
  String? description;
  String? profilePhoto;
  bool? panVerified;
  bool? accountVerified;

  HouseDetail({
    this.houseId,
    this.name,
    this.description,
    this.profilePhoto,
    this.panVerified,
    this.accountVerified,
  });

  HouseDetail.fromJson(Map<String, dynamic> json) {
    houseId = json['houseId'];
    name = json['name'];
    description = json['description'];
    profilePhoto = json['profilePhoto'];
    panVerified = json['panVerified'];
    accountVerified = json['accountVerified'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['houseId'] = houseId;
    data['name'] = name;
    data['description'] = description;
    data['profilePhoto'] = profilePhoto;
    data['panVerified'] = panVerified;
    data['accountVerified'] = accountVerified;
    return data;
  }
}

class ProfileModel {
  final String userId;
  final String email;
  final String userName;
  final String name;
  final bool active;
  final String profilePictureUrl;
  final String coverPictureUrl;
  final String dob;
  final String gender;
  final Address? addresses;
  final Location? location;
  final List<ProfileInterest> profileInterests;
  final List<UserInterest> userInterests;
  final String stage;
  final String status;
  final String referralCode;
  final int currentOnboardingStep;
  final int onboardingSteps;
  final int friendsCount;
  final int groupsCount;
  final int lobbyCount;
  final int age;
  final String conversationId;
  final bool isFriend;
  final bool requestSent;
  final bool requestReceived;
  final bool accountVerified;
  final bool panVerified;
  final String bio;
  final bool showMoments;
  final bool verified;
  final double rating;
//=============================
  final List<String> hashTags;
  final List<Prompts> prompts;
  final List<Prompts2> prompts2;
  final List<SocialMediaLink> socialMediaLinks;

  ProfileModel({
    required this.userId,
    required this.email,
    required this.userName,
    required this.name,
    required this.active,
    required this.profilePictureUrl,
    this.coverPictureUrl = '',
    required this.dob,
    required this.gender,
    this.addresses,
    this.location,
    required this.profileInterests,
    required this.userInterests,
    required this.stage,
    required this.status,
    required this.currentOnboardingStep,
    required this.onboardingSteps,
    required this.friendsCount,
    required this.groupsCount,
    required this.lobbyCount,
    required this.age,
    required this.conversationId,
    required this.isFriend,
    required this.requestSent,
    required this.requestReceived,
    required this.accountVerified,
    required this.panVerified,
    required this.bio,
    required this.showMoments,
    required this.verified,
    required this.socialMediaLinks,
    required this.referralCode,
    required this.rating,

    //================================
    required this.hashTags,
    required this.prompts,
    required this.prompts2,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      coverPictureUrl: json['coverPictureUrl'] ?? '',
      userId: json['userId'] ?? '',
      referralCode: json['referralCode'] ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      active: json['active'] ?? false,
      profilePictureUrl: json['profilePictureUrl'] ??
          'https://art.pixilart.com/sr21eba8fe8daaws3.png',
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      addresses: json['addresses'] != null
          ? Address.fromJson(json['addresses'])
          : null,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      profileInterests: (json['profileInterests'] as List?)
              ?.map((i) => ProfileInterest.fromJson(i))
              .toList() ??
          [],
      userInterests: (json['userInterests'] as List?)
              ?.map((i) => UserInterest.fromJson(i))
              .toList() ??
          [],
      stage: json['stage'] ?? '',
      status: json['status'] ?? '',
      currentOnboardingStep: json['currentOnboardingStep'] ?? 0,
      onboardingSteps: json['onboardingSteps'] ?? 0,
      friendsCount: json['friendsCount'] ?? 0,
      groupsCount: json['groupsCount'] ?? 0,
      lobbyCount: json['lobbiesCount'] ?? 0,
      age: json['age'] ?? 0,
      conversationId: json['conversationId'] ?? '',
      isFriend: json['isFriend'] ?? false,
      requestSent: json['requestSent'] ?? false,
      requestReceived: json['requestReceived'] ?? false,
      accountVerified: json['accountVerified'] ?? false,
      panVerified: json['panVerified'] ?? false,
      bio: json['bio'] ?? '',
      showMoments: json['showMoments'] ?? false,
      verified: json['verified'] ?? false,
      socialMediaLinks: (json['socialMediaLinks'] as List?)
              ?.map((e) => SocialMediaLink.fromJson(e))
              .toList() ??
          [],
      rating: json['rating']?.toDouble() ?? 0.0,
      //==========================================
      hashTags:
          (json['hashTags'] as List?)?.map((e) => e as String).toList() ?? [],
      prompts: (json['prompts'] as List?)
              ?.map((i) => Prompts.fromJson(i))
              .toList() ??
          [],

      prompts2: (json['socialMediaLinks'] as List?)
              ?.map((i) => Prompts2.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class Address {
  final String country;
  final String state;
  final String city;
  final String zipCode;
  final String streetName;
  final String buildingNumber;

  Address({
    required this.country,
    required this.state,
    required this.city,
    required this.zipCode,
    required this.streetName,
    required this.buildingNumber,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      country: json['country'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      zipCode: json['zipCode'] ?? '',
      streetName: json['streetName'] ?? '',
      buildingNumber: json['buildingNumber'] ?? '',
    );
  }
}

class Location {
  final double lat;
  final double lon;

  Location({
    required this.lat,
    required this.lon,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: json['lat']?.toDouble() ?? 0.0,
      lon: json['lon']?.toDouble() ?? 0.0,
    );
  }
}

class ProfileInterest {
  final Category category;
  final List<SubCategory> subCategories;

  ProfileInterest({
    required this.category,
    required this.subCategories,
  });

  factory ProfileInterest.fromJson(Map<String, dynamic> json) {
    return ProfileInterest(
      category: Category.fromJson(json['category'] ?? {}),
      subCategories: (json['subCategories'] as List?)
              ?.map((i) => SubCategory.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class UserInterest {
  final Category category;
  final List<SubCategory> subCategories;

  UserInterest({
    required this.category,
    required this.subCategories,
  });

  factory UserInterest.fromJson(Map<String, dynamic> json) {
    return UserInterest(
      category: Category.fromJson(json['category'] ?? {}),
      subCategories: (json['subCategories'] as List?)
              ?.map((i) => SubCategory.fromJson(i))
              .toList() ??
          [],
    );
  }

  factory UserInterest.empty() {
    return UserInterest(
      category:
          Category(categoryId: "", name: "", iconUrl: "", categoryType: ""),
      subCategories: [],
    );
  }
}

class Category {
  final String categoryId;
  final String name;
  final String? description;
  final String iconUrl;
  final String categoryType;
  final String? imageUrl;
  final String? bgColor;
  final String? onBgColor;
  final String? borderColor;

  Category({
    required this.categoryId,
    required this.name,
    this.description,
    required this.iconUrl,
    required this.categoryType,
    this.imageUrl,
    this.bgColor,
    this.onBgColor,
    this.borderColor,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      categoryType: json['categoryType'] ?? '',
      imageUrl: json['imageUrl'],
      bgColor: json['bgColor'],
      onBgColor: json['onBgColor'],
      borderColor: json['borderColor'],
    );
  }
}

class SubCategory {
  final String subCategoryId;
  final String name;
  final String? description;
  final String categoryId;
  final String iconUrl;
  final double? averageRating;

  SubCategory({
    required this.subCategoryId,
    required this.name,
    this.description,
    required this.categoryId,
    required this.iconUrl,
    this.averageRating,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      subCategoryId: json['subCategoryId'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      categoryId: json['categoryId'] ?? '',
      iconUrl: json['iconUrl'] ?? '',
      averageRating: json['averageRating']?.toDouble(),
    );
  }
}

class Prompts {
  final String subCategoryId;
  final String prompt;
  final String answer;

  Prompts({
    required this.subCategoryId,
    required this.prompt,
    required this.answer,
  });

  factory Prompts.fromJson(Map<String, dynamic> json) {
    return Prompts(
      subCategoryId: json['subCategoryId'] ?? '',
      prompt: json['prompt'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class Prompts2 {
  final String type;
  final String url;
  // final String answer;

  Prompts2({
    // required this.subCategoryId,
    required this.type,
    required this.url,
  });

  factory Prompts2.fromJson(Map<String, dynamic> json) {
    return Prompts2(
      type: json['type'] ?? '',
      // prompt: json['prompt'] ?? '',
      url: json['url'] ?? '',
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
  final String? profilePictureUrl;
  final String gender;
  final String conversationId;

  SearchUserModel({
    required this.userId,
    required this.userName,
    required this.name,
    required this.email,
    required this.isFriend,
    required this.requestSent,
    required this.requestReceived,
    required this.gender,
    this.profilePictureUrl,
    required this.conversationId,
  });

  factory SearchUserModel.fromJson(Map<String, dynamic> json) {
    return SearchUserModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isFriend: json['isFriend'] ?? false,
      requestSent: json['requestSent'] ?? false,
      requestReceived: json['requestReceived'] ?? false,
      gender: json['gender'] ?? '',
      profilePictureUrl: json['profilePictureUrl'] ?? '',
      conversationId: json['conversationId']?? '',
    );
  }
}

class SocialMediaLink {
  final String type;
  final String url;

  SocialMediaLink({
    required this.type,
    required this.url,
  });

  factory SocialMediaLink.fromJson(Map<String, dynamic> json) {
    return SocialMediaLink(
      type: json['type'] ?? '',
      url: json['url'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }
}

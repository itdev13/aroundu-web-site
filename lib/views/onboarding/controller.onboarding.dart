import 'dart:io';

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/models/category.model.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/onboarding/service.onboarding.dart';
import 'package:aroundu/views/onboarding/views/about.view.onboarding.dart';
import 'package:aroundu/views/onboarding/views/interests.view.onboarding.dart';
import 'package:aroundu/views/onboarding/views/personal_info.view.onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../dashboard/dashboard.view.dart';

///
/// Enum to represent current onboarding state received from [User]'s profile
///
enum _CurrentOnboardingState {
  userCreated("USER_CREATED"),
  basicProfileDetail("BASIC_PROFILE_DETAIL"),
  profileInterest("PROFILE_INTEREST"),
  userInterest("USER_INTEREST"),
  onboarded("ONBOARDED");

  final String value;

  const _CurrentOnboardingState(this.value);
}

class HashTag {
  final String name;
  final bool isSelected;
  const HashTag(this.name, this.isSelected);
}

class OnboardingController extends GetxController {
  final destination = 'new'.obs;
  final onboardingIndex = 0.obs;
  final isLoading = false.obs;
  final isValidUsername = false.obs;
  final isCheckingUsername = false.obs;
  final isUsernameEmpty = true.obs;

  final Rx<String?> profileImage = Rx<String?>(null);
  final Rx<File?> pickedProfileImage = Rx<File?>(null);
  final ImagePicker picker = ImagePicker();

  final service = OnboardingService();

  final TextEditingController usersNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController usersBioController = TextEditingController();
  final TextEditingController hashTagController = TextEditingController();
  final TextEditingController promptAnswerController = TextEditingController();

  final Rx<DateTime?> usersDob = Rx<DateTime?>(null);
  final Rx<int> usersGender = 0.obs;

  final RxMap<String, Set<String>> userProfileInterests =
      <String, Set<String>>{}.obs;

  final RxList<HashTag> usersHashtags = <HashTag>[].obs;
  final RxList<HashTag> selectedHashtags = <HashTag>[].obs;

  final RxMap<String, List<String>> userPrompts = <String, List<String>>{}.obs;
  final RxMap<String, List<String>> userPromptQuestions =
      <String, List<String>>{}.obs;

  final RxSet<String> selectedChips = <String>{}.obs;

  final RxBool isEditingEnabled = true.obs;
  final RxList<UserInterest> userInterestList = <UserInterest>[].obs;

  final int dummyChipSelectedIndex = 0;

  final data = OnboardingData();

  @override
  void dispose() {
    usersNameController.dispose();
    emailController.dispose();
    userNameController.dispose();
    usersBioController.dispose();
    hashTagController.dispose();
    promptAnswerController.dispose();

    super.dispose();
  }

  void assignSelectedChips(List<ProfileInterest> profileInterests) {
    // Extract subcategory names and add them to selectedChips
    selectedChips.clear();
    for (var interest in profileInterests) {
      for (var subCategory in interest.subCategories) {
        selectedChips.add(subCategory.subCategoryId);
      }
    }
  }

  void assignSelectedChipsFromUserInterests(List<UserInterest> userInterests) {
    // Clear existing selected chips
    selectedChips.clear();

    // Loop through each UserInterest in the list and extract subcategory IDs
    for (var interest in userInterests) {
      for (var subCategory in interest.subCategories) {
        selectedChips.add(subCategory.subCategoryId);
      }
    }
  }

  void populateProfileInterests(List<ProfileInterest> profileInterests) {
    // Clear existing interests
    userProfileInterests.value = {};

    // Loop through each ProfileInterest in the list
    for (var profileInterest in profileInterests) {
      String categoryId =
          profileInterest.category.categoryId; // Extract categoryId

      // Loop through each subCategory in the ProfileInterest
      for (var subCategory in profileInterest.subCategories) {
        String subCategoryId =
            subCategory.subCategoryId; // Extract subCategoryId

        // Add category if not found
        if (!userProfileInterests.containsKey(categoryId)) {
          userProfileInterests[categoryId] =
              <String>{}; // Initialize an empty set
        }

        // Add sub-category ID to the category
        userProfileInterests[categoryId]!.add(subCategoryId);
      }
    }
  }

  void populateUserInterests(List<UserInterest> userInterests) {
    // Clear existing interests
    userProfileInterests.clear();

    // Loop through each UserInterest in the list
    for (var userInterest in userInterests) {
      String categoryId = userInterest.category.categoryId;

      // Loop through each subCategory in the UserInterest
      for (var subCategory in userInterest.subCategories) {
        String subCategoryId = subCategory.subCategoryId;

        // Add category if not found
        if (!userProfileInterests.containsKey(categoryId)) {
          userProfileInterests[categoryId] =
              <String>{}; // Initialize an empty set
        }

        // Add sub-category ID to the category
        userProfileInterests[categoryId]!.add(subCategoryId);
      }
    }
  }

  final List<Widget> onboardingViews = [
    PersonalInfoOnboardingView(),
    // CheckOutDetailsScreen(),
    const AboutOnboardingView(),
    const InterestsOnboardingView(),
  ];

  void populateUsersHashtags(List<CategoryModel> items) {
    usersHashtags.clear();

    for (CategoryModel model in items) {
      for (SubCategoryInfo subCat in model.subCategoryInfoList) {
        if (subCat.hashTag.isNotEmpty &&
            selectedChips.contains(subCat.subCategoryId)) {
          if (usersHashtags.length <= 5) {
            usersHashtags.add(HashTag(subCat.hashTag, false));
          }
        }
      }
    }
  }

  void updateSelectedHashTag(HashTag tag) {
    bool isPresent =
        selectedHashtags.where((p0) => p0.name == tag.name).isNotEmpty;
    if (isPresent) {
      selectedHashtags.removeWhere((element) => element.name == tag.name);
    } else {
      selectedHashtags.add(tag);
    }
  }

  void initializeUserPrompts(List<Prompts> prompts) {
    // Clear the existing prompts and questions
    userPrompts.clear();
    userPromptQuestions.clear();

    // Populate the maps with existing prompts
    for (var prompt in prompts) {
      String id = prompt.subCategoryId;
      String question = prompt.prompt;
      String answer = prompt.answer.trim();

      // Initialize userPrompts for this ID
      if (!userPrompts.containsKey(id)) {
        userPrompts[id] = [question]; // Start with the question
      }

      // Initialize userPromptQuestions for this ID
      if (!userPromptQuestions.containsKey(id)) {
        userPromptQuestions[id] = [question]; // Store the question
      }

      // If there is an answer, add it to userPrompts
      if (answer.isNotEmpty) {
        userPrompts[id]?.add(answer); // Add the answer to the prompts map
      }
    }

    // Refresh the maps to notify listeners (if using reactive programming)
    userPrompts.refresh();
    userPromptQuestions.refresh();
  }

  void populateUserPrompts(List<CategoryModel> items) {
    selectedChips.refresh();
    for (CategoryModel model in items) {
      for (SubCategoryInfo subCat in model.subCategoryInfoList) {
        if (subCat.prompt.isNotEmpty) {
          if (selectedChips.contains(subCat.subCategoryId)) {
            if (userPrompts.keys.length <= 5) {
              if (userPrompts[subCat.subCategoryId]?.isEmpty ?? true) {
                userPrompts[subCat.subCategoryId] = [subCat.prompt];
              }
            }
          } else {
            if ((userPrompts[subCat.subCategoryId]?.length ?? 0) > 0) {
              userPrompts.remove(subCat.subCategoryId);
            }
          }
        }
      }
    }
    userPrompts.refresh();
  }

  void addProfileInterest(String id, String subId) {
    // add category if not found
    if (!userProfileInterests.containsKey(id)) {
      userProfileInterests[id] = {};
    }

    // remove [subId] if already added
    if (userProfileInterests[id]!.contains(subId)) {
      userProfileInterests[id]!.remove(subId);
      if (userProfileInterests[id]!.isEmpty) {
        userProfileInterests.remove(id);
      }
      selectedChips.remove(subId);
    } else {
      // add [subId] if not found
      userProfileInterests[id]!.add(subId);
      selectedChips.add(subId);
    }
  }

  void increaseOnboardingIndex() {
    if (onboardingIndex.value >= (onboardingViews.length - 1)) {
       Get.offAllNamed(AppRoutes.dashboard);
      if (destination.value != 'new' && destination.value != 'edit') {
        Get.toNamed(AppRoutes.lobby.replaceAll(':lobbyId', destination.value));
      }
      Get.delete<OnboardingController>();
      return;
    }

    onboardingIndex.value++;
  }

  String formatUsersGender() {
    switch (usersGender.value) {
      case 0:
        return "MALE";
      case 1:
        return "FEMALE";
      case 2:
        return "OTHERS";
      default:
        return "MALE";
    }
  }

  Future<void> checkUsernameAvailable(String username) async {
    if (username != "") {
      isUsernameEmpty.value = false;
      isCheckingUsername.value = true;
      final res = await service.validateUsername(username);
      isValidUsername.value = res;
      isCheckingUsername.value = false;
    } else {
      isUsernameEmpty.value = true;
    }
  }

  String formatUsersDob() {
    final dob = usersDob.value ?? DateTime.now();
    String date = DateFormat('dd/MM/yyyy').format(dob);
    return date;
  }

  void setOnboardingIndexAccordingToState(String state) {
    final currentState = _CurrentOnboardingState.values.firstWhere(
      (i) => i.value == state,
      orElse: () => _CurrentOnboardingState.userCreated,
    );

    switch (currentState) {
      case _CurrentOnboardingState.userCreated:
        onboardingIndex.value = 0;
        break;
      case _CurrentOnboardingState.basicProfileDetail:
        onboardingIndex.value = 1;
        break;
      case _CurrentOnboardingState.profileInterest:
        onboardingIndex.value = 2;
        break;
      case _CurrentOnboardingState.userInterest:
        onboardingIndex.value = 3;
        break;
      default:
        break;
    }

    kLogger.trace(
      "Updated {onboardingIndex}'s value to [${onboardingIndex.value}]",
    );
  }

  Future<void> updateUserInterests() async {
    // Validate selected interests
    if (userProfileInterests.isEmpty &&
        selectedHashtags.isEmpty &&
        userPromptQuestions.isEmpty) {
      // DesignSnackbar.showErrorSnackbar(
      //   title: "Oops! Incomplete Fields.",
      //   message: "Please choose at least 2 interests",
      // );

      increaseOnboardingIndex();
      selectedChips.clear();
      return;
    }

    // Validate answered prompts

    final Map<String, String> prompts = {};

    for (var item in userPrompts.entries) {
      if (item.value.length >= 2) {
        prompts[item.key] = item.value.last;
      }
    }

    final Map<String, String> questions = {};

    for (var item in userPromptQuestions.entries) {
      if (item.value.isNotEmpty) {
        questions[item.key] = item.value.last;
      }
    }
    // if (prompts.length < 2) {
    //   DesignSnackbar.showErrorSnackbar(
    //     title: "Oops! Incomplete Fields.",
    //     message: "Please answer to at least two prompts",
    //   );
    //
    //   return;
    // }

    isLoading.value = true;

    //Filter selected hashtags
    List<HashTag> allHashtags = selectedHashtags.toList();
    allHashtags.removeWhere((element) => element.isSelected == false);

    final res = await service.updateUserInterest(
      userSelectedData: userProfileInterests,
      userHashTags: allHashtags.map((element) => element.name).toList(),
      userPromptAnswers: prompts,
      userPromptQuestion: questions,
      isEditingProfile: !isEditingEnabled.value,
    );

    kLogger.trace("Updating user interest");
    kLogger.debug(res);

    isLoading.value = false;

    userProfileInterests.clear();

    increaseOnboardingIndex();
    selectedChips.clear();
  }

  Future<void> updateProfileInterests() async {
    if (userProfileInterests.isEmpty && selectedChips.isEmpty) {
      // DesignSnackbar.showErrorSnackbar(
      //   title: "Oops! Incomplete Fields.",
      //   message: "Please answer at least 2 areas",
      // );
      // return;
      increaseOnboardingIndex();
      return;
    }

    isLoading.value = true;

    final res = await service.updateProfileInterest(
      userSelectedData: userProfileInterests,
      isEditingProfile: !isEditingEnabled.value,
    );

    kLogger.trace("Updating users profile interest");
    kLogger.debug(res);

    isLoading.value = false;

    userProfileInterests.clear();

    increaseOnboardingIndex();
    selectedChips.clear();
  }

  Future<void> updateUserBasicProfile(BuildContext context) async {
    if (usersNameController.text.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Please fill in your Name",
        type: SnackBarType.warning,
      );

      return;
    }

    if (userNameController.text.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Please fill in your Username",
        type: SnackBarType.warning,
      );

      return;
    }
    if (emailController.text.isEmpty) {
      CustomSnackBar.show(
        context: context,
        message: "Please fill in your Email",
        type: SnackBarType.warning,
      );

      return;
    }

    if (isValidUsername.value == false && isEditingEnabled.value) {
      CustomSnackBar.show(
        context: context,
        message: "Please choose a different username",
        type: SnackBarType.warning,
      );

      return;
    }

    // if (usersBioController.text.isEmpty) {
    //   DesignSnackbar.showErrorSnackbar(
    //     title: "Oops! Incomplete Fields.",
    //     message: "Please fill in your Bio",
    //   );

    //   return;
    // }

    if (usersDob.value == null) {
      CustomSnackBar.show(
        context: context,
        message: "Please update your DOB",
        type: SnackBarType.warning,
      );

      return;
    }

    isLoading.value = true;

    final res = await service.updateBasicProfileDetails(
      isEditingProfile: !isEditingEnabled.value,
      name: usersNameController.text,
      username: userNameController.text,
      email: emailController.text,
      bio: usersBioController.text,
      gender: formatUsersGender(),
      dob: formatUsersDob(),
      profilePictureUrl: profileImage.value ?? "",
    );

    kLogger.trace("Updating users basic profile details");
    kLogger.debug(res);

    isLoading.value = false;

    increaseOnboardingIndex();
  }

  Future<void> updateUserProfilePicture(BuildContext context) async {
    if (profileImage.value == null) {
      CustomSnackBar.show(
        context: context,
        message: "Please Select Image",
        type: SnackBarType.warning,
      );

      return;
    }

    isLoading.value = true;

    final res = await service.updateProfilePicture(
      context: context,
      profilePictureUrl: profileImage.value ?? "",
    );

    kLogger.trace("Updating users profile picture");
    kLogger.debug(res);

    isLoading.value = false;
  }
}

class OnboardingData {
  final List<String> genders = ["👨 Male", "👩 Female", "⚧ Others"];

  final List<String> pets = [
    "🐶 Dog Person",
    "🐈 Cat Person",
    "🦜 Bird Person",
    "🐾 Others",
  ];

  final List<String> life = [
    "🏫 Just got out of college",
    "💼 Got a job",
    "👨🏻‍💻 Nomad, freelancer",
    "🔄 Other",
  ];

  final List<String> smoking = ["🚬 Regular", "🚬 Occasional", "🚭 Never"];

  final List<String> drinking = ["🍺 Regular", "🥂 Occasional", "🚱 Never"];

  final List<String> personality = [
    "🤫 Introvert",
    "🗣️ Extrovert",
    "🤔 Ambivert",
  ];

  final List<String> sports = [
    "🏸 Badminton",
    "⚽️ Football",
    "🏏 Cricket",
    "🏀 Basket Ball",
    "🎾 Tennis",
    "⛳️ Golf",
    "🏓 Table Tennis",
    "🏊🏻‍♂️ Swimming",
    "🏅 Other",
  ];

  final List<String> goingOut = [
    "☕️ Cafe Hopping",
    "🍺 Bars",
    "🎸 Concerts",
    "🎭 Comedy Shows",
    "🕺🏻 Clubs",
    "🎉 Other",
  ];

  final List<String> traveling = [
    "🎒 Backpacking",
    "🏖️ Beaches",
    "⛺️ Camping",
    "⛰️ Hiking",
    "❄️ Winter Sports",
    "✈️ Other",
  ];
}

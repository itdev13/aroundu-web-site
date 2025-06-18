

import 'package:aroundu/models/category.model.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:flutter/material.dart';

import '../../utils/api_service/api.service.dart';



class OnboardingService {
  final apiService = ApiService();

  final List<CategoryModel> aboutCategories = [];
  final List<CategoryModel> interestCategories = [];

  Future<bool> validateUsername(String username) async {
    final res = await apiService.get(
      "user/api/v1/userNameAvailable?userName=$username",
    );
    return res.data;
  }

  Future<dynamic> updateProfilePicture({
    required BuildContext context,
    required String profilePictureUrl,
  }) async {
    final data = {
      "isEditingProfile": true,
      "profilePictureUrl": profilePictureUrl,
    };
    final res = await apiService.post(
      "user/api/v1/updateBasicProfile",
      body: data,
    );

    if (res.statusCode == 200) {
      CustomSnackBar.show(
        context: context,
        message: "Profile picture updated successfully",
        type: SnackBarType.success,
      );
    } else {
      CustomSnackBar.show(
        context: context,
        message: "Failed to upload cover image",
        type: SnackBarType.error,
      );
    }

    return res.data;
  }

  Future<dynamic> updateBasicProfileDetails({
    required bool isEditingProfile,
    required String name,
    required String username,
     required String email,
    required String bio,
    required String gender,
    required String dob,
    required String profilePictureUrl,
  }) async {
    Map<String, dynamic> data = {
      "name": name,
      "userName": username,
      "email": email,
      "gender": gender,
      "dob": dob,
      "bio": bio,
      "profilePictureUrl": profilePictureUrl,
    };

    if (isEditingProfile) {
      data["isEditingProfile"] = isEditingProfile;
    }

    final res = await apiService.post(
      "user/api/v1/updateBasicProfile",
      body: data,
    );

    return res.data;
  }

  Future<dynamic> updateProfileInterest({
    required Map<String, Set<String>> userSelectedData,
    required bool isEditingProfile,
  }) async {
    final attr = [];

    for (String catId in userSelectedData.keys) {
      attr.add(
        {
          "categoryId": catId,
          "subCategoryIds": userSelectedData[catId]!.toList(),
        },
      );
    }
    print(
      {
        "interestAttributes": attr,
      },
    );
    Map<String, dynamic> body = {
       "interestAttributes": attr,
    };

    if (isEditingProfile) {
      body["isEditingProfile"] = isEditingProfile;
    }

    final res = await apiService.post(
      "user/api/v1/updateProfileInterest",
      body: body,
    );

    return res.data;
  }

  Future<dynamic> updateUserInterest({
    required Map<String, Set<String>> userSelectedData,
    required List<String> userHashTags,
    required Map<String, String> userPromptAnswers,
    required Map<String, String> userPromptQuestion,
    required bool isEditingProfile,
  }) async {
    final attr = [];
    final prompts = [];

    for (String catId in userSelectedData.keys) {
      attr.add(
        {
          "categoryId": catId,
          "subCategoryIds": userSelectedData[catId]!.toList(),
        },
      );
    }

    for (var item in userPromptAnswers.entries) {
      for (var q in userPromptQuestion.entries) {
        if (item.key == q.key) {
          prompts.add({
            "subCategoryId": item.key,
            "prompt": q.value,
            "answer": item.value,
          });
        }
      }
    }

    Map<String, dynamic> body = {
       "interestAttributes": attr,
       "hashTags": userHashTags,
       "prompts": prompts,
    };

    if (isEditingProfile) {
      body["isEditingProfile"] = isEditingProfile; 
    }

    final res = await apiService.post(
      "user/api/v1/updateUserInterests",
      body: body,
    );

    return res.data;
  }

  Future<List<CategoryModel>> getListOfProfileInfo() async {
    if (aboutCategories.isNotEmpty) return aboutCategories;

    //TODO: Update the API here
    final res = await apiService.get(
      "match/category/api/v1/getAll/PROFILE_INFO",
    );

    for (var item in res.data["onboardingResponseList"]) {
      aboutCategories.add(CategoryModel.fromJson(item));
    }

    return aboutCategories;
  }

  Future<List<CategoryModel>> getListOfUserInterests() async {
    if (interestCategories.isNotEmpty) return interestCategories;

    final res = await apiService.get(
      "match/category/api/v1/getAll/INTERESTS",
    );

    for (var item in res.data["onboardingResponseList"]) {
      interestCategories.add(CategoryModel.fromJson(item));
    }

    return interestCategories;
  }
}

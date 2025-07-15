import 'dart:io';
import 'dart:math';
import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/icons.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/views/auth/auth.service.dart';
import 'package:aroundu/views/dashboard/controller.dashboard.dart';
import 'package:aroundu/views/dashboard/house.view.dart';
import 'package:aroundu/views/onboarding/controller.onboarding.dart';
import 'package:aroundu/views/onboarding/view.onboarding.dart';
import 'package:aroundu/views/profile/account_setting_page.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:aroundu/views/profile/widgets/mySocialHandles.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:get/get.dart' hide Response, FormData;
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../designs/colors.designs.dart';
import '../../../designs/widgets/space.widget.designs.dart';
import 'package:aroundu/utils/custome_snackbar.dart';

class ProfileDetailsFollowedScreen extends ConsumerStatefulWidget {
  const ProfileDetailsFollowedScreen({super.key, this.isFromNavBar = false});
  final bool isFromNavBar;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileDetailsFollowedScreenState();
}

class _ProfileDetailsFollowedScreenState
    extends ConsumerState<ProfileDetailsFollowedScreen> {
  final DashboardController dashboardController =
      Get.put(DashboardController());
  final controller = Get.put(ProfileController());
  bool isLoading = false;
  // late final List<File> selectedImages;
  List<dynamic> url = [];
  // List<File> selectedImages = [];
  final ImagePicker _picker = ImagePicker();
  List<File> selectedImages = [];

  Future<void> selectImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImages = [File(pickedFile.path)];
      });
      await uploadCoverImage(); // Auto-upload after selection
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getUserProfileData();
    });
    super.initState();
  }

  Future<Response?> coverImageProfile(String url) async {
    try {
      final headers = await AuthService().getAuthHeaders();
      const postRequestUrl =
          "${ApiConstants.arounduBaseUrl}user/api/v1/updateProfileMedia";

      FormData formData = FormData.fromMap({"type": "COVER_PIC", "url": url});

      Dio dio = Dio();
      final response = await dio.post(
        postRequestUrl,
        data: formData,
        options: Options(
          headers: {
            "Authorization": headers['Authorization'],
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      print(response.statusCode);
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("CoverImage link created successfully: ${response.data}");
        return response;
      } else {
        print("Error creating CoverImage: ${response.statusCode}");
        return response;
      }
    } catch (e, stack) {
      print("API Error: $e \n $stack");
      rethrow;
    }
  }

  Future<void> uploadCoverImage() async {
    setState(() => isLoading = true);

    try {
      if (selectedImages.isEmpty) {
        url = [];
      } else {
        final uploadedUrls = [];
        final uploadBody = {
          'userId': await GetStorage().read("userUID") ?? '',
          'lobbyId': 'HOUSE_CREATION',
        };
        for (File image in selectedImages) {
          final result = await FileUploadService().upload(
            ApiConstants.uploadFile,
            image,
            uploadBody,
          );
          if (result.statusCode == 200) {
            uploadedUrls.add(result.data['imageUrl']);
          }
        }
        url = uploadedUrls;
      }

      final response = await coverImageProfile(url[0]);

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        CustomSnackBar.show(
          context: context,
          message: "Cover image uploaded successfully",
          type: SnackBarType.success,
        );
        // Refresh profile data
        controller.getUserProfileData();
      } else {
        CustomSnackBar.show(
          context: context,
          message: "Failed to upload cover image",
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      CustomSnackBar.show(
        context: context,
        message: "Error: $e",
        type: SnackBarType.error,
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  bool _showSettings = false;

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Container(
              margin: EdgeInsets.all(2),
              height: 28,
              width: 28,
              child: CircularProgressIndicator(
                color: DesignColors.accent,
                strokeWidth: 3,
              ),
            ),
          );
        }

        ProfileModel? data = controller.profileData.value;
        if (data == null) {
          return const Center(child: Text('Error loading profile data.'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.lightImpact();
            await controller.getUserProfileData();
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cover Image Section
                _buildCoverImageSection(data),

                // Profile Stats Section
                _buildProfileStatsSection(data),

                // Only show these sections when settings are not visible
                if (!_showSettings) ...[
                  // Bio section
                  _buildBioSection(data),

                  // Personal info section
                  _buildPersonalInfoSection(data),

                  if (data.currentOnboardingStep >= 2) ...[
                    // Profile interests section
                    if (data.currentOnboardingStep > 2)
                      _buildProfileInterestsSection(data),

                    // Interests Section
                    if (data.currentOnboardingStep > 3)
                      _buildInterestsSection(data),
                  ],
                  if (data.currentOnboardingStep < 4)
                    // Profile Completion Card
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFFEC6546), // Lighter shade of primary color
                            Color(0xFFEC4B5D), // Updated to app's primary color
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(
                              0xFFEC4B5D,
                            ).withOpacity(0.3), // Updated shadow color
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      DesignText(
                                        text: "Complete Your Profile",
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                      SizedBox(height: 4),
                                      DesignText(
                                        text:
                                            "Unlock all features by completing your profile",
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Progress indicator
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DesignText(
                                      text: "Profile Completion",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                    DesignText(
                                      text:
                                          "${((data.currentOnboardingStep / data.onboardingSteps) * 100).toInt()}%",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Stack(
                                  children: [
                                    // Background
                                    Container(
                                      height: 8,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    // Progress
                                    Container(
                                      height: 8,
                                      width:
                                          (data.currentOnboardingStep /
                                                  data.onboardingSteps) *
                                              sw(1) -
                                          32,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                          colors: [
                                            Colors.white.withOpacity(0.9),
                                            Colors.white,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(
                                              0.5,
                                            ),
                                            blurRadius: 4,
                                            offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            // Complete profile button
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.mediumImpact();

                                // Map currentOnboardingStep to startingPageIndex
                                int startingPageIndex = 0;
                                if (data.currentOnboardingStep == 2) {
                                  startingPageIndex = 1;
                                } else if (data.currentOnboardingStep == 3) {
                                  startingPageIndex = 2;
                                } else if (data.currentOnboardingStep == 4) {
                                  startingPageIndex = 0;
                                }

                                // Navigate to onboarding or profile completion
                                Get.toNamed(
                                  AppRoutes.onboarding.replaceAll(
                                    ':startingPageIndex',
                                    '$startingPageIndex',
                                  ).replaceAll(':destination', 'edit'),
                                  arguments: [
                                    false,
                                    data.status,
                                    data.name,
                                    data.userName,
                                    data.dob,
                                    data.bio,
                                    data.profileInterests,
                                    data.userInterests,
                                    data.hashTags,
                                    data.prompts,
                                    data.gender,
                                    data.email,
                                    data.profilePictureUrl,
                                  ],
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DesignText(
                                        text: "Complete Your Profile",
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(
                                          0xFFEC4B5D,
                                        ), // Updated to app's primary color
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Color(
                                          0xFFEC4B5D,
                                        ), // Updated to app's primary color
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Aura Section
                  // _buildAuraSection(),

                  // Social Media Section
                  _buildSocialMediaSection(data),
                ],

                // Always show settings section when settings button is pressed
                if (_showSettings) _buildSettingsSection(data),

                SizedBox(height: 24),

                // Copyright text
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  margin: const EdgeInsets.only(top: 16),
                  child: const Text(
                    "© 2025 AroundU. All rights reserved.\nProperty of NextGen Tech © 2025",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: sh(0.15)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Future<void> _pickProfileImage() async {
    // Show loading indicator immediately when user taps
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: DesignColors.accent),
                SizedBox(height: 16),
                Text('Opening image picker...', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        );
      },
    );

    try {
      // Initialize the image picker
      final ImagePicker picker = ImagePicker();

      // Close the loading dialog before showing the picker
      Navigator.of(context).pop();

      // Show the image picker
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile == null) {
        return; // User canceled the picker
      }

      setState(() => isLoading = true);

      // Set the picked image file
      File imageFile = File(pickedFile.path);

      // Upload the image
      String uploadedUrl = '';
      final uploadBody = {
        'userId': await GetStorage().read("userUID") ?? '',
        'lobbyId': 'USER_PFP',
      };

      final result = await FileUploadService().upload(
        ApiConstants.uploadFile,
        imageFile,
        uploadBody,
      );

      if (result.statusCode == 200) {
        uploadedUrl = result.data['imageUrl'];

        // Get the controller instance
        final OnboardingController onboardingController = Get.put(
          OnboardingController(),
        );

        // Set the profile image URL
        onboardingController.profileImage.value = uploadedUrl;

        // Call the existing update profile picture function
        await onboardingController.updateUserProfilePicture(context);

        // Refresh profile data
        setState(() {
          isLoading = false;
        });

        await controller.getUserProfileData();
      } else {
        CustomSnackBar.show(
          context: context,
          message: "Failed to upload image",
          type: SnackBarType.error,
        );

        setState(() => isLoading = false);
      }
    } catch (e) {
      // Make sure to close the dialog if there's an error
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print("Error updating profile picture: $e");
      CustomSnackBar.show(
        context: context,
        message: "Error updating profile picture",
        type: SnackBarType.error,
      );
      setState(() => isLoading = false);
    }
  }

  Widget _buildCoverImageSection(ProfileModel data) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Cover Image
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            // Show dialog with options
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: DesignText(
                    text: "Cover Image",
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (selectedImages.isNotEmpty ||
                          data.coverPictureUrl.isNotEmpty)
                        ListTile(
                          leading: Icon(
                            Icons.image,
                            color: DesignColors.accent,
                          ),
                          title: DesignText(
                            text: "View Cover Image",
                            fontSize: 14,
                          ),
                          onTap: () async {
                            Navigator.pop(context);
                            // Show full screen image view
                            Get.to(
                              () => ImageViewer(
                                image:
                                    selectedImages.isNotEmpty
                                        ? FileImage(selectedImages[0])
                                            as ImageProvider
                                        : NetworkImage(data.coverPictureUrl),
                              ),
                            );
                          },
                        ),
                      ListTile(
                        leading: Icon(
                          Icons.add_photo_alternate,
                          color: DesignColors.accent,
                        ),
                        title: DesignText(
                          text: "Select Cover Image",
                          fontSize: 14,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          selectImage();
                        },
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: Container(
            height: sh(0.28),
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
              image:
                  (selectedImages.isNotEmpty || data.coverPictureUrl.isNotEmpty)
                      ? DecorationImage(
                        image:
                            selectedImages.isNotEmpty
                                ? FileImage(selectedImages[0]) as ImageProvider
                                : NetworkImage(data.coverPictureUrl),
                        fit: BoxFit.cover,
                      )
                      : null,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Dark overlay for better text contrast
                Container(color: Colors.black.withOpacity(0.2)),

                // Upload indicator if no image
                if (selectedImages.isEmpty && data.coverPictureUrl.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Tap to upload cover image",
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!widget.isFromNavBar)
          Positioned(
            top: 40,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(8),
              height: 40,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  Get.back();
                },
                padding: EdgeInsets.zero,
              ),
            ),
          ),

        // Settings Button (NEW)
        Positioned(
          top: 40,
          right: Get.width * 0.05,
          child: Container(
            padding: EdgeInsets.all(8),
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.settings, color: Colors.black, size: 20),
              onPressed: () async {
                HapticFeedback.selectionClick();
                setState(() {
                  _showSettings = !_showSettings;
                });
              },
              padding: EdgeInsets.zero,
            ),
          ),
        ),

        // Share Button
        // Positioned(
        //   top: 40,
        //   right: 16,
        //   child: Container(
        //     padding: EdgeInsets.all(8),
        //     height: 40,
        //     width: 40,
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       shape: BoxShape.circle,
        //       boxShadow: [
        //         BoxShadow(
        //           color: Colors.black.withOpacity(0.2),
        //           blurRadius: 4,
        //           offset: const Offset(0, 2),
        //         ),
        //       ],
        //     ),
        //     child: IconButton(
        //       icon: Icon(Icons.share, color: Colors.black, size: 20),
        //       onPressed: () async {
        //         //Get.to(() =>
        //         // ProfileDetailsScreen(userId: "67606286201e0c28d9678a5c"));
        //         //673c77f899c5da7c7bbcadb4
        //         //67606286201e0c28d9678a5c

        //         HapticFeedback.selectionClick();
        //         try {
        //           await ShareUtility.showShareBottomSheet(
        //             context: context,
        //             entityType: EntityType.profile,
        //             entity: data,
        //           );
        //         } catch (e) {
        //           if (mounted) {
        //             CustomSnackBar.show(
        //               context: context,
        //               message: "Error preparing share options: $e",
        //               type: SnackBarType.error,
        //             );
        //           }
        //         }
        //       },
        //       padding: EdgeInsets.zero,
        //     ),
        //   ),
        // ),

        // Profile Card
        Positioned(
          top: sh(0.2),
          left: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Picture
                GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _pickProfileImage();
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                (data.verified)
                                    ? const Color(0xFF4EA55E)
                                    : Colors.white,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFEAEFF2),
                          child: ClipOval(
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: DesignColors.accent,
                                    )
                                    : Image.network(
                                      data.profilePictureUrl,
                                      fit: BoxFit.cover,
                                      width: 80,
                                      height: 80,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.person,
                                            size: 20,
                                            color: Colors.grey,
                                          ),
                                      loadingBuilder:
                                          (context, child, loadingProgress) =>
                                              loadingProgress == null
                                                  ? child
                                                  : const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              DesignColors
                                                                  .accent,
                                                        ),
                                                  ),
                                    ),
                          ),
                        ),
                      ),
                      // Verification Badge
                      if (data.verified)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(width: 16),

                // Name and Username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DesignText(
                        text: data.name,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      SizedBox(height: 4),
                      DesignText(
                        text: "@${data.userName}",
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.cake, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          DesignText(
                            text: "${data.age} years old",
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit Profile Button
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.black, size: 20),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    Get.toNamed(
                      AppRoutes.onboarding.replaceAll(
                        ':startingPageIndex',
                        '0',
                      ).replaceAll(':destination', 'edit'),
                      arguments: [
                        false,
                        data.status,
                        data.name,
                        data.userName,
                        data.dob,
                        data.bio,
                        data.profileInterests,
                        data.userInterests,
                        data.hashTags,
                        data.prompts,
                        data.gender,
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBioSection(ProfileModel data) {
    if (data.bio.isEmpty) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.format_quote, color: Colors.teal, size: 20),
              SizedBox(width: 8),
              DesignText(
                text: "About Me",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            data.bio,
            style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(ProfileModel data) {
    // Only show this section if we have either gender or address info
    if (data.gender.isEmpty && data.addresses == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person, color: Colors.purple, size: 20),
              SizedBox(width: 8),
              DesignText(
                text: "Personal Info",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          SizedBox(height: 16),

          // Gender info
          if (data.gender.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      data.gender.toLowerCase() == 'male'
                          ? Icons.male
                          : data.gender.toLowerCase() == 'female'
                          ? Icons.female
                          : Icons.person,
                      color: Colors.purple,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gender",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        data.gender,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Age info
          if (data.age > 0)
            Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.cake, color: Colors.orange, size: 18),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Age",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        "${data.age} years",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          // Address info
          if (data.addresses != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: Colors.blue, size: 18),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Location",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _formatAddress(data.addresses!),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Helper method to format address
  String _formatAddress(Address address) {
    List<String> parts = [];

    // if (address.buildingNumber.isNotEmpty) parts.add(address.buildingNumber);
    // if (address.streetName.isNotEmpty) parts.add(address.streetName);
    if (address.city.isNotEmpty) parts.add(address.city);
    if (address.state.isNotEmpty) parts.add(address.state);
    if (address.country.isNotEmpty) parts.add(address.country);
    if (address.zipCode.isNotEmpty) parts.add(address.zipCode);

    return parts.join(", ");
  }

  Widget _buildProfileInterestsSection(ProfileModel data) {
    if (data.profileInterests.isEmpty) return SizedBox.shrink();

    // Initial number of interests to show
    final interestsToShow = 2;
    final profileInterestsExpandedProvider = StateProvider<bool>(
      (ref) => false,
    );
    return Consumer(
      builder: (context, ref, child) {
        final isExpanded = ref.watch(profileInterestsExpandedProvider);

        return Container(
          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.star, color: Colors.amber, size: 18),
                  ),
                  SizedBox(width: 8),
                  DesignText(
                    text: "Profile Interests",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Display categories with their subcategories
              ...data.profileInterests
                  .take(
                    isExpanded ? data.profileInterests.length : interestsToShow,
                  )
                  .map((interest) {
                    // Get the category color
                    Color categoryColor = _getColorFromHex(
                      interest.category.bgColor ?? '#FFA726',
                    );

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category header
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  interest.category.iconUrl,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                interest.category.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 8),

                          // Subcategories
                          if (interest.subCategories.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 6),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...interest.subCategories.take(3).map((
                                    subCategory,
                                  ) {
                                    return _buildCompactSubCategoryChip(
                                      emoji: subCategory.iconUrl,
                                      label: subCategory.name,
                                      color: categoryColor,
                                    );
                                  }),
                                  // Show "+X more" if there are more subcategories
                                  if (interest.subCategories.length > 3)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "+${interest.subCategories.length - 3} more",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  })
                  .toList(),

              // Show More/Less button if needed
              if (data.profileInterests.length > interestsToShow)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref
                          .read(profileInterestsExpandedProvider.notifier)
                          .state = !isExpanded;
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? "Show Less" : "Show More",
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.amber,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStatsSection(ProfileModel data) {
    return Container(
      margin: EdgeInsets.only(top: 64, left: 16, right: 16),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: FontAwesomeIcons.solidStar,
            value: data.rating.toStringAsFixed(1),
            label: "Rating",
            color: Colors.amber,
          ),
          _buildDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.userGroup,
            value: data.friendsCount.toString(),
            label: "Friends",
            color: Colors.blue,
            onTap: () {
              // HapticFeedback.selectionClick();
              // Get.to(
              //   () => FriendsOnProfileView(usersName: data.name),
              // );
            },
          ),
          _buildDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.users,
            value: data.groupsCount.toString(),
            label: "Squads",
            color: Colors.purple,
            onTap: () {
              // HapticFeedback.selectionClick();
              // Get.to(
              //   () => GroupsOnProfileView(),
              // );
            },
          ),
          _buildDivider(),
          _buildStatItem(
            icon: FontAwesomeIcons.landmark,
            value: data.lobbyCount.toString(),
            label: "Lobbies",
            color: Colors.green,
            onTap: () {
              // HapticFeedback.selectionClick();
              // Get.to(
              //   () => const LobbiesOnProfileView(),
              // );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    void Function()? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        color: Colors.white,
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            SizedBox(height: 8),
            DesignText(text: value, fontSize: 16, fontWeight: FontWeight.bold),
            SizedBox(height: 2),
            DesignText(text: label, fontSize: 12, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(height: 40, width: 1, color: Colors.grey.shade300);
  }

  Widget _buildInterestsSection(ProfileModel data) {
    // Initial number of interests to show
    final interestsToShow = 2;
    final interestsExpandedProvider = StateProvider<bool>((ref) => false);

    // Process interests to remove duplicates
    final processedInterests = _removeDuplicateInterests(data.userInterests);

    return Consumer(
      builder: (context, ref, child) {
        final isExpanded = ref.watch(interestsExpandedProvider);

        return Container(
          margin: EdgeInsets.only(top: 16, left: 16, right: 16),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and title
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.interests, color: Colors.teal, size: 18),
                  ),
                  SizedBox(width: 8),
                  DesignText(
                    text: "Interests",
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Display categories with their subcategories (compact version)
              ...processedInterests
                  .take(
                    isExpanded ? data.userInterests.length : interestsToShow,
                  )
                  .map((interest) {
                    // Get the category color
                    Color categoryColor = _getColorFromHex(
                      interest.category.bgColor ?? '#4EA55E',
                    );

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category header - more compact
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  interest.category.iconUrl,
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                interest.category.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: categoryColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          // Subcategories - limited to 3 with "more" indicator
                          if (interest.subCategories.isNotEmpty)
                            Padding(
                              padding: EdgeInsets.only(left: 10, top: 6),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...interest.subCategories.take(3).map((
                                    subCategory,
                                  ) {
                                    return _buildCompactSubCategoryChip(
                                      emoji: subCategory.iconUrl,
                                      label: subCategory.name,
                                      color: categoryColor,
                                    );
                                  }),
                                  // Show "+X more" if there are more subcategories
                                  if (interest.subCategories.length > 3)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "+${interest.subCategories.length - 3} more",
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  })
                  .toList(),

              // Show More/Less button if needed
              if (processedInterests.length > interestsToShow)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      ref.read(interestsExpandedProvider.notifier).state =
                          !isExpanded;
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isExpanded ? "Show Less" : "Show More",
                          style: TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          color: Colors.teal,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),

              // Hashtags section - compact version
              if (data.hashTags.isNotEmpty) ...[
                SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.tag, color: Colors.blue, size: 16),
                    ),
                    SizedBox(width: 8),
                    DesignText(
                      text: "Hashtags",
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Show only first 5 hashtags with "+X more" indicator
                    ...data.hashTags
                        .take(5)
                        .map((tag) => _buildCompactHashtagChip(tag)),
                    if (data.hashTags.length > 5)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "+${data.hashTags.length - 5} more",
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Helper method to remove duplicate interests
  List<UserInterest> _removeDuplicateInterests(List<UserInterest> interests) {
    // Map to track seen categories
    final Map<String, UserInterest> uniqueCategories = {};

    // Process each interest
    for (final interest in interests) {
      final categoryId = interest.category.categoryId;

      if (!uniqueCategories.containsKey(categoryId)) {
        // This is a new category, add it with its subcategories
        uniqueCategories[categoryId] = interest;
      } else {
        // This category already exists, merge subcategories
        final existingInterest = uniqueCategories[categoryId]!;
        final existingSubCatIds =
            existingInterest.subCategories.map((s) => s.subCategoryId).toSet();

        // Add only new subcategories
        for (final subCat in interest.subCategories) {
          if (!existingSubCatIds.contains(subCat.subCategoryId)) {
            existingInterest.subCategories.add(subCat);
          }
        }
      }
    }

    return uniqueCategories.values.toList();
  }

  Widget _buildCompactSubCategoryChip({
    required String emoji,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 12)),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Compact hashtag chip
  Widget _buildCompactHashtagChip(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2), width: 1),
      ),
      child: Text(
        "#$tag",
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection(ProfileModel data) {
    // This would display social media links if available
    return Container(
      margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.link, color: Colors.indigo, size: 20),
              SizedBox(width: 8),
              DesignText(
                text: "Social Media",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              Spacer(),
              TextButton(
                onPressed: () async {
                  HapticFeedback.selectionClick();
                  await Get.to(
                    () => SocialHandlesScreen(
                      socialMediaLinks:
                          data.socialMediaLinks != null
                              ? data.socialMediaLinks
                                  .map(
                                    (link) => {
                                      'type': link.type,
                                      'url': link.url,
                                    },
                                  )
                                  .toList()
                              : [],
                    ),
                  );
                  await controller.getUserProfileData();
                },
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),

          // Display social media buttons based on available data
          if (data.socialMediaLinks != null && data.socialMediaLinks.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  data.socialMediaLinks.map((link) {
                    // Define icon, color and URL based on social media type
                    IconData icon;
                    Color color;
                    String url;

                    switch (link.type) {
                      case 'FB':
                        icon = FontAwesomeIcons.facebook;
                        color = Colors.blue.shade800;
                        url = 'https://facebook.com/${link.url}';
                        break;
                      case 'IG':
                        icon = FontAwesomeIcons.instagram;
                        color = Colors.pink;
                        // For Instagram, format username with @
                        url =
                            'https://instagram.com/${link.url.replaceAll('@', '')}';
                        break;
                      case 'YOUTUBE':
                        icon = FontAwesomeIcons.youtube;
                        color = Colors.red;
                        url = 'https://youtube.com/${link.url}';
                        break;
                      case 'LINKEDIN':
                        icon = FontAwesomeIcons.linkedin;
                        color = Colors.blue.shade700;
                        url = 'https://linkedin.com/in/${link.url}';
                        break;
                      default:
                        icon = FontAwesomeIcons.link;
                        color = Colors.grey;
                        url = link.url;
                    }

                    return _buildSocialButton(
                      icon: icon,
                      color: color,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        _launchSocialMedia(link.type, link.url);
                      },
                    );
                  }).toList(),
            )
          else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  "No social media accounts linked",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  // Helper method to launch social media apps or websites
  void _launchSocialMedia(String type, String username) async {
    String url;
    String appUrl;

    switch (type) {
      case 'FB':
        // Try to open Facebook app first, then website
        appUrl = 'fb://profile/$username';
        url = 'https://facebook.com/$username';
        break;
      case 'IG':
        // Remove @ if present for the URL
        String cleanUsername =
            username.startsWith('@') ? username.substring(1) : username;
        appUrl = 'instagram://user?username=$cleanUsername';
        url = 'https://instagram.com/$cleanUsername';
        break;
      case 'YOUTUBE':
        appUrl = 'youtube://user/$username';
        url = 'https://youtube.com/$username';
        break;
      case 'LINKEDIN':
        appUrl = 'linkedin://profile/$username';
        url = 'https://linkedin.com/in/$username';
        break;
      default:
        // If it's not a recognized platform, just try to open as URL
        if (username.startsWith('http')) {
          url = username;
        } else {
          url = 'https://$username';
        }
        appUrl = url;
    }

    // Try to launch the app first
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // If app launch fails, open in browser
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          // Show error if both fail
          Get.snackbar(
            'Error',
            'Could not open link',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    } catch (e) {
      // Fallback to web URL if app launch throws an error
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        Get.snackbar(
          'Error',
          'Could not open link',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    }
  }

  Widget _buildSettingsSection(ProfileModel data) {
    return Container(
      margin: EdgeInsets.only(top: 16, left: 16, right: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DesignText(
                text: "Account Settings",
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              if (_showSettings)
                InkWell(
                  onTap: () {
                    setState(() {
                      _showSettings = false;
                    });
                  },
                  child: Icon(Icons.close, size: 16),
                ),
            ],
          ),
          SizedBox(height: 16),

          // // Lobby Ledger
          // _buildSettingItem(
          //   icon: Icons.book,
          //   title: "Lobby Ledger",
          //   onTap: () {
          //     Get.to(() => LobbyLedgerPage(userId: data.userId));
          //   },
          // ),

          // // Transaction History
          // _buildSettingItem(
          //   icon: Icons.history,
          //   title: "Transaction History",
          //   onTap: () {
          //     Get.to(() => TransactionHistoryPage());
          //   },
          // ),

          // Account Settings
          _buildSettingItem(
            icon: Icons.settings,
            title: "Accounts & Settings",
            onTap: () {
              Get.to(() => AccountAndSettingsPage());
            },
          ),

          // Video Verification
          // _buildSettingItem(
          //   icon: Icons.videocam,
          //   title: "Video Verification",
          //   onTap: () {
          //     Get.to(
          //       () => StartVerifyView(
          //         userId: controller.profileData.value?.userId ?? "",
          //       ),
          //     );
          //   },
          // ),

          // // Verify with PAN
          // _buildSettingItem(
          //   icon: Icons.verified_user,
          //   title: "Verify with PAN",
          //   onTap: dashboardController.userPanVerified.value
          //       ? () => Get.to(() => AddFinalDetails(
          //             isAccountSetup: false,
          //           ))
          //       : () => Get.to(() => VerifyFromUserAccount(
          //             isIndividual: true,
          //             isAccountSetup: false,
          //             isLobby: false,
          //           )),
          // ),

          // Invite Friends
          // _buildSettingItem(
          //   icon: Icons.people,
          //   title: "Invite Friends",
          //   onTap: () =>
          //       Get.to(() => FriendsOnProfileView(usersName: data.name)),
          // ),

          // Privacy Policy
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: "Privacy Policy",
            onTap: () {
              Get.to(() => const PrivacyPolicyPage());
            },
          ),

          // Terms & Conditions
          _buildSettingItem(
            icon: Icons.description,
            title: "Terms & Conditions",
            onTap: () {
              Get.to(() => const TermsConditionsPage());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: DesignColors.accent, size: 20),
            SizedBox(width: 16),
            DesignText(text: title, fontSize: 14, fontWeight: FontWeight.w500),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // Helper method to convert hex color string to Color
  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}

/// Featured Moments
// class FeaturedMoments extends ConsumerStatefulWidget {
//   final String userName;
//   const FeaturedMoments({super.key, this.userName = ""});

//   @override
//   ConsumerState<FeaturedMoments> createState() => _FeaturedMomentsState();
// }

// class _FeaturedMomentsState extends ConsumerState<FeaturedMoments> {
//   @override
//   void initState() {
//     super.initState();
//     Future.microtask(() => ref.read(momentsProvider.notifier).fetchMoments());
//   }

//   @override
//   Widget build(BuildContext context) {
//     final momentsState = ref.watch(momentsProvider);

//     return momentsState.when(
//       loading: () => SizedBox(
//         width: 1.sw,
//         // child: const Center(
//         //   child: CircularProgressIndicator(color: DesignColors.accent),
//         // ),
//       ), // Show nothing while loading
//       error: (error, stackTrace) => Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             DesignText(text: 'Something went wrong', fontSize: 12),
//             ElevatedButton(
//               onPressed: () =>
//                   ref.read(momentsProvider.notifier).fetchMoments(),
//               child: const Text('Retry'),
//             ),
//           ],
//         ),
//       ), // Show nothing on error
//       data: (moments) {
//         if (moments.isEmpty) {
//           return const SizedBox.shrink(); // Show nothing when empty
//         }

//         return SizedBox(
//           width: double.infinity,
//           child: Padding(
//             padding: EdgeInsets.only(left: 8),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 DesignText(
//                   text: 'My Moments',
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 Space(height: 18),
//                 SizedBox(
//                   height: 0.14.sh,
//                   child: ListView.builder(
//                     physics: const BouncingScrollPhysics(),
//                     scrollDirection: Axis.horizontal,
//                     shrinkWrap: true,
//                     itemCount: moments.length,
//                     itemBuilder: (context, index) {
//                       final moment = moments[index];
//                       if (moment.createdBy?.userName != widget.userName) {
//                         return const SizedBox.shrink();
//                       }
//                       return MomentCircle(
//                         imageUrl: moment.media!.isNotEmpty
//                             ? moment.media!.first
//                             : "https://art.pixilart.com/sr2e207c7fa53aws3.png",
//                         username: moment.createdBy?.userName ?? "user name",
//                         isViewed: false,
//                         onTap: () {
//                           // Handle moment tap
//                         },
//                       );
//                     },
//                   ),
//                 ),
//                 // Space(height: 34),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://www.aroundu.in/privacy');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch URL immediately when page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl();
      // Return to previous screen after launching URL
      Navigator.of(context).pop();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Opening Privacy Policy...'),
          ],
        ),
      ),
    );
  }
}

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({Key? key}) : super(key: key);

  Future<void> _launchUrl() async {
    final Uri url = Uri.parse('https://www.aroundu.in/terms');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Launch URL immediately when page is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _launchUrl();
      // Return to previous screen after launching URL
      Navigator.of(context).pop();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Opening Terms of Service...'),
          ],
        ),
      ),
    );
  }
}

class ImageViewer extends StatelessWidget {
  final ImageProvider<Object> image;
  final String? title;

  const ImageViewer({super.key, required this.image, this.title});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      left: false,
      right: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title:
              title != null
                  ? Text(
                    title!,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  )
                  : null,
        ),
        body: PhotoView(
          imageProvider: image,
          loadingBuilder:
              (context, event) => Center(
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CircularProgressIndicator(
                    value:
                        event?.expectedTotalBytes != null
                            ? event!.cumulativeBytesLoaded /
                                (event.expectedTotalBytes ?? 1)
                            : null,
                    color: Colors.white,
                  ),
                ),
              ),
          errorBuilder:
              (context, error, stackTrace) => Center(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_rounded,
                        size: 60,
                        color: Colors.white70,
                      ),
                      SizedBox(height: 16),
                      DesignText(
                        text: "Failed to load image",
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      SizedBox(height: 8),
                      DesignText(
                        text: "The image could not be loaded",
                        fontSize: 14,
                        color: Colors.white70,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
          backgroundDecoration: const BoxDecoration(color: Colors.transparent),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2.0,
          initialScale: PhotoViewComputedScale.contained,
          basePosition: Alignment.center,
          filterQuality: FilterQuality.high,
          enableRotation: false,
          // tightMode: true,
        ),
      ),
    );
  }
}

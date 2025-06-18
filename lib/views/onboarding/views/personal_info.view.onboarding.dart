import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../designs/colors.designs.dart';
import '../../../designs/widgets/button.widget.designs.dart';
import '../../../designs/widgets/chip.widgets.designs.dart';
import '../../../designs/widgets/icon.widget.designs.dart';
import '../../../designs/widgets/space.widget.designs.dart';
import '../../../designs/widgets/text.widget.designs.dart';
import '../../../designs/widgets/textfield.widget.designs.dart';
import '../controller.onboarding.dart';

class PersonalInfoOnboardingView extends GetWidget<OnboardingController> {
  const PersonalInfoOnboardingView({super.key});

  Future<void> _pickImage(BuildContext context) async {
    String url = '';
    final pickedFile = await controller.picker.pickImage(
      source: ImageSource.gallery,
    );

    try {
      if (pickedFile == null) {
        url = '';
      } else {
        controller.pickedProfileImage.value = File(pickedFile.path);
        String uploadedUrls = '';
        final uploadBody = {
          'userId': await GetStorage().read("userUID") ?? '',
          'lobbyId': 'USER_PFP',
        };

        final result = await FileUploadService().upload(
          ApiConstants.uploadFile,
          File(pickedFile.path),
          uploadBody,
        );
        if (result.statusCode == 200) {
          uploadedUrls = result.data['imageUrl'];
        }

        url = uploadedUrls;
      }

      controller.profileImage.value = url;
    } catch (e, s) {
      kLogger.error("personal info view errror : ", error: e, stackTrace: s);
      CustomSnackBar.show(
        context: context,
        message: "Something went wrong",
        type: SnackBarType.error,
      );
    } finally {
      controller.update();
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //ture section
        Center(
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Obx(
                  () => CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    backgroundImage:
                        controller.pickedProfileImage.value != null
                            ? FileImage(controller.pickedProfileImage.value!)
                            : null,
                    child:
                        controller.pickedProfileImage.value == null
                            ? Icon(
                              Icons.camera_alt,
                              size: 40,
                              color: Colors.grey,
                            )
                            : null,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  _pickImage(context);
                },
                child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorsPalette.grayColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    color: ColorsPalette.redColor,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 16),
        const Space.h(height: 8),
        Center(
          child: DesignText(
            text: "Add your picture here",
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        const Space.h(height: 32),

        // Existing code
        DesignText(
          text: "What’s your name?",
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        const Space.h(height: 8),
        DesignText(text: "You won’t be able to change this.", fontSize: 14),
        const Space.h(height: 16),
        Opacity(
          opacity: controller.isEditingEnabled.value ? 1.0 : 0.6,
          child: DesignTextField(
            enabled: controller.isEditingEnabled.value,
            controller: controller.usersNameController,
            hintText: "Name",
          ),
        ),

        const Space.h(height: 32),
        //
        //username
        //
        DesignText(
          text: "Claim your username",
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        const Space.h(height: 8),
        Obx(
          () => Opacity(
            opacity: controller.isEditingEnabled.value ? 1.0 : 0.6,
            child: DesignTextField(
              enabled: controller.isEditingEnabled.value,
              controller: controller.userNameController,
              hintText: "Username",
              onChanged:
                  (username) => controller.checkUsernameAvailable(username!),
              suffixIcon:
                  controller.isUsernameEmpty.value
                      ? null
                      : controller.isCheckingUsername.value
                      ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          color: Colors.grey,
                          strokeWidth: 4,
                        ),
                      )
                      : controller.isValidUsername.value
                      ? const Icon(Icons.check, color: Colors.green)
                      : const Icon(Icons.error, color: Colors.red),
            ),
          ),
        ),
        const Space.h(height: 32),
        DesignText(
          text: "What’s your email?",
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        const Space.h(height: 8),
        Opacity(
          opacity: controller.isEditingEnabled.value ? 1.0 : 0.6,
          child: DesignTextField(
            enabled: controller.isEditingEnabled.value,
            controller: controller.emailController,
            hintText: "Email",
          ),
        ),
        const Space.h(height: 32),
        //
        // Gender
        //
        DesignText(text: "Gender", fontSize: 24, fontWeight: FontWeight.w500),
        const Space.h(height: 16),
        Obx(
          () => Wrap(
            runSpacing: 12,
            spacing: 12,
            children: List.generate(controller.data.genders.length, (index) {
              final gender = controller.data.genders[index];

              return DesignChip(
                title: gender,
                isSelected: controller.usersGender.value == index,
                onTap: () {
                  controller.usersGender.value = index;
                },
              );
            }),
          ),
        ),

        const Space.h(height: 32),

        //
        // User's DOB
        //
        DesignText(
          text: "Date of Birth",
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
        const Space.h(height: 16),
        Opacity(
          opacity: controller.isEditingEnabled.value ? 1.0 : 0.6,
          child: AbsorbPointer(
            absorbing: !controller.isEditingEnabled.value,
            child: GestureDetector(
              onTap:
                  controller.isEditingEnabled.value
                      ? () async {
                        final selectedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(1920),
                          lastDate: DateTime.now(),
                          currentDate: controller.usersDob.value,
                        );

                        if (selectedDate == null) return;

                        controller.usersDob.value = selectedDate;
                      }
                      : () {},
              child: Container(
                padding: EdgeInsets.only(left: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: DesignColors.border, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => DesignText(
                        text:
                            controller.usersDob.value == null
                                ? "Select Your DOB"
                                : controller.formatUsersDob(),
                        color: DesignColors.secondary,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: DesignIcon.icon(
                        icon: Icons.keyboard_arrow_down_sharp,
                        color: DesignColors.primary,
                        size: 20,
                      ),
                      onPressed: null,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const Space.h(height: 32),

        //
        // Users Bio
        //
        DesignText(text: "Bio", fontSize: 24, fontWeight: FontWeight.w500),
        const Space.h(height: 8),
        DesignText(text: "A short caption about you", fontSize: 14),
        const Space.h(height: 16),
        DesignTextField(
          controller: controller.usersBioController,
          hintText: "",
          // charCount: 50,
          maxLines: 1,
        ),

        const Space.h(height: 32),

        //
        // Continue to next step
        //
        SizedBox(
          width: sw(1), // 100% of the available width
          child: Obx(
            () => DesignButton(
              // isEnabled: controller.isValidUsername.value,
              title: "Next",
              isEnabled:
                  !controller.isLoading.value ||
                  !controller.isCheckingUsername.value,
              isLoading:
                  controller.isLoading.value ||
                  controller.isCheckingUsername.value,
              onPress: () async {
                await controller.updateUserBasicProfile(context);
              },
            ),
          ),
        ),
        const Space.h(height: 16),
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     DesignIcon.icon(
        //       icon: Icons.remove_red_eye_sharp,
        //       size: 16.sp,
        //     ),
        //     const Space.w(width: 8),
        //         SizedBox(
        //           width: 1.sw, // 100% of the available width
        //           child: DesignButton(
        //             title: "Next",
        //             isLoading: controller.isLoading.value,
        //             onPress: () async {
        //               await controller.updateUserBasicProfile();
        //             },
        //           ),
        //         ),
        //         const Space.h(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DesignIcon.icon(icon: Icons.remove_red_eye_sharp, size: 16),
            const Space.w(width: 8),
            DesignText(
              text: "This would be shown on your profile",
              fontSize: 12,
            ),
          ],
        ),
      ],
    );
  }
}

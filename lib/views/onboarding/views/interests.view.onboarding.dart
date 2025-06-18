
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/models/category.model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../designs/colors.designs.dart';
import '../../../designs/widgets/button.widget.designs.dart';
import '../../../designs/widgets/chip.widgets.designs.dart';
import '../../../designs/widgets/icon.widget.designs.dart';
import '../../../designs/widgets/space.widget.designs.dart';
import '../../../designs/widgets/text.widget.designs.dart';
import '../controller.onboarding.dart';

class InterestsOnboardingView extends GetWidget<OnboardingController> {
  const InterestsOnboardingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return FutureBuilder<List<CategoryModel>>(
        future: controller.service.getListOfUserInterests(),
        builder: (context, snapshot) {
          controller.populateUsersHashtags(snapshot.data ?? []);
          controller.populateUserPrompts(snapshot.data ?? []);
          if (snapshot.data == null) {
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //
              // User's interests
              //
              DesignText(
                text: "Your Interests",
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              const Space.h(height: 8),
              DesignText(
                text: "Pick at least 5 things that describes you",
                fontSize: 14,
              ),

              const Space.h(height: 32),

              for (CategoryModel model in snapshot.data ?? [])
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    // Which Pets user likes
                    //
                    DesignText(
                      text: model.name,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    const Space.h(height: 16),
                    Wrap(
                      runSpacing: 12,
                      spacing: 12,
                      children: List.generate(
                        model.subCategoryInfoList.length,
                        (index) {
                          final subCategory = model.subCategoryInfoList[index];

                          return Obx(
                            () => DesignChip(
                              title:
                                  "${subCategory.iconUrl} ${subCategory.name}",
                              isSelected: controller.selectedChips.contains(
                                subCategory.subCategoryId,
                              ),
                              onTap: () {
                                controller.addProfileInterest(
                                  model.categoryId,
                                  subCategory.subCategoryId,
                                );
                                // populate list of hashTags and prompts
                                controller
                                    .populateUsersHashtags(snapshot.data ?? []);
                                controller
                                    .populateUserPrompts(snapshot.data ?? []);
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const Space.h(height: 32),
                  ],
                ),

              //
              // Let users create hashtags
              //
              DesignText(
                text: "Create hashtag",
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              const Space.h(height: 8),
              Obx(
                () => Wrap(
                  runSpacing: 12,
                  spacing: 12,
                  children: [
                    DesignText(
                      text: "Suggested hashtags:",
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    ...List.generate(
                      controller.usersHashtags.length,
                      (index) => DesignChip.small(
                        title: controller.usersHashtags[index].name,
                        onTap: () {
                          controller.updateSelectedHashTag(HashTag(
                              controller.usersHashtags[index].name,
                              !controller.usersHashtags[index].isSelected));
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const Space.h(height: 8),
              DesignText(
                text: "Create your custom hashtags",
                fontSize: 14,
              ),
              const Space.h(height: 8),
              Wrap(
                runSpacing: 12,
                spacing: 12,
                children: [
                  Obx(
                    () => Wrap(
                      runSpacing: 12,
                      spacing: 12,
                      children: List.generate(
                        controller.selectedHashtags.length,
                        (index) => DesignChip(
                          title: controller.selectedHashtags[index].name,
                          isSelected: true,
                          showCloseAction: true,
                          onCloseClicked: () {
                            controller.updateSelectedHashTag(
                                (controller.selectedHashtags[index]));
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const Space.h(height: 8),
              DesignTextField(
                controller: controller.hashTagController,
                hintText: "Create # for your interest",
                suffixIcon: GestureDetector(
                  onTap: () {
                    final hashTag = controller.hashTagController.text;

                    if (hashTag.isEmpty) return;

                    if (hashTag.startsWith("#")) {
                      controller.selectedHashtags.add(HashTag(hashTag, true));
                    } else {
                      controller.selectedHashtags
                          .add(HashTag("#$hashTag", true));
                    }

                    controller.hashTagController.clear();
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: DesignColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: DesignIcon.icon(
                      icon: Icons.add_rounded,
                      color: DesignColors.white,
                      size: 16,
                    ),
                  ),
                ),
              ),

              const Space.h(height: 32),

              //
              // Let users answer prompts
              //
              DesignText(
                text: "Prompts",
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
              const Space.h(height: 16),

              Obx(() => ListView.builder(
                    itemCount: controller.userPrompts.entries.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final item =
                          controller.userPrompts.entries.elementAt(index);

                      final promptsList = item.value;

                      // Check if the prompt is already selected
                      bool isAlreadySelected =
                          promptsList.length == 2 && promptsList[1].isNotEmpty;

                      return GestureDetector(
                        onTap: () async {
                          final id = item.key;
                          final q = item.value[0];
                          controller.promptAnswerController.text =
                              item.value.length > 1 ? item.value[1] : "";
                          await showPromptAnswerBottomSheet(context, id, q);
                        },
                        child: Container(
                          width: sw(1),
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 12,
                          ),
                          margin: EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isAlreadySelected
                                ? DesignColors.accent.withOpacity(0.25)
                                : null,
                            border: Border.all(
                                color: DesignColors.border, width: 1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: DesignText(
                                  text: item.value[0],
                                  fontSize: 14,
                                  maxLines: 3,
                                ),
                              ),
                              DesignIcon.icon(
                                icon: Icons.arrow_forward_ios_rounded,
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  )),

              // ...List.generate(
              //   controller.userPrompts.length,
              //       (index) {
              //     final item = controller.userPrompts.entries.elementAt(index);
              //
              //     return GestureDetector(
              //       onTap: () async {
              //         final id = item.key;
              //         final q = item.value[0];
              //
              //         await showPromptAnswerBottomSheet(context, id, q);
              //       },
              //       child: Obx(
              //             () => Container(
              //           width: 1.sw,
              //           padding: EdgeInsets.symmetric(
              //             horizontal: 8.sp,
              //             vertical: 12.sp,
              //           ),
              //           margin: EdgeInsets.symmetric(vertical: 8.sp),
              //           decoration: BoxDecoration(
              //             color: controller.userPrompts[item.key]!.length == 2
              //                 ? DesignColors.accent.withOpacity(0.25)
              //                 : null,
              //             border:
              //             Border.all(color: DesignColors.border, width: 1),
              //             borderRadius: BorderRadius.circular(8.r),
              //           ),
              //           child: Row(
              //             children: [
              //               Expanded(
              //                 child: DesignText(
              //                   text: item.value[0],
              //                   fontSize: 14.sp,
              //                   maxLines: 3,
              //                 ),
              //               ),
              //               DesignIcon.icon(
              //                 icon: Icons.arrow_forward_ios_rounded,
              //                 size: 16.sp,
              //               )
              //             ],
              //           ),
              //         ),
              //       ),
              //     );
              //   },
              // ),

              const Space.h(height: 32),

              //
              // Continue to next step
              //
              SizedBox(
                width: sw(1), // 100% of the available width
                child: Obx(
                  () => DesignButton(
                    isEnabled: !controller.isLoading.value,
                     isLoading: controller.isLoading.value,
                    title: (controller.userProfileInterests.isEmpty &&
      controller.selectedHashtags.isEmpty &&
        controller.userPromptQuestions.isEmpty) ? "Skip" : 
                    controller.isEditingEnabled.value
                        ? "Create Profile"
                        : "Done",
                    onPress: () async {
                      await controller.updateUserInterests();
                    },
                  ),
                ),
              ),
              const Space.h(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DesignIcon.icon(
                    icon: Icons.remove_red_eye_sharp,
                    size: 16,
                  ),
                  const Space.w(width: 8),
                  DesignText(
                    text: "This would be shown on your profile",
                    fontSize: 12,
                  ),
                ],
              ),
            ],
          );
        });
  }

  Future<void> showPromptAnswerBottomSheet(
    BuildContext context,
    String id,
    String question,
  ) async {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    await showModalBottomSheet(
      enableDrag: true,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24,
              ),
              height: sh(0.35),
              width: sw(1),
              decoration: BoxDecoration(
                color: DesignColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DesignText(
                    text: "Write Your Answer",
                    fontSize: 20,
                  ),
                  const Space.h(height: 24),
                  DesignTextField(
                    controller: controller.promptAnswerController,
                    hintText: question,
                  ),
                  const Space.h(height: 64),
                  SizedBox(
                    width: sw(1), // 100% of the available width
                    child: DesignButton(
                      title: "Continue",
                      onPress: () {
                        if (controller.promptAnswerController.text.isEmpty) {
                          return;
                        }

                        if (controller.userPrompts[id] == null) {
                          controller.userPrompts[id] = [question];
                        }
                        if (controller.userPromptQuestions[id] == null) {
                          controller.userPromptQuestions[id] = [question];
                        }
                        if (controller.userPrompts[id]!.length > 1) {
                          controller.userPrompts[id]![1] =
                              controller.promptAnswerController.text.trim();
                        } else {
                          controller.userPromptQuestions[id]!.add(question);
                          controller.userPrompts[id]!.add(
                            controller.promptAnswerController.text.trim(),
                          );
                        }
                        controller.userPrompts.refresh();

                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

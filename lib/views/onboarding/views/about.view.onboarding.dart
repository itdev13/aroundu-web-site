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

class AboutOnboardingView extends GetWidget<OnboardingController> {
  const AboutOnboardingView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return FutureBuilder<List<CategoryModel>>(
      future: controller.service.getListOfProfileInfo(),
      builder: (context, snapshot) {
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
            // About users
            //
            DesignText(
              text: "About you",
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
            const Space.h(height: 8),
            DesignText(
              text: "Tell us about yourself",
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
                  const Space.h(height: 6),
                  DesignText(
                    text: model.description,
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
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
                            title: "${subCategory.iconUrl} ${subCategory.name}",
                            isSelected: controller.selectedChips.contains(
                              subCategory.subCategoryId,
                            ),
                            onTap: () {
                              controller.addProfileInterest(
                                model.categoryId,
                                subCategory.subCategoryId,
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const Space.h(height: 32),
                ],
              ),

            const Space.h(height: 16),

            //
            // Continue to next step
            //
            SizedBox(
              width: sw(1), // 100% of the available width
              child: Obx(
                () => DesignButton(
                  title: (controller.userProfileInterests.isEmpty && controller.selectedChips.isEmpty)? "Skip" : "Next",
                  isEnabled: !controller.isLoading.value,
                  isLoading: controller.isLoading.value,
                  onPress: () async {
                    await controller.updateProfileInterests();
                    controller.assignSelectedChipsFromUserInterests(
                        controller.userInterestList);
                    controller
                        .populateUserInterests(controller.userInterestList);
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
      },
    );
  }
}

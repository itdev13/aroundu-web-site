import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/models/profile.model.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/onboarding/controller.onboarding.dart';
import 'package:aroundu/views/onboarding/widgets/progress_indicator.widget.onboarding.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../designs/utils.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({
    super.key,
    this.startingPageIndex = 0,
    this.destination = 'new',
  });
  final int startingPageIndex;
  final String destination;

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = Get.put(OnboardingController());

  @override
  void initState() {
    super.initState();
    controller.destination.value = widget.destination;
    controller.onboardingIndex.value = widget.startingPageIndex;

    controller.isEditingEnabled.value = Get.arguments[0] as bool;
    final currentState = Get.arguments[1] as String;
    final usersName = Get.arguments[2] as String;
    controller.userNameController.text = Get.arguments[3] as String;
    controller.usersDob.value = DateTime.parse(Get.arguments[4]);
    controller.usersBioController.text = Get.arguments[5] as String;

    controller.assignSelectedChips(Get.arguments[6] as List<ProfileInterest>);
    controller.populateProfileInterests(
      Get.arguments[6] as List<ProfileInterest>,
    );

    controller.userInterestList.value = Get.arguments[7] as List<UserInterest>;

    List<String> hashtagsAsString = Get.arguments[8] as List<String>;
    // Convert List<String> to List<HashTag> with isSelected set to false
    List<HashTag> hashtags =
        hashtagsAsString.map((tag) => HashTag(tag, true)).toList();
    // Assign the value to the controller
    controller.selectedHashtags.value = hashtags;
    controller.initializeUserPrompts(Get.arguments[9] as List<Prompts>);

    final userGender = Get.arguments[10] as String;
    controller.usersGender.value =
        (userGender == 'MALE') ? 0 : ((userGender == 'FEMALE') ? 1 : 2);

    kLogger.trace(
      "Received [$currentState] as onboarding state in `OnboardingView`",
    );

    kLogger.trace(
      "Received Users Name as [$usersName] from [GAuth] in `OnboardingView`",
    );

    controller.setOnboardingIndexAccordingToState(currentState);
    controller.usersNameController.text = usersName;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          scrolledUnderElevation: 0,
          leading:
              (!controller.isEditingEnabled.value)
                  ? IconButton(
                    onPressed: () {
                      controller.onboardingIndex.value = 0;
                      Get.back();
                    },
                    icon: DesignIcon.icon(icon: Icons.arrow_back),
                  )
                  : null,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: DesignUtils.scaffoldPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //
                // Progress Indicators
                //
                Obx(
                  () => Row(
                    children: [
                      OnboardingProgressIndicatorWidget(
                        isCompleted: controller.onboardingIndex.value >= 0,
                      ),
                      const Space.w(width: 16),
                      OnboardingProgressIndicatorWidget(
                        isCompleted: controller.onboardingIndex.value >= 1,
                      ),
                      const Space.w(width: 16),
                      OnboardingProgressIndicatorWidget(
                        isCompleted: controller.onboardingIndex.value == 2,
                      ),
                    ],
                  ),
                ),

                const Space.h(height: 32),

                //
                // Onboarding views
                //
                Obx(
                  () =>
                      controller.onboardingViews[controller
                          .onboardingIndex
                          .value],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

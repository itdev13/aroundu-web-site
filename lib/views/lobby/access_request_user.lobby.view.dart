import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/widgets/rounded.rectangle.tab.indicator.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/checkout.view.lobby.dart';
import 'package:aroundu/views/lobby/form_page.dart';
import 'package:aroundu/views/lobby/provider/get_price_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_access_provider.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../designs/colors.designs.dart';
import '../../designs/fonts.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/icon.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';
import '../../designs/widgets/text.widget.designs.dart';
import '../../models/lobby.dart';
import '../dashboard/controller.dashboard.dart';
import '../profile/controllers/controller.groups.profiledart.dart';
import 'package:aroundu/views/profile/service.profile.dart';
import '../profile/services/service.groups.profile.dart' hide UserFriendsModel;
import 'checkout.view.lobby.dart';

final selectedFriendIds = StateProvider<List<String>>((ref) => []);
final selectedSquadIds = StateProvider<List<String>>((ref) => []);
final selectedConversationIds = StateProvider<List<String>>((ref) => []);
final requestedText = StateProvider<String>((ref) => '');

class UserLobbyAccessRequest extends ConsumerStatefulWidget {
  const UserLobbyAccessRequest({
    super.key,
    // required this.lobbyDetails,
    required this.lobby,
    this.isIndividual = true,
  });

  // final LobbyDetails lobbyDetails;
  final Lobby lobby;
  final bool isIndividual;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserLobbyAccessRequestState();
}

class _UserLobbyAccessRequestState
    extends ConsumerState<UserLobbyAccessRequest> {
  final groupController = Get.put(GroupController());
  final profileController = Get.put(ProfileController());
  final DashboardController dashboardController =
      Get.find<DashboardController>();
  final TextEditingController requestedTextEditingController =
      TextEditingController();

  @override
  void initState() {
    groupController.fetchGroups();
    profileController.getFriends();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formStateProvider(widget.lobby.id).notifier).reloadFormData();
    });
    super.initState();
  }

  @override
  void dispose() {
    requestedTextEditingController.clear();
    super.dispose();
  }

  Future<void> _submitRequest(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final requestText = ref.read(requestedText);
    final lobby = widget.lobby;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    // Handle form submission if the lobby has a form
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return AlertDialog(
    //       backgroundColor: Colors.transparent,
    //       content: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         children: [
    //           CircularProgressIndicator(
    //             color: DesignColors.accent,
    //           ),
    //         ],
    //       ),
    //     );
    //   },
    // );

    await ref
        .read(pricingProvider(lobby.id).notifier)
        .fetchPricing(lobby.id, groupSize: 1);

    final pricingState = ref.read(pricingProvider(lobby.id));
    final pricingData = pricingState.pricingData;

    if (pricingData != null && pricingData.status == 'SUCCESS') {
      if (lobby.isPrivate) {
        if (lobby.hasForm) {
          final formNotifier = ref.read(formStateProvider(lobby.id).notifier);

          // Check if the message is empty when required
          if (requestText.isEmpty && !lobby.hasForm) {
            Get.snackbar("Error", "Message cannot be empty");
            return;
          }

          // Check if all mandatory questions have been answered
          final missingQuestion =
              formNotifier.getMandatoryQuestionWithoutAnswer();
          if (missingQuestion != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Incomplete Form"),
                    content: Text(
                      "Please answer the mandatory question: $missingQuestion",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
            );
            return;
          }

          try {
            // Get final list of questions with their answers
            final finalQuestions = formNotifier.getQuestionsWithAnswers();

            // Convert to JSON for submission
            final formModel = FormModel(
              title: ref.read(formStateProvider(lobby.id)).title,
              questions: finalQuestions,
            );

            kLogger.trace(formModel.toJson().toString());

            if (widget.isIndividual) {
              // Submit the form
              final response = await ref.read(
                handleLobbyAccessProvider(
                  lobby.id,
                  lobby.isPrivate,
                  friends:
                      widget.isIndividual ? [] : ref.read(selectedFriendIds),
                  groupId:
                      widget.isIndividual ? [] : ref.read(selectedSquadIds),
                  text: requestText,
                  form: formModel.toJson(),
                  hasForm: true,
                ).future,
              );

              // Handle conversation sharing if needed
              // if (ref.read(selectedConversationIds).isNotEmpty) {
              //   await chatController.sendBulkMessages(
              //     message: "",
              //     id: response['id'],
              //     from: chatController.currentUserId.value,
              //     attachments: [],
              //     conversationIds: ref.read(selectedConversationIds),
              //     type: "ACCESS_REQUEST",
              //   );
              // }

              // Reset state and navigate
              _resetState();
              Get.back();
              dashboardController.updateTabIndex(2);
            } else {
              Get.toNamed(
                AppRoutes.lobbyAccessRequestShare,
                arguments: {
                  'friends': profileController.friendsList,
                  'squads': groupController.groups,
                  'lobbyId': widget.lobby.id,
                  'lobbyHasForm': widget.lobby.hasForm,
                  'lobbyIsPrivate': widget.lobby.isPrivate,
                  'requestText': requestText,
                  'formModel': formModel,
                },
              );
              requestedTextEditingController.clear();
            }
          } catch (e) {
            // Handle submission errors
            Get.snackbar(
              "Error",
              "Failed to submit form: ${e.toString()}",
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
        // Handle non-form lobby access
        else {
          if (widget.isIndividual) {
            // Check if message is empty
            if (requestText.isEmpty) {
              Get.snackbar("Error", "Message cannot be empty");
              return;
            }

            try {
              final response = await ref.read(
                handleLobbyAccessProvider(
                  lobby.id,
                  lobby.isPrivate,
                  text: requestText,
                  hasForm: false,
                ).future,
              );

              // if (ref.read(selectedConversationIds).isNotEmpty) {
              //   await chatController.sendBulkMessages(
              //     message: "",
              //     id: response['id'],
              //     from: chatController.currentUserId.value,
              //     attachments: [],
              //     conversationIds: ref.read(selectedConversationIds),
              //     type: "ACCESS_REQUEST",
              //   );
              // }

              _resetState();
              Get.back();
              dashboardController.updateTabIndex(2);
            } catch (e) {
              Get.snackbar(
                "Error",
                "Failed to submit request: ${e.toString()}",
                snackPosition: SnackPosition.BOTTOM,
              );
            }
          } else {
            Get.toNamed(
              AppRoutes.lobbyAccessRequestShare,
              arguments: {
                'friends': profileController.friendsList,
                'squads': groupController.groups,
                'lobbyId': widget.lobby.id,
                'lobbyHasForm': widget.lobby.hasForm,
                'lobbyIsPrivate': widget.lobby.isPrivate,
                'requestText': requestText,
              },
            );
            requestedTextEditingController.clear();
          }
        }
      } else {
        //Public lobby
        if (lobby.hasForm && lobby.priceDetails?.price != 0.0) {
          final formNotifier = ref.read(formStateProvider(lobby.id).notifier);

          // Check if the message is empty when required
          if (requestText.isEmpty && !lobby.hasForm) {
            Get.snackbar("Error", "Message cannot be empty");
            return;
          }

          // Check if all mandatory questions have been answered
          if (lobby.isFormMandatory) {
            final missingQuestion =
                formNotifier.getMandatoryQuestionWithoutAnswer();
            if (missingQuestion != null) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text("Incomplete Form"),
                      content: Text(
                        "Please answer the mandatory question: $missingQuestion",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
              );
              return;
            }
          }

          try {
            // Get final list of questions with their answers
            final finalQuestions = formNotifier.getQuestionsWithAnswers();

            // Convert to JSON for submission
            final formModel = FormModel(
              title: ref.read(formStateProvider(lobby.id)).title,
              questions: finalQuestions,
            );

            kLogger.trace(formModel.toJson().toString());

            await Get.off(
              () => CheckOutPublicLobbyView(
                lobby: widget.lobby,
                formModel: formModel,
                requestText: requestText,
              ),
            );

            // Reset state and navigate
            _resetState();
            // Get.back();
            dashboardController.updateTabIndex(2);
          } catch (e) {
            // Handle submission errors
            // Get.snackbar(
            //   "Error",
            //   "Failed to submit form: ${e.toString()}",
            //   snackPosition: SnackPosition.BOTTOM,
            // );
          }
        }
        // Handle non-form lobby access
        else {
          final formNotifier = ref.read(formStateProvider(lobby.id).notifier);

          // Check if the message is empty when required
          if (requestText.isEmpty && !lobby.hasForm) {
            Get.snackbar("Error", "Message cannot be empty");
            return;
          }

          // Check if all mandatory questions have been answered
          final missingQuestion =
              formNotifier.getMandatoryQuestionWithoutAnswer();
          if (missingQuestion != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    title: const Text("Incomplete Form"),
                    content: Text(
                      "Please answer the mandatory question: $missingQuestion",
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("OK"),
                      ),
                    ],
                  ),
            );
            return;
          }

          try {
            // Get final list of questions with their answers
            final finalQuestions = formNotifier.getQuestionsWithAnswers();

            // Convert to JSON for submission
            final formModel = FormModel(
              title: ref.read(formStateProvider(lobby.id)).title,
              questions: finalQuestions,
            );

            kLogger.trace(formModel.toJson().toString());

            // Submit the form
            final response = await ref.read(
              handleLobbyAccessProvider(
                lobby.id,
                lobby.isPrivate,
                // friends: widget.isIndividual ? [] : ref.read(selectedFriendIds),
                // groupId: widget.isIndividual ? [] : ref.read(selectedSquadIds),
                text: requestText,
                form: formModel.toJson(),
                hasForm: true,
              ).future,
            );

            // Handle conversation sharing if needed
            // if (ref.read(selectedConversationIds).isNotEmpty) {
            //   await chatController.sendBulkMessages(
            //     message: "",
            //     id: response['id'],
            //     from: chatController.currentUserId.value,
            //     attachments: [],
            //     conversationIds: ref.read(selectedConversationIds),
            //     type: "ACCESS_REQUEST",
            //   );
            // }

            // Reset state and navigate
            _resetState();
            Get.back();
            if (response != null && response['status'] == 'SUCCESS') {
              Get.dialog(
                Dialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Lottie.asset(
                              'assets/animations/success_badge.json',
                              repeat: false,
                              fit: BoxFit.fitHeight,
                              height: sh(0.2),
                              width: sw(0.9),
                            ),
                            Space.h(height: 8),
                            DesignText(
                              text: "  Congratulations 🎉",
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF323232),
                            ),
                            Space.h(height: 8),
                            DesignText(
                              text: "you have successfully joined the lobby",
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF444444),
                              maxLines: 3,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Lottie.asset(
                        'assets/animations/confetti.json',
                        repeat: false,
                        fit: BoxFit.fill,
                        // height: 0.8.sw,
                      ),
                    ],
                  ),
                ),
                barrierDismissible: true,
              );
              Fluttertoast.showToast(msg: "successfully joined the lobby");
            }
            dashboardController.updateTabIndex(2);
          } catch (e) {
            // Handle submission errors
            Get.snackbar(
              "Error",
              "Failed to submit form: ${e.toString()}",
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        }
      }
    } else {
      CustomSnackBar.show(
        context: context,
        message: "Something went wrong",
        type: SnackBarType.error,
      );
    }
  }

  void _resetState() {
    ref.read(selectedFriendIds.notifier).state = [];
    ref.read(selectedSquadIds.notifier).state = [];
    ref.read(selectedConversationIds.notifier).state = [];
    ref.read(requestedText.notifier).state = '';
    requestedTextEditingController.clear();

    ref.read(requestTextProvider.notifier).state = '';
    ref.invalidate(lobbyFormAutofillProvider(widget.lobby.id));
    ref.read(formStateProvider(widget.lobby.id).notifier).resetForm();
    ref.invalidate(formStateProvider(widget.lobby.id));
  }

  @override
  Widget build(BuildContext context) {
    final lobby = widget.lobby;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            onPressed: () {
              _resetState();
              Get.back();
            },
            icon: DesignIcon.icon(
              icon: Icons.arrow_back_ios_new_rounded,
              size: 18,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.all(16),
              child: InkWell(
                onTap: _resetState,
                child: DesignText(
                  text: 'Clear',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3E79A1),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: GestureDetector(
          onTap: () => _submitRequest(context),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              child: Container(
                width: sw(0.1),
                height: 50,
                color: Colors.red,
                child: Center(
                  child: DesignText(
                    text:
                        widget.isIndividual
                            ? lobby.isPrivate
                                ? 'Request Access'
                                : 'Join Lobby'
                            : "Continue",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!lobby.hasForm && lobby.isPrivate) ...[
                  Card(
                    shadowColor: Color(0x143E79A1),
                    elevation: 6,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 18,
                        top: 12,
                        left: 12,
                        right: 12,
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: DesignText(
                              text: "Add note for the host ",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF444444),
                            ),
                          ),
                          Space.h(height: 12),

                          // TextField to enter request text
                          DesignTextField(
                            controller: requestedTextEditingController,
                            hintText: "Enter Request Message",
                            maxLines: 5,
                            onChanged: (value) {
                              ref.read(requestedText.notifier).state = value!;
                            },
                            borderRadius: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Space.h(height: 34),
                ],
                if (lobby.hasForm) _buildFormContent(lobby),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(Lobby lobby) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Request message section
        if (lobby.isPrivate) ...[
          Card(
            shadowColor: Color(0x143E79A1),
            elevation: 6,
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: 18,
                top: 12,
                left: 12,
                right: 12,
              ),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: DesignText(
                      text: "Add note for the host ",
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF444444),
                    ),
                  ),
                  Space.h(height: 12),

                  // TextField to enter request text
                  DesignTextField(
                    controller: requestedTextEditingController,
                    hintText: "Enter Request Message",
                    maxLines: 5,
                    fontSize: 12,
                    onChanged: (value) {
                      ref.read(requestedText.notifier).state = value!;
                    },
                    borderRadius: 24,
                  ),
                ],
              ),
            ),
          ),
          Space.h(height: 34),
        ],

        // Form section
        DesignText(
          text: "Fill the survey form",
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF323232),
        ),
        Space.h(height: 12),
        DesignText(
          text:
              "Your answer to this survey from will be visible to the lobby host",
          fontSize: 12,
          fontWeight: FontWeight.w300,
          color: Color(0xFF444444),
          maxLines: 2,
        ),
        Space.h(height: 34),

        _buildFormQuestions(lobby),
      ],
    );
  }

  Widget _buildFormQuestions(Lobby lobby) {
    final formState = ref.watch(formStateProvider(lobby.id));
    final formNotifier = ref.watch(formStateProvider(lobby.id).notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Form title
        // Align(
        //   alignment: Alignment.centerLeft,
        //   child: DesignText(
        //     text: formState.title,
        //     fontSize: 16,
        //     fontWeight: FontWeight.w500,
        //   ),
        // ),

        // Form questions
        Padding(
          // constraints: BoxConstraints(maxHeight: 0.6.sh),
          padding: EdgeInsets.only(bottom: (Get.height * 0.1)),
          child:
              formState.questions.isEmpty
                  ? FutureBuilder(
                    future: Future.delayed(const Duration(milliseconds: 2500)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFEC4B5D),
                          ),
                        );
                      } else {
                        return Center(
                          child: DesignText(
                            text: "No questions found",
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF323232),
                          ),
                        );
                      }
                    },
                  )
                  : Column(
                    children: List.generate(formState.questions.length, (
                      index,
                    ) {
                      final question = formState.questions[index];

                      // Text question
                      if (question.questionType == 'text') {
                        final controller = formNotifier
                            .getControllerForQuestion(question.id);

                        if (controller == null) {
                          return const SizedBox.shrink();
                        }

                        // Make sure controller has the latest value
                        if (controller.text != question.answer) {
                          controller.text = question.answer;
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 18,
                                top: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText),
                                        if (question.isMandatory)
                                          TextSpan(
                                            text: '   *',
                                            style: TextStyle(
                                              color: Color(0xFFEC4B5D),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Answer",
                                    // maxLines: 5,
                                    fontSize: 12,
                                    onChanged:
                                        (val) => formNotifier.updateAnswer(
                                          question.id,
                                          val!,
                                        ),
                                    borderRadius: 16,
                                  ),
                                  // const SizedBox(height: 8),
                                  // TextFormField(
                                  //   controller: controller,
                                  //   decoration: const InputDecoration(
                                  //     labelText: "Answer",
                                  //     border: OutlineInputBorder(),
                                  //   ),
                                  //   onChanged: (val) => formNotifier.updateAnswer(
                                  //       question.id, val,),
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Multiple choice question
                      else if (question.questionType == 'multiple-choice') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 24),
                          child: Card(
                            shadowColor: Color(0x143E79A1),
                            elevation: 6,
                            color: Colors.white,
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: 18,
                                top: 12,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: 10,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText),
                                        if (question.isMandatory)
                                          TextSpan(
                                            text: '   *',
                                            style: TextStyle(
                                              color: Color(0xFFEC4B5D),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  ...question.options.map((option) {
                                    return CheckboxListTile(
                                      title: DesignText(
                                        text: option,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xFF444444),
                                      ),
                                      value: question.answer == option,
                                      onChanged: (val) {
                                        if (val != null && val) {
                                          formNotifier.updateAnswer(
                                            question.id,
                                            option,
                                          );
                                        }
                                      },
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 0,
                                          ),
                                      activeColor: const Color(0xFFEC4B5D),
                                      checkColor: Colors.white,
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                      dense: true,
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      // Default fallback for unsupported question types
                      return Container();
                    }),
                  ),
        ),
      ],
    );
  }
}

class UserLobbyAccessRequestShare extends ConsumerStatefulWidget {
  const UserLobbyAccessRequestShare({
    super.key,
    required this.friends,
    required this.squads,
    required this.lobbyId,
    required this.lobbyHasForm,
    required this.lobbyIsPrivate,
    required this.requestText,
    this.formModel,
  });

  final List<GroupModel> squads;
  final List<UserFriendsModel> friends;
  // final Lobby lobby;
  final String lobbyId;
  final bool lobbyHasForm;
  final bool lobbyIsPrivate;
  final String requestText;
  final FormModel? formModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _UserLobbyAccessRequestShare();
}

class _UserLobbyAccessRequestShare
    extends ConsumerState<UserLobbyAccessRequestShare> {
  final controller = Get.find<ProfileController>();
  // final chatController = Get.find<ChatsController>();
  final DashboardController dashboardController =
      Get.find<DashboardController>();

  void _resetState() {
    ref.read(selectedFriendIds.notifier).state = [];
    ref.read(selectedSquadIds.notifier).state = [];
    ref.read(selectedConversationIds.notifier).state = [];
    ref.read(requestedText.notifier).state = '';

    ref.read(requestTextProvider.notifier).state = '';
    ref.invalidate(lobbyFormAutofillProvider(widget.lobbyId));
    ref.read(formStateProvider(widget.lobbyId).notifier).resetForm();
    ref.invalidate(formStateProvider(widget.lobbyId));
  }

  @override
  Widget build(BuildContext context) {
    double sw = MediaQuery.of(context).size.width;
    double sh = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          bottomNavigationBar: GestureDetector(
            onTap: () async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    backgroundColor: Colors.transparent,
                    content: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: DesignColors.accent),
                      ],
                    ),
                  );
                },
              );

              print(
                "Request text value: ${widget.requestText}",
              ); // Log requestText value

              print(
                "friendsIds: ${ref.read(selectedFriendIds)} squadsIds: ${ref.read(selectedSquadIds)}",
              );

              try {
                if (widget.lobbyHasForm) {
                  final response = await ref.read(
                    handleLobbyAccessProvider(
                      widget.lobbyId,
                      widget.lobbyIsPrivate,
                      friends: ref.read(selectedFriendIds),
                      groupId: ref.read(selectedSquadIds),
                      text: widget.requestText,
                      form: widget.formModel?.toJson() ?? {},
                      hasForm: true,
                    ).future,
                  );
                  // if (ref.read(selectedConversationIds).isNotEmpty) {
                  //   await chatController.sendBulkMessages(
                  //     message: "",
                  //     id: response['id'],
                  //     from: chatController.currentUserId.value,
                  //     attachments: [],
                  //     conversationIds: ref.read(selectedConversationIds),
                  //     type: "ACCESS_REQUEST",
                  //   );
                  // }
                } else {
                  final response = await ref.read(
                    handleLobbyAccessProvider(
                      widget.lobbyId,
                      widget.lobbyIsPrivate,
                      friends: ref.read(selectedFriendIds),
                      groupId: ref.read(selectedSquadIds),
                      text: widget.requestText,
                      hasForm: false,
                    ).future,
                  );
                  // if (ref.read(selectedConversationIds).isNotEmpty) {
                  //   await chatController.sendBulkMessages(
                  //     message: "",
                  //     id: response['id'],
                  //     from: chatController.currentUserId.value,
                  //     attachments: [],
                  //     conversationIds: ref.read(selectedConversationIds),
                  //     type: "ACCESS_REQUEST",
                  //   );
                  // }
                }

                await Future.delayed(const Duration(seconds: 1));
                // Close loading dialog
                Navigator.pop(context);

                Fluttertoast.showToast(
                  msg:
                      "Your request has been sent successfully, Please check the chats",
                );

                // Reset states and navigate back
                ref.read(selectedFriendIds.notifier).state = [];
                ref.read(selectedSquadIds.notifier).state = [];
                ref.read(selectedConversationIds.notifier).state = [];
                ref.read(requestedText.notifier).state = '';
                Get.back();
                Get.back();
                Get.back();

                dashboardController.updateTabIndex(2);
              } catch (e) {
                // Close loading dialog on error
                Navigator.pop(context);
                Fluttertoast.showToast(msg: "Error: ${e.toString()}");
              }
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                child: Container(
                  width: 0.1*sw,
                  height: 0.12*sw,
                  color: Colors.red,
                  child: Center(
                    child: DesignText(
                      text:
                          widget.lobbyIsPrivate
                              ? 'Request Access'
                              : 'Join Lobby',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.only(top: 16, left: 16, right: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: DesignIcon.icon(
                              icon: Icons.arrow_back_ios_new_rounded,
                            ),
                          ),
                        ],
                      ),
                      Space.h(height: 16),
                      Obx(
                        () => TabBar(
                          onTap: controller.setInviteTabIndex,
                          tabs: [
                            Tab(
                              child: DesignText(
                                text: "Friends",
                                fontSize: 14,
                                color:
                                    controller.inviteTabIndex.value == 0
                                        ? const Color(0xFF323232)
                                        : const Color(0xFF989898),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Tab(
                              child: DesignText(
                                text: "Squads",
                                fontSize: 14,
                                color:
                                    controller.inviteTabIndex.value == 1
                                        ? const Color(0xFF323232)
                                        : const Color(0xFF989898),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          labelColor: const Color(0xFF323232),
                          unselectedLabelColor: const Color(0xFF989898),
                          labelStyle: DesignFonts.poppins.merge(
                            TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF323232),
                            ),
                          ),
                          unselectedLabelStyle: DesignFonts.poppins.merge(
                            TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF989898),
                            ),
                          ),
                          indicator: RoundedRectangleTabIndicator(
                            color: const Color(0xFFEAEFF2),
                            radius: 24,
                            paddingV: 2,
                            paddingH: 40,
                          ),
                          dividerColor: Colors.transparent,
                          labelPadding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: TabBarView(
                      physics: const BouncingScrollPhysics(),
                      children: [
                        //       ListTile(
                        //       onTap: () {
                        // setState(() {
                        // if (isSelected) {
                        // selectedUserIds.remove(member.userId);
                        // } else {
                        // selectedUserIds.add(member.userId);
                        // }
                        // });
                        // },
                        //   leading: CircleAvatar(
                        //     radius: 24.r,
                        //     child: (member.profilePictureUrl != "")
                        //         ? Image.network(
                        //       fit: BoxFit.cover,
                        //       member.profilePictureUrl ?? "",
                        //     )
                        //         : Icon(
                        //       Icons.person,
                        //       size: 20.sp,
                        //     ),
                        //   ),
                        //   title: DesignText(
                        //     text: member.name,
                        //     fontSize: 14.sp,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        //   subtitle: DesignText(
                        //     text: member.userName,
                        //     fontSize: 12.sp,
                        //     fontWeight: FontWeight.w500,
                        //     color: DesignColors.secondary,
                        //   ),
                        //   trailing: CupertinoButton(
                        //     padding: EdgeInsets
                        //         .zero, // Remove padding to align icon properly
                        //     onPressed: () {
                        //       setState(() {
                        //         if (isSelected) {
                        //           selectedUserIds
                        //               .remove(member.userId);
                        //         } else {
                        //           selectedUserIds.add(member.userId);
                        //         }
                        //       });
                        //     },
                        //     child: Icon(
                        //       isSelected
                        //           ? CupertinoIcons
                        //           .check_mark_circled_solid
                        //           : CupertinoIcons.circle,
                        //       color: isSelected
                        //           ? DesignColors.accent
                        //           : CupertinoColors.inactiveGray,
                        //       size: 28,
                        //     ),
                        //   ),
                        // );

                        //
                        // friends
                        //
                        widget.friends.isNotEmpty
                            ? ListView.separated(
                              itemCount: widget.friends.length,
                              separatorBuilder:
                                  (context, index) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final member = widget.friends[index];
                                final isSelected = ref
                                    .read(selectedFriendIds)
                                    .contains(member.userId);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        ref
                                            .read(selectedFriendIds)
                                            .remove(member.userId);
                                        ref
                                            .read(selectedConversationIds)
                                            .remove(member.conversationId);
                                      } else {
                                        ref
                                            .read(selectedFriendIds)
                                            .add(member.userId);
                                        ref
                                            .read(selectedConversationIds)
                                            .add(member.conversationId);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 32,
                                              backgroundImage:
                                                  member.profilePictureUrl !=
                                                              null &&
                                                          member
                                                              .profilePictureUrl!
                                                              .isNotEmpty
                                                      ? NetworkImage(
                                                        member.profilePictureUrl ??
                                                            "https://w7.pngwing.com/pngs/205/731/png-transparent-default-avatar-thumbnail.png",
                                                      )
                                                      : null,
                                              child:
                                                  member.profilePictureUrl !=
                                                              null &&
                                                          member
                                                              .profilePictureUrl!
                                                              .isNotEmpty
                                                      ? null
                                                      : DesignIcon.icon(
                                                        icon:
                                                            Icons
                                                                .person_rounded,
                                                        size: 32,
                                                      ),
                                            ),
                                            const Space.w(width: 11),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  DesignText(
                                                    text: member.name,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  DesignText(
                                                    text: member.userName,
                                                    fontSize: 14,
                                                    color:
                                                        DesignColors.secondary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding:
                                            EdgeInsets
                                                .zero, // Remove padding to align icon properly
                                        onPressed: () {
                                          setState(() {
                                            if (isSelected) {
                                              ref
                                                  .read(selectedFriendIds)
                                                  .remove(member.userId);
                                              ref
                                                  .read(selectedConversationIds)
                                                  .remove(
                                                    member.conversationId,
                                                  );
                                            } else {
                                              ref
                                                  .read(selectedFriendIds)
                                                  .add(member.userId);
                                              ref
                                                  .read(selectedConversationIds)
                                                  .add(member.conversationId);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isSelected
                                              ? CupertinoIcons
                                                  .check_mark_circled_solid
                                              : CupertinoIcons.circle,
                                          color:
                                              isSelected
                                                  ? DesignColors.accent
                                                  : CupertinoColors
                                                      .inactiveGray,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : const Center(child: Text("No friends to show")),

                        //
                        // squads
                        //
                        widget.squads.isNotEmpty
                            ? ListView.separated(
                              itemCount: widget.squads.length,
                              separatorBuilder:
                                  (context, index) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final squad = widget.squads[index];
                                final isSelected = ref
                                    .read(selectedSquadIds)
                                    .contains(squad.groupId);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        ref
                                            .read(selectedSquadIds)
                                            .remove(squad.groupId);
                                        ref
                                            .read(selectedConversationIds)
                                            .remove(squad.groupId);
                                      } else {
                                        ref
                                            .read(selectedSquadIds)
                                            .add(squad.groupId);
                                        ref
                                            .read(selectedConversationIds)
                                            .add(squad.groupId);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 32,
                                              backgroundImage:
                                                  squad.profilePicture !=
                                                              null &&
                                                          squad
                                                              .profilePicture!
                                                              .isNotEmpty
                                                      ? NetworkImage(
                                                        squad.profilePicture ??
                                                            "https://w7.pngwing.com/pngs/205/731/png-transparent-default-avatar-thumbnail.png",
                                                      )
                                                      : null,
                                              child:
                                                  squad.profilePicture !=
                                                              null &&
                                                          squad
                                                              .profilePicture!
                                                              .isNotEmpty
                                                      ? null
                                                      : DesignIcon.icon(
                                                        icon:
                                                            Icons
                                                                .groups_rounded,
                                                        size: 32,
                                                      ),
                                            ),
                                            const Space.w(width: 11),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  DesignText(
                                                    text: squad.groupName,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  DesignText(
                                                    text:
                                                        "${squad.participants.length} member",
                                                    fontSize: 14,
                                                    color:
                                                        DesignColors.secondary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding:
                                            EdgeInsets
                                                .zero, // Remove padding to align icon properly
                                        onPressed: () {
                                          setState(() {
                                            if (isSelected) {
                                              ref
                                                  .read(selectedSquadIds)
                                                  .remove(squad.groupId);
                                              ref
                                                  .read(selectedConversationIds)
                                                  .remove(squad.groupId);
                                            } else {
                                              ref
                                                  .read(selectedSquadIds)
                                                  .add(squad.groupId);
                                              ref
                                                  .read(selectedConversationIds)
                                                  .add(squad.groupId);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isSelected
                                              ? CupertinoIcons
                                                  .check_mark_circled_solid
                                              : CupertinoIcons.circle,
                                          color:
                                              isSelected
                                                  ? DesignColors.accent
                                                  : CupertinoColors
                                                      .inactiveGray,
                                          size: 28,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            )
                            : const Center(child: Text("No squads to show")),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

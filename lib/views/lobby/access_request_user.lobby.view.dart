import 'dart:io';
import 'dart:typed_data';

import 'package:aroundu/constants/appRoutes.dart';
import 'package:aroundu/designs/widgets/rounded.rectangle.tab.indicator.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/utils/api_service/file_upload.service.dart';
import 'package:aroundu/utils/custome_snackbar.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/checkout.view.lobby.dart';
import 'package:aroundu/views/lobby/form_page.dart';
import 'package:aroundu/views/lobby/provider/get_price_provider.dart';
import 'package:aroundu/views/lobby/provider/lobby_access_provider.dart';
import 'package:aroundu/views/lobby/provider/selected_tickets_provider.dart';
import 'package:aroundu/views/profile/controllers/controller.profile.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
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
    this.selectedTickets = const <SelectedTicket>[],
  });

  // final LobbyDetails lobbyDetails;
  final Lobby lobby;
  final bool isIndividual;
  final List<SelectedTicket> selectedTickets;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserLobbyAccessRequestState();
}

class _UserLobbyAccessRequestState extends ConsumerState<UserLobbyAccessRequest> {
  final groupController = Get.put(GroupController());
  final profileController = Get.put(ProfileController());
  final DashboardController dashboardController = Get.put(DashboardController());
  final TextEditingController requestedTextEditingController = TextEditingController();

  @override
  void initState() {
    groupController.fetchGroups();
    profileController.getFriends();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(formStateProvider(widget.lobby.id).notifier).reloadFormData(widget.selectedTickets.map((e) => e.ticketId).toList());
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
        .fetchPricing(lobby.id, groupSize: 1, selectedTickets: widget.selectedTickets);

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
          final missingQuestion = formNotifier.getMandatoryQuestionWithoutAnswer();
          if (missingQuestion != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: DesignText(text: "Incomplete Form", fontSize: 16, fontWeight: FontWeight.w500),
                    content: DesignText(
                      text: "Please answer the mandatory question: $missingQuestion",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: DesignText(text: "OK", fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
            );
            return;
          }

          final formatError = formNotifier.validateQuestionAnswersFormat();
          if (formatError != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: DesignText(text: "Invalid Input", fontSize: 16, fontWeight: FontWeight.w500),
                    content: DesignText(text: formatError, fontSize: 14, fontWeight: FontWeight.w400),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: DesignText(text: "OK", fontSize: 14, fontWeight: FontWeight.w500),
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
            final formModel = FormModel(title: ref.read(formStateProvider(lobby.id)).title, questions: finalQuestions);

            kLogger.trace(formModel.toJson().toString());

            if (widget.isIndividual) {
              // Submit the form
              final response = await ref.read(
                handleLobbyAccessProvider(
                  lobby.id,
                  lobby.isPrivate,
                  friends: widget.isIndividual ? [] : ref.read(selectedFriendIds),
                  groupId: widget.isIndividual ? [] : ref.read(selectedSquadIds),
                  text: requestText,
                  form: formModel.toJson(),
                  hasForm: true,
                  selectedTickets: widget.selectedTickets,
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
                  'selectedTickets': widget.selectedTickets,

                },
              );
              requestedTextEditingController.clear();
            }
          } catch (e) {
            // Handle submission errors
            Get.snackbar("Error", "Failed to submit form: ${e.toString()}", snackPosition: SnackPosition.BOTTOM);
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
                  selectedTickets: widget.selectedTickets,
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
              // dashboardController.updateTabIndex(2);
            } catch (e) {
              Get.snackbar("Error", "Failed to submit request: ${e.toString()}", snackPosition: SnackPosition.BOTTOM);
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
                'selectedTickets': widget.selectedTickets,

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
            final missingQuestion = formNotifier.getMandatoryQuestionWithoutAnswer();
            if (missingQuestion != null) {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      title: DesignText(text: "Incomplete Form", fontSize: 16, fontWeight: FontWeight.w500),
                      content: DesignText(
                        text: "Please answer the mandatory question: $missingQuestion",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: DesignText(text: "OK", fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
              );
              return;
            }
          }

          // Add format validation check
          final formatError = formNotifier.validateQuestionAnswersFormat();
          if (formatError != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: DesignText(text: "Invalid Input", fontSize: 16, fontWeight: FontWeight.w500),
                    content: DesignText(text: formatError, fontSize: 14, fontWeight: FontWeight.w400),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: DesignText(text: "OK", fontSize: 14, fontWeight: FontWeight.w500),
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
            final formModel = FormModel(title: ref.read(formStateProvider(lobby.id)).title, questions: finalQuestions);

            kLogger.trace(formModel.toJson().toString());

            await Get.offNamed(
              AppRoutes.checkOutPublicLobbyView,
              arguments: {
                'lobby': widget.lobby,
                'formModel': formModel,
                'requestText': requestText,
                'selectedTickets': widget.selectedTickets,
              },
            );

            // Reset state and navigate
            _resetState();
            // Get.back();
            // dashboardController.updateTabIndex(2);
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
          final missingQuestion = formNotifier.getMandatoryQuestionWithoutAnswer();
          if (missingQuestion != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: DesignText(text: "Incomplete Form", fontSize: 16, fontWeight: FontWeight.w500),
                    content: DesignText(
                      text: "Please answer the mandatory question: $missingQuestion",
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: DesignText(text: "OK", fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
            );
            return;
          }

          // Add format validation check
          final formatError = formNotifier.validateQuestionAnswersFormat();
          if (formatError != null) {
            showDialog(
              context: context,
              builder:
                  (context) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: DesignText(text: "Invalid Input", fontSize: 16, fontWeight: FontWeight.w500),
                    content: DesignText(text: formatError, fontSize: 14, fontWeight: FontWeight.w400),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: DesignText(text: "OK", fontSize: 14, fontWeight: FontWeight.w500),
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
            final formModel = FormModel(title: ref.read(formStateProvider(lobby.id)).title, questions: finalQuestions);

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
                selectedTickets: widget.selectedTickets,
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
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
            Get.snackbar("Error", "Failed to submit form: ${e.toString()}", snackPosition: SnackPosition.BOTTOM);
          }
        }
      }
    } else {
      CustomSnackBar.show(context: context, message: "Something went wrong", type: SnackBarType.error);
    }
  }

  void _resetState() {
    ref.read(selectedFriendIds.notifier).state = [];
    ref.read(selectedSquadIds.notifier).state = [];
    ref.read(selectedConversationIds.notifier).state = [];
    ref.read(requestedText.notifier).state = '';
    requestedTextEditingController.clear();

    ref.read(requestTextProvider.notifier).state = '';
    ref.invalidate(
      lobbyFormAutofillProvider((
        lobbyId: widget.lobby.id,
        selectedTicketIds: widget.selectedTickets.map((e) => e.ticketId).toList(),
      )),
    );
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
    final formState = ref.watch(formStateProvider(lobby.id));
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
            icon: DesignIcon.icon(icon: Icons.arrow_back_ios_new_rounded, size: 18),
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
          onTap: () async {
            formState.questions.isEmpty
                ? await Future.delayed(const Duration(milliseconds: 2500), () {
                  // CustomSnackBar.show(
                  //   context: context,
                  //   message: "Please add questions to the form",
                  //   type: SnackBarType.error,
                  // );
                })
                : _submitRequest(context);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              child: Container(
                width: sw(0.1),
                height: 50,
                color: Colors.red,
                child: Center(
                  child:
                      formState.questions.isEmpty
                          ? FutureBuilder(
                            future: Future.delayed(const Duration(milliseconds: 2500)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
                                );
                              } else {
                                return DesignText(
                                  text:
                                      widget.isIndividual
                                          ? lobby.isPrivate
                                              ? 'Request Access'
                                              : 'Join Lobby'
                                          : "Continue",
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                );
                              }
                            },
                          )
                          : DesignText(
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
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!lobby.hasForm && lobby.isPrivate) ...[
                  Card(
                    shadowColor: Color(0x143E79A1),
                    elevation: 6,
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
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
              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
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
        DesignText(text: "Fill the survey form", fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF323232)),
        Space.h(height: 12),
        DesignText(
          text: "Your answer to this survey from will be visible to the lobby host",
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
                   future: formNotifier.loadFormData(widget.selectedTickets.map((e) => e.ticketId).toList()),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Color(0xFFEC4B5D)));
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
                    children: List.generate(formState.questions.length, (index) {
                      final question = formState.questions[index];

                      // Text question
                      if (question.questionType == 'text') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Answer",
                                    fontSize: 12,
                                    onChanged: (val) => formNotifier.updateAnswer(question.id, val!),
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Number question
                      else if (question.questionType == 'number') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter a number",
                                    fontSize: 12,
                                    inputType: TextInputType.number,
                                    onEditingComplete: () {
                                      if (controller.text != null) {
                                        if (controller.text.isEmpty || RegExp(r'^\d+$').hasMatch(controller.text)) {
                                          formNotifier.updateAnswer(question.id, controller.text);
                                        } else {
                                          // Revert to previous valid value
                                          controller.text = question.answer;
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );
                                          // Show error message
                                          Fluttertoast.showToast(
                                            msg: "Please enter digits only",
                                            toastLength: Toast.LENGTH_SHORT,
                                            gravity: ToastGravity.BOTTOM,
                                            backgroundColor: Colors.red,
                                            textColor: Colors.white,
                                          );
                                        }
                                      }
                                    },
                                    onChanged: (val) {
                                      // Validate: only allow digits
                                      if (val != null) {
                                        if (val.isEmpty || RegExp(r'^\d+$').hasMatch(val)) {
                                          formNotifier.updateAnswer(question.id, val);
                                        } else {
                                          // Revert to previous valid value
                                          controller.text = question.answer;
                                          controller.selection = TextSelection.fromPosition(
                                            TextPosition(offset: controller.text.length),
                                          );
                                          // Show error message
                                          // Fluttertoast.showToast(
                                          //   msg: "Please enter digits only",
                                          //   toastLength: Toast.LENGTH_SHORT,
                                          //   gravity: ToastGravity.BOTTOM,
                                          //   backgroundColor: Colors.red,
                                          //   textColor: Colors.white,
                                          // );
                                        }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Email question
                      else if (question.questionType == 'email') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter your email",
                                    fontSize: 12,
                                    inputType: TextInputType.emailAddress,
                                    onEditingComplete: () {
                                      if (controller.text.isNotEmpty &&
                                          !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(controller.text)) {
                                        // Show warning but don't revert the text
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid email address",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        // Update the answer regardless of validation
                                        formNotifier.updateAnswer(question.id, val);

                                        // Validate email format if not empty
                                        if (val.isNotEmpty &&
                                            !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(val)) {
                                          // Show warning but don't revert the text
                                          // Fluttertoast.showToast(
                                          //   msg: "Please enter a valid email address",
                                          //   toastLength: Toast.LENGTH_SHORT,
                                          //   gravity: ToastGravity.BOTTOM,
                                          //   backgroundColor: Colors.orange,
                                          //   textColor: Colors.white,
                                          // );
                                        }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // Date question
                      else if (question.questionType == 'date') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  InkWell(
                                    onTap: () async {
                                      final DateTime? picked = await showDatePicker(
                                        context: context,
                                        initialDate:
                                            controller.text.isNotEmpty
                                                ? DateTime.parse(controller.text)
                                                : DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime(2100),
                                        builder: (context, child) {
                                          return Theme(
                                            data: Theme.of(context).copyWith(
                                              colorScheme: ColorScheme.light(
                                                primary: DesignColors.accent,
                                                onPrimary: Colors.white,
                                                surface: Colors.white,
                                                onSurface: Color(0xFF262933),
                                              ),
                                              textButtonTheme: TextButtonThemeData(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: DesignColors.accent,
                                                  textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                                ),
                                              ),
                                            ),
                                            child: child!,
                                          );
                                        },
                                      );

                                      if (picked != null) {
                                        // Format date as ISO string for storage
                                        final formattedDate = picked.toIso8601String();
                                        controller.text = formattedDate;
                                        formNotifier.updateAnswer(question.id, formattedDate);
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: DesignColors.border),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            controller.text.isNotEmpty ? _formatDate(controller.text) : "Select a date",
                                            style: TextStyle(
                                              color: controller.text.isNotEmpty ? Colors.black : Colors.grey,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                          Icon(Icons.calendar_today, size: 20, color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // File question
                      else if (question.questionType == 'file') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 8),
                                  Text(
                                    "Accepts PDF, PNG, JPG, MP4 files (Max 50MB)",
                                    style: TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'Poppins'),
                                  ),
                                  Space.h(height: 12),
                                  InkWell(
                                    onTap: () async {
                                      try {
                                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'mp4'],
                                          withData: true, // Required for web
                                        );

                                        if (result != null && result.files.single.bytes != null) {
                                          // Get file data for web
                                          final file = result.files.single;
                                          final bytes = file.bytes!;
                                          final filename = file.name;

                                          // Check file size (50MB = 50 * 1024 * 1024 bytes)
                                          if (bytes.length > 50 * 1024 * 1024) {
                                            Fluttertoast.showToast(
                                              msg: "File size exceeds 50MB limit",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                            return;
                                          }

                                          // Show loading indicator
                                          showDialog(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                backgroundColor: Colors.transparent,
                                                content: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    CircularProgressIndicator(color: DesignColors.accent),
                                                    SizedBox(height: 16),
                                                    Text("Uploading file...", style: TextStyle(color: Colors.white)),
                                                  ],
                                                ),
                                              );
                                            },
                                          );

                                          // Upload file
                                          try {
                                            final uploadBody = {
                                              'userId': await GetStorage().read("userUID") ?? '',
                                              'lobbyId': lobby.id,
                                              'questionId': question.id,
                                            };

                                            final result = await FileUploadService().uploadBytes(
                                              "user/upload/api/v1/file",
                                              bytes,
                                              filename,
                                              uploadBody,
                                            );

                                            // Close loading dialog
                                            Navigator.pop(context);

                                            if (result.statusCode == 200) {
                                              String fileUrl = result.data['imageUrl'];
                                              controller.text = fileUrl;
                                              formNotifier.updateAnswer(question.id, fileUrl);

                                              Fluttertoast.showToast(
                                                msg: "File uploaded successfully",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.green,
                                                textColor: Colors.white,
                                              );
                                            } else {
                                              Fluttertoast.showToast(
                                                msg: "Failed to upload file",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.red,
                                                textColor: Colors.white,
                                              );
                                            }
                                          } catch (e) {
                                            // Close loading dialog
                                            Navigator.pop(context);
                                            Fluttertoast.showToast(
                                              msg: "Error uploading file: $e",
                                              toastLength: Toast.LENGTH_SHORT,
                                              gravity: ToastGravity.BOTTOM,
                                              backgroundColor: Colors.red,
                                              textColor: Colors.white,
                                            );
                                          }
                                        }
                                      } catch (e, s) {
                                        kLogger.error("Error selecting file:", error: e, stackTrace: s);
                                        Fluttertoast.showToast(
                                          msg: "Error selecting file: $e",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: DesignColors.border),
                                        borderRadius: BorderRadius.circular(16),
                                        color: Colors.white,
                                      ),
                                      child:
                                          controller.text.isEmpty
                                              ? Container(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.shade300, width: 1),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.05),
                                                      blurRadius: 5,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(
                                                      Icons.cloud_upload_outlined,
                                                      color: Colors.grey.shade600,
                                                      size: 24,
                                                    ),
                                                    SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        "Upload File",
                                                        style: TextStyle(
                                                          color: Colors.grey.shade700,
                                                          fontSize: 14,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade100,
                                                        borderRadius: BorderRadius.circular(8),
                                                      ),
                                                      child: Icon(Icons.add, color: Colors.grey.shade600, size: 20),
                                                    ),
                                                  ],
                                                ),
                                              )
                                              : Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.topRight,
                                                    children: [
                                                      if (_isImageFile(controller.text))
                                                        ClipRRect(
                                                          borderRadius: BorderRadius.circular(8),
                                                          child: Image.network(
                                                            controller.text,
                                                            height: 120,
                                                            width: double.infinity,
                                                            fit: BoxFit.cover,
                                                            errorBuilder:
                                                                (context, error, stackTrace) =>
                                                                    Icon(Icons.image, size: 50, color: Colors.grey),
                                                          ),
                                                        )
                                                      else if (_isPdfFile(controller.text))
                                                        Icon(Icons.picture_as_pdf, size: 50, color: Colors.red)
                                                      else if (_isVideoFile(controller.text))
                                                        Icon(Icons.video_file, size: 50, color: Colors.blue),
                                                      IconButton(
                                                        style: IconButton.styleFrom(
                                                          backgroundColor: Colors.white,
                                                          minimumSize: Size(32, 32),
                                                          maximumSize: Size(32, 32),
                                                        ),
                                                        icon: Icon(Icons.close, color: Colors.black, size: 16),
                                                        onPressed: () {
                                                          controller.clear();
                                                          formNotifier.updateAnswer(question.id, '');
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    _getFileNameFromUrl(controller.text),
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      // URL question
                      else if (question.questionType == 'url') {
                        final controller = formNotifier.getControllerForQuestion(question.id);

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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
                                      ],
                                    ),
                                  ),
                                  Space.h(height: 12),
                                  DesignTextField(
                                    controller: controller,
                                    hintText: "Enter URL",
                                    fontSize: 12,
                                    inputType: TextInputType.url,
                                    onEditingComplete: () {
                                      kLogger.trace(isValidUrl(controller.text).toString());
                                      // Validate URL format if not empty
                                      if (controller.text.isNotEmpty && !isValidUrl(controller.text)) {
                                        // Show warning but don't revert the text
                                        Fluttertoast.showToast(
                                          msg: "Please enter a valid URL",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.orange,
                                          textColor: Colors.white,
                                        );
                                      }
                                    },
                                    onChanged: (val) {
                                      if (val != null) {
                                        // Update the answer regardless of validation
                                        formNotifier.updateAnswer(question.id, val);

                                        // Validate URL format if not empty
                                        // if (val.isNotEmpty && !_isValidUrl(val)) {
                                        //   // Show warning but don't revert the text
                                        //   Fluttertoast.showToast(
                                        //     msg: "Please enter a valid URL",
                                        //     toastLength: Toast.LENGTH_SHORT,
                                        //     gravity: ToastGravity.BOTTOM,
                                        //     backgroundColor: Colors.orange,
                                        //     textColor: Colors.white,
                                        //   );
                                        // }
                                      }
                                    },
                                    borderRadius: 16,
                                  ),
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
                              padding: EdgeInsets.only(bottom: 18, top: 12, left: 12, right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    maxLines: null,
                                    overflow: TextOverflow.visible,
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF323232),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(text: question.questionText.trim()),
                                        if (question.isMandatory)
                                          TextSpan(text: '   *', style: TextStyle(color: Color(0xFFEC4B5D))),
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
                                          formNotifier.updateAnswer(question.id, option);
                                        }
                                      },
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                                      activeColor: const Color(0xFFEC4B5D),
                                      checkColor: Colors.white,
                                      controlAffinity: ListTileControlAffinity.leading,
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

  // Helper method to format date for display
  String _formatDate(String isoString) {
    try {
      final date = DateTime.parse(isoString);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return isoString; // Return original string if parsing fails
    }
  }

  // Helper method to extract file name from URL
  String _getFileNameFromUrl(String url) {
    try {
      return url.split('/').last;
    } catch (e) {
      return url; // Return original URL if extraction fails
    }
  }

  bool isValidUrl(String url) {
    if (url.isEmpty || url.trim().isEmpty) return false;

    String cleanUrl = url.trim();

    // Basic sanity checks
    if (cleanUrl.length < 3 ||
        cleanUrl.contains(' ') ||
        cleanUrl.contains('\n') ||
        cleanUrl.contains('\t') ||
        cleanUrl.contains('\r')) {
      return false;
    }

    // Remove protocol if present to check the domain part
    String domainPart = cleanUrl;
    bool hasProtocol = false;

    if (cleanUrl.startsWith('http://')) {
      domainPart = cleanUrl.substring(7);
      hasProtocol = true;
    } else if (cleanUrl.startsWith('https://')) {
      domainPart = cleanUrl.substring(8);
      hasProtocol = true;
    }

    // Remove path, query, and fragment to isolate domain
    domainPart = domainPart.split('/')[0].split('?')[0].split('#')[0];

    // Handle port
    String domain = domainPart.split(':')[0];

    // Domain must not be empty after all parsing
    if (domain.isEmpty) return false;

    // Validate the domain structure BEFORE trying Uri.parse
    if (!_isValidDomainStructure(domain)) {
      return false;
    }

    // Now try to parse with https if no protocol
    String urlToParse = hasProtocol ? cleanUrl : 'https://$cleanUrl';

    // Additional attempt with www if needed
    if (!hasProtocol && !cleanUrl.startsWith('www.') && !_isIpAddress(domain)) {
      String urlWithWww = 'https://www.$cleanUrl';
      Uri? uriWithWww = Uri.tryParse(urlWithWww);
      if (uriWithWww != null && _isValidParsedUri(uriWithWww)) {
        return true;
      }
    }

    Uri? uri = Uri.tryParse(urlToParse);
    return uri != null && _isValidParsedUri(uri);
  }

  bool _isValidDomainStructure(String domain) {
    if (domain.isEmpty || domain.length > 253) return false;

    // Handle localhost
    if (domain == 'localhost') return true;

    // Check if it's an IP address
    if (_isIpAddress(domain)) {
      return _isValidIpAddress(domain);
    }

    // For domain names, must contain at least one dot
    if (!domain.contains('.')) return false;

    // Cannot start or end with dot or hyphen
    if (domain.startsWith('.') || domain.endsWith('.') || domain.startsWith('-') || domain.endsWith('-')) {
      return false;
    }

    // Cannot contain consecutive dots
    if (domain.contains('..')) return false;

    // Split into labels and validate each
    final labels = domain.split('.');
    if (labels.length < 2) return false;

    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      if (!_isValidDomainLabel(label, i == labels.length - 1)) {
        return false;
      }
    }

    return true;
  }

  bool _isValidDomainLabel(String label, bool isTLD) {
    if (label.isEmpty || label.length > 63) return false;

    // Cannot start or end with hyphen
    if (label.startsWith('-') || label.endsWith('-')) return false;

    // Must contain only alphanumeric characters and hyphens
    if (!RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(label)) return false;

    // If it's a TLD (last label), additional validation
    if (isTLD) {
      // TLD must be at least 2 characters
      if (label.length < 2) return false;

      // TLD should contain at least one letter
      if (!RegExp(r'[a-zA-Z]').hasMatch(label)) return false;

      // Common valid TLD patterns - reject obvious random strings
      if (!_isValidTLD(label)) return false;
    } else {
      // Non-TLD labels cannot be all hyphens or have weird patterns
      if (RegExp(r'^-+$').hasMatch(label)) return false;
    }

    return true;
  }

  bool _isValidTLD(String tld) {
    // Convert to lowercase for checking
    String lowerTLD = tld.toLowerCase();

    // List of definitely invalid TLDs (random letter combinations)
    final obviouslyInvalid = {
      'aa',
      'bb',
      'cc',
      'dd',
      'ee',
      'ff',
      'gg',
      'hh',
      'ii',
      'jj',
      'kk',
      'll',
      'mm',
      'nn',
      'oo',
      'pp',
      'qq',
      'rr',
      'ss',
      'tt',
      'uu',
      'vv',
      'ww',
      'xx',
      'yy',
      'zz',
      'aaa',
      'bbb',
      'ccc',
      'ddd',
      'eee',
      'fff',
      'ggg',
      'hhh',
      'iii',
      'jjj',
      'kkk',
      'lll',
      'mmm',
      'nnn',
      'ooo',
      'ppp',
      'qqq',
      'rrr',
      'sss',
      'ttt',
      'uuu',
      'vvv',
      'www',
      'xxx',
      'yyy',
      'zzz',
    };

    if (obviouslyInvalid.contains(lowerTLD)) return false;

    // Check for common valid TLD patterns
    // Real TLDs usually have meaningful patterns
    final commonValidTLDs = {
      'com',
      'org',
      'net',
      'gov',
      'edu',
      'mil',
      'int',
      'co',
      'io',
      'ai',
      'me',
      'uk',
      'us',
      'ca',
      'au',
      'de',
      'fr',
      'jp',
      'cn',
      'in',
      'br',
      'mx',
      'ru',
      'info',
      'biz',
      'name',
      'pro',
      'aero',
      'asia',
      'cat',
      'coop',
      'jobs',
      'mobi',
      'museum',
      'post',
      'tel',
      'travel',
      'xxx',
      'app',
      'dev',
      'tech',
      'online',
      'site',
      'website',
      'store',
      'blog',
      'news',
      'today',
      'world',
    };

    // If it's a common valid TLD, accept it
    if (commonValidTLDs.contains(lowerTLD)) return true;

    // For other TLDs, check if they look reasonable
    // Real TLDs typically:
    // 1. Are not random character sequences
    // 2. Have vowels and consonants mixed reasonably
    // 3. Don't have repeating patterns

    // Check for reasonable letter distribution
    if (lowerTLD.length >= 3) {
      // Count vowels
      int vowels = 0;
      for (int i = 0; i < lowerTLD.length; i++) {
        if ('aeiou'.contains(lowerTLD[i])) vowels++;
      }

      // Should have at least one vowel for longer TLDs
      if (vowels == 0 && lowerTLD.length > 3) return false;

      // Check for excessive repetition
      if (RegExp(r'(.)\1{2,}').hasMatch(lowerTLD)) return false;
    }

    // If it passes basic checks and isn't obviously invalid, accept it
    return true;
  }

  bool _isIpAddress(String host) {
    // IPv4 pattern
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      return true;
    }

    // Basic IPv6 pattern (simplified)
    if (host.contains(':') && RegExp(r'^[0-9a-fA-F:]+$').hasMatch(host)) {
      return true;
    }

    return false;
  }

  bool _isValidIpAddress(String host) {
    // IPv4 validation
    final ipv4Pattern = RegExp(r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$');
    final match = ipv4Pattern.firstMatch(host);

    if (match != null) {
      for (int i = 1; i <= 4; i++) {
        final octet = int.tryParse(match.group(i)!);
        if (octet == null || octet < 0 || octet > 255) {
          return false;
        }
      }
      return true;
    }

    // IPv6 basic validation
    if (host.contains(':')) {
      final parts = host.split(':');
      if (parts.length > 8) return false;

      for (final part in parts) {
        if (part.isNotEmpty && (part.length > 4 || !RegExp(r'^[0-9a-fA-F]+$').hasMatch(part))) {
          return false;
        }
      }
      return true;
    }

    return false;
  }

  bool _isValidParsedUri(Uri uri) {
    // Must be http or https
    if (uri.scheme != 'http' && uri.scheme != 'https') return false;

    // Must have a valid host
    if (uri.host.isEmpty) return false;

    // Final validation of the host
    return _isValidDomainStructure(uri.host);
  }

  // Helper functions to check file types
  bool _isImageFile(String url) {
    final ext = url.toLowerCase().split('.').last;
    return ['png', 'jpg', 'jpeg'].contains(ext);
  }

  bool _isPdfFile(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  bool _isVideoFile(String url) {
    return url.toLowerCase().endsWith('.mp4');
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
    this.selectedTickets = const [],
  });

  final List<GroupModel> squads;
  final List<UserFriendsModel> friends;
  // final Lobby lobby;
  final String lobbyId;
  final bool lobbyHasForm;
  final bool lobbyIsPrivate;
  final String requestText;
  final FormModel? formModel;
  final List<SelectedTicket> selectedTickets;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _UserLobbyAccessRequestShare();
}

class _UserLobbyAccessRequestShare extends ConsumerState<UserLobbyAccessRequestShare> {
  final controller = Get.put(ProfileController());
  // final chatController = Get.find<ChatsController>();
  final DashboardController dashboardController = Get.put(DashboardController());

  void _resetState() {
    ref.read(selectedFriendIds.notifier).state = [];
    ref.read(selectedSquadIds.notifier).state = [];
    ref.read(selectedConversationIds.notifier).state = [];
    ref.read(requestedText.notifier).state = '';

    ref.read(requestTextProvider.notifier).state = '';
    ref.invalidate(
      lobbyFormAutofillProvider((
        lobbyId: widget.lobbyId,
        selectedTicketIds: widget.selectedTickets.map((e) => e.ticketId).toList(),
      )),
    );
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
                      children: [CircularProgressIndicator(color: DesignColors.accent)],
                    ),
                  );
                },
              );

              print("Request text value: ${widget.requestText}"); // Log requestText value

              print("friendsIds: ${ref.read(selectedFriendIds)} squadsIds: ${ref.read(selectedSquadIds)}");

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
                      selectedTickets: widget.selectedTickets,
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
                      selectedTickets: widget.selectedTickets,
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

                Fluttertoast.showToast(msg: "Your request has been sent successfully, Please check the chats");

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
                  width: 0.1 * sw,
                  height: 0.12 * sw,
                  color: Colors.red,
                  child: Center(
                    child: DesignText(
                      text: widget.lobbyIsPrivate ? 'Request Access' : 'Join Lobby',
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
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16)),
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
                            child: DesignIcon.icon(icon: Icons.arrow_back_ios_new_rounded),
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
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF323232)),
                          ),
                          unselectedLabelStyle: DesignFonts.poppins.merge(
                            TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: const Color(0xFF989898)),
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
                        //     radius: 24,
                        //     child: (member.profilePictureUrl != "")
                        //         ? Image.network(
                        //       fit: BoxFit.cover,
                        //       member.profilePictureUrl ?? "",
                        //     )
                        //         : Icon(
                        //       Icons.person,
                        //       size: 20,
                        //     ),
                        //   ),
                        //   title: DesignText(
                        //     text: member.name,
                        //     fontSize: 14,
                        //     fontWeight: FontWeight.w500,
                        //   ),
                        //   subtitle: DesignText(
                        //     text: member.userName,
                        //     fontSize: 12,
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
                              separatorBuilder: (context, index) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final member = widget.friends[index];
                                final isSelected = ref.read(selectedFriendIds).contains(member.userId);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        ref.read(selectedFriendIds).remove(member.userId);
                                        ref.read(selectedConversationIds).remove(member.conversationId);
                                      } else {
                                        ref.read(selectedFriendIds).add(member.userId);
                                        ref.read(selectedConversationIds).add(member.conversationId);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 32,
                                              backgroundImage:
                                                  member.profilePictureUrl != null &&
                                                          member.profilePictureUrl!.isNotEmpty
                                                      ? NetworkImage(
                                                        member.profilePictureUrl ??
                                                            "https://w7.pngwing.com/pngs/205/731/png-transparent-default-avatar-thumbnail.png",
                                                      )
                                                      : null,
                                              child:
                                                  member.profilePictureUrl != null &&
                                                          member.profilePictureUrl!.isNotEmpty
                                                      ? null
                                                      : DesignIcon.icon(icon: Icons.person_rounded, size: 32),
                                            ),
                                            const Space.w(width: 11),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  DesignText(
                                                    text: member.name,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  DesignText(
                                                    text: member.userName,
                                                    fontSize: 14,
                                                    color: DesignColors.secondary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero, // Remove padding to align icon properly
                                        onPressed: () {
                                          setState(() {
                                            if (isSelected) {
                                              ref.read(selectedFriendIds).remove(member.userId);
                                              ref.read(selectedConversationIds).remove(member.conversationId);
                                            } else {
                                              ref.read(selectedFriendIds).add(member.userId);
                                              ref.read(selectedConversationIds).add(member.conversationId);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                                          color: isSelected ? DesignColors.accent : CupertinoColors.inactiveGray,
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
                              separatorBuilder: (context, index) => SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final squad = widget.squads[index];
                                final isSelected = ref.read(selectedSquadIds).contains(squad.groupId);
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      if (isSelected) {
                                        ref.read(selectedSquadIds).remove(squad.groupId);
                                        ref.read(selectedConversationIds).remove(squad.groupId);
                                      } else {
                                        ref.read(selectedSquadIds).add(squad.groupId);
                                        ref.read(selectedConversationIds).add(squad.groupId);
                                      }
                                    });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 32,
                                              backgroundImage:
                                                  squad.profilePicture != null && squad.profilePicture!.isNotEmpty
                                                      ? NetworkImage(
                                                        squad.profilePicture ??
                                                            "https://w7.pngwing.com/pngs/205/731/png-transparent-default-avatar-thumbnail.png",
                                                      )
                                                      : null,
                                              child:
                                                  squad.profilePicture != null && squad.profilePicture!.isNotEmpty
                                                      ? null
                                                      : DesignIcon.icon(icon: Icons.groups_rounded, size: 32),
                                            ),
                                            const Space.w(width: 11),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  DesignText(
                                                    text: squad.groupName,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  DesignText(
                                                    text: "${squad.participants.length} member",
                                                    fontSize: 14,
                                                    color: DesignColors.secondary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      CupertinoButton(
                                        padding: EdgeInsets.zero, // Remove padding to align icon properly
                                        onPressed: () {
                                          setState(() {
                                            if (isSelected) {
                                              ref.read(selectedSquadIds).remove(squad.groupId);
                                              ref.read(selectedConversationIds).remove(squad.groupId);
                                            } else {
                                              ref.read(selectedSquadIds).add(squad.groupId);
                                              ref.read(selectedConversationIds).add(squad.groupId);
                                            }
                                          });
                                        },
                                        child: Icon(
                                          isSelected ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
                                          color: isSelected ? DesignColors.accent : CupertinoColors.inactiveGray,
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

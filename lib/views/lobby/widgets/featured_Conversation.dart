import 'package:aroundu/designs/widgets/button.widget.designs.dart';
import 'package:aroundu/designs/widgets/icon.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/models/detailed.lobby.model.dart';
import 'package:aroundu/views/lobby/provider/featured_conversation_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../designs/colors.designs.dart';
import '../../../designs/icons.designs.dart';
import '../../../designs/widgets/space.widget.designs.dart';
import '../../../models/lobby.dart';
import '../../profile/public_profile/public.profile.model.dart';

class FeaturedConversation extends ConsumerStatefulWidget {
  const FeaturedConversation({
    super.key,
    required this.lobby,
    required this.lobbyDetail,
  });
  final Lobby lobby;
  final LobbyDetails lobbyDetail;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeaturedConversationState();
}

class _FeaturedConversationState extends ConsumerState<FeaturedConversation> {
  final TextEditingController _featuredConversationQuestionController =
      TextEditingController();

  void _handleQuestionSend(String text) async {
    if (text.isNotEmpty) {
      final success = await ref.read(
        askQuestionProvider(widget.lobbyDetail.lobby.id, text).future,
      );
      if (success) {
        Fluttertoast.showToast(msg: "Question submitted");
        _featuredConversationQuestionController.clear();
      } else {
        Fluttertoast.showToast(msg: "Something went please wrong try again");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lobbyDetail = widget.lobbyDetail;
    final featuredConversations = ref.watch(
      getFeaturedConversationsProvider(lobbyDetail.lobby.id),
    );
    final allQuestions = ref.watch(
      getAllQuestionsProvider(lobbyDetail.lobby.id),
    );
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Column(
      children: [
        Row(
          children: [
            DesignText(
              text: "Featured Questions",
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const Spacer(),
            InkWell(
              // onTap: () {
              //   Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (_) => MarkdownEditorPage(
              //         lobbyId: lobbyDetail.lobby.id,
              //         initialTitle: lobbyDetail.lobby.content?.title ?? '',
              //         initialBody: lobbyDetail.lobby.content?.body ?? '',
              //         isHost: true, // set false for viewers
              //       ),
              //     ),
              //   );
              // },
              onTap:
                  () => Get.to(
                    () =>
                        DetailedViewOfFeaturedConversation(lobby: widget.lobby),
                  ),
              child: DesignText(
                text: "View all",
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF3E79A1),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        lobbyDetail.lobby.userStatus == "ADMIN"
            ? allQuestions.when(
              data: (questions) {
                if (questions.isNotEmpty) {
                  // Render conversations if successfully fetched
                  final topConversations = questions.take(3).toList();
                  return Column(
                    children: [
                      if (widget.lobbyDetail.lobby.userStatus == "VISITOR")
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.grey[100],
                                constraints: BoxConstraints(minHeight: sh(0.2)),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: DesignText(
                                                text:
                                                    "Ask your queries to admin",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              controller:
                                                  _featuredConversationQuestionController,
                                              onSubmitted: (value) {
                                                _handleQuestionSend(value);
                                                Get.back();
                                              },
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                hintText: 'ask a question',
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ), // Hint text color
                                                filled: true,
                                                fillColor:
                                                    Colors
                                                        .grey[200], // Light gray background color
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ), // Optional: rounded corners
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when enabled
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when focused
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons
                                                        .solidPaperPlane,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _handleQuestionSend(
                                                      _featuredConversationQuestionController
                                                          .text,
                                                    );
                                                    Get.back();
                                                  }, // Trigger function when icon is pressed
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ), // Text color inside the field
                                            ),
                                            SizedBox(height: 32),
                                            SizedBox(
                                              width: sw(1),
                                              child: DesignButton(
                                                onPress: () {
                                                  print(
                                                    _featuredConversationQuestionController
                                                        .text,
                                                  );
                                                  _handleQuestionSend(
                                                    _featuredConversationQuestionController
                                                        .text,
                                                  );
                                                  Get.back();
                                                },
                                                title: "send",
                                                titleSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFEC4B5D),
                                  child: DesignText(
                                    text: 'A',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .w700, // Add the required fontSize argument
                                  ),
                                ),
                                SizedBox(width: 14),
                                DesignText(
                                  text: "Ask Question",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEC4B5D),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      ...List.generate(topConversations.length, (index) {
                        return CommentCard(
                          question: topConversations[index],
                          lobby: widget.lobby,
                        );
                      }),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.lobbyDetail.lobby.userStatus == "VISITOR")
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.grey[100],
                                constraints: BoxConstraints(minHeight:sh(0.2)),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: DesignText(
                                                text:
                                                    "Ask your queries to admin",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              controller:
                                                  _featuredConversationQuestionController,
                                              onSubmitted: (value) {
                                                _handleQuestionSend(value);
                                                Get.back();
                                              },
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                hintText: 'ask a question',
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ), // Hint text color
                                                filled: true,
                                                fillColor:
                                                    Colors
                                                        .grey[200], // Light gray background color
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ), // Optional: rounded corners
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when enabled
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when focused
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons
                                                        .solidPaperPlane,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _handleQuestionSend(
                                                      _featuredConversationQuestionController
                                                          .text,
                                                    );
                                                    Get.back();
                                                  }, // Trigger function when icon is pressed
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ), // Text color inside the field
                                            ),
                                            SizedBox(height: 32),
                                            SizedBox(
                                              width: sw(1),
                                              child: DesignButton(
                                                onPress: () {
                                                  _handleQuestionSend(
                                                    _featuredConversationQuestionController
                                                        .text,
                                                  );
                                                  Get.back();
                                                },
                                                title: "send",
                                                titleSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFEC4B5D),
                                  child: DesignText(
                                    text: 'A',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .w700, // Add the required fontSize argument
                                  ),
                                ),
                                SizedBox(width: 14),
                                DesignText(
                                  text: "Ask Question",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEC4B5D),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      DesignIcon.custom(
                        icon: DesignIcons.question,
                        size: 16,
                        color: const Color(0xFF989898),
                      ),
                      SizedBox(height: 2),
                      DesignText(
                        text: "No questions available",
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF444444),
                      ),
                    ],
                  );
                }
              },
              error: (error, stack) => Text('Error: $error \n $stack'),
              loading:
                  () => const CircularProgressIndicator(
                    color: DesignColors.accent,
                  ),
            )
            : featuredConversations.when(
              data: (questions) {
                if (questions.isNotEmpty) {
                  // Render conversations if successfully fetched
                  final topConversations = questions.take(3).toList();
                  return Column(
                    children: [
                      if (widget.lobbyDetail.lobby.userStatus == "VISITOR")
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.grey[100],
                                constraints: BoxConstraints(minHeight: sh(0.2)),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: DesignText(
                                                text:
                                                    "Ask your queries to admin",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              controller:
                                                  _featuredConversationQuestionController,
                                              onSubmitted: (value) {
                                                _handleQuestionSend(value);
                                                Get.back();
                                              },
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                hintText: 'ask a question',
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ), // Hint text color
                                                filled: true,
                                                fillColor:
                                                    Colors
                                                        .grey[200], // Light gray background color
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ), // Optional: rounded corners
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when enabled
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when focused
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons
                                                        .solidPaperPlane,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _handleQuestionSend(
                                                      _featuredConversationQuestionController
                                                          .text,
                                                    );
                                                    Get.back();
                                                  }, // Trigger function when icon is pressed
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ), // Text color inside the field
                                            ),
                                            SizedBox(height: 32),
                                            SizedBox(
                                              width: sw(1),
                                              child: DesignButton(
                                                onPress: () {
                                                  print(
                                                    _featuredConversationQuestionController
                                                        .text,
                                                  );
                                                  _handleQuestionSend(
                                                    _featuredConversationQuestionController
                                                        .text,
                                                  );
                                                  Get.back();
                                                },
                                                title: "send",
                                                titleSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFEC4B5D),
                                  child: DesignText(
                                    text: 'A',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .w700, // Add the required fontSize argument
                                  ),
                                ),
                                SizedBox(width: 14),
                                DesignText(
                                  text: "Ask Question",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEC4B5D),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      ...List.generate(topConversations.length, (index) {
                        return CommentCard(
                          question: topConversations[index],
                          lobby: widget.lobby,
                        );
                      }),
                    ],
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.lobbyDetail.lobby.userStatus == "VISITOR")
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.grey[100],
                                constraints: BoxConstraints(minHeight: sh(0.2)),
                                builder: (context) {
                                  return Padding(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 24,
                                          horizontal: 16,
                                        ),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: DesignText(
                                                text:
                                                    "Ask your queries to admin",
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            TextField(
                                              controller:
                                                  _featuredConversationQuestionController,
                                              onSubmitted: (value) {
                                                _handleQuestionSend(value);
                                                Get.back();
                                              },
                                              textInputAction:
                                                  TextInputAction.done,
                                              decoration: InputDecoration(
                                                hintText: 'ask a question',
                                                hintStyle: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ), // Hint text color
                                                filled: true,
                                                fillColor:
                                                    Colors
                                                        .grey[200], // Light gray background color
                                                border: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ), // Optional: rounded corners
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when enabled
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                    color: Colors.grey,
                                                  ), // Border color when focused
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        8.0,
                                                      ),
                                                ),
                                                suffixIcon: IconButton(
                                                  icon: const Icon(
                                                    FontAwesomeIcons
                                                        .solidPaperPlane,
                                                    color: Colors.grey,
                                                    size: 18,
                                                  ),
                                                  onPressed: () {
                                                    _handleQuestionSend(
                                                      _featuredConversationQuestionController
                                                          .text,
                                                    );
                                                    Get.back();
                                                  }, // Trigger function when icon is pressed
                                                ),
                                              ),
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ), // Text color inside the field
                                            ),
                                            SizedBox(height: 32),
                                            SizedBox(
                                              width: sw(1),
                                              child: DesignButton(
                                                onPress: () {
                                                  _handleQuestionSend(
                                                    _featuredConversationQuestionController
                                                        .text,
                                                  );
                                                  Get.back();
                                                },
                                                title: "send",
                                                titleSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: const Color(0xFFEC4B5D),
                                  child: DesignText(
                                    text: 'A',
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .w700, // Add the required fontSize argument
                                  ),
                                ),
                                SizedBox(width: 14),
                                DesignText(
                                  text: "Ask Question",
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFEC4B5D),
                                ),
                              ],
                            ),
                          ),
                        ),
                      SizedBox(height: 24),
                      DesignIcon.custom(
                        icon: DesignIcons.question,
                        size: 16,
                        color: const Color(0xFF989898),
                      ),
                      SizedBox(height: 2),
                      DesignText(
                        text: "No questions available",
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF444444),
                      ),
                    ],
                  );
                }
              },
              error: (error, stack) => Text('Error: $error \n $stack'),
              loading:
                  () => const CircularProgressIndicator(
                    color: DesignColors.accent,
                  ),
            ),
      ],
    );
  }
}

class DetailedViewOfFeaturedConversation extends ConsumerStatefulWidget {
  const DetailedViewOfFeaturedConversation({super.key, required this.lobby});
  final Lobby lobby;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DetailedViewOfFeaturedConversationState();
}

class _DetailedViewOfFeaturedConversationState
    extends ConsumerState<DetailedViewOfFeaturedConversation> {
  _DetailedViewOfFeaturedConversationState();

  @override
  Widget build(BuildContext context) {
    final featuredConversations = ref.watch(
      getFeaturedConversationsProvider(widget.lobby.id),
    );
    final allQuestions = ref.watch(getAllQuestionsProvider(widget.lobby.id));
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: DesignIcon.icon(
            icon: Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: const Color(0xFF444444),
          ),
        ),
        title: DesignText(
          text: 'Featured Questions',
          color: const Color(0xFF444444),
          fontWeight: FontWeight.w600,
          fontSize: 18, // Add the required fontSize argument
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child:
            widget.lobby.userStatus == "ADMIN"
                ? allQuestions.when(
                  data: (questions) {
                    if (questions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DesignIcon.custom(
                              icon: DesignIcons.question,
                              size: 22,
                              color: const Color(0xFF989898),
                            ),
                            SizedBox(height: 2),
                            DesignText(
                              text: "No questions available",
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF444444),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: questions.length,
                      // separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final question = questions[index];

                        return CommentCard(
                          question: question,
                          lobby: widget.lobby,
                        );
                      },
                    );
                  },
                  loading:
                      () => const CircularProgressIndicator(
                        color: DesignColors.accent,
                      ),
                  error: (error, stack) => Text('Error: $error \n $stack'),
                )
                : featuredConversations.when(
                  data: (questions) {
                    if (questions.isNotEmpty) {
                      if (questions.isEmpty) {
                        return const Text('No questions available');
                      }

                      return ListView.builder(
                        itemCount: questions.length,
                        // separatorBuilder: (context, index) =>
                        //     const Divider(color: Color(0xFF444444)),
                        itemBuilder: (context, index) {
                          final question = questions[index];

                          return CommentCard(
                            question: question,
                            lobby: widget.lobby,
                          );
                        },
                      );
                    } else {
                      // Handle if failed to fetch conversations
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DesignIcon.custom(
                              icon: DesignIcons.question,
                              size: 22,
                              color: const Color(0xFF989898),
                            ),
                            SizedBox(height: 2),
                            DesignText(
                              text: "No questions available",
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: const Color(0xFF444444),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  loading:
                      () => const CircularProgressIndicator(
                        color: DesignColors.accent,
                      ),
                  error: (error, stack) => Text('Error: $error \n $stack'),
                ),
      ),
    );
  }
}

class CommentCard extends ConsumerWidget {
  CommentCard({super.key, required this.question, required this.lobby});

  final ConversationQuestion question;
  final Lobby lobby;
  final TextEditingController _featuredConversationAnswerController =
      TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void handleAnswerSend(String questionId) async {
      String enteredText = _featuredConversationAnswerController.text;
      if (enteredText.isNotEmpty) {
        final success = await ref.read(
          answerQuestionProvider(lobby.id, questionId, enteredText).future,
        );
        if (success) {
          Fluttertoast.showToast(msg: "Answer submitted");
          _featuredConversationAnswerController.clear();
        } else {
          Fluttertoast.showToast(msg: "Something went please wrong try again");
        }
      }
    }
double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.red,
                child: DesignText(
                  text: question.questionBy?.name[0].toUpperCase() ?? 'A',
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.w700, // Add the required fontSize argument
                ),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        DesignText(
                          text: question.questionBy?.name ?? 'Anonymous',
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: const Color(0xFF323232),
                        ),
                        SizedBox(width: 6),
                        DesignText(
                          text: DateFormat(
                            'MMM d, y',
                          ).format(question.createdAt),
                          fontSize: 8,
                          color: const Color(0xFF444444),
                          fontWeight: FontWeight.w300,
                        ),
                        const Spacer(),
                        const Icon(Icons.more_horiz, color: Color(0xFF444444)),
                      ],
                    ),
                    SizedBox(height: 2),
                    DesignText(
                      text: question.questionText,
                      maxLines: 10,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: const Color(0xFF444444),
                    ),
                    SizedBox(height: 8),
                    if (lobby.userStatus == "ADMIN")
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.grey[100],
                            constraints: BoxConstraints(minHeight: sh(0.2)),
                            builder: (context) {
                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.of(context).viewInsets.bottom,
                                ),
                                child: SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 24,
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: DesignText(
                                            text: question.questionText,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        SizedBox(height: 12),
                                        TextField(
                                          controller:
                                              _featuredConversationAnswerController,
                                          textInputAction: TextInputAction.done,
                                          decoration: InputDecoration(
                                            hintText: 'answer here...',
                                            hintStyle: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ), // Hint text color
                                            filled: true,
                                            fillColor: Colors.white,
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                              ), // Border color
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    8.0,
                                                  ), // Optional: rounded corners
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                              ), // Border color when enabled
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                color: Colors.grey,
                                              ), // Border color when focused
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                          ),
                                          style: const TextStyle(
                                            color: Colors.black,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ), // Text color inside the field
                                        ),
                                        SizedBox(height: 32),
                                        SizedBox(
                                          width: sw(1),
                                          child: DesignButton(
                                            onPress: () {
                                              handleAnswerSend(
                                                question.questionId,
                                              );
                                              Navigator.pop(context);
                                              ref.refresh(
                                                getAllQuestionsProvider(
                                                  lobby.id,
                                                ),
                                              );
                                            },
                                            title: "save",
                                            titleSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }, // Add reply action here
                        child: DesignText(
                          text: 'Reply',
                          color: const Color(0xFF3E79A1),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    SizedBox(height: 16),
                    // Reply Section
                    if (question.answered)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue,
                            child: Image.network(
                              question.answeredBy?.profilePictureUrl ?? "",
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                BuildContext context,
                                Widget child,
                                ImageChunkEvent? loadingProgress,
                              ) {
                                if (loadingProgress == null) {
                                  return child; // The image is fully loaded.
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return DesignText(
                                  text:
                                      question.answeredBy?.name[0]
                                          .toUpperCase() ??
                                      'A',
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight
                                          .w700, // Add the required fontSize argument
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                DesignText(
                                  text:
                                      question.answeredBy?.name ?? 'Anonymous',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: const Color(0xFF444444),
                                ),
                                SizedBox(height: 2),
                                DesignText(
                                  text: question.answerText ?? "",
                                  maxLines: 10,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w300,
                                  color: const Color(0xFF444444),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}

// class DetailedViewOfFeaturedConversationState
//     extends ConsumerState<DetailedViewOfFeaturedConversation> {
//   final TextEditingController _featuredConversationController =
//       TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     final featuredConversations =
//         ref.watch(getFeaturedConversationsProvider(widget.lobby.id));
//     final allQuestions = ref.watch(getAllQuestionsProvider(widget.lobby.id));
//
//     void handleSend(String questionId) async {
//       String enteredText = _featuredConversationController.text;
//       if (enteredText.isNotEmpty) {
//         final success = await ref.read(
//             answerQuestionProvider(widget.lobby.id, questionId, enteredText)
//                 .future);
//         if (success) {
//           Fluttertoast.showToast(msg: "Answer submitted");
//           _featuredConversationController.clear();
//         } else {
//           Fluttertoast.showToast(msg: "Something went please wrong try again");
//         }
//       }
//     }
//
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         scrolledUnderElevation: 0,
//       ),
//       body: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         child: widget.lobby.userStatus == "ADMIN"
//             ? allQuestions.when(
//                 data: (questions) {
//                   if (questions.isEmpty) {
//                     return const Text('No questions available');
//                   }
//
//                   return ListView.separated(
//                     itemCount: questions.length,
//                     separatorBuilder: (context, index) => const Divider(),
//                     itemBuilder: (context, index) {
//                       final question = questions[index];
//
//                       return InkWell(
//                         onTap: () {
//                           showModalBottomSheet(
//                               context: context,
//                               backgroundColor: DesignColors.white,
//                               constraints: BoxConstraints(minHeight: 0.2.sh),
//                               builder: (context) {
//                                 return Padding(
//                                   padding: EdgeInsets.only(
//                                       bottom: MediaQuery.of(context)
//                                           .viewInsets
//                                           .bottom),
//                                   child: SingleChildScrollView(
//                                     child: Padding(
//                                       padding: EdgeInsets.symmetric(
//                                           vertical: 24, horizontal: 16),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         children: [
//                                           Align(
//                                             alignment: Alignment.centerLeft,
//                                             child: DesignText(
//                                               text:
//                                                   "${index + 1}. ${question.questionText}",
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                             ),
//                                           ),
//                                           SizedBox(height: 12),
//                                           TextField(
//                                             controller:
//                                                 _featuredConversationController,
//                                             textInputAction:
//                                                 TextInputAction.done,
//                                             decoration: InputDecoration(
//                                               hintText: 'answer here...',
//                                               hintStyle: const TextStyle(
//                                                 color: Colors.grey,
//                                                 fontSize: 14,
//                                                 fontWeight: FontWeight.w500,
//                                               ), // Hint text color
//                                               filled: true,
//                                               fillColor: Colors.white,
//                                               border: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Colors
//                                                         .grey), // Border color
//                                                 borderRadius: BorderRadius.circular(
//                                                     8.0), // Optional: rounded corners
//                                               ),
//                                               enabledBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Colors
//                                                         .grey), // Border color when enabled
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.0),
//                                               ),
//                                               focusedBorder: OutlineInputBorder(
//                                                 borderSide: const BorderSide(
//                                                     color: Colors
//                                                         .grey), // Border color when focused
//                                                 borderRadius:
//                                                     BorderRadius.circular(8.0),
//                                               ),
//                                             ),
//                                             style: const TextStyle(
//                                               color: Colors.black,
//                                               fontSize: 14,
//                                               fontWeight: FontWeight.w500,
//                                             ), // Text color inside the field
//                                           ),
//                                           SizedBox(height: 32),
//                                           SizedBox(
//                                             width: 1.sw,
//                                             child: DesignButton(
//                                               onPress: () {
//                                                 handleSend(question.questionId);
//                                                 Navigator.pop(context);
//                                                 ref.refresh(
//                                                     getAllQuestionsProvider(
//                                                         widget.lobby.id));
//                                               },
//                                               title: "save",
//                                               titleSize: 14,
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               });
//                         },
//                         child: Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               DesignText(
//                                 text: "${index + 1}. ${question.questionText}",
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               DesignText(
//                                 text: question.answered
//                                     ? "${question.answerText}"
//                                     : "Not answered yet",
//                                 fontSize: 12,
//                                 color: question.answered
//                                     ? Colors.black
//                                     : DesignColors.accent,
//                               ),
//                               SizedBox(height: 8),
//                             ],
//                           ),
//                         ),
//                       );
//                     },
//                   );
//                 },
//                 loading: () => const CircularProgressIndicator(),
//                 error: (error, stack) => Text('Error: $error'),
//               )
//             : featuredConversations.when(
//                 data: (questions) {
//                   if (questions.isNotEmpty) {
//                     if (questions.isEmpty) {
//                       return const Text('No questions available');
//                     }
//
//                     return ListView.separated(
//                       itemCount: questions.length,
//                       separatorBuilder: (context, index) => const Divider(),
//                       itemBuilder: (context, index) {
//                         final question = questions[index];
//
//                         return Container(
//                           width: double.infinity,
//                           padding: EdgeInsets.symmetric(horizontal: 8),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               DesignText(
//                                 text: "${index + 1}. ${question.questionText}",
//                                 fontSize: 12,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                               DesignText(
//                                 text: "${question.answerText}",
//                                 fontSize: 12,
//                                 color: question.answered
//                                     ? Colors.black
//                                     : DesignColors.accent,
//                               ),
//                               SizedBox(height: 8),
//                             ],
//                           ),
//                         );
//                       },
//                     );
//                   } else {
//                     // Handle if failed to fetch conversations
//                     return Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         DesignIcon.custom(
//                           icon: DesignIcons.question,
//                           size: 16,
//                           color: const Color(0xFF989898),
//                         ),
//                         SizedBox(height: 2),
//                         DesignText(
//                           text: "No questions available",
//                           fontSize: 12,
//                           fontWeight: FontWeight.w300,
//                           color: const Color(0xFF444444),
//                         )
//                       ],
//                     );
//                   }
//                 },
//                 loading: () => const CircularProgressIndicator(),
//                 error: (error, stack) => Text('Error: $error'),
//               ),
//       ),
//     );
//   }
// }

import 'package:aroundu/constants/colors_palette.dart';
import 'package:aroundu/designs/widgets/chip.widgets.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/designs/widgets/textfield.widget.designs.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/lobby_access_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../designs/colors.designs.dart';
import '../../designs/widgets/button.widget.designs.dart';
import '../../designs/widgets/space.widget.designs.dart';

import 'package:aroundu/models/lobby.dart';

class PreviewFormScreen extends StatelessWidget {
  final FormModel form;

  const PreviewFormScreen({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: DesignText(
          text: 'Preview',
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        scrolledUnderElevation: 0,
        backgroundColor: DesignColors.bg,
      ),
      body: Column(
        children: [
          DesignText(
            text: form.title,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
          Expanded(
            child: ListView.builder(
              itemCount: form.questions.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                final question = form.questions[index];
                if (question.questionType == 'text') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            DesignText(
                              text: question.questionText,
                              fontSize: 16,
                            ),
                            if (question.isMandatory)
                              DesignText(
                                text: ' *',
                                fontSize: 16,
                                color: Colors.red,
                              ),
                          ],
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText:
                                question.answer.isNotEmpty
                                    ? question.answer
                                    : "",
                          ),
                          enabled: false, // Make text field read-only
                        ),
                      ],
                    ),
                  );
                } else if (question.questionType == 'multiple-choice') {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: DesignText(
                          text: question.questionText,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        children:
                            question.options.map((option) {
                              return RadioListTile(
                                title: Text(option),
                                value: option,
                                groupValue: question.answer,
                                onChanged: null, // Disable selection
                              );
                            }).toList(),
                      ),
                    ],
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Question2 {
  final String id;
  final String questionText;
  final String questionType;
  final List<String> options;
  final String answer;
  final bool isMandatory;
  final String questionLabel;
  final String dataKey;

  Question2({
    required this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.answer,
    required this.isMandatory,
    required this.questionLabel,
    required this.dataKey,
  });

  factory Question2.fromJson(Map<String, dynamic> json) {
    return Question2(
      id: json['id'],
      questionText: json['questionText'],
      questionType: json['questionType'],
      options: List<String>.from(json['options']),
      answer: json['answer'] ?? '',
      isMandatory: json['isMandatory'],
      questionLabel: json['questionLabel'],
      dataKey: json['dataKey'],
    );
  }
}

class FormModel2 {
  final String title;
  final List<Question2> questions;

  FormModel2({required this.title, required this.questions});

  factory FormModel2.fromJson(Map<String, dynamic> json) {
    return FormModel2(
      title: json['title'],
      questions:
          (json['questions'] as List)
              .map((question) => Question2.fromJson(question))
              .toList(),
    );
  }
}

final lobbyFormAutofillProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, lobbyId) async {
      try {
        final response = await ApiService().get(
          "match/lobby/$lobbyId/form/autofill",
        );

        if (response.data is String) {
          return {"userId": null, "title": "", "questions": []};
        } else {
          return response.data as Map<String, dynamic> ?? {};
        }

        // Assuming the response.data is already a Map<String, dynamic>
      } catch (e, stack) {
        kLogger.trace("Failed to load autofill data: $e \n $stack");
        throw "Failed to load autofill data: $e";
      }
    });

// Define providers for managing form state
final formStateProvider =
    StateNotifierProvider.family<FormStateNotifier, FormModel, String>(
      (ref, lobbyId) => FormStateNotifier(lobbyId: lobbyId, ref: ref),
    );

// Form state notifier to manage the form data
class FormStateNotifier extends StateNotifier<FormModel> {
  final String lobbyId;
  final Ref ref;
  final Map<String, TextEditingController> textControllers = {};

  FormStateNotifier({required this.lobbyId, required this.ref})
    : super(FormModel(title: 'Loading...', questions: [])) {
    _loadFormData();
  }

  Future<void> _loadFormData() async {
    try {
      final autofillData = await ref.read(
        lobbyFormAutofillProvider(lobbyId).future,
      );
      final List<Question> questions = [];

      if (autofillData.containsKey('questions') &&
          autofillData['questions'] is List) {
        final formQuestions = autofillData['questions'] as List;

        for (var questionData in formQuestions) {
          // Create Question object using your existing model
          final question = Question.fromJson(questionData);
          questions.add(question);

          // Create and initialize text controllers with existing answers
          if (question.questionType == 'text') {
            textControllers[question.id] = TextEditingController(
              text: question.answer,
            );
          }
        }
      }

      state = FormModel(
        title: autofillData['title'] ?? 'Form',
        questions: questions,
      );
    } catch (e, stack) {
      kLogger.trace("Error loading form data: $e \n $stack");
      state = FormModel(title: 'Error Loading Form', questions: []);
    }
  }

  void updateAnswer(String questionId, String newAnswer) {
    final updatedQuestions =
        state.questions.map((question) {
          if (question.id == questionId) {
            return question.copyWith(answer: newAnswer);
          }
          return question;
        }).toList();

    state = state.copyWith(questions: updatedQuestions);
  }

  TextEditingController? getControllerForQuestion(String questionId) {
    return textControllers[questionId];
  }

  List<Question> getQuestionsWithAnswers() {
    return state.questions;
  }

  bool validateForm() {
    return !state.questions.any(
      (question) => question.isMandatory && question.answer.isEmpty,
    );
  }

  String? getMandatoryQuestionWithoutAnswer() {
    for (final question in state.questions) {
      if (question.isMandatory && question.answer.isEmpty) {
        return question.questionText;
      }
    }
    return null;
  }

  Future<void> reloadFormData() async {
    state = FormModel(title: '', questions: []);
    await ref.refresh(lobbyFormAutofillProvider(lobbyId).future).then((data) {
      print("autofill refreshed");
    });
    _loadFormData();
  }

  void resetForm() {
    // Clear all answers
    final clearedQuestions =
        state.questions.map((question) {
          return question.copyWith(answer: '');
        }).toList();

    // Update state
    state = state.copyWith(questions: clearedQuestions);

    // Clear all text controllers
    textControllers.forEach((id, controller) {
      controller.clear();
    });
  }

  @override
  void dispose() {
    // Dispose all text controllers
    for (var controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}

final requestTextProvider = StateProvider<String>((ref) => '');

class AnswerFormScreen extends ConsumerWidget {
  final Lobby lobby;
  final String groupId;

  const AnswerFormScreen({
    super.key,
    required this.lobby,
    required this.groupId,
  });

  void _submitResponses(BuildContext context, WidgetRef ref) async {
    final formNotifier = ref.read(formStateProvider(lobby.id).notifier);
    final requestText = ref.read(requestTextProvider);

    // Check if the message is empty
    if (requestText.isEmpty) {
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

      // Submit the form
      await ref.read(
        handleLobbyAccessProvider(
          lobby.id,
          lobby.isPrivate,
          friends: [],
          groupId: [groupId],
          text: requestText,
          form: formModel.toJson(),
          hasForm: true,
        ).future,
      );

      // Close the bottom sheet after successful submission
      Navigator.pop(context);
    } catch (e) {
      // Handle submission errors
      Get.snackbar(
        "Error",
        "Failed to submit form: ${e.toString()}",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(formStateProvider(lobby.id));
    final formNotifier = ref.watch(formStateProvider(lobby.id).notifier);
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double sw(double size) => screenWidth * size;

    double sh(double size) => screenHeight * size;
    return Column(
      children: [
        // Request message section
        Align(
          alignment: Alignment.centerLeft,
          child: DesignText(
            text: "Send the Admin a message with your request",
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: DesignColors.secondary,
          ),
        ),
        const Space.h(height: 8),

        // Request text field
        TextField(
          onChanged: (value) {
            ref.read(requestTextProvider.notifier).state = value;
          },
          maxLines: 5,
          decoration: const InputDecoration(
            alignLabelWithHint: true,
            labelText: 'Enter Request Message',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
          ),
        ),
        const Space.h(height: 16),

        // Form title
        Align(
          alignment: Alignment.centerLeft,
          child: DesignText(
            text: formState.title,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),

        // Form questions
        SizedBox(
          height: sh(0.4),
          child:
              formState.questions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                    shrinkWrap: true,
                    itemCount: formState.questions.length,
                    itemBuilder: (context, index) {
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DesignText(
                                      text: question.questionText,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (question.isMandatory)
                                    DesignText(
                                      text: ' *',
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: controller,
                                decoration: const InputDecoration(
                                  labelText: "Answer",
                                  border: OutlineInputBorder(),
                                ),
                                onChanged:
                                    (val) => formNotifier.updateAnswer(
                                      question.id,
                                      val,
                                    ),
                              ),
                            ],
                          ),
                        );
                      }
                      // Multiple choice question
                      else if (question.questionType == 'multiple-choice') {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DesignText(
                                      text: question.questionText,
                                      fontSize: 14,
                                    ),
                                  ),
                                  if (question.isMandatory)
                                    DesignText(
                                      text: ' *',
                                      fontSize: 14,
                                      color: Colors.red,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ...question.options.map((option) {
                                return RadioListTile<String>(
                                  title: Text(option),
                                  value: option,
                                  groupValue: question.answer,
                                  onChanged: (val) {
                                    if (val != null) {
                                      formNotifier.updateAnswer(
                                        question.id,
                                        val,
                                      );
                                    }
                                  },
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 0,
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        );
                      }

                      // Default fallback for unsupported question types
                      return Container();
                    },
                  ),
        ),

        // Submit button
        const Space.h(height: 16),
        DesignButton(
          onPress: () => _submitResponses(context, ref),
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          title: 'Request Access',
          titleSize: 12,
        ),
      ],
    );
  }
}

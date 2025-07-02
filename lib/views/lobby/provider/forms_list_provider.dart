
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/lobby.dart';
/// Provider that manages a list of forms
final formsListProvider =
    StateNotifierProvider<FormsListNotifier, List<FormModel>>(
  (ref) => FormsListNotifier(),
);

/// Notifier class for managing a list of forms
class FormsListNotifier extends StateNotifier<List<FormModel>> {
  // Map to store text controllers for each form's text questions
  final Map<String, Map<String, TextEditingController>> formTextControllers =
      {};

  FormsListNotifier() : super([]);

  /// Add a new form to the list
  void addForm(FormModel form) {
    // Generate a unique ID for the form if it doesn't have one
    final String formId =
        form.title.isNotEmpty ? form.title : 'Form ${state.length + 1}';

    // Initialize text controllers for this form's text questions
    formTextControllers[formId] = {};
    for (var question in form.questions) {
      if (question.questionType == 'text') {
        formTextControllers[formId]![question.id] =
            TextEditingController(text: question.answer);
      }
    }

    state = [...state, form];
  }

  /// Update an existing form in the list
  void updateForm(int index, FormModel updatedForm) {
    if (index >= 0 && index < state.length) {
      final newList = [...state];
      newList[index] = updatedForm;
      state = newList;

      // Update text controllers for this form
      final String formId = updatedForm.title.isNotEmpty
          ? updatedForm.title
          : 'Form ${index + 1}';

      // Create controllers for new text questions
      for (var question in updatedForm.questions) {
        if (question.questionType == 'text' &&
            !formTextControllers[formId]!.containsKey(question.id)) {
          formTextControllers[formId]![question.id] =
              TextEditingController(text: question.answer);
        }
      }
    }
  }

  /// Remove a form from the list
  void removeForm(int index) {
    if (index >= 0 && index < state.length) {
      final formToRemove = state[index];
      final String formId = formToRemove.title.isNotEmpty
          ? formToRemove.title
          : 'Form ${index + 1}';

      // Dispose text controllers for this form
      if (formTextControllers.containsKey(formId)) {
        for (var controller in formTextControllers[formId]!.values) {
          controller.dispose();
        }
        formTextControllers.remove(formId);
      }

      final newList = [...state];
      newList.removeAt(index);
      state = newList;
    }
  }

  /// Get a form by index
  FormModel? getForm(int index) {
    if (index >= 0 && index < state.length) {
      return state[index];
    }
    return null;
  }

  /// Get a form by title
  FormModel? getFormByTitle(String title) {
    return state.firstWhere(
      (form) => form.title == title,
      orElse: () => const FormModel(title: '', questions: []),
    );
  }

  /// Update an answer in a specific form
  void updateAnswer(int formIndex, String questionId, String newAnswer) {
    if (formIndex >= 0 && formIndex < state.length) {
      final form = state[formIndex];
      final updatedQuestions = form.questions.map((question) {
        if (question.id == questionId) {
          return question.copyWith(answer: newAnswer);
        }
        return question;
      }).toList();

      final updatedForm = form.copyWith(questions: updatedQuestions);
      updateForm(formIndex, updatedForm);
    }
  }

  /// Get a text controller for a specific question in a form
  TextEditingController? getControllerForQuestion(
      int formIndex, String questionId) {
    if (formIndex >= 0 && formIndex < state.length) {
      final form = state[formIndex];
      final String formId =
          form.title.isNotEmpty ? form.title : 'Form ${formIndex + 1}';

      return formTextControllers[formId]?[questionId];
    }
    return null;
  }

  /// Check if all mandatory questions are answered in all forms
 bool validateAllForms() {
    if (state.isEmpty) return true; // Handle empty forms case
    print(state.length.toString());
    for (var form in state) {
      kLogger.info(form.questions.length.toString());
      if (form.questions.any((question) {
        kLogger.info(
          "${question.toJson()} \n isMandatory ${question.isMandatory} \n answer empty :${question.answer.isEmpty} \n ${question.isMandatory && question.answer.isEmpty} ${form.questions.indexOf(question)}",
        );
        return question.isMandatory &&
            question.answer.trim().isEmpty; // Add trim()
      })) {
        return false;
      }
    }
    return true;
  }

  /// Get the first mandatory question without an answer across all forms
  Map<String, String>? getMandatoryQuestionWithoutAnswer() {
    for (int i = 0; i < state.length; i++) {
      final form = state[i];
      for (final question in form.questions) {
        if (question.isMandatory && question.answer.isEmpty) {
          return {
            'formTitle': form.title,
            'formIndex': i.toString(),
            'questionText': question.questionText
          };
        }
      }
    }
    return null;
  }

  /// Reset all forms (clear all answers)
  void resetAllForms() {
    final updatedForms = state.map((form) {
      final clearedQuestions = form.questions.map((question) {
        return question.copyWith(answer: '');
      }).toList();
      return form.copyWith(questions: clearedQuestions);
    }).toList();

    // Clear all text controllers
    formTextControllers.forEach((formId, controllers) {
      controllers.forEach((id, controller) {
        controller.clear();
      });
    });

    state = updatedForms;
  }

  void resetFormsList() {
    // Dispose all text controllers
    formTextControllers.forEach((formId, controllers) {
      controllers.forEach((id, controller) {
        controller.dispose();
      });
    });
    formTextControllers.clear();
    state = [];
  }

  /// Get all forms data for submission
  List<Map<String, dynamic>> getAllFormsData() {
    return state.map((form) => form.toJson()).toList();
  }

  @override
  void dispose() {
    // Dispose all text controllers
    // formTextControllers.forEach((formId, controllers) {
    //   controllers.forEach((id, controller) {
    //     controller.dispose();
    //   });
    // });

    resetFormsList();

    super.dispose();
  }
}

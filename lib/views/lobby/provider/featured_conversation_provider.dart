
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'featured_conversation_provider.g.dart';

@riverpod
Future<bool> askQuestion(Ref ref, String lobbyId, String question) async {
  try {
    final response = await ApiService().post(
      "match/lobby/$lobbyId/question",
      {"questionText": question},
      (json) => json,
    );
    if (response['status'] == "SUCCESS") {
      kLogger.debug('Question asked successfully in lobby: $lobbyId');
      return true;
    } else {
      kLogger.error('Failed to ask question in lobby: $lobbyId');
      return false;
    }
  } catch (e) {
    kLogger.error('Error in askQuestion: $e');
    return false;
  }
}

@riverpod
Future<bool> answerQuestion(
    Ref ref, String lobbyId, String questionId, String answer) async {
  try {
    final response = await ApiService().post(
      "match/lobby/$lobbyId/question/$questionId/answer",
      {"answerText": answer},
      (json) => json,
    );

    if (response['status'] == "SUCCESS") {
      kLogger.debug('Answered successfully : $questionId');
      return true;
    } else {
      kLogger.error('Failed to answer question : $questionId');
      return false;
    }
  } catch (e) {
    kLogger.error('Error in answerQuestion: $e');
    return false;
  }
}

@riverpod
Future<List<ConversationQuestion>> getFeaturedConversations(
    Ref ref, String lobbyId) async {
  try {
    final response = await ApiService().get(
      "match/lobby/$lobbyId/questions/answered",
      (json) => json,
    );
    if (response != null) {
      kLogger.debug('getFeaturedConversations successfully : $response');
      List data = response;
      return data.map((json) => ConversationQuestion.fromJson(json)).toList();
    } else {
      kLogger.error('Failed in fetching Featured Conversations : $lobbyId');
      return [];
    }
  } catch (e) {
    kLogger.error('Error in getFeaturedConversations: $e');
    return [];
  }
}

@riverpod
Future<List<ConversationQuestion>> getAllQuestions(
    Ref ref, String lobbyId) async {
  try {
    final response = await ApiService().get(
      "match/lobby/$lobbyId/questions",
      (json) => json,
    );

    if (response != null) {
      List data = response;
      return data.map((json) => ConversationQuestion.fromJson(json)).toList();
    } else {
      kLogger.error('Failed to fetch all question : $lobbyId');
      return [];
    }
  } catch (e) {
    kLogger.error('Error in getAllQuestions: $e');
    return [];
  }
}

class ConversationQuestion {
  final String questionId;
  final String questionText;
  final String? answerText;
  final UserSummary? answeredBy;
  final UserSummary? questionBy;
  final bool answered;
  final DateTime createdAt;
  final DateTime? answeredAt;

  ConversationQuestion({
    required this.questionId,
    required this.questionText,
    this.answerText,
    this.answeredBy,
    this.questionBy,
    required this.answered,
    required this.createdAt,
    this.answeredAt,
  });

  // Factory method to parse JSON data
  factory ConversationQuestion.fromJson(Map<String, dynamic> json) {
    return ConversationQuestion(
      questionId: json['questionId'],
      questionText: json['questionText'],
      answerText: json['answerText'],
      answeredBy: (json['answeredBy']!=null) ? UserSummary.fromJson(json['answeredBy']):null,
      questionBy: (json['questionBy']!=null) ? UserSummary.fromJson(json['questionBy']):null,
      answered: json['answered'],
      createdAt: DateTime.parse(json['createdAt']),
      answeredAt: DateTime.parse(json['answeredAt']),
    );
  }
}

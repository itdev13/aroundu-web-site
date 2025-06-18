

import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Generate the required code.
part 'lobby_access_provider.g.dart';

// Function-based provider to handle visitor joining a lobby
@riverpod
Future<Map<String, dynamic>> handleLobbyAccess(
  Ref ref,
  String lobbyId,
  bool isPrivate, {
  required bool hasForm,
  List<String>? groupId,
  List<String>? friends,
  String text = '',
  Map<String, dynamic> form = const {},
  List<Map<String, dynamic>> formList = const [],
  int? slots,
}) async {
  Map<String, dynamic> response;
  if (isPrivate) {
    if (hasForm) {
      response = await _requestAccessWithForm(
        lobbyId,
        text,
        groupId,
        friends,
        form,
      );
    } else {
      response = await _requestAccess(
        lobbyId,
        groupId,
        friends,
        text,
      );
    }
    // Private lobby - request access with a groupId and text
  } else {
    // Public lobby - send join request
    // if (hasForm) {}
    if (slots != null) {
      response = await _joinLobby(lobbyId, text, friends, form,formList, slots);
    } else {
      response = await _joinLobby(lobbyId, text, friends, form,null ,null);
    }
  }
  return response;
}

// Function to handle joining a public lobby (POST request)
Future<Map<String, dynamic>> _joinLobby(
  String lobbyId,
  String text,
  List<String>? friends,
  Map<String, dynamic>? form,
  List<Map<String, dynamic>>? formList,
  int? slots,
) async {
  try {
    Map<String, dynamic> body = {
      "lobbyId": lobbyId,
      "friends": friends ?? [],
      "form": form ?? {}
    };
    if (slots != null) {
      body['slots'] = slots;
    }
    if (formList != null) {
      body['forms'] = formList;
    }
    final response = await ApiService().post(
      'match/lobby/public/join', // API endpoint for public lobby join
      body, // Empty body
      (json) => json,
    );
    kLogger.debug('Joined public lobby successfully: $response');
    
    
    return response;
  } catch (e) {
    kLogger.error('Error joining public lobby: $e');
    Fluttertoast.showToast(msg: "something went wrong!");
    rethrow;
  }
}

// Function to request access to a private lobby (POST request)
Future<Map<String, dynamic>> _requestAccess(
  String lobbyId,
  List<String>? groupId,
  List<String>? friends,
  String text,
) async {
  try {
    final response = await ApiService().post(
      'match/lobby/api/v1/request-access', // API endpoint for requesting access to private lobby
      {
        "text": text,
        "lobbyId": lobbyId,
        "friends": friends ?? [],
        "groups": groupId ?? []
      }, // Empty body
      (json) => json,
    );
    kLogger.debug('Request sent successfully: $response');
    return response;
  } catch (e) {
    kLogger.error('Error requesting access: $e');
    rethrow;
  }
}

Future<Map<String, dynamic>> _requestAccessWithForm(
  String lobbyId,
  String text,
  List<String>? groupId,
  List<String>? friends,
  Map<String, dynamic> form,
) async {
  try {
    final response = await ApiService().post(
      'match/lobby/api/v1/request-access', // API endpoint for requesting access to private lobby
      {
        "text": text,
        "groups": groupId ?? [],
        "lobbyId": lobbyId,
        "friends": friends ?? [],
        "form": form
      }, // Empty body
      (json) => json,
    );
    kLogger.debug('Request sent with form successfully: $response');
    return response;
  } catch (e, stack) {
    kLogger.error('Error requesting access with form: $e \n $stack');
    rethrow;
  }
}

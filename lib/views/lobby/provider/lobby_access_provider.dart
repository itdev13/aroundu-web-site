import 'package:aroundu/designs/widgets/space.widget.designs.dart';
import 'package:aroundu/designs/widgets/text.widget.designs.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:aroundu/views/lobby/provider/selected_tickets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
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
  String? offerId,
  List<SelectedTicket>? selectedTickets,
}) async {
  Map<String, dynamic> response;
  if (isPrivate) {
    if (hasForm) {
      response = await _requestAccessWithForm(lobbyId, text, groupId, friends, form, offerId, selectedTickets);
    } else {
      response = await _requestAccess(lobbyId, groupId, friends, text, offerId, selectedTickets);
    }
    // Private lobby - request access with a groupId and text
  } else {
    // Public lobby - send join request
    // if (hasForm) {}
    if (slots != null) {
      response = await _joinLobby(lobbyId, text, friends, form, formList, slots, offerId, selectedTickets);
    } else {
      response = await _joinLobby(lobbyId, text, friends, form, null, null, offerId, selectedTickets);
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
  String? offerId,
  List<SelectedTicket>? selectedTickets,
) async {
  try {
    Map<String, dynamic> body = {"lobbyId": lobbyId, "friends": friends ?? [], "form": form ?? {}};
    if (selectedTickets != null && selectedTickets.isNotEmpty) {
      body['slots'] = selectedTickets.fold<int>(0, (sum, ticket) => sum + ticket.slots).toString();
      body['ticketOptionsDTOS'] = selectedTickets.map((e) => e.toJson()).toList();
    } else if (slots != null) {
      body['slots'] = slots;
    }
    if (formList != null) {
      body['forms'] = formList;
    }
    if (offerId != null) {
      body['offerId'] = offerId;
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
  String? offerId,
  List<SelectedTicket>? selectedTickets,
) async {
  try {
    Map<String, dynamic> body = {"text": text, "lobbyId": lobbyId, "friends": friends ?? [], "groups": groupId ?? []};
    if (offerId != null) {
      body['offerId'] = offerId;
    }
    if (selectedTickets != null && selectedTickets.isNotEmpty) {
      // body['slots'] = selectedTickets.fold<int>(0, (sum, ticket) => sum + ticket.slots).toString();
      body['ticketOptionsDTOS'] = selectedTickets.map((e) => e.toJson()).toList();
    }
    final response = await ApiService().post(
      'match/lobby/api/v1/request-access', // API endpoint for requesting access to private lobby
      body, // Empty body
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
  String? offerId,
  List<SelectedTicket>? selectedTickets,
) async {
  try {
    Map<String, dynamic> body = {
      "text": text,
      "groups": groupId ?? [],
      "lobbyId": lobbyId,
      "friends": friends ?? [],
      "form": form,
    };
    if (offerId != null) {
      body['offerId'] = offerId;
    }
    if (selectedTickets != null && selectedTickets.isNotEmpty) {
      // body['slots'] = selectedTickets.fold<int>(0, (sum, ticket) => sum + ticket.slots).toString();
      body['ticketOptionsDTOS'] = selectedTickets.map((e) => e.toJson()).toList();
    }
    final response = await ApiService().post(
      'match/lobby/api/v1/request-access', // API endpoint for requesting access to private lobby
      body, // Empty body
      (json) => json,
    );
    kLogger.debug('Request sent with form successfully: $response');
    return response;
  } catch (e, stack) {
    kLogger.error('Error requesting access with form: $e \n $stack');
    rethrow;
  }
}

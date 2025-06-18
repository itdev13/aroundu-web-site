
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'manage_members_lobby_provider.g.dart';

@riverpod
Future<bool> removeLobbyMember(Ref ref,
    {required String lobbyId, required List<String> membersToRemove}) async {
  try {
    final response = await ApiService().delete(
      "match/lobby/api/v1/members",
      <String, dynamic>{"lobbyId": lobbyId, "membersToRemove": membersToRemove},
    );
    if (response) {
      kLogger.debug('member removed: $response');
      Fluttertoast.showToast(msg: "Members Removed Successfully");
    }
    return response;
  } catch (e, stack) {
    kLogger.error('Error in removing members: $e \n $stack');
    Fluttertoast.showToast(msg: "Something went wrong try again later !!!");
    return false;
  }
}

@riverpod
Future<bool> invitePeopleInLobby(
  Ref ref, {
  required String lobbyId,
  required List<String> friendsIds,
  required List<String> squadMembersIds,
}) async {
  List friendsAndSquadsUserIds =
      <dynamic>{...friendsIds, ...squadMembersIds}.toList();
  try {
    final response = await ApiService().post(
      "match/lobby/api/v1/invitations",
      {
        "lobbyId": lobbyId,
        "friends": friendsAndSquadsUserIds,
      },
      (json) => json,
    );
    Fluttertoast.showToast(msg: response['status']);
    if (response['status'] == "SUCCESS") {
      kLogger.debug('Invited successfully');
      return true;
    } else {
      kLogger.error('Failed to Invite');
      return false;
    }
  } catch (e) {
    kLogger.error('Error in answerQuestion: $e');
    return false;
  }
}

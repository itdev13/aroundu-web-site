
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'delete_lobby_provider.g.dart';

@riverpod
Future<bool> deleteLobby(Ref ref, String lobbyId) async {
  try {
    final response = await ApiService().delete(
      "match/lobby/api/v1/$lobbyId",
      <String, dynamic>{},
    );
    if (response) {
      kLogger.debug('Lobby Deleted: $response');
    }
    return response;
  } catch (e) {
    kLogger.error('Error in deleting lobby: $e');
    return false;
  }
}

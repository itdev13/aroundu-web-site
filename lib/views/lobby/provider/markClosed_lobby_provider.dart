
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'markClosed_lobby_provider.g.dart';

@riverpod
Future<bool> markAsClosedLobby(Ref ref, String lobbyId) async {
  try {
    final response = await ApiService().put(
      "match/lobby/api/v1/$lobbyId/close",
      {},
      (json) => json,
    );
    kLogger.debug('Marked lobby as closed: $response');
    return true;
  } catch (e) {
    kLogger.error('Error in mark lobby as closed: $e');
    return false;
  }
}

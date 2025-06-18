
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models/lobby.dart';

part 'category_lobby_provider.g.dart';

@riverpod
Future<List<Lobby>> getLobbiesFromCategory(Ref ref, String categoryId) async {
  try {
    final response = await ApiService().get(
      "match/lobby?categoryId=$categoryId",
      (json) => json,
    );

    if (response != null) {
      kLogger.debug('get Lobbies From Category successfully : $response');
      List data = response;
      return data.map((json) => Lobby.fromJson(json)).toList();
    } else {
      kLogger.error('Failed in fetching Lobbies From Category');
      return [];
    }
  } catch (e) {
    kLogger.error('Error in getLobbiesFromCategory: $e');
    return [];
  }
}

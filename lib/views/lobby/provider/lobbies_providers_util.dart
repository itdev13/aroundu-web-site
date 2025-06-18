import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/views/lobby/provider/lobbies_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

class LobbyProviderUtil {
  static FutureProvider<List<Lobby>> getProvider(
    LobbyType lobbyType, {
    String? categoryId,
    String? subCategoryId,
  }) {
    switch (lobbyType) {
      case LobbyType.myLobbies:
        return yourLobbiesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case LobbyType.recommendations:
        return recommendedLobbiesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case LobbyType.trending:
        return topLobbiesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case LobbyType.joined:
        return joinedLobbiesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case LobbyType.saved:
        return savedLobbiesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      default:
        return yourLobbiesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
    }
  }
}

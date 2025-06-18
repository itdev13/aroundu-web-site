import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/card_colors.designs.dart';
import 'package:aroundu/models/lobby.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
// import 'package:aroundu/utils/api_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lobbies_providers.g.dart';

enum LobbyType {
  myLobbies,
  recommendations,
  trending,
  joined,
  saved,
}

@Riverpod(keepAlive: true)
Future<List<Lobby>> yourLobbies(YourLobbiesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchLobbies(LobbyType.myLobbies,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<Lobby>> recommendedLobbies(RecommendedLobbiesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchLobbies(LobbyType.recommendations,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<Lobby>> topLobbies(TopLobbiesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchLobbies(LobbyType.trending,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<Lobby>> joinedLobbies(JoinedLobbiesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchLobbies(LobbyType.joined,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<Lobby>> savedLobbies(SavedLobbiesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchLobbies(LobbyType.saved,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

Future<List<Lobby>> fetchLobbies(
  LobbyType lobbyType, {
  String? categoryId,
  String? subCategoryId,
}) async {
  try {
    String url = ApiConstants.getLobbies;
    Map<String, dynamic> queryParameters = {};

    // Add type-specific parameters
    switch (lobbyType) {
      case LobbyType.myLobbies:
        queryParameters['createdLobbies'] = true;
        break;
      case LobbyType.recommendations:
        queryParameters['topPicks'] = true;
        break;
      case LobbyType.trending:
        queryParameters['fastFilling'] = true;
        break;
      case LobbyType.joined:
        queryParameters['joinedLobbies'] = true;
        break;
      case LobbyType.saved:
        queryParameters['savedLobbies'] = true;
        break;
    }

    // Add optional filters if provided
    if (categoryId != null) {
      queryParameters['categoryId'] = categoryId;
    }
    if (subCategoryId != null) {
      queryParameters['subCategoryId'] = subCategoryId;
    }

    final response =
        await ApiService().get(url, queryParameters: queryParameters);

    if (response.data != null) {
      final lobbies = response.data.map<Lobby>((json) {
        final lobby = Lobby.fromJson(json);
        return lobby.copyWith(
            colorScheme: geLobbyColors(lobby.filter.categoryId));
      }).toList();
      return lobbies;
    } else {
      throw Exception("Failed to load lobbies");
    }
  } catch (e, stackTrace) {
    kLogger.error("Error fetching lobbies: $e");
    kLogger.error('Stack trace: $stackTrace');
    throw Exception("Failed to fetch lobbies");
  }
}

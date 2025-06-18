import 'package:aroundu/models/house.model.dart';
import 'package:aroundu/utils/api_service/api.service.dart';
import 'package:aroundu/utils/logger.utils.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../constants/urls.dart';

part 'houses_providers.g.dart';

enum HouseType {
  myHouses,
  recommendations,
  trending,
  followed,
  created,
}

@Riverpod(keepAlive: true)
Future<List<House>> yourHouses(YourHousesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchHouses(HouseType.myHouses,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<House>> recommendedHouses(RecommendedHousesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchHouses(HouseType.recommendations,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<House>> topHouses(TopHousesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchHouses(HouseType.trending,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<House>> followedHouses(FollowedHousesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchHouses(HouseType.followed,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

@Riverpod(keepAlive: true)
Future<List<House>> createdHouses(CreatedHousesRef ref,
    {String? categoryId, String? subCategoryId}) {
  return fetchHouses(HouseType.created,
      categoryId: categoryId, subCategoryId: subCategoryId);
}

Future<List<House>> fetchHouses(
  HouseType houseType, {
  String? categoryId,
  String? subCategoryId,
}) async {
  try {
    String url = ApiConstants.getHouses;
    Map<String, dynamic> queryParameters = {};

    // Add type-specific parameters
    switch (houseType) {
      case HouseType.myHouses:
        queryParameters['createdHouses'] = true;
        break;
      case HouseType.recommendations:
        queryParameters['topPicks'] = true;
        break;
      case HouseType.trending:
        queryParameters['trendingHouses'] = true;
        break;
      case HouseType.followed:
        queryParameters['followingHouses'] = true;
        break;
       case HouseType.created:
        queryParameters['createdHouses'] = true;
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
      final houses = response.data.map<House>((json) {
        final house = House.fromJson(json);
        return house;
      }).toList();
      return houses;
    } else {
      throw Exception("Failed to load houses");
    }
  } catch (e) {
    kLogger.error("Error fetching houses: $e");
    throw Exception("Failed to fetch houses");
  }
}

import 'package:aroundu/models/house.model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';


import 'houses_providers.dart';

class HouseProviderUtil {
  static FutureProvider<List<House>> getProvider(
    HouseType houseType, {
    String? categoryId,
    String? subCategoryId,
  }) {
    switch (houseType) {
      case HouseType.myHouses:
        return yourHousesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case HouseType.recommendations:
        return recommendedHousesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case HouseType.trending:
        return topHousesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case HouseType.followed:
        return followedHousesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      case HouseType.created:
        return createdHousesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
      default:
        return yourHousesProvider(
            categoryId: categoryId, subCategoryId: subCategoryId);
    }
  }
}

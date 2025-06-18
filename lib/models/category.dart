import 'dart:ui';

import 'package:aroundu/constants/urls.dart';
import 'package:aroundu/designs/card_colors.designs.dart';
import 'package:aroundu/utils/api_service/api_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';
part 'category.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String name,
    required String description,
    required String iconUrl,
    required String categoryId,
    @Default("") String? imageUrl,
    required List<SubCategoryInfo> subCategoryInfoList,
    String? bgColor,
    String? onBgColor,
    String? borderColor,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  // get lobbyId => null;
}

@freezed
class SubCategoryInfo with _$SubCategoryInfo {
  const factory SubCategoryInfo({
    required String name,
    required String description,
    required String subCategoryId,
    required String iconUrl,
    String? imageUrl,
    String? hashTag,
    String? prompt,
  }) = _SubCategoryInfo;

  factory SubCategoryInfo.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryInfoFromJson(json);

  // get id => null;
}

extension CategoryModelX on CategoryModel {
  CardColorScheme get colorColors {
    if (bgColor != null && onBgColor != null && borderColor != null) {
      return CardColorScheme(
        bgColor!.toColor(),
        onBgColor!.toColor(),
        borderColor!.toColor(),
      );
    }
    return geLobbyColors(categoryId);
  }
}

extension ColorExtension on String {
  Color toColor() {
    var hexColor = replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
    return Color(int.parse("0xFF55B9F4"));
  }
}

final FutureProvider<List<CategoryModel>?> categoryProvider =
    FutureProvider<List<CategoryModel>?>((ref) {
      return ApiService<List<CategoryModel>>().get(ApiConstants.userInterest, (
        json,
      ) {
        final data = json['onboardingResponseList'] as List;
        return data.map((e) => CategoryModel.fromJson(e)).toList();
      });
    });
// class SubCategoryInfo {
//   const SubCategoryInfo({
//     required this.name,
//     required this.description,
//     required this.iconUrl,
//     required this.subCategoryId,
//   });
//
//   final String name;
//   final String description;
//   final String iconUrl;
//   final String subCategoryId;
//
//   factory SubCategoryInfo.fromJson(Map<String, dynamic> json) {
//     return SubCategoryInfo(
//       name: json['name'] ?? "",
//       description: json['description'] ?? "",
//       iconUrl: json['iconUrl'] ?? "",
//       subCategoryId: json['subCategoryId'] ?? "",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'description': description,
//       'iconUrl': iconUrl,
//       'subCategoryId': subCategoryId,
//     };
//   }
// }
//
// class CategoryModel {
//   const CategoryModel({
//     required this.name,
//     required this.description,
//     required this.iconUrl,
//     required this.categoryId,
//     required this.subCategoryInfoList,
//   });
//
//   final String name;
//   final String description;
//   final String iconUrl;
//   final String categoryId;
//   final List<SubCategoryInfo> subCategoryInfoList;
//
//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     return CategoryModel(
//       name: json['name'] ?? "",
//       description: json['description'] ?? "",
//       iconUrl: json['iconUrl'] ?? "",
//       categoryId: json['categoryId'] ?? "",
//       subCategoryInfoList: json['subCategoryInfoList'] != null
//           ? List<SubCategoryInfo>.from(json['subCategoryInfoList']
//               .map((x) => SubCategoryInfo.fromJson(x)))
//           : [],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'name': name,
//       'description': description,
//       'iconUrl': iconUrl,
//       'categoryId': categoryId,
//       'subCategoryInfoList':
//           List<dynamic>.from(subCategoryInfoList.map((x) => x.toJson())),
//     };
//   }
// }

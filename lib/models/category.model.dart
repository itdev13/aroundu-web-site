class CategoryModel {
  const CategoryModel({
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.categoryId,
    required this.subCategoryInfoList,
  });

  final String name;
  final String description;
  final String iconUrl;
  final String categoryId;
  final List<SubCategoryInfo> subCategoryInfoList;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      iconUrl: json['iconUrl'] ?? "",
      categoryId: json['categoryId'] ?? "",
      subCategoryInfoList: json['subCategoryInfoList'] != null
          ? List<SubCategoryInfo>.from(
              json['subCategoryInfoList'].map(
                (x) => SubCategoryInfo.fromJson(x),
              ),
            )
          : [],
    );
  }
}

class SubCategoryInfo {
  const SubCategoryInfo({
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.subCategoryId,
    required this.hashTag,
    required this.prompt,
  });

  final String name;
  final String description;
  final String iconUrl;
  final String subCategoryId;
  final String hashTag;
  final String prompt;

  factory SubCategoryInfo.fromJson(Map<String, dynamic> json) {
    return SubCategoryInfo(
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      iconUrl: json['iconUrl'] ?? "",
      subCategoryId: json['subCategoryId'] ?? "",
      hashTag: json['hashTag'] ?? "",
      prompt: json['prompt'] ?? "",
    );
  }
}

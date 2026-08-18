class CategoryModel {
  final String id;
  final String category;
  final String? storeId;

  CategoryModel({required this.id, required this.category, this.storeId});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      storeId: json['storeId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      if (storeId != null) 'storeId': storeId,
    };
  }
}

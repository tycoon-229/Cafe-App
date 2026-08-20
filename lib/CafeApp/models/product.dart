class Product {
  String id;
  String name;
  String? description;
  String? imageUrl;
  String? categoryId;
  String? cafeId;
  bool isAvailable;
  bool isActive;
  DateTime? createdAt;
  double? minPrice;

  Product({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.cafeId,
    this.isAvailable = true,
    this.isActive = true,
    this.createdAt,
    this.minPrice,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      categoryId: json['category_id']?.toString(),
      cafeId: json['cafe_id']?.toString(),
      isAvailable: json['is_available'] ?? true,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      minPrice: json['min_price'] != null
          ? double.tryParse(json['min_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId?.isNotEmpty == true ? categoryId : null,
      'cafe_id': cafeId,
      'is_available': isAvailable,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

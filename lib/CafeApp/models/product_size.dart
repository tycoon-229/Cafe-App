class ProductSize {
  String id;
  String productId;
  String name;
  double price;

  ProductSize({
    required this.id,
    required this.productId,
    required this.name,
    required this.price,
  });

  factory ProductSize.fromJson(Map<String, dynamic> json) {
    return ProductSize(
      id: json['id'].toString(),
      productId: json['product_id'].toString(),
      name: json['name'],
      price: double.tryParse(json['price'].toString()) ?? 0,
    );
  }
}

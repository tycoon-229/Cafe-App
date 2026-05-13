class OrderDetail {
  String id;
  String productName;
  String sizeName;
  double price;
  int quantity;
  double subtotal;

  OrderDetail({
    required this.id,
    required this.productName,
    required this.sizeName,
    required this.price,
    required this.quantity,
    required this.subtotal,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'],
      productName: json['product_name'] ?? '',
      sizeName: json['size_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
    );
  }
}
class Order {
  String id;
  String tableId;
  String tableName;
  double total;
  String status;
  DateTime? createdAt;
  String? paymentMethod;

  Order({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.total,
    required this.status,
    this.createdAt,
    this.paymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'].toString(),
      tableId: json['table_id']?.toString() ?? '',
      tableName: json['tables']?['name'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      paymentMethod: json['payment_method'],
    );
  }
}

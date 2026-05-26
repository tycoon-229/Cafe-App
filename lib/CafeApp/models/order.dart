class Order {
  String id;
  String tableId;
  String tableName;
  double total;
  String status;
  DateTime? createdAt;

  Order({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.total,
    required this.status,
    this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      tableId: json['table_id'],
      tableName: json['tables']?['name'] ?? '',
      total: (json['total'] ?? 0).toDouble(),
      status: json['status'] ?? 'open',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}
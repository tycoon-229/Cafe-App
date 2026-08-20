class Expense {
  String id;
  String title;
  double amount;
  String? description;
  DateTime? createdAt;
  String cafeId;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    this.description,
    this.createdAt,
    required this.cafeId,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'].toString(),
      title: json['title'],
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : null,
      cafeId: json['cafe_id'].toString(),
    );
  }
}

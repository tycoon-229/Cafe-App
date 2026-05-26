class CafeTable {
  String id;
  String name;
  String status;

  CafeTable({
    required this.id,
    required this.name,
    required this.status,
  });

  factory CafeTable.fromJson(Map<String, dynamic> json) {
    return CafeTable(
      id: json['id'],
      name: json['name'],
      status: json['status'] ?? 'empty',
    );
  }
}
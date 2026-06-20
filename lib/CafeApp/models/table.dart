class CafeTable {
  String id;
  String name;
  String status;
  String? mergedTo;

  CafeTable({
    required this.id,
    required this.name,
    required this.status,
    this.mergedTo,
  });

  factory CafeTable.fromJson(Map<String, dynamic> json) {
    return CafeTable(
      id: json['id'],
      name: json['name'],
      status: json['status'] ?? 'empty',
      mergedTo: json['merged_to'],
    );
  }
}
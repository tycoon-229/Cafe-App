class CafeTable {
  String id;
  String name;
  String status;
  String? mergedTo;
  bool isActive;

  CafeTable({
    required this.id,
    required this.name,
    required this.status,
    this.mergedTo,
    this.isActive = true,
  });

  factory CafeTable.fromJson(Map<String, dynamic> json) {
    return CafeTable(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      status: json['status'] ?? 'empty',
      mergedTo: json['merged_to']?.toString(),
      isActive: json['is_active'] ?? true,
    );
  }
}

class Cafe {
  final String id;
  final String ownerId;

  final String cafeName;
  final String? address;
  final String? phone;
  final String? description;

  /// pending / approved / rejected
  final String approvalStatus;

  final DateTime? createdAt;

  Cafe({
    required this.id,
    required this.ownerId,
    required this.cafeName,
    this.address,
    this.phone,
    this.description,
    this.approvalStatus =
    'pending',
    this.createdAt,
  });

  factory Cafe.fromJson(
      Map<String, dynamic> json,
      ) {
    return Cafe(
      id: json['id'] ?? '',

      ownerId:
      json['owner_id'] ?? '',

      cafeName:
      json['cafe_name'] ??
          '',

      address:
      json['address'],

      phone:
      json['phone'],

      description:
      json['description'],

      approvalStatus:
      json['approval_status'] ??
          'pending',

      createdAt:
      json['created_at'] !=
          null
          ? DateTime.tryParse(
        json[
        'created_at'],
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id':
      ownerId,
      'cafe_name':
      cafeName,
      'address':
      address,
      'phone':
      phone,
      'description':
      description,
      'approval_status':
      approvalStatus,
      'created_at':
      createdAt
          ?.toIso8601String(),
    };
  }

  bool get isApproved =>
      approvalStatus ==
          'approved';

  bool get isPending =>
      approvalStatus ==
          'pending';

  bool get isRejected =>
      approvalStatus ==
          'rejected';
}
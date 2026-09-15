import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';
import 'account_approval_page.dart';

class UserManagementPage extends StatelessWidget {
  UserManagementPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SEARCH & DUYỆT TÀI KHOẢN
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xffe2e8f0)),
                  ),
                  child: TextField(
                    onChanged: (value) => controller.searchText.value = value,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Tìm username hoặc email...',
                      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.black45, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Obx(() {
                final pendingCount = controller.users
                    .where((e) => e['account_status'] == 'pending')
                    .length;

                return Badge(
                  isLabelVisible: pendingCount > 0,
                  label: Text('$pendingCount'),
                  backgroundColor: const Color(0xffef4444),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff4f46e5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _showApprovalPopup,
                    icon: const Icon(Icons.how_to_reg_rounded, size: 18),
                    label: const Text('Duyệt user', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                );
              }),
            ],
          ),
        ),

        // USER LIST
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Color(0xff4f46e5), strokeWidth: 2));
            }

            final approvedUsers = controller.filteredUsers
                .where((user) => user['account_status'] == 'approved')
                .toList();

            if (approvedUsers.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_off_outlined, size: 48, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text('Không tìm thấy tài khoản nào', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: const Color(0xff4f46e5),
              onRefresh: controller.refreshUsers,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: approvedUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final user = approvedUsers[index];
                  final isActive = user['is_active'] ?? true;
                  final cafes = user['cafes'] as List?;
                  final cafe = cafes != null && cafes.isNotEmpty ? cafes.first : null;

                  return InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _showUserDetail(user),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xffe2e8f0)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: const Color(0xffe2e8f0),
                                backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                                child: user['avatar_url'] == null
                                    ? Text(
                                  (user['username'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                                )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['username'] ?? 'Chưa có tên',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    // TRÁNH OVERFLOW EMAIL
                                    Text(
                                      user['email'] ?? '',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (cafe != null) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.coffee_rounded, size: 14, color: Color(0xffd97706)),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              cafe['cafe_name'] ?? '',
                                              style: const TextStyle(
                                                color: Color(0xffd97706),
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              // TRẠNG THÁI ACTIVE / BLOCKED
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive ? const Color(0xfff0fdf4) : const Color(0xfffef2f2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isActive ? const Color(0xffbbf7d0) : const Color(0xfffecaca),
                                  ),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Locked',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                    color: isActive ? const Color(0xff16a34a) : const Color(0xffdc2626),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20, color: Color(0xfff1f5f9)),
                          // ACTIONS (ROLE + LOCK/UNLOCK + DELETE)
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 38,
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff8fafc),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xffe2e8f0)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: user['role'] ?? 'user',
                                      isExpanded: true,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
                                      items: const [
                                        DropdownMenuItem(value: 'user', child: Text('User')),
                                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                      ],
                                      onChanged: (val) {
                                        if (val != null) {
                                          controller.updateUserRole(userId: user['id'], role: val);
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: SizedBox(
                                  height: 38,
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: isActive ? const Color(0xffd97706) : const Color(0xff16a34a),
                                      side: BorderSide(
                                        color: isActive ? const Color(0xfffde68a) : const Color(0xffbbf7d0),
                                      ),
                                      backgroundColor: isActive ? const Color(0xfffffbeb) : const Color(0xfff0fdf4),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: () => controller.toggleUserStatus(
                                      userId: user['id'],
                                      currentStatus: isActive,
                                    ),
                                    icon: Icon(isActive ? Icons.lock_outline_rounded : Icons.lock_open_rounded, size: 14),
                                    label: Text(isActive ? 'Khóa' : 'Mở khóa', style: const TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 38,
                                width: 38,
                                child: IconButton(
                                  style: IconButton.styleFrom(
                                    backgroundColor: const Color(0xfffef2f2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showDeleteDialog(user),
                                  icon: const Icon(Icons.delete_outline_rounded, color: Color(0xffef4444), size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  void _showApprovalPopup() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xfff8fafc),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Duyệt tài khoản mới", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.close_rounded, size: 20)),
                ],
              ),
            ),
            const Divider(color: Color(0xffe2e8f0), height: 1),
            const Expanded(child: AccountApprovalPage()),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showDeleteDialog(Map<String, dynamic> user) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xóa tài khoản', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text('Xác nhận xóa tài khoản "${user['username']}" khỏi hệ thống? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Hủy', style: TextStyle(color: Colors.black54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xffef4444),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Get.back();
              await controller.deleteUser(user['id']);
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showUserDetail(Map<String, dynamic> user) {
    final cafes = user['cafes'] as List?;
    final cafe = cafes != null && cafes.isNotEmpty ? cafes.first : null;
    final isActive = user['is_active'] ?? true;

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
                ),
              ),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: const Color(0xffeef2ff),
                    backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                    child: user['avatar_url'] == null
                        ? const Icon(Icons.person, size: 28, color: Color(0xff4f46e5))
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['username'] ?? 'Chưa đặt tên',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user['email'] ?? '',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _detailRow('Trạng thái', isActive ? 'Đang hoạt động' : 'Đã khóa'),
              _detailRow('Quyền hạn', user['role']?.toString().toUpperCase() ?? 'USER'),
              _detailRow('Số điện thoại', user['phone'] ?? 'Chưa có'),
              if (cafe != null) ...[
                const Divider(height: 24),
                const Text('Thông tin quán cafe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                _detailRow('Tên quán', cafe['cafe_name'] ?? ''),
                _detailRow('Địa chỉ', cafe['address'] ?? ''),
                _detailRow('Hotline', cafe['phone'] ?? ''),
                _detailRow('Trạng thái duyệt', cafe['approval_status'] ?? ''),
              ],
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
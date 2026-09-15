import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class AccountApprovalPage extends StatelessWidget {
  const AccountApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();

    return Obx(() {
      final pendingUsers = controller.users
          .where((e) => e['account_status'] == 'pending')
          .toList();

      if (pendingUsers.isEmpty) {
        return const Center(
          child: Text('Không có tài khoản nào đang chờ xét duyệt', style: TextStyle(color: Colors.black45)),
        );
      }

      return RefreshIndicator(
        color: const Color(0xff4f46e5),
        onRefresh: controller.refreshUsers,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: pendingUsers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (_, index) {
            final user = pendingUsers[index];
            final cafes = user['cafes'] as List?;
            final cafe = cafes != null && cafes.isNotEmpty ? cafes.first : null;

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xffe2e8f0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xffeef2ff),
                        backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
                        child: user['avatar_url'] == null
                            ? Text(
                          (user['username'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xff4f46e5)),
                        )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user['username'] ?? 'Không tên',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user['email'] ?? '',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (cafe != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xfff8fafc),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Quán đăng ký: ${cafe['cafe_name'] ?? ''}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text('Địa chỉ: ${cafe['address'] ?? ''}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          Text('SĐT: ${cafe['phone'] ?? ''}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xffef4444),
                            side: const BorderSide(color: Color(0xfffecaca)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => controller.rejectAccount(user['id']),
                          child: const Text('Từ chối', style: TextStyle(fontSize: 13)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff16a34a),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => controller.approveAccount(user['id']),
                          child: const Text('Duyệt tài khoản', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}
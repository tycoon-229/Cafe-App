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
          child: Text(
            'Không có tài khoản cần duyệt',
            style: TextStyle(fontSize: 16),
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: controller.refreshUsers,

        child: ListView.builder(
          padding: const EdgeInsets.all(20),

          itemCount: pendingUsers.length,

          itemBuilder: (_, index) {
            final user = pendingUsers[index];

            final cafes = user['cafes'] as List?;

            final cafe = cafes != null && cafes.isNotEmpty ? cafes.first : null;

            return Card(
              elevation: 2,

              margin: const EdgeInsets.only(bottom: 16),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),

              child: Padding(
                padding: const EdgeInsets.all(18),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange.shade100,

                          backgroundImage:
                              user['avatar_url'] != null &&
                                  user['avatar_url'].toString().isNotEmpty
                              ? NetworkImage(user['avatar_url'])
                              : null,

                          child:
                              user['avatar_url'] == null ||
                                  user['avatar_url'].toString().isEmpty
                              ? Text(
                                  (user['username'] ?? 'U')
                                      .toString()
                                      .substring(0, 1)
                                      .toUpperCase(),

                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              Text(
                                user['username'] ?? 'Không tên',

                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(user['email'] ?? ''),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    if (cafe != null)
                      Container(
                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.08),

                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            const Text(
                              'Thông tin quán',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 10),

                            Text('Tên quán: ${cafe['cafe_name'] ?? ''}'),

                            Text('Địa chỉ: ${cafe['address'] ?? ''}'),

                            Text('SĐT: ${cafe['phone'] ?? ''}'),

                            if (cafe['description'] != null &&
                                cafe['description'].toString().isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),

                                child: Text('Mô tả: ${cafe['description']}'),
                              ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await controller.rejectAccount(user['id']);
                            },

                            icon: const Icon(Icons.close),

                            label: const Text('Từ chối'),

                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await controller.approveAccount(user['id']);
                            },

                            icon: const Icon(Icons.check),

                            label: const Text('Duyệt'),

                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
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
    });
  }
}

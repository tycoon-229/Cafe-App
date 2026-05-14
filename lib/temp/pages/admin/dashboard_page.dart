import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin/admin_controller.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: controller.refreshUsers,
      child: Obx(
            () => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.dashboard_rounded, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Dashboard',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: controller.refreshUsers,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Stats Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 4;

                  if (constraints.maxWidth < 1100) {
                    crossAxisCount = 2;
                  }

                  if (constraints.maxWidth < 600) {
                    crossAxisCount = 1;
                  }

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.6,
                    children: [
                      _buildCard(
                        title: 'Tổng tài khoản',
                        value:
                        controller.totalUsers.value.toString(),
                        icon: Icons.people_alt_rounded,
                      ),

                      _buildCard(
                        title: 'Admin',
                        value:
                        controller.totalAdmins.value.toString(),
                        icon: Icons.admin_panel_settings_rounded,
                      ),

                      _buildCard(
                        title: 'Đang hoạt động',
                        value: controller
                            .totalActiveUsers.value
                            .toString(),
                        icon: Icons.check_circle_rounded,
                      ),

                      _buildCard(
                        title: 'Đã khóa',
                        value: controller
                            .totalBlockedUsers.value
                            .toString(),
                        icon: Icons.block_rounded,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 30),

              // Recent Users
              Row(
                children: [
                  const Icon(Icons.person_outline_rounded),
                  const SizedBox(width: 10),
                  Text(
                    'Người dùng gần đây',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: controller.users.isEmpty
                    ? const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text('Chưa có dữ liệu'),
                  ),
                )
                    : Column(
                  children: controller.users
                      .take(5)
                      .map(
                        (user) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage:
                        user['avatar_url'] != null
                            ? NetworkImage(
                          user['avatar_url'],
                        )
                            : null,
                        child: user['avatar_url'] == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(
                        user['username'] ??
                            'Chưa có tên',
                      ),
                      subtitle:
                      Text(user['email'] ?? ''),
                      trailing: Container(
                        padding:
                        const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                          BorderRadius.circular(30),
                          color: user['role'] == 'admin'
                              ? Colors.orange
                              .withOpacity(0.15)
                              : Colors.blue
                              .withOpacity(0.15),
                        ),
                        child: Text(
                          user['role'] ?? 'user',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color:
                            user['role'] == 'admin'
                                ? Colors.orange
                                : Colors.blue,
                          ),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 1,
            color: Colors.black.withOpacity(0.05),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            child: Icon(icon, size: 30),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
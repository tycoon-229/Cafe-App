import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/admin_controller.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});

  final controller = Get.find<AdminController>();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xff4f46e5),
      onRefresh: controller.refreshUsers,
      child: Obx(
            () => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              // GRID STAT CARDS (Màu sắc phân định trạng thái)
              LayoutBuilder(
                builder: (_, constraints) {
                  final isSmall = constraints.maxWidth < 650;
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isSmall ? 2 : 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.25,
                    children: [
                      _buildStatCard(
                        title: 'Tổng tài khoản',
                        value: controller.totalUsers.value.toString(),
                        icon: Icons.people_alt_rounded,
                        bgColor: const Color(0xffeef2ff),
                        textColor: const Color(0xff4f46e5),
                        onTap: () => _showUserListBottomSheet("Tất cả tài khoản", controller.users),
                      ),
                      _buildStatCard(
                        title: 'Quản trị viên',
                        value: controller.totalAdmins.value.toString(),
                        icon: Icons.shield_rounded,
                        bgColor: const Color(0xfffaf5ff),
                        textColor: const Color(0xff9333ea),
                        onTap: () {
                          final filtered = controller.users.where((u) => u['role'] == 'admin').toList();
                          _showUserListBottomSheet("Danh sách Admin", filtered);
                        },
                      ),
                      _buildStatCard(
                        title: 'Đang hoạt động',
                        value: controller.totalActiveUsers.value.toString(),
                        icon: Icons.check_circle_rounded,
                        bgColor: const Color(0xfff0fdf4),
                        textColor: const Color(0xff16a34a),
                        onTap: () {
                          final filtered = controller.users.where((u) => u['is_active'] == true).toList();
                          _showUserListBottomSheet("Tài khoản đang hoạt động", filtered);
                        },
                      ),
                      _buildStatCard(
                        title: 'Đã bị khóa',
                        value: controller.totalBlockedUsers.value.toString(),
                        icon: Icons.lock_person_rounded,
                        bgColor: const Color(0xfffef2f2),
                        textColor: const Color(0xffdc2626),
                        onTap: () {
                          final filtered = controller.users.where((u) => u['is_active'] == false).toList();
                          _showUserListBottomSheet("Tài khoản bị khóa", filtered);
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _buildRecentUsers(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xff1e1b4b), Color(0xff312e81)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.insights_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tổng quan hệ thống',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 2),
                Text(
                  'Theo dõi hoạt động của thành viên và các quán cafe',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xffe2e8f0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
                  child: Icon(icon, color: textColor, size: 16),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: textColor,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsers() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xffe2e8f0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Người dùng đăng ký gần đây',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xff0f172a)),
          ),
          const SizedBox(height: 14),
          if (controller.users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('Chưa có dữ liệu người dùng', style: TextStyle(color: Colors.grey.shade400)),
              ),
            )
          else
            ...controller.users.take(5).map((user) => _buildUserListTile(user)),
        ],
      ),
    );
  }

  Widget _buildUserListTile(Map<String, dynamic> user) {
    final bool isAdmin = user['role'] == 'admin';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xfff8fafc),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xfff1f5f9)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isAdmin ? const Color(0xffede9fe) : const Color(0xffe0f2fe),
            backgroundImage: user['avatar_url'] != null ? NetworkImage(user['avatar_url']) : null,
            child: user['avatar_url'] == null
                ? Text(
              (user['username'] ?? 'U').toString().substring(0, 1).toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAdmin ? const Color(0xff7c3aed) : const Color(0xff0284c7),
              ),
            )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['username'] ?? 'Chưa đặt tên',
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user['email'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isAdmin ? const Color(0xfff3e8ff) : const Color(0xfff1f5f9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              isAdmin ? 'Admin' : 'User',
              style: TextStyle(
                color: isAdmin ? const Color(0xff7e22ce) : const Color(0xff475569),
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showUserListBottomSheet(String title, List<dynamic> filteredUsers) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text("${filteredUsers.length} tài khoản", style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: filteredUsers.isEmpty
                  ? Center(child: Text("Không có dữ liệu", style: TextStyle(color: Colors.grey.shade400)))
                  : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (_, index) => _buildUserListTile(filteredUsers[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}